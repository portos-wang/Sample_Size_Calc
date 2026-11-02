# inflate_n rejects invalid dropout

    Code
      inflate_n(100, dropout = 1)
    Condition
      Error in `inflate_n()`:
      ! `dropout` must be a single proportion in [0, 1).
      x You provided 1.

---

    Code
      inflate_n(100, dropout = -0.1)
    Condition
      Error in `inflate_n()`:
      ! `dropout` must be a single proportion in [0, 1).
      x You provided -0.1.

---

    Code
      inflate_n(100, dropout = "10%")
    Condition
      Error in `inflate_n()`:
      ! `dropout` must be a single proportion in [0, 1).
      x You provided "10%".

# design_effect rejects invalid inputs

    Code
      design_effect(0, 0.05)
    Condition
      Error in `design_effect()`:
      ! `cluster_size` must be a single number >= 1.
      x You provided 0.

---

    Code
      design_effect(20, 1)
    Condition
      Error in `design_effect()`:
      ! `icc` must be a single number in [0, 1).
      x You provided 1.

---

    Code
      design_effect(20, -0.1)
    Condition
      Error in `design_effect()`:
      ! `icc` must be a single number in [0, 1).
      x You provided -0.1.

