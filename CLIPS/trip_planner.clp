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

 (deftemplate MAIN::specification
   (slot name)
   (slot subject)
   (multislot value))

(defrule MAIN::start
  (declare (salience 10000))
  =>
  (set-fact-duplication TRUE)
  (focus QUESTIONS LOCATIONS GENERATE-PATH OPTMIZE-PATH HOTEL TRIP TRIP-SELECTION))

(defrule MAIN::combine-certainties ""
  (declare (salience 100)
           (auto-focus TRUE))
  ?rem1 <- (attribute (name ?rel) (value ?val) (certainty ?per1))
  ?rem2 <- (attribute (name ?rel) (value ?val) (certainty ?per2))
  (test (neq ?rem1 ?rem2))
  =>
  (retract ?rem1)
  (modify ?rem2 (certainty (/ (- (* 100 (+ ?per1 ?per2)) (* ?per1 ?per2)) 100))))

(defrule MAIN::merge-specification-fit
    (declare (salience 100)
              (auto-focus TRUE))
    ?s1 <- (specification (name ?n) (subject ?l) (value ?fit1&:(floatp ?fit1)))
    ?s2 <- (specification (name ?n) (subject ?l) (value ?fit2&:(floatp ?fit2)))
    (test (neq ?s1 ?s2))
    =>
    (modify ?s1 (value (+ ?fit1 ?fit2)))
    (retract ?s2)
)
  
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
  (attribute (name tourism-type) (value) (certainty 50.0))
  (attribute (name number-locations) (value 3) (certainty 50.0))
  (attribute (name n-day) (value 15) (certainty 50.0))
  (attribute (name n-people) (value 2) (certainty 50.0))
  (attribute (name max-km) (value 100) (certainty 50.0))
  (attribute (name hotel-stars) (value 1 2 3 4) (certainty 50.0))
  (attribute (name group-allow-double-room) (value TRUE) (certainty 50.0))
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

(deffunction LOCATIONS::location-fit (?loc-turism-type ?loc-region ?pref-turism-type ?pref-region)
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
  (if (subsetp (create$ ?loc-region) (create$ ?pref-region)) then (bind ?fit (+ ?fit 20)))
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

(defrule LOCATIONS::update-tourist-type-fit
  (declare (salience 1000))
  (attribute (name tourism-type) (value $? ?val $?) (certainty ?c))
  ?l <- (location (name ?name) (region ?region) (tourism-type $? ?val&:(lexemep ?val) ?rank&:(floatp ?rank) $?))
  =>
  (assert (specification (name location-fit) (subject ?l) (value ?rank)))
)

(defrule LOCATIONS::update-region-fit
  (declare (salience 1000))
  (attribute (name regions) (value $? ?val $?) (certainty ?c))
  ?l <- (location (name ?name) (region ?val))
  =>
  (assert (specification (name location-fit) (subject ?l) (value 20.0))) ; like a city with 4 matching turism type, but not in the selected region
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
  (assert (specification (name trip-locations) (subject (gensym*)) (value ?nl 0 ?l)))
)

(defrule GENERATE-PATH::expand-path
  ?l1 <- (location (lat ?lat1) (long ?long1))
  (specification (name trip-locations) (value ?nl ?distance $?prec ?l1))
  ?l2 <- (location (lat ?lat2) (long ?long2))
  (test (> ?nl 1))
  (test (neq ?l1 ?l2))
  (test (not (subsetp (create$ ?l2) (create$ ?prec))))
  (attribute (name max-km) (value ?max-km))
  (test (< (+ ?distance (calculate-distance ?lat1 ?long1 ?lat2 ?long2)) ?max-km))
  =>
  (assert (specification (name trip-locations) 
                         (subject (gensym*))
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
  ?a <- (specification (name trip-locations) (value ?nlp&:(> ?nlp 1) $?))
  =>
  (retract ?a)
)

(defrule OPTMIZE-PATH::delete-suboptim-path
  (declare (salience 10))
  ?a <- (specification (name trip-locations) (value ?nl ?d1 $?lcs1))
  ?b <- (specification (name trip-locations) (value ?nl ?d2 $?lcs2))
  (test (>= ?d2 ?d1))
  (test (subsetp (create$ ?lcs1) (create$ ?lcs2)))
  (test (neq ?a ?b))
  =>
  (retract ?b)
)

(defrule OPTMIZE-PATH::generate-path-id
  ?a <- (specification (name trip-locations) (subject ?id) (value ?nl&:(integerp ?nl) ?d1 $?lcs1))
  =>
  (retract ?a)
  (assert (specification (name trip-locations-assigmement) (subject ?id) (value ?d1 ?lcs1)))
)

;;*******************
;;* HOTEL
;;*******************


(defmodule HOTEL (import MAIN ?ALL) (import LOCATIONS ?ALL) (export ?ALL))

(deffunction HOTEL::room-price (?stars)
   (bind ?p (+ 50 (* 25 ?stars)))
   ?p
)

(deffunction HOTEL::rooms-number (?people ?allow-double)
   (bind ?p ?people )
   (if (eq ?allow-double TRUE) then (bind ?p (+ (div ?people 2) (mod ?people 2))))
   ?p
)

(deftemplate HOTEL::hotel
   (slot name (default ?NONE))
   (slot city (default ?NONE))
   (slot region (default ?NONE))
   (slot rooms (default ?NONE) (type INTEGER))
   (slot stars (default ?NONE) (type INTEGER) (range 1 4))
)

(deffacts HOTEL::hotels-lists
  (hotel (name "lido resort")
         (city finale-ligure)
         (region liguria)
         (rooms 30)
         (stars 3)
  )
  (hotel (name "lido mare")
         (city finale-ligure)
         (region liguria)
         (rooms 40)
         (stars 4)
  )
  (hotel (name "lido resort")
         (city alassio)
         (region liguria)
         (rooms 30)
         (stars 4)
  )
  (hotel (name "lido resort")
         (city laigueglia)
         (region liguria)
         (rooms 30)
         (stars 4)
  )
  (hotel (name "lido resort")
         (city torino)
         (region piemonte)
         (rooms 30)
         (stars 3)
  )
  (hotel (name "lido resort")
         (city sanremo)
         (region liguria)
         (rooms 30)
         (stars 4)
  )
)

(defrule HOTEL::generate-hotel-assignment
  (declare (salience 100))
  ?l <- (location (name ?city) (region ?region))
  (specification (name trip-locations-assigmement) (subject ?id) (value ?d $? ?l $?))
  (attribute (name n-people) (value ?np))
  (attribute (name group-allow-double-room) (value ?allow-double))
  (attribute (name hotel-stars) (value $?stars))
  ?h1 <- (hotel (city ?city) (region ?region) (stars ?s&:(subsetp (create$ ?s) (create$ ?stars))) (rooms ?a&:(> ?a (rooms-number ?np ?allow-double))))
  (not (hotel (city ?city) (region ?region) (stars ?s2&:(and (< ?s2 ?s) (subsetp (create$ ?s2) (create$ ?stars)))) (rooms ?a2&:(> ?a2 (rooms-number ?np ?allow-double)))))   ; hotel less stars, enough rooms
  (not (hotel (city ?city) (region ?region) (stars ?s2&:(= ?s2 ?s)) (rooms ?a2&:(> ?a2 ?a))))     ; hotel same stars, but higer rooms
  =>
  (assert (specification (name hotel-assignment) (subject ?id) (value ?l ?h1)))
)

(defrule HOTEL::generate-missing-hotel-assignment
  ?l <- (location (name ?city) (region ?region))
  (specification (name trip-locations-assigmement) (subject ?id) (value ?d $? ?l $?))
  (attribute (name n-people) (value ?np))
  (attribute (name hotel-stars) (value $?stars))
  (attribute (name group-allow-double-room) (value ?allow-double))
  ?h1 <- (hotel (city ?city) (region ?region) (stars ?s) (rooms ?a&:(> ?a (rooms-number ?np ?allow-double))))
  (not (specification (name hotel-assignment) (subject ?id) (value ?l ?h1))) ; not already assigned
  (not (hotel (city ?city) (region ?region) (stars ?s2&:(< ?s2 ?s)) (rooms ?a2&:(> ?a2 (rooms-number ?np ?allow-double)))))   ; hotel less stars, enough rooms
  (not (hotel (city ?city) (region ?region) (stars ?s2&:(= ?s2 ?s)) (rooms ?a2&:(> ?a2 ?a))))     ; hotel same stars, but higer rooms
  =>
  (assert (specification (name hotel-assignment) (subject ?id) (value ?l ?h1)))
)


;;*******************
;;* GENERATE TRIP *
;;*******************

(defmodule TRIP (import MAIN ?ALL) (import LOCATIONS ?ALL) (import HOTEL ?ALL) (export ?ALL))

(deftemplate TRIP::trip
   (slot id (default ?NONE))
   (multislot trip-plan (default ?NONE))
   (slot moving-km (default ?NONE) (type FLOAT))
)

(defrule TRIP::generate-trip
  ?tla <- (specification (name trip-locations-assigmement) (subject ?id) (value ?d ?l $?lcs))
  (not (trip (id ?id)))
  ?ha <- (specification (name hotel-assignment) (subject ?id) (value ?l ?h))
  (attribute (name n-day) (value ?day))
  (attribute (name number-locations) (value ?nl))
  =>
  (assert (trip (id ?id) (moving-km ?d) (trip-plan ?l ?h (+ (div ?day ?nl) (mod ?day ?nl)))))
  (if (> (length$ ?lcs) 0)
    then (modify ?tla (subject ?id) (value ?d ?lcs))
    else (retract ?tla)
  )
  (retract ?ha)
)

(defrule TRIP::complete-trip
  ?tla <- (specification (name trip-locations-assigmement) (subject ?id) (value ?d ?l $?lcs))
  ?ha <- (specification (name hotel-assignment) (subject ?id) (value ?l ?h))
  ?trip <- (trip (id ?id) (trip-plan $?plan))
  (attribute (name n-day) (value ?day))
  (attribute (name number-locations) (value ?nl))
  =>
  (modify ?trip (trip-plan ?plan ?l ?h (div ?day ?nl)))
  (if (> (length$ ?lcs) 0)
    then (modify ?tla (subject ?id) (value ?d ?lcs))
    else (retract ?tla)
  )
  (retract ?ha)
)

(defrule TRIP::optimize-trip-left-to-rigth
  ?h1 <- (hotel (stars ?stars-h1))
  ?h2 <- (hotel (stars ?stars-h2))
  ?l1 <- (location (region ?r1) (tourism-type $?turism-t-1))
  ?l2 <- (location (region ?r2) (tourism-type $?turism-t-2))
  (specification (name location-fit) (subject ?l1) (value ?fit-l1))
  (specification (name location-fit) (subject ?l2) (value ?fit-l2))
  ?trip <- (trip (trip-plan $?rbegin ?l1 ?h1 ?d1 $?rmiddle ?l2 ?h2 ?d2 $?rend))
  (attribute (name n-day) (value ?day))
  (attribute (name number-locations) (value ?nl))
  (test (> ?d1 (div ?day (+ 1 ?nl))))
  (attribute (name tourism-type) (value $?pref-types))
  (attribute (name regions) (value $?pref-regions))
  (test (or (and (< ?fit-l1 ?fit-l2)
                 (>= 
                    (room-price ?stars-h1)
                    (room-price ?stars-h2)
                 )
            )
            (and (= ?fit-l1 ?fit-l2)
                (> 
                    (room-price ?stars-h1)
                    (room-price ?stars-h2)
                )
            )
        )
  )
  =>
  (modify ?trip (trip-plan ?rbegin ?l1 ?h1 (- ?d1 1) ?rmiddle ?l2 ?h2 (+ ?d2 1) ?rend))
)

(defrule TRIP::optimize-trip-rigth-to-left
  ?h1 <- (hotel (stars ?stars-h1))
  ?h2 <- (hotel (stars ?stars-h2))
  ?l1 <- (location (region ?r1) (tourism-type $?turism-t-1))
  ?l2 <- (location (region ?r2) (tourism-type $?turism-t-2))
  (specification (name location-fit) (subject ?l1) (value ?fit-l1))
  (specification (name location-fit) (subject ?l2) (value ?fit-l2))
  ?trip <- (trip (trip-plan $?rbegin ?l1 ?h1 ?d1 $?rmiddle ?l2 ?h2 ?d2 $?rend))
  (attribute (name n-day) (value ?day))
  (attribute (name number-locations) (value ?nl))
  (test (> ?d2 (div ?day (+ 1 ?nl))))
  (attribute (name tourism-type) (value $?pref-types))
  (attribute (name regions) (value $?pref-regions))
  (test (or (and (< ?fit-l2 ?fit-l1)
                (>= 
                    (room-price ?stars-h2)
                    (room-price ?stars-h1)
                )
            )
            (and (= ?fit-l2 ?fit-l1)
                 (> 
                    (room-price ?stars-h2)
                    (room-price ?stars-h1)
                 )
            )
        )
  )
  =>
  (modify ?trip (trip-plan ?rbegin ?l1 ?h1 (+ ?d1 1) ?rmiddle ?l2 ?h2 (- ?d2 1) ?rend))
)

;;************************
;;* TRIP SELECTION *
;;************************

(defmodule TRIP-SELECTION (import MAIN ?ALL) (import LOCATIONS ?ALL) (import HOTEL ?ALL) (import TRIP ?ALL) (export ?ALL))


(defrule TRIP-SELECTION::generate-pathfit
  (declare (salience 1000))
  (trip (id ?id) (trip-plan $? ?l ?h ?d $?))
  (specification (name location-fit) (subject ?l) (value ?fit))
  =>
  (assert (specification (name path-fit) (subject ?id) (value ?fit)))
)

(defrule TRIP-SELECTION::generate-path-certainty
  (specification (name path-fit) (subject ?id) (value ?fit))
  (attribute (name number-locations) (value ?nl) (certainty ?cnl))
  (attribute (name tourism-type) (value $?vals) (certainty ?ctt))
  =>
  (assert (attribute (name path-confidence) (value ?id) (certainty (* (/ ?fit (* (+ (* 5.0 (length$ ?vals)) 20.0) ?nl)) 100))))
)

