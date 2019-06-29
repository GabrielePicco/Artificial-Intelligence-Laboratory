class HybridBayesNet:
    """
    Bayesian network containing discrete nodes.
    """

    def __init__(self, node_specs=None):
        """
        Nodes must be ordered with parents before children.
        :param node_specs: list of tuple or nodes
        """
        self.nodes = []
        self.variables = []
        self.last_max_out = None
        node_specs = node_specs or []
        for node_spec in node_specs:
            self.add(node_spec)

    def add(self, node):
        """
        Add a node to the net. Its parents must already be in the
        net, and its variable must not.
        :param node:
        :return:
        """
        if isinstance(node, tuple):
            node = HybridBayesNode(*node)
        assert node.variable not in self.variables
        assert all((parent in self.variables) for parent in node.parents)
        self.nodes.append(node)
        self.variables.append(node.variable)
        for parent in node.parents:
            self.variable_node(parent).children.append(node)

    def variable_node(self, var):
        """
        Return the node for the variable named var.
        :param var:
        :return: the var
        """
        for n in self.nodes:
            if n.variable == var:
                return n
        raise Exception("No such variable: {}".format(var))

    def variable_values(self, var):
        """
        Return the domain of var
        :param var:
        :return: domain values list
        """
        return self.variable_node(var).domain

    def __repr__(self):
        return 'BayesNet({0!r})'.format(self.nodes)


def get_cpt_key_entry(event, parents):
    """
    Return the cpt key given an event
    :param event:
    :param parents:
    :return:
    """
    return "(" + ", ".join([event[node] for node in parents if node in event.keys()]) + ")"


class HybridBayesNode:
    """
    A conditional probability distribution for a boolean variable,
    P(X | parents). Part of a BayesNet.
    """

    def __init__(self, X, parents, domain, cpt):
        """
        :param X: Var
        :param parents:
        :param domain:
        :param cpt:
        """
        if isinstance(parents, str):
            parents = parents.split()
        assert isinstance(cpt, dict)

        self.variable = X
        self.parents = parents
        self.domain = domain
        self.cpt = cpt
        self.children = []

    def p(self, value, event):
        """
        Return the conditional probability
        P(X=value | parents=parent_values), where parent_values
        are the values of parents in event. (event must assign each
        parent a value.)
        :param value:
        :param event:
        :return:
        """
        key = get_cpt_key_entry(event, self.parents)
        return self.cpt[key][self.domain.index(value)]

    def __repr__(self):
        return repr((self.variable, ' '.join(self.parents)))


burglary = HybridBayesNet([
    ('Burglary', '', ["True", "False"], {"()": [0.01, 0.99]}),
    ('Earthquake', '', ["True", "False"], {"()": [0.02, 0.98]}),
    ('Alarm', 'Burglary Earthquake', ["True", "False"], {"(True, True)": [0.95, 0.05], "(True, False)": [0.94, 0.06], "(False, True)": [0.29, 0.71], "(False, False)": [0.001, 0.999]}),
    ('JohnCalls', 'Alarm', ["True", "False"], {"(True)": [0.9, 0.1], "(False)": [0.05, 0.95]}),
    ('MaryCalls', 'Alarm', ["True", "False"], {"(True)": [0.7, 0.3], "(False)": [0.01, 0.99]})
])
