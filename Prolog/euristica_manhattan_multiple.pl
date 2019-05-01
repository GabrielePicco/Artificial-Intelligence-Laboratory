euristica(pos(R,C), Euristica):-
    findall((pos(R,C), pos(RFIN,CFIN)), finale(pos(RFIN,CFIN)), ListaStatiFinali),
    maplist(euristica_aux, ListaStatiFinali, ListaEuristiche),
    min_list(ListaEuristiche, Euristica).

euristica_aux((pos(R,C), pos(RFIN,CFIN)), Euristica):-
    Euristica is abs(RFIN-R) + abs(CFIN-C).