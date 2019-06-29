import unittest

from bif_parser import parse_network_from_file
from probability import mpe_ask, map_ask


class TestMap(unittest.TestCase):

    def test_map_small_bn(self):
        small_bn = parse_network_from_file("./sample_bayesian_networks/earthquake.bif")
        prob, assgn = map_ask(dict(Burglary="True", JohnCalls="True"), small_bn, not_map_vars=['Alarm'])
        self.assertEqual(prob, 0.005803854)
        self.assertEqual(assgn, [('Earthquake', 'False'), ('MaryCalls', 'True')])

    def test_map_small_bn_2(self):
        small_bn = parse_network_from_file("./sample_bayesian_networks/earthquake.bif")
        prob, assgn = map_ask(dict(JohnCalls="True", Alarm="True"), small_bn, not_map_vars=['Alarm'])
        self.assertEqual(prob, 0.00580356)
        self.assertEqual(assgn, [('Burglary', 'True'), ('Earthquake', 'False'), ('MaryCalls', 'True')])

    def test_mpe_small_bn(self):
        small_bn = parse_network_from_file("./sample_bayesian_networks/earthquake.bif")
        prob, assgn = mpe_ask(dict(JohnCalls="True", MaryCalls="True"), small_bn)
        self.assertEqual(prob, 0.00580356)
        self.assertEqual(assgn, [('Burglary', 'True'), ('Earthquake', 'False'), ('Alarm', 'True')])

    def test_mpe_small_bn_2(self):
        small_bn = parse_network_from_file("./sample_bayesian_networks/earthquake.bif")
        prob, assgn = mpe_ask(dict(JohnCalls="False", Alarm="True"), small_bn)
        self.assertEqual(prob, 0.0006448399999999999)
        self.assertEqual(assgn, [('Burglary', 'True'), ('Earthquake', 'False'), ('MaryCalls', 'True')])

    def test_map_medium_bn(self):
        medium_bn = parse_network_from_file("./sample_bayesian_networks/insurance.bif")
        prob, assgn = map_ask(dict(PropCost="Thousand", RiskAversion="Adventurous"), medium_bn, map_vars=['Theft'])
        self.assertEqual(prob, 0.13093217869278678)
        self.assertEqual(assgn, [('Theft', 'False')])

    def test_map_medium_bn_2(self):
        medium_bn = parse_network_from_file("./sample_bayesian_networks/insurance.bif")
        prob, assgn = map_ask(dict(AntiTheft="True", RiskAversion="Cautious"), medium_bn, map_vars=['Accident'])
        self.assertEqual(prob, 0.19245212164413633)
        self.assertEqual(assgn, [('Accident', 'None')])

    def test_mpe_medium_bn(self):
        medium_bn = parse_network_from_file("./sample_bayesian_networks/insurance.bif")
        prob, assgn = mpe_ask(dict(PropCost="Thousand", RiskAversion="Adventurous"), medium_bn)
        self.assertEqual(prob, 0.0003075815950266564)
        self.assertEqual(assgn,
                         [('Age', 'Adult'), ('Mileage', 'FiftyThou'), ('SocioEcon', 'Prole'), ('OtherCar', 'True'),
                          ('GoodStudent', 'False'), ('MakeModel', 'Economy'), ('SeniorTrain', 'False'),
                          ('HomeBase', 'City'), ('VehicleYear', 'Older'), ('RuggedAuto', 'EggShell'),
                          ('Antilock', 'False'), ('CarValue', 'FiveThou'), ('Airbag', 'False'),
                          ('DrivingSkill', 'Normal'), ('AntiTheft', 'False'), ('Cushioning', 'Poor'),
                          ('DrivHist', 'Zero'), ('DrivQuality', 'Normal'), ('Theft', 'False'), ('Accident', 'None'),
                          ('OtherCarCost', 'Thousand'), ('ILiCost', 'Thousand'), ('ThisCarDam', 'None'),
                          ('MedCost', 'Thousand'), ('ThisCarCost', 'Thousand')])

    def test_mpe_medium_bn_2(self):
        medium_bn = parse_network_from_file("./sample_bayesian_networks/insurance.bif")
        prob, assgn = mpe_ask(dict(AntiTheft="True", RiskAversion="Cautious"), medium_bn)
        self.assertEqual(prob, 0.0007795974803453906)
        self.assertEqual(assgn,
                         [('Age', 'Adult'), ('Mileage', 'FiftyThou'), ('SocioEcon', 'Prole'), ('OtherCar', 'True'),
                          ('GoodStudent', 'False'), ('MakeModel', 'Economy'), ('SeniorTrain', 'False'),
                          ('HomeBase', 'City'), ('VehicleYear', 'Older'), ('RuggedAuto', 'EggShell'),
                          ('Antilock', 'False'), ('CarValue', 'FiveThou'), ('Airbag', 'False'),
                          ('DrivingSkill', 'Normal'), ('Cushioning', 'Poor'), ('DrivHist', 'Zero'),
                          ('DrivQuality', 'Normal'), ('Theft', 'False'), ('Accident', 'None'),
                          ('OtherCarCost', 'Thousand'), ('ILiCost', 'Thousand'), ('ThisCarDam', 'None'),
                          ('MedCost', 'Thousand'), ('ThisCarCost', 'Thousand'), ('PropCost', 'Thousand')])
