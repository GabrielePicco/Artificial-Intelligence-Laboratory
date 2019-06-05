
;;;======================================================
;;;   Trip Expert Problem
;;;
;;;   
;;;
;;;     To execute, merely load, reset and run.
;;;======================================================

(defmodule MAIN (export ?ALL))

;;****************
;;* DEFFUNCTIONS *
;;****************

(deffunction MAIN::ask-question (?question ?allowed-values ?domain)
   (printout t ?question)
   (bind ?answer (explode$ (readline)))
   (if (lexemep ?answer) then (bind ?answer (lowcase ?answer)))
   (while (not (or (subsetp ?answer ?allowed-values) 
                    (and 
                        (eq ?domain "positive-integer")
                        (and 
                            (integerp (string-to-field (implode$ (create$ ?answer))))
                            (> (string-to-field (implode$ (create$ ?answer))) 0)
                        )
                    )
                )
          ) 
    do
      (printout t ?question)
      (bind ?answer (explode$ (readline)))
      (if (lexemep ?answer) then (bind ?answer (lowcase ?answer))))
   ?answer)

;;*****************
;;* INITIAL STATE *
;;*****************

(deftemplate MAIN::attribute
   (slot name)
   (multislot value)
   (slot certainty (default 100.0)))
   
 (deftemplate MAIN::attribute-intention
   (slot name)
   (multislot value)
   (slot certainty (default 100.0)))

(defrule MAIN::start
  (declare (salience 10000))
  =>
  (set-fact-duplication TRUE)
  (focus QUESTIONS GENERATE-PATH OPTMIZE-PATH HOTEL))

(defrule MAIN::combine-certainties ""
  (declare (salience 100)
           (auto-focus TRUE))
  ?rem1 <- (attribute (name ?rel) (value ?val) (certainty ?per1))
  ?rem2 <- (attribute (name ?rel) (value ?val) (certainty ?per2))
  (test (neq ?rem1 ?rem2))
  =>
  (retract ?rem1)
  (modify ?rem2 (certainty (/ (- (* 100 (+ ?per1 ?per2)) (* ?per1 ?per2)) 100))))
  
;;******************
;;* QUESTION RULES *
;;******************

(defmodule QUESTIONS (import MAIN ?ALL) (export ?ALL))

(deftemplate QUESTIONS::question
   (slot attribute (default ?NONE))
   (slot the-question (default ?NONE))
   (multislot valid-answers (default ?NONE))
   (slot valid-answers-domain (default "any"))
   (slot already-asked (default FALSE))
   (multislot precursors (default ?DERIVE)))
   
(defrule QUESTIONS::ask-a-question
   ?f <- (question (already-asked FALSE)
                   (precursors)
                   (the-question ?the-question)
                   (attribute ?the-attribute)
                   (valid-answers-domain ?domain)
                   (valid-answers $?valid-answers))
   =>
   (assert (attribute-intention (name ?the-attribute)
                      (value (ask-question ?the-question ?valid-answers ?domain)))))


(defrule QUESTIONS::verify-attribute-intention-valid
  (declare (salience 100))
  ?rem <- (attribute-intention (name ?rel) (value $?vals&:(> (length$ ?vals) 0)) (certainty ?per))
  ?f <- (question (already-asked FALSE)
                   (precursors)
                   (the-question ?the-question)
                   (attribute ?rel)
                   (valid-answers $?valid-answers))
  =>
  (retract ?rem)
  (modify ?f (already-asked TRUE))
  (assert (attribute (name ?rel) (value ?vals) (certainty ?per))))


(defrule QUESTIONS::delete-attribute-intention-invalid
  (declare (salience 100))
  ?rem <- (attribute-intention (name ?rel) (value $?vals&:(= (length$ ?vals) 0)) (certainty ?per))
  =>
  (retract ?rem)
)

(defrule QUESTIONS::delete-attribute-default
  (declare (salience 100))
  ?rem1 <- (attribute (name ?rel) (value $?vals1&:(= (length$ ?vals1) 0)))
  ?rem2 <- (attribute (name ?rel) (value $?vals2&:(> (length$ ?vals2) 0)))
  =>
  (retract ?rem1)
)

(defrule QUESTIONS::delete-less-specific-default
  (declare (salience 100))
  ?rem1 <- (attribute (name ?nm) (certainty ?val1))
  ?rem2 <- (attribute (name ?nm) (certainty ?val2&:(>= ?val2 ?val1)))
  (test (neq ?rem1 ?rem2))
  =>
  (retract ?rem1)
)

(defrule QUESTIONS::precursor-is-satisfied
   ?f <- (question (already-asked FALSE)
                   (precursors ?name is ?value $?rest))
         (attribute (name ?name) (value ?value))
   =>
   (if (eq (nth$ 1 ?rest) and) 
    then (modify ?f (precursors (rest$ ?rest)))
    else (modify ?f (precursors ?rest))))

(defrule QUESTIONS::precursor-is-not-satisfied
   ?f <- (question (already-asked FALSE)
                   (precursors ?name is-not ?value $?rest))
         (attribute (name ?name) (value ~?value))
   =>
   (if (eq (nth$ 1 ?rest) and) 
    then (modify ?f (precursors (rest$ ?rest)))
    else (modify ?f (precursors ?rest))))

;;*******************
;;* PREFERENCES QUESTIONS *
;;*******************

(defmodule TRIP-QUESTIONS (import QUESTIONS ?ALL))

(deffacts TRIP-QUESTIONS::question-attributes
  (question (attribute tourism-type)
            (the-question "Quali tipi di turismo preferisce? ")
            (valid-answers balneare montano lacustre naturalistico termale culturale religioso sportivo enogastronomico unknown))
  (question (attribute regions)
            (the-question "Quali sono le regioni in cui vuole effettuare il viaggio? ")
            (valid-answers piemonte liguria valle_daosta lombardia emilia_romagna unknown))
  (question (attribute number-locations)
            (the-question "Quante località si vuole visitare durante il viaggio? ")
            (valid-answers)
            (valid-answers-domain "positive-integer"))
  (question (attribute max-km)
            (the-question "Quanti kilometri massimi vuole percorrere durante il viaggio? ")
            (valid-answers)
            (valid-answers-domain "positive-integer"))

;;* DEFAULTS      
  (attribute (name regions) (value) (certainty 50.0))
  (attribute (name number-locations) (value 3) (certainty 50.0))
  (attribute (name n-day) (value 4) (certainty 50.0))
  (attribute (name n-people) (value 2) (certainty 50.0))
  (attribute (name max-km) (value 100) (certainty 50.0))
  (attribute (name hotel-stars) (value 1 2 3) (certainty 50.0))
)

;;*******************
;;* LOCATIONS MATCHING USER PREFERENCES *
;;*******************


(defmodule LOCATIONS (import MAIN ?ALL) (export ?ALL))

(deffunction LOCATIONS::calculate-distance (?lat1 ?lon1 ?lat2 ?lon2)
   (bind ?r 6371)
   (bind ?phi1 (deg-rad ?lat1))
   (bind ?phi2 (deg-rad ?lat2))
   (bind ?deltaphi (deg-rad (- ?lat2 ?lat1)))
   (bind ?deltalambda (deg-rad (- ?lon2 ?lon1)))
   (bind ?a 
        (+ (** (sin (/ ?deltaphi 2)) 2)
           (* (cos ?phi1) (cos ?phi2) (** (sin (/ ?deltalambda 2)) 2))
        )
    ) 
   (bind ?c (* 2 (atan (/ (sqrt ?a) (sqrt (- 1 ?a))))))
   (bind ?d (* ?r ?c))
   ?d
)

(deffunction LOCATIONS::locality-fit (?loc-turism-type ?loc-region ?pref-turism-type ?pref-region)
  (bind ?fit 0)
  (progn$ 
    (?field (create$ ?loc-turism-type))
    (if (lexemep ?field) 
      then (bind ?t-type ?field)
    )
    (if (floatp ?field) 
      then 
      (if (subsetp (create$ ?t-type) (create$ ?pref-turism-type)) 
        then (bind ?fit (+ ?fit ?field))
      )
    )
  )
  (if (subsetp (create$ ?loc-region) (create$ ?pref-region)) then (bind ?fit (+ ?fit 5)))
  ?fit
)

(deffunction LOCATIONS::distance-to-certainty (?distance)
   (bind ?c (/ 800 ?distance))
   (if (> ?c 100) then (bind ?c 100))
   ?c
)

(deftemplate LOCATIONS::location
   (slot name (default ?NONE))
   (slot region (default ?NONE))
   (slot lat (default ?NONE) (type FLOAT))
   (slot long (default ?NONE) (type FLOAT))
   (multislot tourism-type (default ?NONE))
)

(deftemplate LOCATIONS::tourism-type-value
   (slot turism (default ?NONE))
   (slot rank (default ?NONE) (type FLOAT))
)

(deffacts LOCATIONS::location-lists
  (location (name finale-ligure)
            (region liguria)
            (lat 44.169072)
            (long 8.343536)
            (tourism-type balneare 5.0 naturalistico 3.8 montano 3.0)
  )
  (location (name sanremo)
            (region liguria)
            (lat 43.821414)
            (long 7.786561)
            (tourism-type balneare 3.0 culturale 4.2 enogastronomico 4.7)
  )
  (location (name alassio)
            (region liguria)
            (lat 44.007917)
            (long 8.173044)
            (tourism-type balneare 5.0 enogastronomico 4.3)
  )
  (location (name laigueglia)
            (region liguria)
            (lat 43.974511)
            (long 8.158311)
            (tourism-type balneare 4.0)
  )
  (location (name torino)
            (region piemonte)
            (lat 45.066667)
            (long 7.7)
            (tourism-type culturale 4.8 enogastronomico 4.7)
  )
)

(defrule LOCATIONS::init-day-range-domain
    (attribute (name n-day) (value ?day))
    (attribute (name number-locations) (value ?nl))
    =>
    (assert (attribute (name n-day-range) (value (- ?day (- ?nl 1)))))
)

;(defrule LOCATIONS::generate-day-range-domain
;    ?r <- (attribute (name n-day-range) (value $?prec ?day))
;    ?r <- (attribute (name number-locations) (value ?nl))
;    (test (> ?day 1))
;    =>
;    (modify ?r (value ?prec ?day (- ?day 1)))
;)

(defrule LOCATIONS::default-location-certainty
    (declare (salience 100))
    ?l <- (location (name ?name) (region ?region))
    =>
    (assert (attribute (name location-certainty) (value ?l) (certainty 0)))
)

(defrule LOCATIONS::update-turist-type-likelihood
  (attribute (name tourism-type) (value $? ?val $?) (certainty ?c))
  ?l <- (location (name ?name) (region ?region) (tourism-type $? ?val&:(lexemep ?val) ?rank&:(floatp ?rank) $?))
  (attribute (name location-certainty) (value ?l) (certainty ?cl))
  =>
  (assert (attribute (name update-location-cf) (value ?l) (certainty (/ (+ ?c ?cl (* ?rank 20)) 4))))
)

(defrule LOCATIONS::update-region-likelihood
  (attribute (name regions) (value $? ?val $?) (certainty ?c))
  ?l <- (location (name ?name) (region ?val))
  (attribute (name location-certainty) (value ?l) (certainty ?cl))
  =>
  (assert (attribute (name update-location-cf) (value ?l) (certainty (/ (+ ?c ?cl) 2))))
)

;;*******************
;;* UPDATE LOCATIONS CERTAINTY *
;;*******************

(defmodule UPDATE-LOCATIONS (import LOCATIONS ?ALL) (import MAIN ?ALL))

(defrule UPDATE-LOCATIONS::update-location-certainty
  ?l <- (location (name ?name) (region ?region))
  ?up <- (attribute (name update-location-cf) (value ?l) (certainty ?c))
  ?lc <- (attribute (name location-certainty) (value ?l) (certainty ?cl))
  =>
  (retract ?up)
  (modify ?lc (certainty (/ (- (* 100 (+ ?c ?cl)) (* ?c ?cl)) 100)))
)

;;*******************
;;* GENERATE PATH *
;;*******************


(defmodule GENERATE-PATH (import LOCATIONS ?ALL) (import MAIN ?ALL))

(defrule GENERATE-PATH::generate-possible-path
  ?l <- (location (name ?name) (region ?region))
  (attribute (name regions) (value $?rgs) (certainty ?cr))
  (or 
    (test (subsetp (create$ ?region) (create$ ?rgs)))
    (test (= (length$ ?rgs) 0))
  )
  (attribute (name number-locations) (value ?nl))
  =>
  (assert (attribute (name trip-locations) (value ?nl 0 ?l)))
)

(defrule GENERATE-PATH::expand-path
  ?l1 <- (location (lat ?lat1) (long ?long1))
  (attribute (name trip-locations) (value ?nl ?distance $?prec ?l1))
  ?l2 <- (location (lat ?lat2) (long ?long2))
  (test (> ?nl 1))
  (test (neq ?l1 ?l2))
  (test (not (subsetp (create$ ?l2) (create$ ?prec))))
  (attribute (name max-km) (value ?max-km))
  (test (< (+ ?distance (calculate-distance ?lat1 ?long1 ?lat2 ?long2)) ?max-km))
  =>
  (assert (attribute (name trip-locations) 
                     (value (- ?nl 1) 
                     (+ ?distance (calculate-distance ?lat1 ?long1 ?lat2 ?long2)) ?prec ?l1 ?l2)))
)

;;*******************
;;* OPTIMIZE PATH *
;;*******************


(defmodule OPTMIZE-PATH (import LOCATIONS ?ALL) (import MAIN ?ALL))

(defrule OPTMIZE-PATH::remove-partial-path
  (declare (salience 100))
  (attribute (name number-locations) (value ?nl))
  ?a <- (attribute (name trip-locations) (value ?nlp&:(> ?nlp 1) $?))
  =>
  (retract ?a)
)

(defrule OPTMIZE-PATH::delete-suboptim-path
  (declare (salience 10))
  ?a <- (attribute (name trip-locations) (value ?nl ?d1 $?lcs1))
  ?b <- (attribute (name trip-locations) (value ?nl ?d2 $?lcs2))
  (test (>= ?d2 ?d1))
  (test (subsetp (create$ ?lcs1) (create$ ?lcs2)))
  (test (neq ?a ?b))
  =>
  (retract ?b)
)

(defrule OPTMIZE-PATH::generate-path-id
  ?a <- (attribute (name trip-locations) (value ?nl&:(integerp ?nl) ?d1 $?lcs1))
  =>
  (retract ?a)
  (assert (attribute (name trip-locations-id) (value (gensym) ?d1 ?lcs1)))
)

;;*******************
;;* HOTEL
;;*******************


(defmodule HOTEL (import MAIN ?ALL) (import LOCATIONS ?ALL) (export ?ALL))
(deftemplate HOTEL::hotel
   (slot name (default ?NONE))
   (slot city (default ?NONE))
   (slot region (default ?NONE))
   (slot availability (default ?NONE) (type INTEGER))
   (slot stars (default ?NONE) (type INTEGER) (range 1 4))
)

(deffacts HOTEL::hotels-lists
  (hotel (name "lido resort")
         (city finale-ligure)
         (region liguria)
         (availability 30)
         (stars 4)
  )
  (hotel (name "lido mare")
         (city finale-ligure)
         (region liguria)
         (availability 40)
         (stars 4)
  )
  (hotel (name "lido resort")
         (city alassio)
         (region liguria)
         (availability 30)
         (stars 2)
  )
  (hotel (name "lido resort")
         (city laigueglia)
         (region liguria)
         (availability 30)
         (stars 3)
  )
  (hotel (name "lido resort")
         (city torino)
         (region piemonte)
         (availability 30)
         (stars 3)
  )
  (hotel (name "lido resort")
         (city sanremo)
         (region liguria)
         (availability 30)
         (stars 2)
  )
)

(defrule HOTEL::generate-hotel-assignment
  (declare (salience 100))
  ?l <- (location (name ?city) (region ?region))
  (attribute (name trip-locations-id) (value ?id ?d $? ?l $?))
  (attribute (name n-people) (value ?np))
  (attribute (name hotel-stars) (value $?stars))
  ?h1 <- (hotel (city ?city) (region ?region) (stars ?s&:(subsetp (create$ ?s) (create$ ?stars))) (availability ?a&:(> ?a ?np)))
  (not (hotel (city ?city) (region ?region) (stars ?s2&:(and (< ?s2 ?s) (subsetp (create$ ?s2) (create$ ?stars)))) (availability ?a2&:(> ?a2 ?np))))   ; hotel less stars, enough availability
  (not (hotel (city ?city) (region ?region) (stars ?s2&:(= ?s2 ?s)) (availability ?a2&:(> ?a2 ?a))))     ; hotel same stars, but higer availability
  =>
  (assert (attribute (name hotel-assignment) (value ?id ?l ?h1)))
)

(defrule HOTEL::generate-missing-hotel-assignment
  ?l <- (location (name ?city) (region ?region))
  (attribute (name trip-locations-id) (value ?id ?d $? ?l $?))
  (attribute (name n-people) (value ?np))
  (attribute (name hotel-stars) (value $?stars))
  ?h1 <- (hotel (city ?city) (region ?region) (stars ?s) (availability ?a&:(> ?a ?np)))
  (not (attribute (name hotel-assignment) (value ?id ?l ?h1))) ; not already assigned
  (not (hotel (city ?city) (region ?region) (stars ?s2&:(< ?s2 ?s)) (availability ?a2&:(> ?a2 ?np))))   ; hotel less stars, enough availability
  (not (hotel (city ?city) (region ?region) (stars ?s2&:(= ?s2 ?s)) (availability ?a2&:(> ?a2 ?a))))     ; hotel same stars, but higer availability
  =>
  (assert (attribute (name hotel-assignment) (value ?id ?l ?h1)))
)

;;*******************
;;* GENERATE TRIP *
;;*******************


