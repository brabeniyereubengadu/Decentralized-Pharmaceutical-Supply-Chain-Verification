;; Manufacturer Verification Contract
;; Validates legitimate drug producers

(define-data-var admin principal tx-sender)

;; Manufacturer data structure
(define-map manufacturers
  { id: uint }
  {
    name: (string-ascii 100),
    license-number: (string-ascii 50),
    address: (string-ascii 200),
    is-verified: bool,
    registration-date: uint
  }
)

;; Counter for manufacturer IDs
(define-data-var manufacturer-id-counter uint u0)

;; Check if caller is admin
(define-private (is-admin)
  (is-eq tx-sender (var-get admin))
)

;; Register a new manufacturer (admin only)
(define-public (register-manufacturer (name (string-ascii 100)) (license-number (string-ascii 50)) (address (string-ascii 200)))
  (begin
    (asserts! (is-admin) (err u403))

    (let ((new-id (+ (var-get manufacturer-id-counter) u1)))
      (var-set manufacturer-id-counter new-id)
      (map-set manufacturers
        { id: new-id }
        {
          name: name,
          license-number: license-number,
          address: address,
          is-verified: false,
          registration-date: block-height
        }
      )
      (ok new-id)
    )
  )
)

;; Verify a manufacturer (admin only)
(define-public (verify-manufacturer (id uint))
  (begin
    (asserts! (is-admin) (err u403))

    (match (map-get? manufacturers { id: id })
      manufacturer (begin
        (map-set manufacturers
          { id: id }
          (merge manufacturer { is-verified: true })
        )
        (ok true)
      )
      (err u404)
    )
  )
)

;; Get manufacturer details (public)
(define-read-only (get-manufacturer (id uint))
  (map-get? manufacturers { id: id })
)

;; Check if manufacturer is verified (public)
(define-read-only (is-manufacturer-verified (id uint))
  (match (map-get? manufacturers { id: id })
    manufacturer (get is-verified manufacturer)
    false
  )
)

;; Transfer admin rights (admin only)
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-admin) (err u403))
    (var-set admin new-admin)
    (ok true)
  )
)
