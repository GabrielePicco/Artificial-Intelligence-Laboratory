precondizioni(pos(R,C)):-
  num_righe(NR),
  R > 0,
  R =< NR,
  num_colonne(NC),
  C > 0,
  C =< NC,
  \+occupata(pos(R,C)).

applicabile(est,pos(R,C)):-
  num_colonne(NC),
  C < NC,
  C1 is C+1,
  \+occupata(pos(R,C1)).
applicabile(ovest,pos(R,C)):-
  C > 1,
  C1 is C-1,
  \+occupata(pos(R,C1)).
applicabile(sud,pos(R,C)):-
  num_righe(NR),
  R < NR,
  R1 is R+1,
  \+occupata(pos(R1,C)).
applicabile(nord,pos(R,C)):-
  R > 1,
  R1 is R-1,
  \+occupata(pos(R1,C)).

trasforma(est,pos(R,C),pos(R,C1)):-C1 is C+1.
trasforma(ovest,pos(R,C),pos(R,C1)):-C1 is C-1.
trasforma(sud,pos(R,C),pos(R1,C)):-R1 is R+1.
trasforma(nord,pos(R,C),pos(R1,C)):-R1 is R-1.

costo(est,1).
costo(ovest,1).
costo(sud,1).
costo(nord,1).