from Utility.decorator import timeit
from Utility.generate_networks import generate_polytree_network_bif
from bif_parser import parse_network_from_file, parse_network
from probability import mpe_ask, map_ask  # , burglary


def test_mpe():
    bn = parse_network_from_file("./sample_bayesian_networks/earthquake.bif")
    prob, assgn = mpe_ask(dict(JohnCalls="True", MaryCalls="True"), bn)
    print(F"P(mpe,e): {prob}, MPE: {assgn}")


def test_map():
    bn = parse_network_from_file("./sample_bayesian_networks/earthquake.bif")
    prob, assgn = map_ask(dict(Burglary="True", JohnCalls="True"), bn, not_map_vars=['Alarm'])
    print(F"P(map,e): {prob}, MAP: {assgn}")


# test_mpe()
# test_map()

def test_mpe_medium():
    bn = parse_network_from_file("./sample_bayesian_networks/insurance.bif")
    prob, assgn = mpe_ask(dict(PropCost="Thousand", RiskAversion="Adventurous"), bn)
    print(F"P(mpe,e): {prob}, MPE: {assgn}")


def test_map_medium():
    bn = parse_network_from_file("./sample_bayesian_networks/insurance.bif")
    prob, assgn = map_ask(dict(PropCost="Thousand", RiskAversion="Adventurous"), bn, map_vars=['Theft'])
    print(F"P(map,e): {prob}, MAP: {assgn}")


def test_map_medium_alarm():
    bn = parse_network_from_file("./sample_bayesian_networks/insurance.bif")
    prob, assgn = map_ask(dict(PropCost="Thousand", RiskAversion="Adventurous"), bn, map_vars=['Theft'])
    print(F"P(map,e): {prob}, MAP: {assgn}")


#test_mpe_medium()
#test_map_medium()

def test_map_vs_mpe():
    size = 17
    bn = parse_network(generate_polytree_network_bif(size=size))
    map_vars = [F"X{r}" for r in range(1, size+1)]
    prob, assgn = map_ask(dict([(F"S{size}", "TRUE")]), bn, map_vars=map_vars)
    print(F"P(map,e): {prob}, MAP: {assgn}")


def test_map_vs_mpe_2():
    #bn = parse_network_from_file("./sample_bayesian_networks/polytree.bif")
    size = 17
    bn = parse_network(generate_polytree_network_bif(size=size))
    prob, assgn = mpe_ask(dict([(F"S{size}", "TRUE")]), bn)
    print(F"P(map,e): {prob}, MAP: {assgn}")


def test_map_vs_mpe_3():
    size = 17
    bn = parse_network(generate_polytree_network_bif(size=size))
    map_vars = [F"X{r}" for r in range(1, int(size / 2))]
    map_vars += [F"S{r}" for r in range(0, int(size / 2))]
    prob, assgn = map_ask(dict([(F"S{size}", "TRUE")]), bn, map_vars=map_vars)
    print(F"P(map,e): {prob}, MAP: {assgn}")


#test_map_vs_mpe_2()

test_map_vs_mpe_3()