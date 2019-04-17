% calendario settimanale delle lezioni di una scuola media (3 anni):
% ad ogni insegnamento è associata un’aula o un laboratorio
% ci sono otto aule: - lettere (2 aule),  - matematica, tecnologia, musica, inglese, spagnolo, religione
% ci sono tre laboratori: arte, - scienze, educazione fisica (palestra)
% ci sono due docenti per ciascuno dei seguenti insegnamenti: - lettere, - matematica,  -scienze;
% vi è un unico docente per tutti gli altri insegnamenti;
% ci sono due classi per ogni anno di corso, una a regime “tempo prolungato” ed una a regime “tempo normale”
% il calendario delle lezioni, di 30 ore complessive, da distribuire
% in 5 giorni (da lunedì a venerdì), 6 ore al giorno
% la sezione A sia tempo prolungato
% la sezione B sia tempo normale
% le classi sono, pertanto: 1A, 1B, 2A, 2B, 3A, 3B
%
% ogni docente insegna una ed una sola materia, con
% l’eccezione di matematica e scienze, ossia un docente 
% incaricato di insegnare matematica risulterà anche
% insegnante di scienze (non necessariamente per la stessa classe);
%
% per ogni classe, sono previste 10 ore di lettere, 4 di
% matematica, 2 di scienze, 3 di inglese, 2 di spagnolo, 2
% di musica, 2 di tecnologia, 2 di arte, 2 di educazione
% fisica, 1 di religione.

materia(lettere1;lettere2; matematica; tecnologia; musica; inglese; spagnolo; religione; educazione_fisica).

aula_lettere(aula_lettere1; aula_lettere2).
aula(aula_matematica; aula_tecnologia; aula_musica; aula_inglese; aula_spagnolo; aula_religione; lab_arte; lab_scienze; lab_palestra).

docente_lettere(docLett1; docLett2).
docente_matematica(docMate1; docMate2).
docente_scienze(docSci1; docSci2).
docente(docArte; docTec; docMus; docIng; docSpa; docRel; docEdFis).

classe(primaA; secondaA; terzaA; primaB; secondaB; terzaB).
giorno(lun;mar;merc;giov;ven).
ora(primaOra;secondaOra;terzaOra;quartaOra;quintaOra;sestaOra).

% docente singolo insegna materia
docente_insegna_materia(docTec,aula_tecnologia,tecnologia).
docente_insegna_materia(docMus,aula_musica,musica).
docente_insegna_materia(docIng,aula_inglese,inglese).
docente_insegna_materia(docSpa,aula_spagnolo,spagnolo).
docente_insegna_materia(docRel,aula_religione,religione).
docente_insegna_materia(docArte,lab_arte,arte).
docente_insegna_materia(docEdFis,lab_palestra,educazione_fisica).


% Per ogni materia c'è un docente che la insegna in un'aula
% 1 {docente_insegna_materia(D,A,lettere1) : docente_lettere(D)} 1:- aula_lettere(A).
% 1 {docente_insegna_materia(D,A,lettere2) : docente_lettere(D)} 1:- aula_lettere(A).
1 {docente_insegna_materia(D,A,lettere1) : docente_lettere(D)} 1:- aula_lettere(A).
1 {docente_insegna_materia(D,A,lettere2) : docente_lettere(D)} 1:- aula_lettere(A).

1 {docente_insegna_materia(D,aula_matematica,matematica) : docente_matematica(D)} 1.
1 {docente_insegna_materia(D,lab_scienze,scienze) : docente_matematica(D)} 1.
1 {docente_insegna_materia(D,aula_matematica,matematica) : docente_scienze(D)} 1.



% Per ogni giorno G ci sono 6 e solo 6 ore O di lezione *****
6 {ore_lezione_per_giorno(O,G) : ora(O)} 6 :- giorno(G).

% Per ogni classe C ci sono min X e max Y ore O di lezione della materia ----
5 {ore_materia_per_classe(O,C,lettere1) : ora(O)} 5 :- classe(C).
5 {ore_materia_per_classe(O,C,lettere2) : ora(O)} 5 :- classe(C).
4 {ore_materia_per_classe(O,C,matematica) : ora(O)} 4 :- classe(C).
2 {ore_materia_per_classe(O,C,scienze) : ora(O)} 2 :- classe(C).
3 {ore_materia_per_classe(O,C,inglese) : ora(O)} 3 :- classe(C).
2 {ore_materia_per_classe(O,C,spagnolo) : ora(O)} 2 :- classe(C).
2 {ore_materia_per_classe(O,C,musica) : ora(O)} 2 :- classe(C).
2 {ore_materia_per_classe(O,C,tecnologia) : ora(O)} 2 :- classe(C).
2 {ore_materia_per_classe(O,C,arte) : ora(O)} 2 :- classe(C).
2 {ore_materia_per_classe(O,C,palestra) : ora(O)} 2 :- classe(C).
1 {ore_materia_per_classe(O,C,religione) : ora(O)} 1 :- classe(C).

30 {assegnamento_ora(Classe, Giorno, Ora, Aula, Doc, Materia) : docente(Doc),aula(Aula),ora(Ora),giorno(Giorno),materia(Materia) } 30 :- classe(Classe).

#show assegnamento_ora/6.