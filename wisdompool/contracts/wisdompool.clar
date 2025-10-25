;; Wisdom Pool - Decentralized Collective Decision Making & Prediction Market
;; A production-ready smart contract for crowdsourced wisdom with stake-weighted voting

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u1500))
(define-constant err-not-found (err u1501))
(define-constant err-unauthorized (err u1502))
(define-constant err-invalid-amount (err u1503))
(define-constant err-question-closed (err u1504))
(define-constant err-already-voted (err u1505))
(define-constant err-not-finalized (err u1506))
(define-constant err-already-claimed (err u1507))
(define-constant err-voting-active (err u1508))
(define-constant err-no-consensus (err u1509))

;; Minimum stake and voting period
(define-constant min-stake-amount u1000000)
(define-constant min-voting-period u1440)

;; Data Variables
(define-data-var question-nonce uint u0)
(define-data-var total-questions uint u0)
(define-data-var total-staked uint u0)
(define-data-var total-resolved uint u0)

;; Question Structure
(define-map questions
    uint
    {
        creator: principal,
        question: (string-utf8 300),
        option-a: (string-utf8 100),
        option-b: (string-utf8 100),
        option-c: (optional (string-utf8 100)),
        total-stake-a: uint,
        total-stake-b: uint,
        total-stake-c: uint,
        total-voters: uint,
        deadline: uint,
        resolution-block: uint,
        correct-option: (optional (string-ascii 1)),
        status: (string-ascii 20),
        category: (string-ascii 30),
        created-at: uint
    }
)

;; Vote Records
(define-map votes
    { question-id: uint, voter: principal }
    {
        option: (string-ascii 1),
        stake-amount: uint,
        voted-at: uint,
        claimed: bool
    }
)

;; Voter Statistics
(define-map voter-stats
    principal
    {
        total-votes: uint,
        correct-predictions: uint,
        total-staked: uint,
        total-earned: uint,
        accuracy-rate: uint
    }
)

;; Creator tracking
(define-map creator-questions
    { creator: principal, index: uint }
    uint
)

(define-map creator-question-count
    principal
    uint
)

;; Read-Only Functions

(define-read-only (get-question (question-id uint))
    (ok (map-get? questions question-id))
)

(define-read-only (get-vote (question-id uint) (voter principal))
    (ok (map-get? votes { question-id: question-id, voter: voter }))
)

(define-read-only (get-voter-stats (voter principal))
    (ok (map-get? voter-stats voter))
)

(define-read-only (get-creator-question-count (creator principal))
    (ok (default-to u0 (map-get? creator-question-count creator)))
)

(define-read-only (get-creator-question-id (creator principal) (index uint))
    (ok (map-get? creator-questions { creator: creator, index: index }))
)

(define-read-only (get-platform-stats)
    (ok {
        total-questions: (var-get total-questions),
        total-staked: (var-get total-staked),
        total-resolved: (var-get total-resolved)
    })
)

(define-read-only (calculate-payout (question-id uint) (voter principal))
    (let (
        (question (unwrap! (map-get? questions question-id) err-not-found))
        (vote (unwrap! (map-get? votes { question-id: question-id, voter: voter }) err-not-found))
        (correct-option (unwrap! (get correct-option question) err-not-finalized))
        (voter-stake (get stake-amount vote))
        (voter-option (get option vote))
        (total-pool (+ (+ (get total-stake-a question) (get total-stake-b question)) (get total-stake-c question)))
        (winning-pool (if (is-eq correct-option "a")
            (get total-stake-a question)
            (if (is-eq correct-option "b")
                (get total-stake-b question)
                (get total-stake-c question))))
    )
        (if (is-eq voter-option correct-option)
            (ok (/ (* voter-stake total-pool) winning-pool))
            (ok u0)
        )
    )
)

(define-read-only (get-winning-option (question-id uint))
    (let (
        (question (unwrap! (map-get? questions question-id) err-not-found))
        (stake-a (get total-stake-a question))
        (stake-b (get total-stake-b question))
        (stake-c (get total-stake-c question))
    )
        (ok (if (and (> stake-a stake-b) (> stake-a stake-c))
            "a"
            (if (and (> stake-b stake-a) (> stake-b stake-c))
                "b"
                "c"
            )
        ))
    )
)

;; Private Helper Functions

(define-private (add-to-creator-index (creator principal) (question-id uint))
    (let (
        (current-count (default-to u0 (map-get? creator-question-count creator)))
    )
        (map-set creator-questions
            { creator: creator, index: current-count }
            question-id
        )
        (map-set creator-question-count creator (+ current-count u1))
    )
)

(define-private (update-voter-stats-vote (voter principal) (stake uint))
    (let (
        (stats (default-to 
            { total-votes: u0, correct-predictions: u0, total-staked: u0, total-earned: u0, accuracy-rate: u0 }
            (map-get? voter-stats voter)))
    )
        (map-set voter-stats voter
            (merge stats {
                total-votes: (+ (get total-votes stats) u1),
                total-staked: (+ (get total-staked stats) stake)
            })
        )
    )
)

;; Public Functions

;; Create a wisdom question
(define-public (create-question
    (question (string-utf8 300))
    (option-a (string-utf8 100))
    (option-b (string-utf8 100))
    (option-c (optional (string-utf8 100)))
    (voting-period uint)
    (resolution-period uint)
    (category (string-ascii 30)))
    (let (
        (question-id (+ (var-get question-nonce) u1))
        (deadline (+ stacks-block-height voting-period))
        (resolution-block (+ deadline resolution-period))
    )
        (asserts! (> (len question) u0) err-invalid-amount)
        (asserts! (> (len option-a) u0) err-invalid-amount)
        (asserts! (> (len option-b) u0) err-invalid-amount)
        (asserts! (>= voting-period min-voting-period) err-invalid-amount)
        (asserts! (> resolution-period u0) err-invalid-amount)
        
        (map-set questions question-id {
            creator: tx-sender,
            question: question,
            option-a: option-a,
            option-b: option-b,
            option-c: option-c,
            total-stake-a: u0,
            total-stake-b: u0,
            total-stake-c: u0,
            total-voters: u0,
            deadline: deadline,
            resolution-block: resolution-block,
            correct-option: none,
            status: "active",
            category: category,
            created-at: stacks-block-height
        })
        
        (add-to-creator-index tx-sender question-id)
        
        (var-set question-nonce question-id)
        (var-set total-questions (+ (var-get total-questions) u1))
        
        (ok question-id)
    )
)

;; Cast vote on a question with stake
(define-public (cast-vote
    (question-id uint)
    (option (string-ascii 1))
    (stake-amount uint))
    (let (
        (question (unwrap! (map-get? questions question-id) err-not-found))
        (existing-vote (map-get? votes { question-id: question-id, voter: tx-sender }))
    )
        (asserts! (is-eq (get status question) "active") err-question-closed)
        (asserts! (<= stacks-block-height (get deadline question)) err-question-closed)
        (asserts! (is-none existing-vote) err-already-voted)
        (asserts! (>= stake-amount min-stake-amount) err-invalid-amount)
        (asserts! (or (is-eq option "a") (or (is-eq option "b") (is-eq option "c"))) err-invalid-amount)
        
        ;; Verify option c exists if voting for it
        (if (is-eq option "c")
            (asserts! (is-some (get option-c question)) err-invalid-amount)
            true
        )
        
        ;; Transfer stake to contract
        (try! (stx-transfer? stake-amount tx-sender (as-contract tx-sender)))
        
        ;; Record vote
        (map-set votes
            { question-id: question-id, voter: tx-sender }
            {
                option: option,
                stake-amount: stake-amount,
                voted-at: stacks-block-height,
                claimed: false
            }
        )
        
        ;; Update question stakes
        (map-set questions question-id
            (merge question {
                total-stake-a: (if (is-eq option "a") (+ (get total-stake-a question) stake-amount) (get total-stake-a question)),
                total-stake-b: (if (is-eq option "b") (+ (get total-stake-b question) stake-amount) (get total-stake-b question)),
                total-stake-c: (if (is-eq option "c") (+ (get total-stake-c question) stake-amount) (get total-stake-c question)),
                total-voters: (+ (get total-voters question) u1)
            })
        )
        
        ;; Update voter stats
        (update-voter-stats-vote tx-sender stake-amount)
        
        ;; Update global stats
        (var-set total-staked (+ (var-get total-staked) stake-amount))
        
        (ok true)
    )
)

;; Finalize question based on stake-weighted consensus
(define-public (finalize-question (question-id uint))
    (let (
        (question (unwrap! (map-get? questions question-id) err-not-found))
        (stake-a (get total-stake-a question))
        (stake-b (get total-stake-b question))
        (stake-c (get total-stake-c question))
        (winning-option (unwrap! (get-winning-option question-id) err-no-consensus))
    )
        (asserts! (is-eq (get status question) "active") err-question-closed)
        (asserts! (> stacks-block-height (get deadline question)) err-voting-active)
        
        (map-set questions question-id
            (merge question {
                correct-option: (some winning-option),
                status: "resolved"
            })
        )
        
        (var-set total-resolved (+ (var-get total-resolved) u1))
        
        (ok winning-option)
    )
)

;; Claim winnings
(define-public (claim-winnings (question-id uint))
    (let (
        (question (unwrap! (map-get? questions question-id) err-not-found))
        (vote (unwrap! (map-get? votes { question-id: question-id, voter: tx-sender }) err-not-found))
        (correct-option (unwrap! (get correct-option question) err-not-finalized))
        (voter-option (get option vote))
        (payout (unwrap! (calculate-payout question-id tx-sender) err-invalid-amount))
        (voter-stat (unwrap! (map-get? voter-stats tx-sender) err-not-found))
        (stake-amount (get stake-amount vote))
        (profit (if (> payout stake-amount) (- payout stake-amount) u0))
    )
        (asserts! (is-eq (get status question) "resolved") err-not-finalized)
        (asserts! (not (get claimed vote)) err-already-claimed)
        (asserts! (> payout u0) err-invalid-amount)
        
        ;; Transfer payout
        (try! (as-contract (stx-transfer? payout tx-sender tx-sender)))
        
        ;; Mark as claimed
        (map-set votes
            { question-id: question-id, voter: tx-sender }
            (merge vote { claimed: true })
        )
        
        ;; Update voter stats
        (let (
            (new-correct (+ (get correct-predictions voter-stat) u1))
            (total-votes (get total-votes voter-stat))
            (new-accuracy (/ (* new-correct u100) total-votes))
        )
            (map-set voter-stats tx-sender
                (merge voter-stat {
                    correct-predictions: new-correct,
                    total-earned: (+ (get total-earned voter-stat) profit),
                    accuracy-rate: new-accuracy
                })
            )
        )
        
        (ok payout)
    )
)

;; Claim refund for incorrect vote
(define-public (claim-refund (question-id uint))
    (let (
        (question (unwrap! (map-get? questions question-id) err-not-found))
        (vote (unwrap! (map-get? votes { question-id: question-id, voter: tx-sender }) err-not-found))
        (correct-option (unwrap! (get correct-option question) err-not-finalized))
        (voter-option (get option vote))
    )
        (asserts! (is-eq (get status question) "resolved") err-not-finalized)
        (asserts! (not (get claimed vote)) err-already-claimed)
        (asserts! (not (is-eq voter-option correct-option)) err-invalid-amount)
        
        ;; Mark as claimed (lost stake, no refund)
        (map-set votes
            { question-id: question-id, voter: tx-sender }
            (merge vote { claimed: true })
        )
        
        (ok true)
    )
)

;; Cancel question (creator only, before votes)
(define-public (cancel-question (question-id uint))
    (let (
        (question (unwrap! (map-get? questions question-id) err-not-found))
    )
        (asserts! (is-eq tx-sender (get creator question)) err-unauthorized)
        (asserts! (is-eq (get status question) "active") err-question-closed)
        (asserts! (is-eq (get total-voters question) u0) err-voting-active)
        
        (map-set questions question-id
            (merge question { status: "cancelled" })
        )
        
        (ok true)
    )
)