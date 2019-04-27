% Domain

materia(lettere; matematica; tecnologia; musica; inglese; spagnolo; religione; educazione_fisica, scienze).
aula(aula_matematica; aula_tecnologia; aula_musica; aula_inglese; aula_spagnolo; aula_religione; lab_arte; lab_scienze; palestra; aula_lettere1; aula_lettere2).
docente(docArte; docTec; docMus; docIng; docSpa; docRel; docEdFis; docSci1; docSci2; docMate1; docMate2; docLett1; docLett2; docChimica; docRecMat; docEdCiv; docLabDisegno).
classe(primaA; secondaA; terzaA; primaB; secondaB; terzaB).
giorno(lun;mar;merc;giov;ven).
ora(primaOra;secondaOra;terzaOra;quartaOra;quintaOra;sestaOra).

ora_extra(prima_ora_extra; seconda_ora_extra).
mensa(pausaMensa).
materia_extra(chimica; recupero_matematica; educazione_civica; lab_disegno).

docente_insegna_extra(docChimica, chimica).
docente_insegna_extra(docRecMat, recupero_matematica).
docente_insegna_extra(docEdCiv, educazione_civica).
docente_insegna_extra(docLabDisegno, lab_disegno).

% Generate
1 {assegnamento_ora(Classe, Giorno, Ora, Aula, Doc, Materia) : 
               aula_materia(Materia,Aula), docente_insegna(Doc, Materia),
                     giorno_lezione(Classe,Giorno), insegnamento_ora(Classe,Giorno, Ora, Materia)} 1 :- ora_lezione(Classe,Giorno,Ora).

 2 {assegnamento_ora(primaA, Giorno, Ora, Aula, Doc, Materia) : aula(Aula), giorno_lezione(primaA,Giorno), docente_insegna_extra(Doc, Materia), ora_extra(Ora) } 2 :- giorno_lezione(primaA, Giorno).
 2 {assegnamento_ora(secondaA, Giorno, Ora, Aula, Doc, Materia) : aula(Aula), giorno_lezione(secondaA,Giorno), docente_insegna_extra(Doc, Materia), ora_extra(Ora) } 2 :- giorno_lezione(secondaA, Giorno).
 2 {assegnamento_ora(terzaA, Giorno, Ora, Aula, Doc, Materia) : aula(Aula), giorno_lezione(terzaA,Giorno), docente_insegna_extra(Doc, Materia), ora_extra(Ora) } 2 :- giorno_lezione(terzaA, Giorno).

5 { giorno_lezione(Classe,Giorno) : giorno(Giorno)} 5 :- classe(Classe).
6 { ora_lezione(Classe,Giorno,Ora) : ora(Ora)} 6 :- giorno_lezione(Classe,Giorno).


10 {insegnamento_ora(Classe, Giorno, Ora, lettere) : ora(Ora), giorno(Giorno)} 10 :- classe(Classe).
4 {insegnamento_ora(Classe, Giorno, Ora, matematica) : ora(Ora), giorno(Giorno)} 4 :- classe(Classe).
2 {insegnamento_ora(Classe, Giorno, Ora, scienze) : ora(Ora), giorno(Giorno)} 2 :- classe(Classe).
3 {insegnamento_ora(Classe, Giorno, Ora, inglese) : ora(Ora), giorno(Giorno)} 3 :- classe(Classe).
2 {insegnamento_ora(Classe, Giorno, Ora, spagnolo) : ora(Ora), giorno(Giorno)} 2 :- classe(Classe).
2 {insegnamento_ora(Classe, Giorno, Ora, musica) : ora(Ora), giorno(Giorno)} 2 :- classe(Classe).
2 {insegnamento_ora(Classe, Giorno, Ora, tecnologia) : ora(Ora), giorno(Giorno)} 2 :- classe(Classe).
2 {insegnamento_ora(Classe, Giorno, Ora, arte) : ora(Ora), giorno(Giorno)} 2 :- classe(Classe).
2 {insegnamento_ora(Classe, Giorno, Ora, educazione_fisica) : ora(Ora), giorno(Giorno)} 2 :- classe(Classe). 
1 {insegnamento_ora(Classe, Giorno, Ora, religione) : ora(Ora), giorno(Giorno)} 1 :- classe(Classe).


% Define

docente_insegna(docTec,tecnologia).
docente_insegna(docMus,musica).
docente_insegna(docIng,inglese).
docente_insegna(docSpa,spagnolo).
docente_insegna(docRel,religione).
docente_insegna(docArte,arte).
docente_insegna(docEdFis,educazione_fisica).
docente_insegna(docMate1,matematica).
docente_insegna(docMate2,matematica).
docente_insegna(docMate1,scienze).
docente_insegna(docMate2,scienze).
docente_insegna(docSci1,scienze).
docente_insegna(docSci2,scienze).
docente_insegna(docSci1,matematica).
docente_insegna(docSci2,matematica).
docente_insegna(docLett1, lettere).
docente_insegna(docLett2, lettere).

aula_materia(matematica,aula_matematica).
aula_materia(tecnologia,aula_tecnologia).
aula_materia(lettere,aula_lettere1).
aula_materia(lettere,aula_lettere2).
aula_materia(musica,aula_musica).
aula_materia(inglese,aula_inglese).
aula_materia(spagnolo,aula_spagnolo).
aula_materia(religione,aula_religione).
aula_materia(arte,lab_arte).
aula_materia(educazione_fisica,palestra).
aula_materia(scienze,lab_scienze).

% Test


% una classe non può essere in due aule diverse contemporaneamente
 :- assegnamento_ora(Classe, Giorno, Ora, Aula1, _, _), assegnamento_ora(Classe, Giorno, Ora, Aula2, _, _), Aula1 <> Aula2.

% % Un'aula non può essere occupata da due classi diverse nello stesso giorno alla stessa ora
:- assegnamento_ora(Classe1, Giorno, Ora, Aula, _, _), assegnamento_ora(Classe2, Giorno, Ora, Aula, _, _), Classe1 <> Classe2.

% Un docente non può essere in aule diverse o due classi diverse lo stesso giorno alla stessa ora
:- assegnamento_ora(Classe1, Giorno, Ora, _, Doc, _), assegnamento_ora(Classe2, Giorno, Ora, _, Doc, _), Classe1 <> Classe2.
% (primaA, lun, primaOra, aula_inglese, docIng, _), (secondaB, lun, primaOra, aula_musica, docIng, _) vieta questo caso

#show assegnamento_ora/6.
