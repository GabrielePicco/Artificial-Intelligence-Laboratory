a_star(Soluzione):-
    iniziale(S),
    a_star_aux([nodo(euristica(S),0,S,[])],[],Soluzione),!.

% a_star_aux(Coda,Visitati,Soluzione)
% Coda = [nodo(F,G,S,Azioni)|...]
a_star_aux([nodo(_,_,S,Azioni)|_],_,Azioni):-finale(S).
a_star_aux([nodo(F,G,S,Azioni)|Tail],Visitati,Soluzione):-
    findall(Azione, applicabile(Azione,S), ListaAzioniApplicabili),
    generaFigli(nodo(F,G,S,Azioni),ListaAzioniApplicabili,Visitati,ListaFigli),
    append(Tail,ListaFigli,NuovaCoda),
    sort(NuovaCoda,CodaOrdinata),
    a_star_aux(CodaOrdinata,[S|Visitati],Soluzione).

% generaFigli(Nodo(S,Azioni), ListaAzioniApplicabili, Visitati, ListaFigli)
generaFigli(_,[],_,[]).
generaFigli(nodo(F,G,S,Azioni),[Azione|AltreAzioni],Visitati,[nodo(FNuovo,GNuovo,SNuovo,[Azione|Azioni])|FigliTail]):-
    trasforma(Azione,S,SNuovo),
    GNuovo is G+1,
    euristica(SNuovo,H),
    FNuovo is H + GNuovo,
    \+member(SNuovo,Visitati),!,
    generaFigli(nodo(F,G,S,Azioni),AltreAzioni,Visitati,FigliTail).

generaFigli(nodo(F,G,S,AzioniPerS),[_|AltreAzioni],Visitati,FigliTail):-
    generaFigli(nodo(F,G,S,AzioniPerS),AltreAzioni,Visitati,FigliTail).