ida_star(Soluzione):-
    iniziale(S),
    precondizioni(S),
    euristica(S,H),
    assertz(fvalue(H)),
    %assertz(esc(true)),
    ida_star_aux(S,Soluzione,[S],H),!.

ida_star_aux(S,Soluzione,Visitati,FSoglia):-
    nl,write(fsoglia=FSoglia),
    dfs_aux(S,Soluzione,Visitati,0,FSoglia).

ida_star_aux(S,Soluzione,Visitati,_):-
    fvalue(NuovaFSoglia),
    %esc(false),
    %retract(esc(_)),
    %assertz(esc(true)),
    ida_star_aux(S,Soluzione,Visitati,NuovaFSoglia).

dfs_aux(S,[],_,_,_):-finale(S).

dfs_aux(S,_,_,G,FSoglia):-
    euristica(S,H),
    FValue is G + H,
    FValue > FSoglia,!,
    fvalue(CurrentFValue),
    (FValue < CurrentFValue ; CurrentFValue = FSoglia),
    retract(fvalue(_)),
    assertz(fvalue(FValue)),
    false.

dfs_aux(S,[Azione|AzioniTail],Visitati,G,FSoglia):-
    applicabile(Azione,S),
    trasforma(Azione,S,SNuovo),
    \+member(SNuovo,Visitati),
    %retract(esc(_)),
    %assertz(esc(false)),
    costo(Azione,C),
    GNuovo is G+C,
    dfs_aux(SNuovo,AzioniTail,[SNuovo|Visitati],GNuovo,FSoglia).