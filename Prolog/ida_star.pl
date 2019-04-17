% --------------------------------------------------------
%                       IDA*
% --------------------------------------------------------

% ida_star(Soluzione)
%   Controlla la validità dello stato iniziale e avvia la
%   ricerca impostando come prima FSoglia l'euristica del nodo iniziale
% 
%   Soluzione: lista di azioni corrispondenti alla soluzione
ida_star(Soluzione):-
    iniziale(S),
    precondizioni(S),
    euristica(S,H),
    assertz(fvalue(H)),
    ida_star_aux(S,Soluzione,[S],H),!.

% ida_star_aux(S,Soluzione,Visitati,FSoglia)
%   Effettua una ricerca in profondità limitata, incrementando
%   ricorsivamente la FSoglia basandosi sul minimo valore F
%   superiore alla FSoglia in caso di fallimento
%
%   S: Stato
%   Visitati: lista di stati già visitati
%   Soluzione: lista di azioni corrispondenti alla soluzione
%   FSoglia: valore F di soglia
ida_star_aux(S,Soluzione,Visitati,FSoglia):-
    nl,write(fsoglia=FSoglia),
    dfs_aux(S,Soluzione,Visitati,0,FSoglia).
ida_star_aux(S,Soluzione,Visitati,FSoglia):-
    fvalue(NuovaFSoglia),!,
    FSoglia \= NuovaFSoglia,
    ida_star_aux(S,Soluzione,Visitati,NuovaFSoglia).


% dfs_aux(S,Soluzione,Visitati,G,FSoglia)
%   Effettua una ricerca in profondità limitata, asserendo
%   il proprio valore F in caso di fallimento e se minore
%   di valori precedentemente memorizzati
%
%   S: Stato
%   Soluzione: lista di azioni corrispondenti alla soluzione
%   Visitati: lista di stati già visitati
%   G: costo del percorso in considerazione fino allo stato S
%   FSoglia: valore F di soglia
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
    costo(Azione,C),
    GNuovo is G+C,
    dfs_aux(SNuovo,AzioniTail,[SNuovo|Visitati],GNuovo,FSoglia).