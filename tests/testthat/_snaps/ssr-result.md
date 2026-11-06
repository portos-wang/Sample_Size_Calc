# result construction rejects a negative count

    Code
      new_sample_size_result("singleMean", "estimate", "mean", "Invalid count",
        legacy = list(n_required = -1L))
    Condition
      Error in `validate_sample_size_result()`:
      ! n_required must be a finite integer at least 1.

# result construction rejects a fractional participant total

    Code
      new_sample_size_result("caseControl", "test", "proportion", "Invalid total",
        legacy = list(cases_needed = 117L, controls_needed = 175L, total_subjects = 292.5))
    Condition
      Error in `validate_sample_size_result()`:
      ! total_subjects must be a finite integer at least 1.

# result validation rejects inconsistent group totals

    Code
      new_sample_size_result("caseControl", "test", "proportion",
        "Inconsistent total", legacy = list(cases_needed = 3L, controls_needed = 4L,
          total_subjects = 8L))
    Condition
      Error in `validate_sample_size_result()`:
      ! total_n must equal the sum of cases_needed and controls_needed.

# mutation cannot desynchronize top-level and stored counts

    Code
      validate_sample_size_result(res)
    Condition
      Error in `validate_sample_size_result()`:
      ! Top-level n_required disagrees with the stored result field.

# validate_sample_size_result rejects malformed objects

    Code
      validate_sample_size_result(list(a = 1))
    Condition
      Error in `validate_sample_size_result()`:
      ! `x` must be a <sample_size_result> object.
      x You provided <list>.

---

    Code
      validate_sample_size_result("rct")
    Condition
      Error in `validate_sample_size_result()`:
      ! `x` must be a <sample_size_result> object.
      x You provided <character>.

---

    Code
      validate_sample_size_result(bad)
    Condition
      Error in `validate_sample_size_result()`:
      ! roles must be a character vector.
      x You provided <numeric>.

