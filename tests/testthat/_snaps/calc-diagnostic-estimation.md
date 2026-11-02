# screen_required rejects invalid inputs

    Code
      screen_required(0, 0.5)
    Condition
      Error in `screen_required()`:
      ! `n` must be a positive integer number of cases.

---

    Code
      screen_required(100, 1.5)
    Condition
      Error in `screen_required()`:
      ! `prevalence` must be in (0, 1).

---

    Code
      screen_required(100, 0.5, beta = 0)
    Condition
      Error in `screen_required()`:
      ! `beta` must be in (0, 1).

