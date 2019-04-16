program :-
    open('soluzione.txt',write, Stream),
    forall(a_star(S), write(Stream,S)),
    close(Stream).

