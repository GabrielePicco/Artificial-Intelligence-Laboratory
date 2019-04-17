% --------------------------------------------------------
%                       Iterative Deepening
% --------------------------------------------------------

% iterative_deepening(Soluzione)
%   Effettua una ricerca in profondità limitata,
%   incrementando ricorsivamente il limite.
%   La soglia viene inizialmente impostata a 1.
% 
%   Soluzione: lista di azioni corrispondenti alla soluzione
iterative_deepening(_):-retract(maybe_solvable(_)),false.
iterative_deepening(Soluzione):-
    iniziale(S),
    assert(maybe_solvable(true)),
    iterative_deepening_aux(S,Soluzione,[S],1),!.

% iterative_deepening_aux(S,Soluzione,Visitati,Soglia)
%   Effettua una ricerca in profondità limitata,
%   incrementando ricorsivamente il limite.
%   Se almeno un percorso termina perchè limitato dalla
%   soglia, viene asserito un termine maybe_solvable(true)
%   In caso contrario, la ricerca termina, poichè tutte le
%   possibili strade sono state esplorate e non esiste
%   soluzione
% 
%   Soluzione: lista di azioni corrispondenti alla soluzione
iterative_deepening_aux(_,_,_,_):-
    maybe_solvable(true),
    retract(maybe_solvable(true)),
    assert(maybe_solvable(false)),
    false.
iterative_deepening_aux(S,Soluzione,Visitati,Soglia):-
    nl,write(soglia=Soglia),
    dfs_aux(S,Soluzione,Visitati,Soglia),!.
iterative_deepening_aux(S,Soluzione,Visitati,Soglia):-
    NuovaSoglia is Soglia+1,
    maybe_solvable(true),
    iterative_deepening_aux(S,Soluzione,Visitati,NuovaSoglia).

% dfs_aux(S,Soluzione,Visitati,Soglia)
%   Effettua una ricerca in profondità limitata
%
%   S: Stato
%   Soluzione: lista di azioni corrispondenti alla soluzione
%   Visitati: lista di stati già visitati
%   Soglia: valore di soglia
dfs_aux(S,[],_,_):-finale(S).
dfs_aux(S,[Azione|AzioniTail],Visitati,Soglia):-
    Soglia>0,
    applicabile(Azione,S),
    trasforma(Azione,S,SNuovo),
    \+member(SNuovo,Visitati),
    NuovaSoglia is Soglia-1,
    dfs_aux(SNuovo,AzioniTail,[SNuovo|Visitati],NuovaSoglia).
dfs_aux(_,_,_,Soglia):-
    Soglia=0,
    maybe_solvable(false),
    retract(maybe_solvable(false)),
    assert(maybe_solvable(true)),
    false.
