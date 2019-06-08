;;;======================================================
;;;   Planning a Trip: Expert Problem
;;;
;;;   
;;;
;;;======================================================

(defmodule MAIN (export ?ALL))

;;****************
;;* DEFFUNCTIONS *
;;****************

(deffunction MAIN::ask-question (?question ?allowed-values ?domain ?must-answer)
   (printout t ?question)
   (bind ?answer (explode$ (readline)))
   (if (lexemep ?answer) then (bind ?answer (lowcase ?answer)))
   (while (not (or (or (and (subsetp ?answer ?allowed-values) (eq ?must-answer FALSE)) 
                       (and (subsetp ?answer ?allowed-values) (> (length$ ?answer) 0) (eq ?must-answer TRUE))
                    ) 
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
  (declare (salience 10000) (auto-focus TRUE))
  (attribute (name restart))
  =>
  (set-fact-duplication TRUE)
  (focus QUESTIONS LOCATIONS GENERATE-PATH OPTMIZE-PATH HOTEL TRIP TRIP-COST TRIP-SELECTION PRINT-RESULTS FINAL-QUESTIONS)
)

(defrule MAIN::combine-positive-certainties
  (declare (salience 100) (auto-focus TRUE))
  ?rem1 <- (attribute (name ?rel) (value ?val) (certainty ?per1&:(>= ?per1 0)))
  ?rem2 <- (attribute (name ?rel) (value ?val) (certainty ?per2&:(>= ?per2 0)))
  (test (neq ?rem1 ?rem2))
  =>
  (retract ?rem1)
  (modify ?rem2 (certainty (/ (- (* 100 (+ ?per1 ?per2)) (* ?per1 ?per2)) 100))))

(defrule MAIN::combine-negative-certainties
  (declare (salience 100) (auto-focus TRUE))
  ?rem1 <- (attribute (name ?rel) (value ?val) (certainty ?per1&:(< ?per1 0)))
  ?rem2 <- (attribute (name ?rel) (value ?val) (certainty ?per2&:(< ?per2 0)))
  (test (neq ?rem1 ?rem2))
  =>
  (retract ?rem1)
  (modify ?rem2 (certainty (/ (+ (* 100 (+ ?per1 ?per2)) (* ?per1 ?per2)) 100))))

(defrule MAIN::combine-opposite-certainties
  (declare (salience 100)
           (auto-focus TRUE))
  ?rem1 <- (attribute (name ?rel) (value ?val) (certainty ?per1))
  ?rem2 <- (attribute (name ?rel) (value ?val) (certainty ?per2))
  (test (neq ?rem1 ?rem2))
  (test (< (* ?per1 ?per2) 0))
  =>
  (retract ?rem1)
  (modify ?rem2 (certainty (* 100 (/ (+ ?per1 ?per2) (- 100 (min (abs ?per1) (abs ?per2)))))))
)

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

(deffacts MAIN::restart-fact
    (attribute (name restart))
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
   (slot must-answer (default FALSE))
   (multislot precursors (default ?DERIVE)))
   
(defrule QUESTIONS::ask-a-question
   (attribute (name restart))
   ?f <- (question (already-asked FALSE)
                   (precursors)
                   (the-question ?the-question)
                   (attribute ?the-attribute)
                   (must-answer ?must-answer)
                   (valid-answers-domain ?domain)
                   (valid-answers $?valid-answers))
   =>
   (assert (attribute-intention (name ?the-attribute)
                      (value (ask-question ?the-question ?valid-answers ?domain ?must-answer)))))


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

(defrule QUESTIONS::precursor-is-cf-satisfied
   ?f <- (question (already-asked FALSE)
                   (precursors ?name is-cf ?value $?rest))
         (attribute (name ?name) (certainty ?cf&:(= ?cf ?value)))
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
            (valid-answers balneare montano lacustre naturalistico termale culturale religioso sportivo enogastronomico))
  (question (attribute regions)
            (the-question "Quali sono le regioni in cui vuole effettuare il viaggio? ")
            (valid-answers piemonte liguria valle_daosta lombardia emilia_romagna))
  (question (attribute number-locations)
            (the-question "Quante località si vuole visitare durante il viaggio? ")
            (valid-answers)
            (valid-answers-domain "positive-integer"))
  (question (attribute max-km)
            (the-question "Quanti kilometri massimi vuole percorrere durante il viaggio? ")
            (valid-answers)
            (valid-answers-domain "positive-integer"))
  (question (attribute hotel-stars)
            (the-question "Quante stelle deve avere l'hotel? ")
            (valid-answers 1 2 3 4))
  (question (attribute budget)
            (the-question "Quanto si desidera spendere al massimo? ")
            (valid-answers)
            (valid-answers-domain "positive-integer"))
  (question (attribute n-people)
            (the-question "Quante persone desiderano partecipare? ")
            (valid-answers)
            (valid-answers-domain "positive-integer"))
  (question (attribute group-allow-double-room)
            (the-question "Le persone sono disponibili a dormire in camere doppie? ")
            (precursors n-people is-cf 100)
            (valid-answers TRUE FALSE))

;;* DEFAULTS      
  (attribute (name regions) (value) (certainty 50.0))
  (attribute (name tourism-type) (value) (certainty 50.0))
  (attribute (name number-locations) (value 3) (certainty 50.0))
  (attribute (name n-day) (value 5) (certainty 50.0))
  (attribute (name n-people) (value 2) (certainty 50.0))
  (attribute (name group-allow-double-room) (value TRUE) (certainty 50.0))
  (attribute (name max-km) (value 100) (certainty 50.0))
  (attribute (name hotel-stars) (value 1 2 3 4) (certainty 50.0))
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
  (if (subsetp (create$ ?loc-region) (create$ ?pref-region)) then (bind ?fit (+ ?fit 15)))
  ?fit
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
  (location (name "Finale Ligure")
            (region liguria)
            (lat 44.169072)
            (long 8.343536)
            (tourism-type balneare 5.0 naturalistico 3.8 montano 3.0)
  )
  (location (name "Sanremo")
            (region liguria)
            (lat 43.821414)
            (long 7.786561)
            (tourism-type balneare 3.0 culturale 4.2 enogastronomico 4.7)
  )
  (location (name "Alassio")
            (region liguria)
            (lat 44.007917)
            (long 8.173044)
            (tourism-type balneare 5.0 enogastronomico 4.3)
  )
  (location (name "Laigueglia")
            (region liguria)
            (lat 43.974511)
            (long 8.158311)
            (tourism-type balneare 4.0)
  )
  (location (name "Torino")
            (region piemonte)
            (lat 45.066667)
            (long 7.7)
            (tourism-type culturale 4.8 enogastronomico 4.7)
  )
)

(defrule LOCATIONS::update-tourist-type-fit
  (declare (salience 100))
  (attribute (name tourism-type) (value $? ?val $?) (certainty ?c))
  ?l <- (location (name ?name) (region ?region) (tourism-type $? ?val&:(lexemep ?val) ?rank&:(floatp ?rank) $?))
  =>
  (assert (specification (name location-fit) (subject ?l) (value ?rank)))
)

(defrule LOCATIONS::update-region-fit
  (declare (salience 100))
  (attribute (name regions) (value $? ?val $?) (certainty ?c))
  ?l <- (location (name ?name) (region ?val))
  =>
  (assert (specification (name location-fit) (subject ?l) (value 15.0))) ; like a city with 3 matching turism type, but not in the selected region
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
  (test (< (+ ?distance (calculate-distance ?lat1 ?long1 ?lat2 ?long2)) (* ?max-km 1.2)))
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

(defrule OPTMIZE-PATH::delete-path-counter
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
         (city "Finale Ligure")
         (region liguria)
         (rooms 30)
         (stars 3)
  )
  (hotel (name "lido mare")
         (city "Finale Ligure")
         (region liguria)
         (rooms 40)
         (stars 4)
  )
  (hotel (name "lido resort")
         (city "Alassio")
         (region liguria)
         (rooms 30)
         (stars 4)
  )
  (hotel (name "lido resort")
         (city "Laigueglia")
         (region liguria)
         (rooms 30)
         (stars 4)
  )
  (hotel (name "lido resort")
         (city "Torino")
         (region piemonte)
         (rooms 30)
         (stars 3)
  )
  (hotel (name "lido resort")
         (city "Sanremo")
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
  (not (specification (name hotel-assignment) (subject ?id) (value ?l $?))) ; not already assigned
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
   (slot cost (default 0.0) (type FLOAT))
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

(defrule TRIP::optimize-trip-left-to-right
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

(defrule TRIP::optimize-trip-right-to-left
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
;;* TRIP CALCULATE PRICE *
;;************************

(defmodule TRIP-COST (import MAIN ?ALL) (import HOTEL ?ALL) (import TRIP ?ALL) (export ?ALL))

(defrule TRIP-COST::calculate-path-price
  (declare (salience 100))
  (attribute (name n-people) (value ?np))
  ?h <- (hotel (stars ?stars))
  ?t <- (trip (id ?id) (trip-plan $? ?l ?h ?d $?) (cost ?cost&:(= ?cost 0.0)))
  (attribute (name group-allow-double-room) (value ?allow-double))
  =>
  (assert (specification (name hotel-price) (subject ?t) (value (float (* (* (room-price ?stars) ?d) (rooms-number ?np ?allow-double))))))
)

(defrule TRIP-COST::modify-trip-path-price
  ?t <- (trip (cost ?cost))
  ?s <- (specification (name hotel-price) (subject ?t) (value ?trip-cost))
  =>
  (modify ?t (cost ?trip-cost))
  (retract ?s)
)

;;************************
;;* TRIP SELECTION *
;;************************

(defmodule TRIP-SELECTION (import MAIN ?ALL) (import LOCATIONS ?ALL) (import HOTEL ?ALL) (import TRIP ?ALL) (export ?ALL))

(deffunction TRIP-SELECTION::bounded-price-to-cf (?price ?max-price)
   (bind ?g (/ ?price ?max-price))
   (if (> ?g 1) 
   then (bind ?cf (max (* -1 (/ (** 2 ?g) 4)) -1)) ; when ?price is 2*?max-price cf is -100   ;if ?price > ?max-price use exponential
   else (bind ?cf (- 1 ?g)) ; when ?price = ?max-price CF = 0    ;if ?price <= ?max-price use linear increasing CF
   )
   (* ?cf 100)
)

(deffunction TRIP-SELECTION::price-to-cf (?price ?estimate)
   (bind ?cf (max -1 (- 1 (/ ?price ?estimate)))) ; linear CF using an estimate medium price; CF is 0 for estimate price, < 0 for price more than estimate 
   (* ?cf 100)
)

(deffunction LOCATIONS::distance-to-cf (?distance ?max-distance)
   (bind ?cf (- 1 (/ ?distance ?max-distance)))
   (* ?cf 100)
)

(deffunction TRIP-SELECTION::default-to-denominator (?cfs)
   (bind ?cf (max (expand$ (create$ ?cfs))))
   (if (< ?cf 100) 
   then (bind ?d 2)
   else (bind ?d 1)
   )
   ?d
)

(defrule TRIP-SELECTION::generate-pathfit
  (declare (salience 100))
  ?t <- (trip (trip-plan $? ?l ?h ?d $?))
  (specification (name location-fit) (subject ?l) (value ?fit))
  =>
  (assert (specification (name path-fit) (subject ?t) (value ?fit)))
)

(defrule TRIP-SELECTION::generate-path-fit-certainty
  ?s <- (specification (name path-fit) (subject ?t) (value ?fit))
  (attribute (name number-locations) (value ?nl) (certainty ?cnl))
  (attribute (name tourism-type) (value $?vals) (certainty ?ctt))
  =>
  (assert (attribute (name path-confidence) (value ?t) (certainty (* (/ ?fit (* (+ (* 5.0 (length$ ?vals)) 15.0) (* ?nl 1.5))) 100))))
  (retract ?s)
)

(defrule TRIP-SELECTION::generate-path-price-bounded-certainty
  ?t <- (trip (cost ?price))
  (attribute (name budget) (value ?max-price))
  =>
  (assert (attribute (name path-confidence) (value ?t) (certainty (bounded-price-to-cf ?price ?max-price))))
)

(defrule TRIP-SELECTION::generate-path-price-certainty
  ?t <- (trip (cost ?price))
  (attribute (name n-day) (value ?day))
  (attribute (name n-people) (value ?np))
  (attribute (name group-allow-double-room) (value ?allow-double))
  =>
  (assert (attribute (name path-confidence) 
  (value ?t) 
  (certainty (price-to-cf ?price 
                          (* (* (room-price 3) ?day) (rooms-number ?np ?allow-double)))))) ; price estimation
)

(defrule TRIP-SELECTION::generate-trip-distance-certainty
  ?t <- (trip (moving-km ?km))
  (attribute (name max-km) (value ?max-km) (certainty ?c-km))
  =>
  (assert (attribute (name path-confidence) (value ?t) (certainty (/ (distance-to-cf ?km ?max-km) (default-to-denominator ?c-km)))))
)

(defrule TRIP-SELECTION::generate-trip-hotel-incorrect-count
  (declare (salience 100))
  (attribute (name hotel-stars) (value $?stars))
  (test (< (length$ ?stars) 4))
  ?h <- (hotel (stars ?s-h))
  ?t <- (trip (trip-plan $? ?l ?h ?d $?))
  (test (not (subsetp (create$ ?s-h) (create$ ?stars))))
  =>
  (assert (specification (name path-out-of-range-hotel) (subject ?t) (value 1.0)))
)

(defrule TRIP-SELECTION::generate-trip-hotel-certainty
  ?s <- (specification (name path-out-of-range-hotel) (subject ?t) (value ?ih))
  (attribute (name number-locations) (value ?nl))
  =>
  (assert (attribute (name path-confidence) (value ?t) (certainty (* (/ ?ih ?nl) -60))))
  (retract ?s)
)

;;************************
;;* PRINT RESULTS *
;;************************

(defmodule PRINT-RESULTS (import MAIN ?ALL) (import LOCATIONS ?ALL) (import HOTEL ?ALL) (import TRIP ?ALL) (export ?ALL))

(deffunction PRINT-RESULTS::print-formatted-trip (?trip)
  (bind ?city nil)
  (bind ?hotel nil)
  (bind ?stars -1)
  (bind ?days -1)
  (progn$ 
    (?field (create$ ?trip))
    (if (eq ?city nil) 
      then (bind ?city ?field)
      else 
        (if (eq ?hotel nil)
        then (bind ?hotel ?field)
        else
          (if (= ?stars -1)
          then (bind ?stars ?field)
          else
            (if (= ?days -1)
            then 
              (bind ?days ?field)
              (printout t "      City: " ?city crlf "      Hotel: " ?hotel " (" ?stars " stars)" crlf "      Permanence: " ?days)
              (if (> ?days 1) then (printout t " days" crlf crlf) else (printout t " day" crlf crlf))
              (bind ?city nil)
              (bind ?hotel nil)
              (bind ?stars -1)
              (bind ?days -1)
            )
          )
        )
    )
  )
)

(deffacts PRINT-RESULTS::print-fact
  (attribute (name max-print) (value 3))
  (attribute (name printed) (value 0))
)

(defrule PRINT-RESULTS::init-printable-solution
  ?t <- (trip (trip-plan ?l ?h ?d $?rest) (moving-km ?km) (cost ?cost))
  (attribute (name path-confidence) (value ?t) (certainty ?cf))
  (not (attribute (name path-confidence) (value ?t2) (certainty ?cf2&:(> ?cf2 ?cf))))
  (not (specification (name printable-trip) (subject ?t)))
  (attribute (name max-print) (value ?max-print))
  ?p <- (attribute (name printed) (value ?printed&:(< ?printed ?max-print)))
  =>
  (assert (specification (name printable-trip) (subject ?t) (value)))
  (modify ?p (value (+ ?printed 1)))
)

(defrule PRINT-RESULTS::generate-printable-solution
  ?l <- (location (name ?l-name) (region ?l-region))
  ?h <- (hotel (name ?h-name) (stars ?h-stars))
  ?t <- (trip (trip-plan ?l ?h ?d $?rest) (moving-km ?km) (cost ?cost))
  ?print <- (specification (name printable-trip) (subject ?t) (value $?prec))
  =>
  (modify ?t (trip-plan ?rest))
  (modify ?print (value ?prec ?l-name ?h-name ?h-stars ?d))
)

(defrule PRINT-RESULTS::print-printable-solution
  (declare (salience -100))
  ?t <- (trip (moving-km ?km) (cost ?cost))
  ?tcf <- (attribute (name path-confidence) (value ?t) (certainty ?cf))
  ?print <- (specification (name printable-trip) (subject ?t) (value $?to-print))
  (attribute (name n-day) (value ?nd))
  (attribute (name n-people) (value ?np))
  (attribute (name group-allow-double-room) (value ?allow-double))
  (attribute (name number-locations) (value ?nl))
  =>
  (printout t crlf)
  (printout t "Trip suggestion (with certainty " (round ?cf) ")" crlf)
  (printout t " - Journey length: " ?nd " days" crlf)
  (printout t " - Number of locations: " ?nl " city" crlf)
  (printout t " - Number of people: " ?np crlf)
  (printout t " - Total journey: " (round ?km) " km" crlf)
  (printout t " - Hotels cost: " (round ?cost) "€")
  (if (eq ?allow-double TRUE) then (printout t " (with double rooms)" crlf) else (printout t " (with single rooms)" crlf))
  (printout t " - Journey: " crlf)
  (print-formatted-trip ?to-print)
  (retract ?print)
  (retract ?t)
  (retract ?tcf)
)

;;************************
;;* PRINT RESULTS *
;;************************

(defmodule FINAL-QUESTIONS (import MAIN ?ALL) (import QUESTIONS ?ALL) (import PRINT-RESULTS ?ALL) (export ?ALL))

(defrule FINAL-QUESTIONS::insert-final-question
  (not (attribute (name final-question)))
  =>
  (assert (question (attribute final-question)
          (the-question "Insert -more- for showing other solutions, -affine- to affine the research or -exit-: ")
          (must-answer TRUE)
          (valid-answers more affine exit reset)))
  (focus QUESTIONS FINAL-QUESTIONS)
)

(defrule FINAL-QUESTIONS::show-more-result
  ?fq <- (attribute (name final-question) (value more))
  ?max-p <- (attribute (name max-print) (value ?max-print))
  =>
  (modify ?max-p (value (+ ?max-print 3)))
  (retract ?fq)
  (focus PRINT-RESULTS FINAL-QUESTIONS)
)

(defrule FINAL-QUESTIONS::affine-search
  ?fq <- (attribute (name final-question) (value affine))
  ?rs <- (attribute (name restart))
  =>
  (retract ?fq)
  (retract ?rs) (assert (attribute (name restart)))
)

(defrule FINAL-QUESTIONS::reset-instance
  (attribute (name final-question) (value reset))
  =>
  (reset)
  (run)
)