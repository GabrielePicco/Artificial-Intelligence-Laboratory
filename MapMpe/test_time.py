from bif_parser import parse_network
from probability import mpe_ask, map_ask  # , burglary


def test_time_mpe_small_earthquake():
    bn = parse_network("./sample_bayesian_networks/earthquake.bif")
    mpe_ask(dict(JohnCalls="True", MaryCalls="True"), bn)


def test_time_map_small_earthquake():
    bn = parse_network("./sample_bayesian_networks/earthquake.bif")
    map_ask(dict(Burglary="True", JohnCalls="True"), bn, not_map_vars=['Alarm'])


def test_time_mpe_medium_insurance():
    bn = parse_network("./sample_bayesian_networks/insurance.bif")
    mpe_ask(dict(PropCost="Thousand", RiskAversion="Adventurous"), bn)


def test_time_map_medium_insurance():
    bn = parse_network("./sample_bayesian_networks/insurance.bif")
    map_ask(dict(PropCost="Thousand", RiskAversion="Psychopath"), bn, map_vars=['Theft'])


def test_time_mpe_medium_alarm():
    bn = parse_network("./sample_bayesian_networks/alarm.bif")
    mpe_ask(dict(STROKEVOLUME="NORMAL", HISTORY="TRUE"), bn)


def test_time_map_medium_alarm():
    bn = parse_network("./sample_bayesian_networks/alarm.bif")
    map_ask(dict(), bn, map_vars=['HISTORY', 'CVP', 'PCWP', 'HYPOVOLEMIA'])


if __name__ == "__main__":
    test_time_mpe_small_earthquake()
    test_time_map_small_earthquake()
    test_time_mpe_medium_alarm()
    test_time_map_medium_alarm()
    test_time_mpe_medium_insurance()
    test_time_map_medium_insurance()
