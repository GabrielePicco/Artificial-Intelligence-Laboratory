from _operator import mul
from functools import reduce

from HybridBayesNet import HybridBayesNet, HybridBayesNode
import re


def parse_network_from_file(bif_file):
    """
    Parse and generate a networks encoded in a bif file
    :param bif_file: path to a bif file
    :return: a bayesian networks
    """
    with open(bif_file) as f:
        bif = f.read()
    return parse_network(bif)


def parse_network(bif):
    """
    Parse and generate a networks from bif file
    :param bif: bif text
    :return:
    """
    variables = r"variable (.+?) {\n(.+?);"
    net = HybridBayesNet()
    nodes = []
    for match in re.finditer(variables, bif):
        v_name = match.group(1)
        v_domain = __get_variable_domain_by_parsable_text(match.group(2))
        v_parent = __get_parent(v_name, bif)
        v_cpt = __get_cpt(v_name, v_parent, bif)
        node = HybridBayesNode(v_name, v_parent, v_domain, v_cpt)
        nodes.append(node)
    while nodes:
        for index, n in enumerate(nodes):
            if all((parent in net.variables) for parent in n.parents):
                net.add(n)
                nodes.pop(index)
    return net


def __get_variable_domain_by_parsable_text(bif_domain):
    return list(map(str.strip, bif_domain[bif_domain.index("{") + 1:bif_domain.index("}")].split(",")))


def __get_variable_domain_by_name(variable, bif):
    match = F"variable {variable} {{\n(.+?);"
    s = re.search(match, bif)
    v_domain = []
    if s:
        v_domain = __get_variable_domain_by_parsable_text(s.group(1))
    return v_domain


def __extract_float_list(str_i):
    return list(map(float, str_i.replace("table", "").replace(";", "").replace(",", "").strip().split()))


def __get_parent(v_name, bif):
    variable = F"probability \( {v_name} (.*?)\)"
    s = re.search(variable, bif)
    parent = ""
    if s:
        parent = s.group(1).replace("|", "").strip().replace(",", "")
    return parent


def __get_cpt(v_name, v_parents, bif):
    n_cpt_entry = reduce(mul, [len(__get_variable_domain_by_name(p, bif)) for p in v_parents.split()], 1)
    variable = F"probability \( {v_name} (.*?)\)" + F" {{\n" + F"(.*?)\n" * n_cpt_entry + F"}}"
    s = re.search(variable, bif)
    cpt = {}
    if s:
        if n_cpt_entry == 1:
            cpt['()'] = __extract_float_list(s.group(2))
        else:
            for e in range(2, n_cpt_entry + 2):
                entry = s.group(e)
                key = entry[entry.index("("):entry.index(")") + 1]
                cpt[key] = __extract_float_list(entry.replace(key, ""))
    return cpt
