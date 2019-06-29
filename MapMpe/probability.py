"""
Modified AIMA-core classes and extended wiht MPE and MAP
"""

from functools import reduce
from Utility.decorator import timeit

from factor import Factor, all_events, event_values


def elimination_ask(X, e, bn):
    """
    Compute bn's P(X|e) by variable elimination.
    :param X: Var
    :param e: evidence
    :param bn: bayesian network
    :return: P(X|e)
    """
    assert X not in e, "Query variable must be distinct from evidence"
    factors = []
    for var in reversed(bn.variables):
        factors.append(make_factor(var, e, bn))
        if is_hidden(var, X, e):
            factors = sum_out(var, factors, bn)
    return pointwise_product(factors, bn).normalize()


@timeit
def mpe_ask(e, bn):
    """
    Compute mpe
    :param e: evidence
    :param bn: the network
    :return: p, max assignment
    """
    factors = []
    for var in reversed(bn.variables):
        factors.append(make_factor(var, e, bn))
        if not is_evidence(var, e):
            factors = max_out(var, factors, bn)
    not_evidence_variables = [x for x in bn.variables if x not in list(e.keys())]
    p = pointwise_product(factors, bn).cpt['()']
    return p, bn.last_max_out.mpe_assignement(not_evidence_variables)


@timeit
def map_ask(e, bn, map_vars=[], not_map_vars=[]):
    """
    Compute map
    :param e: evidence
    :param bn: network
    :param map_vars: map variable (map_vars or not_map_vars must be empty)
    :param not_map_vars: not map variable
    :return:
    """
    assert (len(map_vars) == 0 or len(not_map_vars) == 0) and (
            len(map_vars) > 0 or len(not_map_vars) > 0), "only map or not map should be specified"
    if len(not_map_vars) == 0:
        not_map_vars = [var for var in bn.variables if var not in map_vars and var not in e]
    factors = []
    for var in reversed(bn.variables):
        factors.append(make_factor(var, e, bn))
        if var in not_map_vars and not is_evidence(var, e):
            factors = sum_out(var, factors, bn)
    for var in reversed(bn.variables):
        if not is_evidence(var, e) and var not in not_map_vars:
            factors = max_out(var, factors, bn)
    results_variables = [x for x in bn.variables if x not in list(e.keys()) and x not in not_map_vars]
    p = pointwise_product(factors, bn).cpt['()']
    return p, bn.last_max_out.mpe_assignement(results_variables)


def is_hidden(var, X, e):
    """
    Is var a hidden variable when querying P(X|e)
    :param var:
    :param X:
    :param e:
    :return: boolean
    """
    return var != X and var not in e


def is_evidence(var, e):
    """
    Is var is in the evidence
    :param var:
    :param e:
    :return:
    """
    return var in e


def make_factor(var, e, bn):
    """
    Return the factor for var in bn's joint distribution given e.
    That is, bn's full joint distribution, projected to accord with e,
    is the pointwise product of these factors for bn's variables.
    :param var:
    :param e:
    :param bn:
    :return:
    """
    node = bn.variable_node(var)
    variables = [X for X in [var] + node.parents if X not in e]
    cpt = {}
    for e1 in all_events(variables, bn, e):
        cpt[event_values(e1, variables)] = node.p(e1[var], e1)
    return Factor(variables, cpt)


def pointwise_product(factors, bn):
    """
    Make the pointwise product between factors
    :param factors:
    :param bn:
    :return:
    """
    return reduce(lambda f, g: f.pointwise_product(g, bn), factors)


def sum_out(var, factors, bn):
    """
    Eliminate var from all factors by summing over its values.
    :param var:
    :param factors:
    :param bn:
    :return:
    """
    result, var_factors = [], []
    for f in factors:
        (var_factors if var in f.variables else result).append(f)
    result.append(pointwise_product(var_factors, bn).sum_out(var, bn))
    return result


def max_out(var, factors, bn):
    """
    Eliminate var from all factors by summing over its values.
    :param var:
    :param factors:
    :param bn:
    :return:
    """
    result, var_factors = [], []
    for f in factors:
        (var_factors if var in f.variables else result).append(f)
    result.append(pointwise_product(var_factors, bn).max_out(var, bn))
    return result
