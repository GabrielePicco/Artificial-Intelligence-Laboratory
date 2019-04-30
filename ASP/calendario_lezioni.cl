% Domain

materia(lettere; matematica; tecnologia; musica; inglese; spagnolo; religione; educazione_fisica, scienze).
materia_extra(chimica; recupero_matematica; educazione_civica; lab_disegno).

aula(aula_matematica; aula_tecnologia; aula_musica; aula_inglese; aula_spagnolo; aula_religione; lab_arte; lab_scienze; palestra; aula_lettere1; aula_lettere2).

docente(doc_arte; doc_tecnologia; doc_musica; doc_inglese; doc_spagnolo; doc_religione; doc_ed_fisica; doc_scienze_1; doc_scienze_2; doc_matematica_1; doc_matematica_2; doc_lettere_1; doc_lettere_2; doc_chimica; doc_rec_matematica; doc_ed_civica; doc_lab_disegno).

classe_tempo_normale(prima_B; seconda_B; terza_B).
classe_tempo_prolungato(prima_A; seconda_A; terza_A).

giorno(lun;mar;merc;giov;ven).

ora(prima_ora;seconda_ora;terza_ora;quarta_ora;quinta_ora;sesta_ora).
ora_mensa(settima_ora).
ora_extra(ottava_ora; nona_ora).

% Define

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

docente_insegna(doc_tecnologia,tecnologia).
docente_insegna(doc_musica,musica).
docente_insegna(doc_inglese,inglese).
docente_insegna(doc_spagnolo,spagnolo).
docente_insegna(doc_religione,religione).
docente_insegna(doc_arte,arte).
docente_insegna(doc_ed_fisica,educazione_fisica).
docente_insegna(doc_matematica_1,matematica).
docente_insegna(doc_matematica_2,matematica).
docente_insegna(doc_matematica_1,scienze).
docente_insegna(doc_matematica_2,scienze).
docente_insegna(doc_scienze_1,scienze).
docente_insegna(doc_scienze_2,scienze).
docente_insegna(doc_scienze_1,matematica).
docente_insegna(doc_scienze_2,matematica).
docente_insegna(doc_lettere_1,lettere).
docente_insegna(doc_lettere_2,lettere).

docente_insegna_extra(doc_chimica, chimica).
docente_insegna_extra(doc_scienze_1, chimica).
docente_insegna_extra(doc_scienze_2, chimica).
docente_insegna_extra(doc_rec_matematica, recupero_matematica).
docente_insegna_extra(doc_matematica_1, recupero_matematica).
docente_insegna_extra(doc_matematica_2, recupero_matematica).
docente_insegna_extra(doc_ed_civica, educazione_civica).
docente_insegna_extra(doc_lab_disegno, lab_disegno).
docente_insegna_extra(doc_arte, lab_disegno).

% Generate

1 {assegnamento_ora(Classe, Giorno, Ora, Aula, Doc, Materia) : 
               aula_materia(Materia,Aula), docente_insegna(Doc, Materia),
                     giorno_lezione(Classe,Giorno), insegnamento_ora(Classe,Giorno,Ora,Materia)} 1 :- ora_lezione(Classe,Giorno,Ora). 

1 {assegnamento_ora(Classe, Giorno, Ora, Aula, Doc, Materia) : giorno_lezione_extra(Classe,Giorno), aula(Aula),
      docente_insegna_extra(Doc, Materia), insegnamento_ora(Classe,Giorno,Ora,Materia) } 1 :- ora_lezione_extra(Classe, Giorno, Ora).

1 {assegnamento_ora_mensa(Classe, Giorno, settima_ora, mensa)} 1 :- giorno_lezione_extra(Classe, Giorno).

5 { giorno_lezione(Classe,Giorno) : giorno(Giorno)} 5 :- classe_tempo_normale(Classe).
5 { giorno_lezione(Classe,Giorno) : giorno(Giorno)} 5 :- classe_tempo_prolungato(Classe).
6 { ora_lezione(Classe,Giorno,Ora) : ora(Ora)} 6 :- giorno_lezione(Classe,Giorno).

5 { giorno_lezione_extra(Classe,Giorno) : giorno(Giorno)} 5 :- classe_tempo_prolungato(Classe).
2 { ora_lezione_extra(Classe,Giorno,Ora) : ora_extra(Ora)} 2 :- giorno_lezione_extra(Classe,Giorno).


10 {insegnamento_ora(Classe, Giorno, Ora, lettere) : ora(Ora), giorno(Giorno)} 10 :- classe_tempo_normale(Classe).
10 {insegnamento_ora(Classe, Giorno, Ora, lettere) : ora(Ora), giorno(Giorno)} 10 :- classe_tempo_prolungato(Classe).
4 {insegnamento_ora(Classe, Giorno, Ora, matematica) : ora(Ora), giorno(Giorno)} 4 :- classe_tempo_normale(Classe).
4 {insegnamento_ora(Classe, Giorno, Ora, matematica) : ora(Ora), giorno(Giorno)} 4 :- classe_tempo_prolungato(Classe).
2 {insegnamento_ora(Classe, Giorno, Ora, scienze) : ora(Ora), giorno(Giorno)} 2 :- classe_tempo_normale(Classe).
2 {insegnamento_ora(Classe, Giorno, Ora, scienze) : ora(Ora), giorno(Giorno)} 2 :- classe_tempo_prolungato(Classe).
3 {insegnamento_ora(Classe, Giorno, Ora, inglese) : ora(Ora), giorno(Giorno)} 3 :- classe_tempo_normale(Classe).
3 {insegnamento_ora(Classe, Giorno, Ora, inglese) : ora(Ora), giorno(Giorno)} 3 :- classe_tempo_prolungato(Classe).
2 {insegnamento_ora(Classe, Giorno, Ora, spagnolo) : ora(Ora), giorno(Giorno)} 2 :- classe_tempo_normale(Classe).
2 {insegnamento_ora(Classe, Giorno, Ora, spagnolo) : ora(Ora), giorno(Giorno)} 2 :- classe_tempo_prolungato(Classe).
2 {insegnamento_ora(Classe, Giorno, Ora, musica) : ora(Ora), giorno(Giorno)} 2 :- classe_tempo_normale(Classe).
2 {insegnamento_ora(Classe, Giorno, Ora, musica) : ora(Ora), giorno(Giorno)} 2 :- classe_tempo_prolungato(Classe).
2 {insegnamento_ora(Classe, Giorno, Ora, tecnologia) : ora(Ora), giorno(Giorno)} 2 :- classe_tempo_normale(Classe).
2 {insegnamento_ora(Classe, Giorno, Ora, tecnologia) : ora(Ora), giorno(Giorno)} 2 :- classe_tempo_prolungato(Classe).
2 {insegnamento_ora(Classe, Giorno, Ora, arte) : ora(Ora), giorno(Giorno)} 2 :- classe_tempo_normale(Classe).
2 {insegnamento_ora(Classe, Giorno, Ora, arte) : ora(Ora), giorno(Giorno)} 2 :- classe_tempo_prolungato(Classe).
2 {insegnamento_ora(Classe, Giorno, Ora, educazione_fisica) : ora(Ora), giorno(Giorno)} 2 :- classe_tempo_normale(Classe). 
2 {insegnamento_ora(Classe, Giorno, Ora, educazione_fisica) : ora(Ora), giorno(Giorno)} 2 :- classe_tempo_prolungato(Classe). 
1 {insegnamento_ora(Classe, Giorno, Ora, religione) : ora(Ora), giorno(Giorno)} 1 :- classe_tempo_normale(Classe).
1 {insegnamento_ora(Classe, Giorno, Ora, religione) : ora(Ora), giorno(Giorno)} 1 :- classe_tempo_prolungato(Classe).
4 {insegnamento_ora(Classe, Giorno, Ora, recupero_matematica): ora_extra(Ora), giorno(Giorno)} 4:-classe_tempo_prolungato(Classe).
2 {insegnamento_ora(Classe, Giorno, Ora, chimica): ora_extra(Ora), giorno(Giorno)} 2:-classe_tempo_prolungato(Classe).
2 {insegnamento_ora(Classe, Giorno, Ora, educazione_civica): ora_extra(Ora), giorno(Giorno)} 2:-classe_tempo_prolungato(Classe).
2 {insegnamento_ora(Classe, Giorno, Ora, lab_disegno): ora_extra(Ora), giorno(Giorno)} 2:-classe_tempo_prolungato(Classe).


% Test

% una classe non può essere in due aule diverse contemporaneamente
:- assegnamento_ora(Classe, Giorno, Ora, Aula1, _, _), assegnamento_ora(Classe, Giorno, Ora, Aula2, _, _), Aula1 <> Aula2.

% % Un'aula non può essere occupata da due classi diverse nello stesso giorno alla stessa ora
:- assegnamento_ora(Classe1, Giorno, Ora, Aula, _, _), assegnamento_ora(Classe2, Giorno, Ora, Aula, _, _), Classe1 <> Classe2.

% Un docente non può essere in aule diverse o due classi diverse lo stesso giorno alla stessa ora
:- assegnamento_ora(Classe1, Giorno, Ora, _, Doc, _), assegnamento_ora(Classe2, Giorno, Ora, _, Doc, _), Classe1 <> Classe2.

:- assegnamento_ora(Classe, _, _, _, Doc1, Materia), assegnamento_ora(Classe, _, _, _, Doc2, Materia), Doc1 <> Doc2.

#show assegnamento_ora/6.
#show assegnamento_ora_mensa/4.
