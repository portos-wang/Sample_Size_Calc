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

