ida_star(Soluzione):-
    iniziale(S),
    euristica(S,H),
    ida_star_aux(S,Soluzione,[S],H).

ida_star_aux(S,Soluzione,Visitati,FSoglia):-
    dfs_aux(S,Soluzione,Visitati,0,FSoglia),!.

ida_star_aux(S,Soluzione,Visitati,FSoglia):-
    min_nuova_FSoglia(FSoglia,NuovaFSoglia),
    ida_star_aux(S,Soluzione,Visitati,NuovaFSoglia).

dfs_aux(S,[],_,_,_):-finale(S).
dfs_aux(S,[Azione|AzioniTail],Visitati,G,FSoglia):-
    G<FSoglia,
    applicabile(Azione,S),
    trasforma(Azione,S,SNuovo),
    \+member(SNuovo,Visitati),
    GNuovo is G+1,
    dfs_aux(SNuovo,AzioniTail,[SNuovo|Visitati],GNuovo,FSoglia).

dfs_aux(S,_,_,G,_):-
    euristica(S,H),
    FValue is G + H,
    assertz(fvalue(FValue)),
    false.

min_nuova_FSoglia(F,FSoglia):-
    findall(V, (fvalue(V), V > F), ListaV),
    min_list(ListaV, FSoglia).
    