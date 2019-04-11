iterative_deepening(Soluzione):-
    iniziale(S),
    iterative_deepening_aux(S,Soluzione,[S],1).

iterative_deepening_aux(S,Soluzione,Visitati,Soglia):-
    dfs_aux(S,Soluzione,Visitati,Soglia),!.

iterative_deepening_aux(S,Soluzione,Visitati,Soglia):-
    NuovaSoglia is Soglia+1,
    iterative_deepening_aux(S,Soluzione,Visitati,NuovaSoglia).

dfs_aux(S,[],_,_):-finale(S).
dfs_aux(S,[Azione|AzioniTail],Visitati,Soglia):-
    Soglia>0,
    applicabile(Azione,S),
    trasforma(Azione,S,SNuovo),
    \+member(SNuovo,Visitati),
    NuovaSoglia is Soglia-1,
    dfs_aux(SNuovo,AzioniTail,[SNuovo|Visitati],NuovaSoglia).