from HybridBayesNet import HybridBayesNode, HybridBayesNet


def generate_polytree_network_bif(size):
    """
    Generate a network of the format described here: https://arxiv.org/pdf/1107.0024.pdf (Figure 4)
    :param size:
    :return:
    """
    bif_network = ""
    with open("./Utility/polytree_header.txt") as f:
        header = f.read()
    with open("./Utility/polytree_template.txt") as f:
        template = f.read()
    bif_network += header
    for i in range(1, size + 1):
        bif_network += template.format(i, i-1)
    return bif_network


def generate_chain(size):
    """
    Generate a chain network of the specified size
    :param size:
    :return: the BN
    """
    net = HybridBayesNet()
    net.add(HybridBayesNode("S0", "", ["True", "False"], {"()": [0.01, 0.99]}))
    for i in range(1, size+1):
        node = HybridBayesNode(F"S{i}", F"S{i-1}", ["True", "False"], {"(True)": [0.9, 0.1], "(False)": [0.05, 0.95]})
        net.add(node)
    return net


