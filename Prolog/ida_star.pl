ida_star(Soluzione):-
    iniziale(S),
    precondizioni(S),
    euristica(S,H),
    ida_star_aux(S,Soluzione,[S],H).

ida_star_aux(S,Soluzione,Visitati,FSoglia):-
    nl,write(fsoglia=FSoglia),
    dfs_aux(S,Soluzione,Visitati,0,FSoglia),!.

ida_star_aux(_,_,_,FSoglia):-
    retract(fvalue(FSoglia)), false.

ida_star_aux(S,Soluzione,Visitati,FSoglia):-
    min_nuova_FSoglia(FSoglia,NuovaFSoglia),
    ida_star_aux(S,Soluzione,Visitati,NuovaFSoglia).

dfs_aux(S,[],_,_,_):-finale(S).

dfs_aux(S,_,_,G,FSoglia):-
    euristica(S,H),
    FValue is G + H,
    FValue > FSoglia,!,
    assertz(fvalue(FValue)),
    false.

dfs_aux(S,[Azione|AzioniTail],Visitati,G,FSoglia):-
    applicabile(Azione,S),
    trasforma(Azione,S,SNuovo),
    \+member(SNuovo,Visitati),
    costo(Azione,C),
    GNuovo is G+C,
    dfs_aux(SNuovo,AzioniTail,[SNuovo|Visitati],GNuovo,FSoglia).

min_nuova_FSoglia(F,FSoglia):-
    findall(V, (fvalue(V), V > F), ListaV),
    min_list(ListaV, FSoglia).
    