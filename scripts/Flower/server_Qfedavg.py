import flwr as fl
import utils
import sys
from sklearn.metrics import log_loss
from sklearn.linear_model import LogisticRegression
from typing import Dict

from time import process_time
t_start = process_time()

def fit_round(server_round: int) -> Dict:
    """Send round number to client."""
    return {"server_round": server_round}


def get_evaluate_fn(model: LogisticRegression):
    """Return an evaluation function for server-side evaluation."""
    # get input from csv:
    directory = sys.argv[1]
    file_name = "Site1.test.N_300.csv"

    X_train, y_train = utils.get_dat_csv(file_name, directory)
    X_test, y_test = X_train, y_train

    # The `evaluate` function will be called after every round
    def evaluate(server_round, parameters: fl.common.NDArrays, config):
        # Update model with the latest parameters
        utils.set_model_params(model, parameters)
        loss = log_loss(y_test, model.predict_proba(X_test))
        accuracy = model.score(X_test, y_test)
        print(utils.get_model_parameters(model))
        return loss, {"accuracy": accuracy}

    return evaluate


# Start Flower server for five rounds of federated learning
if __name__ == "__main__":
    model = LogisticRegression()
    utils.set_initial_params(model)
    strategy = fl.server.strategy.QFedAvg(
        min_available_clients=3,
        evaluate_fn=get_evaluate_fn(model),
        on_fit_config_fn=fit_round,
    )
    fl.server.start_server(
        server_address="0.0.0.0:8080",
        strategy=strategy,
        config=fl.server.ServerConfig(num_rounds=30),
    )

t_stop = process_time()
print(">>>>>>>>>>>>>run time:")
print(str(t_stop - t_start) + 's')
