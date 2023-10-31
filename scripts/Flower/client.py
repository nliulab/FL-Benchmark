import warnings
import flwr as fl
import numpy as np
import sys

from sklearn.linear_model import LogisticRegression
from sklearn.metrics import log_loss

import utils

if __name__ == "__main__":
    # get input from csv:
    directory = sys.argv[1]
    file_name = sys.argv[2]
    X_train, y_train = utils.get_dat_csv(file_name, directory)
    X_test, y_test = X_train, y_train

    print(X_train)

    # Create LogisticRegression Model
    model = LogisticRegression(
        penalty="l2",
        max_iter=10,  # local epoch
        warm_start=True,  # prevent refreshing weights when fitting
    )

    # Setting initial parameters, akin to model.compile for keras models
    utils.set_initial_params(model)

    # Define Flower client
    class LRClient(fl.client.NumPyClient):
        def get_parameters(self, config):  # type: ignore
            return utils.get_model_parameters(model)

        def fit(self, parameters, config):  # type: ignore
            print(">>>>>>>>>>>>> printing intermediate parameters")
            print(parameters)
            utils.set_model_params(model, parameters)
            # Ignore convergence failure due to low local epochs
            with warnings.catch_warnings():
                warnings.simplefilter("ignore")
                model.fit(X_train, y_train)
            print(f"Training finished for round {config['server_round']}")
            return utils.get_model_parameters(model), len(X_train), {}

        def evaluate(self, parameters, config):  # type: ignore
            print(">>>>>>>>>>>>> evaluating on client-side")
            print(">>>>>>>>>>>>> printing final parameters")
            print(parameters)
            utils.set_model_params(model, parameters)
            loss = log_loss(y_test, model.predict_proba(X_test))
            accuracy = model.score(X_test, y_test)
            return loss, len(X_test), {"accuracy": accuracy}

    # Start Flower client
    fl.client.start_numpy_client(server_address="localhost:8080", client=LRClient())
