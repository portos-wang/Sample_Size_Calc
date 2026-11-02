# kappa test rejects equal kappas and invalid marginals

    Code
      calculate("kappa", "test", "proportion", pi1 = 0.5, pi2 = 0.5, kappa1 = 0.7,
        kappa2 = 0.7)
    Condition
      Error in `calculate_kappa()`:
      ! `kappa2` (alternative kappa) must differ from kappa1 and be in (0, 1).

---

    Code
      calculate("kappa", "estimate", "proportion", pi1 = 0.5, pi2 = 0.5, kappa = 0.7,
        d = 0)
    Condition
      Error in `calculate_kappa()`:
      ! `d` (CI half-width) must be in (0, 1).

