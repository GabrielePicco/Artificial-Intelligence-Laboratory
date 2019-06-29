def generate_polytree_network_bif(size):
    """
    Generate a network of the format described here: https://arxiv.org/pdf/1107.0024.pdf (Figure 4)
    :param size:
    :return:
    """
    bif_network = ""
    with open("./Utility/map_vs_mpe_header.txt") as f:
        header = f.read()
    with open("./Utility/map_vs_mpe_template.txt") as f:
        template = f.read()
    bif_network += header
    for i in range(1, size + 1):
        bif_network += template.format(i, i-1)
    return bif_network


