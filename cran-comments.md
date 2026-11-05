## Submission

This is the first submission of SampleSizeCalc to CRAN. Version 3.1.1 follows
earlier development releases outside CRAN. The package name and namespace are
SampleSizeCalc, with the capitalisation shown here.

The package provides a common interface for sample size and power calculations
across clinical trial, observational, diagnostic accuracy, and complex study
designs. Results include formulas, calculation steps, parameter definitions,
and methodological references. Tests include comparisons with published
examples and with presize and PowerTOST.

## Test environments

Checked on 2026-11-05 using the same source tarball built with R CMD build:

- Windows 11 x64, R 4.6.1 (2026-06-24 ucrt).
- Windows 11 x64, R-devel (2026-11-03 r90835 ucrt).
- Ubuntu 24.04.4 LTS under WSL2, R 4.6.1 (2026-06-24).

Each environment ran:

```
R CMD check --as-cran SampleSizeCalc_3.1.1.tar.gz
```

The checks included all tests, examples (including donttest examples),
rebuilding four vignettes, and PDF and HTML manual validation. TeX Live 2026
and HTML Tidy 5.8.0 were available. No tests, examples, vignettes, or manual
checks were disabled through command-line options.

CRAN repository metadata was accessed through https://cran.rstudio.com because
connections to the primary host were intermittently failing. CRAN incoming
and URL checks remained enabled.

## R CMD check results

All three environments reported:

0 errors | 0 warnings | 1 note

The only NOTE was the expected first-submission message:

```
* checking CRAN incoming feasibility ... NOTE
Maintainer: 'Portos (Yishan) Wang <portos.wang@gmail.com>'

New submission
```

## Additional validation

- Development tests: 630 passing assertions, 0 failures, 0 errors, 0 warnings,
  and 0 skipped tests, including snapshots and source documentation checks.
- The renamed package was installed and loaded in a separate library before
  rebuilding the documentation website. citation("SampleSizeCalc") was verified
  to use the new package name and version 3.1.1.
- All four vignettes and the website were rebuilt using the new namespace.
- Exported functions have return-value documentation and runnable examples.
- The source archive excludes local references, website assets, manuscript
  drafts, generated test plots, and temporary build files.
- The source archive contains only the two named human authors in its metadata
  and tutorial author fields.

## Reverse dependencies

There are no reverse dependencies on CRAN because this is a new submission.
