from Utility.decorator import timeit
from bif_parser import parse_network
from probability import mpe_ask, map_ask  # , burglary


def test_mpe():
    bn = parse_network("./sample_bayesian_networks/earthquake.bif")
    prob, assgn = mpe_ask(dict(JohnCalls="True", MaryCalls="True"), bn)
    print(F"P(mpe,e): {prob}, MPE: {assgn}")


def test_map():
    bn = parse_network("./sample_bayesian_networks/earthquake.bif")
    prob, assgn = map_ask(dict(Burglary="True", JohnCalls="True"), bn, not_map_vars=['Alarm'])
    print(F"P(map,e): {prob}, MAP: {assgn}")


# test_mpe()
# test_map()

def test_mpe_medium():
    bn = parse_network("./sample_bayesian_networks/insurance.bif")
    prob, assgn = mpe_ask(dict(PropCost="Thousand", RiskAversion="Adventurous"), bn)
    print(F"P(mpe,e): {prob}, MPE: {assgn}")


def test_map_medium():
    bn = parse_network("./sample_bayesian_networks/insurance.bif")
    prob, assgn = map_ask(dict(PropCost="Thousand", RiskAversion="Adventurous"), bn, map_vars=['Theft'])
    print(F"P(map,e): {prob}, MAP: {assgn}")


def test_map_medium_alarm():
    bn = parse_network("./sample_bayesian_networks/insurance.bif")
    prob, assgn = map_ask(dict(PropCost="Thousand", RiskAversion="Adventurous"), bn, map_vars=['Theft'])
    print(F"P(map,e): {prob}, MAP: {assgn}")


#test_mpe_medium()
#test_map_medium()

@timeit
def test_map_medium_alarm():
    bn = parse_network("./sample_bayesian_networks/alarm.bif")
    prob, assgn = map_ask(dict(), bn, map_vars=['HISTORY', 'CVP', 'PCWP', 'HYPOVOLEMIA'])
    print(F"P(map,e): {prob}, MAP: {assgn}")


test_map_medium_alarm()