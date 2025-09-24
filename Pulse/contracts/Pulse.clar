;; FitChain Smart Contract: Decentralized Fitness Tracking Community
;; A blockchain platform for fitness achievements and wellness goals

(define-constant fitness-coach tx-sender)
(define-constant err-coach-only (err u100))
(define-constant err-athlete-missing (err u101))
(define-constant err-no-access (err u102))
(define-constant err-athlete-exists (err u103))
(define-constant err-no-stats (err u104))
(define-constant err-invalid-exercise (err u105))
(define-constant err-bad-value (err u106))

;; Fitness activity types
(define-data-var fitness-types (list 3 (string-ascii 24)) (list "workout" "challenge" "wellness"))

;; Athlete tracking system
(define-map athlete-stats 
    principal 
    {
        fitness-score: uint,
        workouts-done: uint,
        challenges-won: uint,
        last-session: uint,
        wellness-goals: uint
    }
)
(define-map exercise-points
    {exercise: (string-ascii 24)}
    {calories: uint}
)

;; Set default calorie values
(map-set exercise-points {exercise: "workout"} {calories: u10})
(map-set exercise-points {exercise: "challenge"} {calories: u5})
(map-set exercise-points {exercise: "wellness"} {calories: u15})

;; Validation helpers
(define-private (is-valid-exercise (exercise-type (string-ascii 24)))
    (is-some (index-of (var-get fitness-types) exercise-type))
)

;; Public functions
(define-public (join-fitness-community)
    (begin
        (asserts! (is-none (get-athlete-stats tx-sender)) err-athlete-exists)
        (ok (map-set athlete-stats tx-sender {
            fitness-score: u0,
            workouts-done: u0,
            challenges-won: u0,
            last-session: stacks-block-height,
            wellness-goals: u0
        }))
    )
)

(define-public (log-workout)
    (let (
        (stats (unwrap! (get-athlete-stats tx-sender) err-no-stats))
        (cals (get calories (unwrap! (map-get? exercise-points {exercise: "workout"}) err-invalid-exercise)))
    )
    (ok (map-set athlete-stats tx-sender (merge stats {
        fitness-score: (+ (get fitness-score stats) cals),
        workouts-done: (+ (get workouts-done stats) u1),
        last-session: stacks-block-height
    })))
    )
)

(define-public (win-challenge)
    (let (
        (stats (unwrap! (get-athlete-stats tx-sender) err-no-stats))
        (cals (get calories (unwrap! (map-get? exercise-points {exercise: "challenge"}) err-invalid-exercise)))
    )
    (ok (map-set athlete-stats tx-sender (merge stats {
        fitness-score: (+ (get fitness-score stats) cals),
        challenges-won: (+ (get challenges-won stats) u1),
        last-session: stacks-block-height
    })))
    )
)

(define-public (achieve-wellness)
    (let (
        (stats (unwrap! (get-athlete-stats tx-sender) err-no-stats))
        (cals (get calories (unwrap! (map-get? exercise-points {exercise: "wellness"}) err-invalid-exercise)))
    )
    (ok (map-set athlete-stats tx-sender (merge stats {
        fitness-score: (+ (get fitness-score stats) cals),
        wellness-goals: (+ (get wellness-goals stats) u1),
        last-session: stacks-block-height
    })))
    )
)

;; Admin functions
(define-public (modify-exercise-calories (exercise-type (string-ascii 24)) (new-cals uint))
    (let
        (
            (max-cals u1000)
            (validated-cals (if (> new-cals max-cals) max-cals new-cals))
        )
        (begin
            (asserts! (is-eq tx-sender fitness-coach) err-coach-only)
            (asserts! (is-valid-exercise exercise-type) err-invalid-exercise)
            (ok (map-set exercise-points {exercise: exercise-type} {calories: validated-cals}))
        )
    )
)

;; Read-only functions
(define-read-only (get-athlete-stats (athlete principal))
    (map-get? athlete-stats athlete)
)

(define-read-only (get-exercise-calories (exercise-type (string-ascii 24)))
    (map-get? exercise-points {exercise: exercise-type})
)

;; Private helper
(define-private (apply-degrade (base uint) (gap uint))
    (let (
        (degrade-factor (/ gap u1000))
    )
    (if (> degrade-factor u0)
        (/ base degrade-factor)
        base
    ))
)

;; Current fitness level calculation
(define-read-only (get-current-fitness (athlete principal))
    (let (
        (stats (unwrap! (get-athlete-stats athlete) err-athlete-missing))
        (inactive-period (- stacks-block-height (get last-session stats)))
    )
    (ok (apply-degrade (get fitness-score stats) inactive-period))
    )
)