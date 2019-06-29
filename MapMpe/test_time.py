from bif_parser import parse_network_from_file
from probability import mpe_ask, map_ask  # , burglary
import pylab as pl
import time
from itertools import islice
import random


def test_time_mpe_small_earthquake():
    bn = parse_network_from_file("./sample_bayesian_networks/earthquake.bif")
    mpe_ask(dict(JohnCalls="True", MaryCalls="True"), bn)


def test_time_map_small_earthquake():
    bn = parse_network_from_file("./sample_bayesian_networks/earthquake.bif")
    map_ask(dict(Burglary="True", JohnCalls="True"), bn, not_map_vars=['Alarm'])


def test_time_mpe_medium_insurance():
    bn = parse_network_from_file("./sample_bayesian_networks/insurance.bif")
    mpe_ask(dict(PropCost="Thousand", RiskAversion="Adventurous"), bn)


def test_time_map_medium_insurance():
    bn = parse_network_from_file("./sample_bayesian_networks/insurance.bif")
    map_ask(dict(PropCost="Thousand", RiskAversion="Psychopath"), bn, map_vars=['Theft'])


def test_time_mpe_medium_alarm():
    bn = parse_network_from_file("./sample_bayesian_networks/alarm.bif")
    mpe_ask(dict(STROKEVOLUME="NORMAL", HISTORY="TRUE"), bn)


def test_time_map_medium_alarm():
    bn = parse_network_from_file("./sample_bayesian_networks/alarm.bif")
    map_ask(dict(STROKEVOLUME="NORMAL", HISTORY="TRUE"), bn, map_vars=['HISTORY', 'CVP', 'PCWP', 'HYPOVOLEMIA'])


def plot_list(list, title, xlab, ylab):
    pl.figure()
    pl.title(title)
    pl.plot(list)
    pl.xlabel(xlab)
    pl.ylabel(ylab)
    pl.show()


def plot_mpe_time_growing_var(bn_path):
    bn = parse_network_from_file(bn_path)
    variables = bn.variables
    var_values = [bn.variable_values(var) for var in variables]
    random_sel_values = [random.choice(val_list) for val_list in var_values]
    dic = dict(zip(variables, random_sel_values))
    times_list = []
    for i, item in enumerate(dic):
        # bn = parse_network_from_file("./sample_bayesian_networks/alarm.bif")
        bn.last_max_out = None
        first_n_pairs = {k: dic[k] for k in list(dic)[:i]}
        ts = time.time()
        mpe_ask(first_n_pairs, bn)
        te = time.time()
        times_list.append(te - ts)
    plot_list(times_list, "MPE growing evidences", "# evidences", "time")


def plot_map_time_growing_var_fixed_evidence(bn_path):
    bn = parse_network_from_file(bn_path)
    variables = bn.variables
    var_values = [bn.variable_values(var) for var in variables]
    random_sel_values = [random.choice(val_list) for val_list in var_values]
    dic = dict(zip(variables, random_sel_values))
    times_list = []
    first_n_pairs = {k: dic[k] for k in list(dic)[:2]}
    print(first_n_pairs)
    del variables[:2]
    print(variables)
    for i, var in enumerate(variables):
        bn.last_max_out = None
        map_vars = variables[:i]
        if map_vars:
            ts = time.time()
            map_ask(first_n_pairs, bn, map_vars=map_vars)
            te = time.time()
            times_list.append(te - ts)
    plot_list(times_list, "MAP growing map vars fixed evidence", "# map vars", "time")


def plot_map_time_growing_var_fixed_map_var(bn_path):
    bn = parse_network_from_file(bn_path)
    variables = bn.variables
    fixed_map_var = variables[0]
    var_values = [bn.variable_values(var) for var in variables]
    random_sel_values = [random.choice(val_list) for val_list in var_values]
    del variables[:0]
    del random_sel_values[:0]
    dic = dict(zip(variables, random_sel_values))
    times_list = []
    for i, item in enumerate(dic):
        bn.last_max_out = None
        first_n_pairs = {k: dic[k] for k in list(dic)[:i]}
        if first_n_pairs:
            ts = time.time()
            map_ask(first_n_pairs, bn, map_vars=fixed_map_var)
            te = time.time()
            times_list.append(te - ts)
    plot_list(times_list, "MAP growing map vars fixed map var", "# map vars", "time")


if __name__ == "__main__":
    # test_time_mpe_small_earthquake()
    # test_time_map_small_earthquake()
    # test_time_mpe_medium_alarm()
    # test_time_map_medium_alarm()
    # test_time_mpe_medium_insurance()
    # test_time_map_medium_insurance()
    # plot_mpe_time_growing_var("./sample_bayesian_networks/alarm.bif")
    plot_map_time_growing_var_fixed_map_var("./sample_bayesian_networks/alarm.bif")
