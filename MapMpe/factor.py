from logic import extend


class Factor:
    """
    A factor in a joint distribution.
    """

    def __init__(self, variables, cpt, max_assignment={}, last_max_out=None):
        self.variables = variables
        self.cpt = cpt
        self.max_assignment = max_assignment
        self.last_max_out = last_max_out

    def pointwise_product(self, other, bn):
        """
        Multiply two factors, combining their variables.
        :param other:
        :param bn:
        :return:
        """
        variables = list(set(self.variables) | set(other.variables))
        cpt = {}
        for e in all_events(variables, bn, {}):
            cpt[event_values(e, variables)] = self.p(e) * other.p(e)
        new_factor = Factor(variables, cpt)
        return new_factor

    def sum_out(self, var, bn):
        """
        Make a factor eliminating var by summing over its values.
        :param var:
        :param bn:
        :return:
        """
        variables = [X for X in self.variables if X != var]
        cpt = {event_values(e, variables): sum(self.p(extend(e, var, val))
                                               for val in bn.variable_values(var))
               for e in all_events(variables, bn, {})}
        return Factor(variables, cpt)

    def max_out(self, var, bn):
        """
        Make a factor eliminating var by summing over its values.
        :param var:
        :param bn:
        :return:
        """
        variables = [X for X in self.variables if X != var]
        cpt_with_assignement = {event_values(e, variables): max((self.p(extend(e, var, val)), val)
                                                                for val in bn.variable_values(var))
                                for e in all_events(variables, bn, {})}
        assignement = {}
        cpt = {}
        for key, (value, assgn) in cpt_with_assignement.items():
            cpt[key] = value
            assignement[key] = assgn
        factor = Factor(variables, cpt, assignement, self)
        factor.last_max_out = bn.last_max_out
        bn.last_max_out = factor
        return factor

    def p(self, e):
        """
        Look up my value tabulated for e.
        :param e:
        :return:
        """
        return self.cpt[event_values(e, self.variables)]

    def mpe_assignement(self, variables):
        assignment = [self.max_assignment['()']]
        next_max_out = self.last_max_out
        while next_max_out is not None:
            var_in_key = [assignment[variables.index(var)] for var in next_max_out.variables if var in variables]
            assignment_key = "(" + ", ".join(var_in_key) + ")"
            assignment.append(next_max_out.max_assignment[assignment_key])
            next_max_out = next_max_out.last_max_out
        assert len(assignment) == len(variables), "Variable e value assigned should have the same size"
        return list(zip(variables, assignment))


def all_events(variables, bn, e):
    """
    Yield every way of extending e with values for all variables.
    :param variables:
    :param bn:
    :param e:
    :return:
    """
    if not variables:
        yield e
    else:
        X, rest = variables[0], variables[1:]
        for e1 in all_events(rest, bn, e):
            for x in bn.variable_values(X):
                yield extend(e1, X, x)


def event_values(event, variables):
    return "(" + ", ".join([event[var] for var in variables]) + ")"
