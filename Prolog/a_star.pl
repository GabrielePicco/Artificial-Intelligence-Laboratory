% --------------------------------------------------------
%                       A*
% --------------------------------------------------------

% a_star(Soluzione)
%   Controlla la validità dello stato iniziale e avvia la
%   ricerca inserendo lo stato iniziale come primo nodo
%   sulla frontiera
% 
%   Soluzione: lista di azioni corrispondenti alla soluzione
a_star(Soluzione):-
    iniziale(S),
    precondizioni(S),
    a_star_aux([node(euristica(S),0,S,[])],[],InvSoluzione),
    reverse(InvSoluzione,Soluzione),!.

% a_star_aux(Coda,Visitati,Soluzione)
%   Espande la frontiera (scegliendo il nodo con 
%   (euristica + costo cammino) minore) aggiungendo gli stati successori
%   che già non vi appartengono e non sono già stati visitati.
%
% Coda = [node(F,G,S,Azioni)|...]
% Visitati: lista di stati visitati
% Soluzione: lista di azioni corrispondenti alla soluzione
a_star_aux([node(_,_,S,Azioni)|_],_,Azioni):-finale(S),!.
a_star_aux([node(F,G,S,Azioni)|Frontier],Visitati,Soluzione):-
    findall(Azione, applicabile(Azione,S), ListaAzioniApplicabili),
    estraiStati(Frontier, StatiAperti),
    append(Visitati, StatiAperti, CycleStates),
    generaFigli(node(F,G,S,Azioni),ListaAzioniApplicabili,CycleStates,ListaFigli),
    append(Frontier,ListaFigli,FrontieraEspansa),
    sort(FrontieraEspansa,FrontieraEspansaOrdindata),
    a_star_aux(FrontieraEspansaOrdindata,[S|Visitati],Soluzione).

% generaFigli(S, ListaAzioniApplicabili, CycleStates, ListaFigli)
%   genera i figli successori di una stato, controllandone
%   l'ammissibilità e prevenendo i cicli   
%
% S: stato node(F,G,S,Azioni)
% ListaAzioniApplicabili: lista delle azioni applicabile nello stato S
% CycleStates: lista stati già visitati o in frontiera
% ListaFigli: stati successori
generaFigli(_,[],_,[]):-!.
generaFigli(node(F,G,S,Azioni),[Azione|AltreAzioni],CycleStates,[node(FNuovo,GNuovo,SNuovo,[Azione|Azioni])|FigliTail]):-
    trasforma(Azione,S,SNuovo),
    \+member(SNuovo,CycleStates),!,
    costo(Azione,C),
    GNuovo is G+C,
    euristica(SNuovo,H),
    FNuovo is H + GNuovo,
    generaFigli(node(F,G,S,Azioni),AltreAzioni,CycleStates,FigliTail).
generaFigli(node(F,G,S,AzioniPerS),[_|AltreAzioni],CycleStates,FigliTail):-
    generaFigli(node(F,G,S,AzioniPerS),AltreAzioni,CycleStates,FigliTail).

% estraiStai(N, Stati)
%
% N: node(F,G,S,Azioni)
% Stati: Lista degli S in N
estraiStati([],[]):-!.
estraiStati([node(_,_,S,_)|Frontier],[S|StatesFrontier]):-
    estraiStati(Frontier,StatesFrontier).