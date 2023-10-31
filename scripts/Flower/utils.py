from typing import Tuple, Union, List
import numpy as np
from sklearn.linear_model import LogisticRegression
import os, sys
import pandas as pd

XY = Tuple[np.ndarray, np.ndarray]
Dataset = Tuple[XY, XY]
LogRegParams = Union[XY, Tuple[np.ndarray]]
XYList = List[XY]

def get_dat_csv(file_name, directory):
    
    f = os.path.join(directory, file_name)
    dat = pd.read_csv(f)
    y = dat.iloc[:, 0]
    X = dat.iloc[: , 1:]
    return X,y

def get_number_clients(directory):
    s = os.path.basename(os.path.normpath(directory)).split(".")
    k = int(s[-1].split("_")[1]) # number of clients
    return k


def get_model_parameters(model: LogisticRegression) -> LogRegParams:
    """Returns the paramters of a sklearn LogisticRegression model."""
    if model.fit_intercept:
        params = [
            model.coef_,
            model.intercept_,
        ]
    else:
        params = [
            model.coef_,
        ]
    return params


def set_model_params(
    model: LogisticRegression, params: LogRegParams
) -> LogisticRegression:
    """Sets the parameters of a sklean LogisticRegression model."""
    model.coef_ = params[0]
    if model.fit_intercept:
        model.intercept_ = params[1]
    return model


def set_initial_params(model: LogisticRegression):
    """Sets initial parameters as zeros Required since model params are
    uninitialized until model.fit is called.
    But server asks for initial parameters from clients at launch. Refer
    to sklearn.linear_model.LogisticRegression documentation for more
    information.
    """
    print(">>>>>>>>>>>>> setting initial parameters")
    n_classes = 2
    n_features = 8
    model.classes_ = np.array([i for i in range(2)])

    model.coef_ = np.zeros((n_classes, n_features))
    print(model.coef_)
    if model.fit_intercept:
        model.intercept_ = np.zeros((n_classes,))
