from HybridBayesNet import burglary
from bif_parser import parse_network
from probability import mpe_ask, map_ask  # , burglary


def test_mpe():
    prob, assgn = mpe_ask(dict(JohnCalls="True", MaryCalls="True"), burglary)
    print(F"P(mpe,e): {prob}, MPE: {assgn}")


def test_map():
    bn = parse_network("./sample_bayesian_networks/earthquake.bif")
    prob, assgn = map_ask(dict(Burglary="True", JohnCalls="True"), bn, not_map_vars=['Alarm'])
    print(F"P(map,e): {prob}, MAP: {assgn}")


test_mpe()
test_map()
