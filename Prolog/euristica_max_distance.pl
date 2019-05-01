euristica(pos(R,C), Euristica):-
    finale(pos(RFIN,CFIN)),!,
    Euristica is max(abs(RFIN-R), abs(CFIN-C)).