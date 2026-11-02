# steppedWedge rejects zero theta and invalid cluster allocation

    Code
      calculate("steppedWedge", "test", "mean", theta = 0, tau2 = 0.01, sigma2_ind = 1,
        m = 20, n_clusters = 24, clusters_per_step = 4)
    Condition
      Error in `calculate_stepped_wedge()`:
      ! `theta` must be a non-zero treatment effect on the additive scale.

---

    Code
      calculate("steppedWedge", "test", "mean", theta = -0.1, tau2 = 0.01,
        sigma2_ind = 1, m = 20, n_clusters = 25, clusters_per_step = 4)
    Condition
      Error in `calculate_stepped_wedge()`:
      ! `n_clusters` must be a multiple of `clusters_per_step`.
      x n_clusters = 25, clusters_per_step = 4

