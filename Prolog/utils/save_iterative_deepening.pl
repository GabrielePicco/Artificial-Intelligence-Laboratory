program :-
    open('soluzione.txt',write, Stream),
    forall(iterative_deepening(S), write(Stream,S)),
    close(Stream).

