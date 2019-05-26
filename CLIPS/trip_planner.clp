
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
  (focus QUESTIONS LOCATIONS UPDATE-LOCATIONS GENERATE-PATH CHOOSE-QUALITIES WINES PRINT-RESULTS))

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
  (attribute (name number-locations) (value 1) (certainty 50.0))
  (attribute (name max-km) (value 100) (certainty 50.0))
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
   ?d)

(deftemplate LOCATIONS::location
   (slot name (default ?NONE))
   (slot region (default ?NONE))
   (slot lat)
   (slot long)
   (multislot tourism-type (default ?NONE))
   (slot certainty (default 0))
)

(deffacts LOCATIONS::location-lists
  (location (name finale-ligure)
            (region liguria)
            (lat 44.169072)
            (long 8.343536°)
            (tourism-type balneare naturalistico montano)
  )
  (location (name sanremo)
            (region liguria)
            (lat 43.821414)
            (long 7.786561)
            (tourism-type balneare culturale enogastronomico)
  )
  (location (name alassio)
            (region liguria)
            (lat 44.007917)
            (long 8.173044)
            (tourism-type balneare enogastronomico)
  )
  (location (name laigueglia)
            (region liguria)
            (lat 43.974511)
            (long 8.158311)
            (tourism-type balneare)
  )
  (location (name torino)
            (region piemonte)
            (lat 45.066667)
            (long 7.7)
            (tourism-type culturale enogastronomico)
  )
)

(defrule LOCATIONS::default-location-certainty
    (declare (salience 100))
    ?l <- (location (name ?name) (region ?region) (certainty ?cl))
    =>
    (assert (attribute (name location-certainty) (value ?l) (certainty 0)))
)

(defrule LOCATIONS::update-turist-type-likelihood
  (attribute (name tourism-type) (value $? ?val $?) (certainty ?c))
  ?l <- (location (name ?name) (region ?region) (tourism-type $? ?val $?))
  (attribute (name location-certainty) (value ?l) (certainty ?cl))
  =>
  (assert (attribute (name update-location-cf) (value ?l) (certainty (/ (+ ?c ?cl) 3))))
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
  ?lc <- (attribute (name location-certainty) (value ?l) (certainty ?cl))
  (attribute (name regions) (value $?rgs) (certainty ?cr))
  (or 
    (test (subsetp (create$ ?region) (create$ ?rgs)))
    (test (= (length$ ?rgs) 0))
  )
  (attribute (name number-locations) (value ?nl) (certainty ?clnl))
  =>
  (assert (attribute (name trip-locations) (value ?nl 0 ?l) (certainty (/ (+ ?cl ?clnl) 2))))
)

(defrule GENERATE-PATH::expand-path
  ?l1 <- (location (?lat1) (?long1))
  (attribute (name trip-locations) (value ?nl ?distance ?l1) (certainty ?cl))
  ?l2 <- (location (?lat2) (?long2))
  (attribute (name location-certainty) (value ?l2) (certainty ?lc2))
  (test (> ?nl 0))
  (test (neq ?l1 ?l2))
  =>
  (assert (attribute (name trip-locations) (value (- ?nl 1) ?distance ?l1 ?l2) (certainty (+ ?cl ?lc2))))
)

 
;;******************
;; The RULES module
;;******************

(defmodule RULES (import MAIN ?ALL) (export ?ALL))

(deftemplate RULES::rule
  (slot certainty (default 100.0))
  (multislot if)
  (multislot then))

(defrule RULES::throw-away-ands-in-antecedent
  ?f <- (rule (if and $?rest))
  =>
  (modify ?f (if ?rest)))

(defrule RULES::throw-away-ands-in-consequent
  ?f <- (rule (then and $?rest))
  =>
  (modify ?f (then ?rest)))

(defrule RULES::remove-is-condition-when-satisfied
  ?f <- (rule (certainty ?c1) 
              (if ?attribute is ?value $?rest))
  (attribute (name ?attribute) 
             (value ?value) 
             (certainty ?c2))
  =>
  (modify ?f (certainty (min ?c1 ?c2)) (if ?rest)))

(defrule RULES::remove-is-not-condition-when-satisfied
  ?f <- (rule (certainty ?c1) 
              (if ?attribute is-not ?value $?rest))
  (attribute (name ?attribute) (value ~?value) (certainty ?c2))
  =>
  (modify ?f (certainty (min ?c1 ?c2)) (if ?rest)))

(defrule RULES::perform-rule-consequent-with-certainty
  ?f <- (rule (certainty ?c1) 
              (if) 
              (then ?attribute is ?value with certainty ?c2 $?rest))
  =>
  (modify ?f (then ?rest))
  (assert (attribute (name ?attribute) 
                     (value ?value)
                     (certainty (/ (* ?c1 ?c2) 100)))))

(defrule RULES::perform-rule-consequent-without-certainty
  ?f <- (rule (certainty ?c1)
              (if)
              (then ?attribute is ?value $?rest))
  (test (or (eq (length$ ?rest) 0)
            (neq (nth$ 1 ?rest) with)))
  =>
  (modify ?f (then ?rest))
  (assert (attribute (name ?attribute) (value ?value) (certainty ?c1))))

;;*******************************
;;* CHOOSE WINE QUALITIES RULES *
;;*******************************

(defmodule CHOOSE-QUALITIES (import RULES ?ALL)
                            (import QUESTIONS ?ALL)
                            (import MAIN ?ALL))

(defrule CHOOSE-QUALITIES::startit => (focus RULES))

(deffacts the-wine-rules

  ; Rules for picking the best body

  (rule (if has-sauce is yes and 
            sauce is spicy)
        (then best-body is full))

  (rule (if tastiness is delicate)
        (then best-body is light))

  (rule (if tastiness is average)
        (then best-body is light with certainty 30 and
              best-body is medium with certainty 60 and
              best-body is full with certainty 30))

  (rule (if tastiness is strong)
        (then best-body is medium with certainty 40 and
              best-body is full with certainty 80))

  (rule (if has-sauce is yes and
            sauce is cream)
        (then best-body is medium with certainty 40 and
              best-body is full with certainty 60))

  (rule (if preferred-body is full)
        (then best-body is full with certainty 40))

  (rule (if preferred-body is medium)
        (then best-body is medium with certainty 40))

  (rule (if preferred-body is light) 
        (then best-body is light with certainty 40))

  (rule (if preferred-body is light and
            best-body is full)
        (then best-body is medium))

  (rule (if preferred-body is full and
            best-body is light)
        (then best-body is medium))

  (rule (if preferred-body is unknown) 
        (then best-body is light with certainty 20 and
              best-body is medium with certainty 20 and
              best-body is full with certainty 20))

  ; Rules for picking the best color

  (rule (if main-component is meat)
        (then best-color is red with certainty 90))

  (rule (if main-component is poultry and
            has-turkey is no)
        (then best-color is white with certainty 90 and
              best-color is red with certainty 30))

  (rule (if main-component is poultry and
            has-turkey is yes)
        (then best-color is red with certainty 80 and
              best-color is white with certainty 50))

  (rule (if main-component is fish)
        (then best-color is white))

  (rule (if main-component is-not fish and
            has-sauce is yes and
            sauce is tomato)
        (then best-color is red))

  (rule (if has-sauce is yes and
            sauce is cream)
        (then best-color is white with certainty 40))
                   
  (rule (if preferred-color is red)
        (then best-color is red with certainty 40))

  (rule (if preferred-color is white)
        (then best-color is white with certainty 40))

  (rule (if preferred-color is unknown)
        (then best-color is red with certainty 20 and
              best-color is white with certainty 20))
  
  ; Rules for picking the best sweetness

  (rule (if has-sauce is yes and
            sauce is sweet)
        (then best-sweetness is sweet with certainty 90 and
              best-sweetness is medium with certainty 40))

  (rule (if preferred-sweetness is dry)
        (then best-sweetness is dry with certainty 40))

  (rule (if preferred-sweetness is medium)
        (then best-sweetness is medium with certainty 40))

  (rule (if preferred-sweetness is sweet)
        (then best-sweetness is sweet with certainty 40))

  (rule (if best-sweetness is sweet and
            preferred-sweetness is dry)
        (then best-sweetness is medium))

  (rule (if best-sweetness is dry and
            preferred-sweetness is sweet) 
        (then best-sweetness is medium))

  (rule (if preferred-sweetness is unknown)
        (then best-sweetness is dry with certainty 20 and
              best-sweetness is medium with certainty 20 and
              best-sweetness is sweet with certainty 20))

)

;;************************
;;* WINE SELECTION RULES *
;;************************

(defmodule WINES (import MAIN ?ALL))

(deffacts any-attributes
  (attribute (name best-color) (value any))
  (attribute (name best-body) (value any))
  (attribute (name best-sweetness) (value any)))

(deftemplate WINES::wine
  (slot name (default ?NONE))
  (multislot color (default any))
  (multislot body (default any))
  (multislot sweetness (default any)))

(deffacts WINES::the-wine-list 
  (wine (name Gamay) (color red) (body medium) (sweetness medium sweet))
  (wine (name Chablis) (color white) (body light) (sweetness dry))
  (wine (name Sauvignon-Blanc) (color white) (body medium) (sweetness dry))
  (wine (name Chardonnay) (color white) (body medium full) (sweetness medium dry))
  (wine (name Soave) (color white) (body light) (sweetness medium dry))
  (wine (name Riesling) (color white) (body light medium) (sweetness medium sweet))
  (wine (name Geverztraminer) (color white) (body full))
  (wine (name Chenin-Blanc) (color white) (body light) (sweetness medium sweet))
  (wine (name Valpolicella) (color red) (body light))
  (wine (name Cabernet-Sauvignon) (color red) (sweetness dry medium))
  (wine (name Zinfandel) (color red) (sweetness dry medium))
  (wine (name Pinot-Noir) (color red) (body medium) (sweetness medium))
  (wine (name Burgundy) (color red) (body full))
  (wine (name Zinfandel) (color red) (sweetness dry medium)))
  
(defrule WINES::generate-wines
  (wine (name ?name)
        (color $? ?c $?)
        (body $? ?b $?)
        (sweetness $? ?s $?))
  (attribute (name best-color) (value ?c) (certainty ?certainty-1))
  (attribute (name best-body) (value ?b) (certainty ?certainty-2))
  (attribute (name best-sweetness) (value ?s) (certainty ?certainty-3))
  =>
  (assert (attribute (name wine) (value ?name)
                     (certainty (min ?certainty-1 ?certainty-2 ?certainty-3)))))

;;*****************************
;;* PRINT SELECTED WINE RULES *
;;*****************************

(defmodule PRINT-RESULTS (import MAIN ?ALL))

(defrule PRINT-RESULTS::header ""
   (declare (salience 10))
   =>
   (printout t t)
   (printout t "        SELECTED WINES" t t)
   (printout t " WINE                  CERTAINTY" t)
   (printout t " -------------------------------" t)
   (assert (phase print-wines)))

(defrule PRINT-RESULTS::print-wine ""
  ?rem <- (attribute (name wine) (value ?name) (certainty ?per))		  
  (not (attribute (name wine) (certainty ?per1&:(> ?per1 ?per))))
  =>
  (retract ?rem)
  (format t " %-24s %2d%%%n" ?name ?per))

(defrule PRINT-RESULTS::remove-poor-wine-choices ""
  ?rem <- (attribute (name wine) (certainty ?per&:(< ?per 20)))
  =>
  (retract ?rem))

(defrule PRINT-RESULTS::end-spaces ""
   (not (attribute (name wine)))
   =>
   (printout t t))




