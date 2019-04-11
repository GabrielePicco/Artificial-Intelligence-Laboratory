euristica(pos(R,C), Euristica):-
    finale(pos(RFIN,CFIN)),
    Euristica is abs(RFIN-R) + abs(CFIN-C).