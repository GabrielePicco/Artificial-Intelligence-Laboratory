program :-
    open('soluzione.txt',write, Stream),
    forall(ida_star(S), write(Stream,S)),
    close(Stream).

