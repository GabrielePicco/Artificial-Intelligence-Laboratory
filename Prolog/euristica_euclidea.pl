euristica(pos(R,C), Euristica):-
    finale(pos(RFIN,CFIN)),!,
    Euristica is round(sqrt((RFIN-R)*(RFIN-R) + (CFIN-C)*(CFIN-C))).