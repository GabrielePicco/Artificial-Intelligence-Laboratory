import random
import time

import pylab as pl

from Utility.generate_networks import generate_polytree_network_bif, generate_chain
from bif_parser import parse_network_from_file, parse_network
from probability import mpe_ask, map_ask  # , burglary


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
    variables = bn.variables[:3] + bn.variables[4:]
    fixed_map_var = bn.variables[3]
    var_values = [bn.variable_values(var) for var in variables]
    random_sel_values = [random.choice(val_list) for val_list in var_values]
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
    plot_list(times_list, "MAP growing map vars fixed map var", "# evidence", "time")


def plot_mpe_chain_var_network_size():
    times_list = []
    for i in range(1, 500):
        size = i
        bn = generate_chain(size=size)
        ts = time.time()
        prob, assgn = mpe_ask(dict([(F"S{size}", "True")]), bn)
        te = time.time()
        times_list.append(te - ts)
    plot_list(times_list, "MPE on chain bayesian networks", "size of the chain", "computation time")


def plot_map_chain_var_network_size():
    times_list = []
    for i in range(4, 500):
        size = i
        bn = generate_chain(size=size)
        ts = time.time()
        map_vars = [F"S{r}" for r in range(int(size / 2), size - 1)]
        prob, assgn = map_ask(dict([(F"S{size}", "True")]), bn, not_map_vars=["S0"])
        te = time.time()
        times_list.append(te - ts)
    plot_list(times_list, "MAP on chain bayesian networks", "size of the chain", "computation time")


def plot_map_var_paper_network_size():
    times_list = []
    for i in range(4, 15):
        size = i
        bn = parse_network(generate_polytree_network_bif(size=size))
        map_vars = [F"X{r}" for r in range(1, size + 1)]
        ts = time.time()
        prob, assgn = map_ask(dict([(F"S{size}", "TRUE")]), bn, map_vars=map_vars)
        te = time.time()
        times_list.append(te - ts)
    plot_list(times_list, "MAP on dynamic bayesian networks", "size of the network", "computation time")


def plot_map_insurance_network_var_mapvars():
    times_list = []
    bn = parse_network_from_file("./sample_bayesian_networks/insurance.bif")
    for i in range(1, len(bn.variables)):
        size = i
        bn = parse_network_from_file("./sample_bayesian_networks/insurance.bif")
        map_vars = bn.variables[0:i]
        ts = time.time()
        prob, assgn = map_ask(dict(), bn, map_vars=map_vars)
        te = time.time()
        times_list.append(te - ts)
    plot_list(times_list, "MAP on Insurance network", "# of MAP variables", "computation time")


plot_mpe_time_growing_var("./sample_bayesian_networks/alarm.bif")
plot_map_time_growing_var_fixed_map_var("./sample_bayesian_networks/alarm.bif")
plot_mpe_chain_var_network_size()
plot_map_chain_var_network_size()
plot_map_var_paper_network_size()
plot_map_insurance_network_var_mapvars()
