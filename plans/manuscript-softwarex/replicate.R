# Reproduce all numerical results and figures in the SoftwareX working draft.
# Run from this directory: Rscript --vanilla replicate.R

replicate_manuscript <- function() {
  needed <- c(
    "pkgload",
    "digest",
    "jsonlite",
    "ggplot2",
    "presize",
    "PowerTOST"
  )
  missing <- needed[
    !vapply(needed, requireNamespace, logical(1), quietly = TRUE)
  ]
  if (length(missing)) {
    stop(
      "Install the following packages first: ",
      paste(missing, collapse = ", ")
    )
  }
  for (folder in c("evidence", "tables", "figures")) {
    dir.create(folder, showWarnings = FALSE)
  }

  project_root <- normalizePath(file.path("..", ".."), mustWork = FALSE)
  archive <- file.path("evidence", "SampleSizeCalc_3.1.1.tar.gz")
  if (!file.exists(archive)) {
    original <- file.path(project_root, basename(archive))
    if (!file.exists(original)) {
      stop("The evaluated source archive is required: ", basename(archive))
    }
    stopifnot(file.copy(original, archive, overwrite = FALSE))
  }
  expected_sha256 <- "2f7442cf87329780f4985a253196f01fe119f0ad3e692e46a57175c9c40378ba"
  archive_sha256 <- digest::digest(file = archive, algo = "sha256")
  stopifnot(identical(archive_sha256, expected_sha256))

  source_dir <- tempfile("samplesizecalc-paper-")
  dir.create(source_dir)
  on.exit(unlink(source_dir, recursive = TRUE), add = TRUE)
  utils::untar(archive, exdir = source_dir)
  package_dir <- file.path(source_dir, "SampleSizeCalc")
  pkgload::load_all(
    package_dir,
    export_all = FALSE,
    helpers = FALSE,
    attach_testthat = FALSE,
    quiet = TRUE
  )
  stopifnot(as.character(utils::packageVersion("SampleSizeCalc")) == "3.1.1")

  combinations <- get("ssr_combinations", asNamespace("SampleSizeCalc"))
  routes <- do.call(
    rbind,
    lapply(combinations, function(x) {
      data.frame(
        design = x$design,
        task = x$task,
        outcome = x$outcome,
        route = x$legacy,
        stringsAsFactors = FALSE
      )
    })
  )
  families <- list(
    "Trials" = c(
      "rct",
      "paired",
      "rctSingleArm",
      "crossover",
      "bioequivalence",
      "singleArmPhaseII"
    ),
    "Observational studies" = c(
      "cohort",
      "caseControl",
      "caseControlMatched",
      "crosstab"
    ),
    "Single-sample estimation" = c(
      "singleProportion",
      "singleMean",
      "singleCorrelation"
    ),
    "Diagnostic accuracy" = c(
      "diagAccuracy",
      "diagAccuracyCompare",
      "diagAUC",
      "diagAUCCompare",
      "diagLR"
    ),
    "Complex and specialised designs" = c(
      "clusterRCT",
      "steppedWedge",
      "twoOrdinal",
      "kappa",
      "predictiveModel",
      "its"
    )
  )
  routes$family <- vapply(
    routes$design,
    function(design) {
      found <- names(families)[vapply(
        families,
        function(x) design %in% x,
        logical(1)
      )]
      stopifnot(length(found) == 1L)
      found
    },
    character(1)
  )
  scope <- do.call(
    rbind,
    lapply(names(families), function(family) {
      selected <- routes[routes$family == family, ]
      data.frame(
        Family = family,
        `Design identifiers` = length(unique(selected$design)),
        `Legal combinations` = nrow(selected),
        check.names = FALSE
      )
    })
  )
  stopifnot(nrow(routes) == 46L, length(unique(routes$design)) == 24L)
  utils::write.csv(routes, "tables/dispatch-inventory.csv", row.names = FALSE)
  utils::write.csv(scope, "tables/scope-summary.csv", row.names = FALSE)

  trial <- SampleSizeCalc::calculate(
    "rct",
    "test",
    "mean",
    mean1 = 10,
    mean2 = 12,
    sd = 3,
    alpha = 0.05,
    power = 0.8
  )
  diagnostic <- SampleSizeCalc::calculate(
    "diagAccuracy",
    "estimate",
    "proportion",
    prob = 0.85,
    d = 0.05,
    prevalence = 0.2,
    alpha = 0.05
  )
  screen_n <- SampleSizeCalc::screen_required(
    diagnostic$target_state_cases_needed,
    prevalence = 0.2,
    beta = 0.1
  )
  assurance <- stats::pbinom(
    diagnostic$target_state_cases_needed - 1,
    size = screen_n,
    prob = 0.2,
    lower.tail = FALSE
  )
  assurance_previous <- stats::pbinom(
    diagnostic$target_state_cases_needed - 1,
    size = screen_n - 1,
    prob = 0.2,
    lower.tail = FALSE
  )
  stopifnot(assurance >= 0.9, assurance_previous < 0.9)
  be <- SampleSizeCalc::calculate(
    "bioequivalence",
    "equivalence",
    "mean",
    cv = 0.25,
    theta0 = 1,
    margin_low = 0.8,
    margin_high = 1.25,
    alpha = 0.05,
    power = 0.8
  )
  be_shift <- SampleSizeCalc::calculate(
    "bioequivalence",
    "equivalence",
    "mean",
    cv = 0.25,
    theta0 = 0.95,
    alpha = 0.05,
    power = 0.8
  )
  cases <- data.frame(
    Scenario = c(
      "Parallel trial",
      "Sensitivity precision",
      "Screening assurance",
      "Bioequivalence",
      "Bioequivalence, GMR 0.95"
    ),
    Unit = c(
      "Complete participants per arm",
      "Confirmed disease-positive participants",
      "Participants screened",
      "Complete participants, total",
      "Complete participants, total"
    ),
    Requirement = c(
      trial$n_per_group,
      diagnostic$target_state_cases_needed,
      screen_n,
      be$total_n,
      be_shift$total_n
    ),
    stringsAsFactors = FALSE
  )
  utils::write.csv(cases, "tables/worked-examples.csv", row.names = FALSE)

  proportion <- SampleSizeCalc::calculate(
    "singleProportion",
    p = 0.3,
    precision = 0.05
  )
  single_mean <- SampleSizeCalc::calculate(
    "singleMean",
    sigma = 3,
    precision = 0.5
  )
  se_book <- SampleSizeCalc::calculate(
    "diagAccuracy",
    "estimate",
    "proportion",
    prob = 0.8,
    d = 0.05,
    prevalence = 1
  )
  auc_binormal <- SampleSizeCalc::calculate(
    "diagAUC",
    "estimate",
    "auc",
    auc = 0.8,
    d = 0.1,
    ratio = 1,
    var_method = "binormal"
  )
  auc_exponential <- SampleSizeCalc::calculate(
    "diagAUC",
    "estimate",
    "auc",
    auc = 0.8,
    d = 0.1,
    ratio = 1,
    var_method = "exponential"
  )
  cor_narrow <- SampleSizeCalc::calculate(
    "singleCorrelation",
    r = 0.5,
    precision = 0.05
  )
  cor_wide <- SampleSizeCalc::calculate(
    "singleCorrelation",
    r = 0.5,
    precision = 0.1
  )
  cor_ref_narrow <- presize::prec_cor(
    r = 0.5,
    conf.width = 0.1,
    method = "pearson"
  )$n
  cor_ref_wide <- presize::prec_cor(
    r = 0.5,
    conf.width = 0.2,
    method = "pearson"
  )$n
  be_ref <- PowerTOST::sampleN.TOST(
    CV = 0.25,
    theta0 = 1,
    alpha = 0.05,
    targetpower = 0.8,
    print = FALSE
  )[1, "Sample size"]
  be_ref_shift <- PowerTOST::sampleN.TOST(
    CV = 0.25,
    theta0 = 0.95,
    alpha = 0.05,
    targetpower = 0.8,
    print = FALSE
  )[1, "Sample size"]
  cluster <- SampleSizeCalc::calculate(
    "clusterRCT",
    "test",
    "mean",
    mean1 = 12.4,
    mean2 = 15.9,
    sd = 6.94,
    icc = 0.025,
    cluster_size = 2,
    alpha = 0.05,
    power = 0.9
  )
  simon <- SampleSizeCalc::calculate(
    "singleArmPhaseII",
    "test",
    "proportion",
    p0 = 0.1,
    p1 = 0.3,
    alpha = 0.05,
    power = 0.8,
    optimizer = "optimal"
  )
  screening_candidates <- seq.int(900L, 1200L)
  screening_reference <- min(screening_candidates[
    stats::pbinom(195, screening_candidates, 0.2, lower.tail = FALSE) >= 0.9
  ])
  validation <- data.frame(
    ID = paste0("V", seq_len(12)),
    Method = c(
      "Proportion precision",
      "Mean precision",
      "Sensitivity precision",
      "AUC, binormal variance",
      "AUC, exponential variance",
      "Correlation, CI width 0.10",
      "Correlation, CI width 0.20",
      "Bioequivalence, GMR 1.00",
      "Bioequivalence, GMR 0.95",
      "Cluster trial",
      "Simon optimal design",
      "Screening assurance"
    ),
    Unit = c(
      "Participants",
      "Participants",
      "Cases",
      "Cases",
      "Cases",
      "Participants",
      "Participants",
      "Total participants",
      "Total participants",
      "Total participants",
      "Maximum participants",
      "Screened participants"
    ),
    Package = c(
      proportion$n_required,
      single_mean$n_required,
      se_book$target_state_cases_needed,
      auc_binormal$target_state_cases_needed,
      auc_exponential$target_state_cases_needed,
      cor_narrow$n_required,
      cor_wide$n_required,
      be$total_n,
      be_shift$total_n,
      cluster$total_n,
      simon$n_total,
      screen_n
    ),
    Reference = c(
      ceiling(stats::qnorm(0.975)^2 * 0.3 * 0.7 / 0.05^2),
      141,
      246,
      46,
      38,
      cor_ref_narrow,
      cor_ref_wide,
      be_ref,
      be_ref_shift,
      172,
      29,
      screening_reference
    ),
    Source = c(
      "Normal precision formula",
      "Machin, Eq. 9.18",
      "Zhou, Sec. 6.1.1",
      "Zhou, Eq. 6.5",
      "Zhou, Eq. 6.4",
      paste("presize", utils::packageDescription("presize")$Version),
      paste("presize", utils::packageDescription("presize")$Version),
      paste("PowerTOST", utils::packageDescription("PowerTOST")$Version),
      paste("PowerTOST", utils::packageDescription("PowerTOST")$Version),
      "Machin, Ex. 12.1",
      "Machin, Ex. 17.2",
      "Binomial minimality"
    ),
    stringsAsFactors = FALSE
  )
  validation$Difference <- validation$Package - validation$Reference
  stopifnot(all(validation$Difference == 0))
  stopifnot(
    trial$n_per_group == 37L,
    trial$total_n == 74L,
    diagnostic$target_state_cases_needed == 196L,
    screen_n == 1061L,
    be$total_n == 24L,
    be_shift$total_n == 28L,
    simon$n_stage_1 == 10L,
    simon$r_stage_1 == 1L,
    simon$r_total == 5L
  )
  utils::write.csv(validation, "tables/validation-full.csv", row.names = FALSE)

  sensitivity <- expand.grid(
    delta = seq(1, 4, by = 0.25),
    power = c(0.8, 0.9, 0.95)
  )
  sensitivity$n_per_arm <- vapply(
    seq_len(nrow(sensitivity)),
    function(i) {
      SampleSizeCalc::calculate(
        "rct",
        "test",
        "mean",
        mean1 = 10,
        mean2 = 10 + sensitivity$delta[i],
        sd = 3,
        alpha = 0.05,
        power = sensitivity$power[i]
      )$n_per_group
    },
    numeric(1)
  )
  sensitivity$power_label <- factor(
    sprintf("%d%% power", round(100 * sensitivity$power)),
    levels = c("80% power", "90% power", "95% power")
  )
  utils::write.csv(sensitivity, "tables/sensitivity.csv", row.names = FALSE)
  sensitivity_plot <- ggplot2::ggplot(
    sensitivity,
    ggplot2::aes(delta, n_per_arm, colour = power_label, group = power_label)
  ) +
    ggplot2::geom_line(linewidth = 0.8) +
    ggplot2::geom_point(size = 1.6) +
    ggplot2::scale_colour_manual(values = c("#0072B2", "#D55E00", "#009E73")) +
    ggplot2::labs(
      x = "Anticipated between-group difference (mmHg)",
      y = "Complete participants per arm",
      colour = NULL
    ) +
    ggplot2::theme_minimal(base_size = 11) +
    ggplot2::theme(
      legend.position = "top",
      panel.grid.minor = ggplot2::element_blank()
    )
  ggplot2::ggsave(
    "figures/power-sensitivity.png",
    sensitivity_plot,
    width = 6.7,
    height = 3.7,
    dpi = 300
  )
  ggplot2::ggsave(
    "figures/power-sensitivity.pdf",
    sensitivity_plot,
    width = 6.7,
    height = 3.7,
    device = grDevices::cairo_pdf
  )

  draw_architecture <- function() {
    grid::grid.newpage()
    titles <- c(
      "Study specification",
      "Dispatch and validation",
      "Calculation kernels",
      "Reportable result"
    )
    bodies <- c(
      "Design + task + outcome\nExplicit study parameters",
      "Legal combination\nRequired inputs and ranges",
      "Published formula or solver\nDesign-specific conventions",
      "Sample-size units and inputs\nFormula, steps and references"
    )
    positions <- c(0.125, 0.375, 0.625, 0.875)
    fills <- c("#E8F1FA", "#EAF4EF", "#FFF1DC", "#ECEAF7")
    for (i in seq_along(positions)) {
      grid::grid.roundrect(
        x = positions[i],
        y = 0.62,
        width = 0.228,
        height = 0.44,
        r = grid::unit(2, "mm"),
        gp = grid::gpar(fill = fills[i], col = "#526175")
      )
      grid::grid.text(
        titles[i],
        x = positions[i],
        y = 0.73,
        gp = grid::gpar(fontsize = 10, fontface = "bold")
      )
      grid::grid.text(
        bodies[i],
        x = positions[i],
        y = 0.56,
        gp = grid::gpar(fontsize = 8.6, lineheight = 1.4)
      )
      if (i < length(positions)) {
        grid::grid.lines(
          x = c(positions[i] + 0.115, positions[i + 1] - 0.117),
          y = c(0.62, 0.62),
          arrow = grid::arrow(length = grid::unit(1.5, "mm")),
          gp = grid::gpar(col = "#526175")
        )
      }
    }
    grid::grid.text(
      "Versioned source + executable examples + numerical reference checks",
      x = 0.5,
      y = 0.18,
      gp = grid::gpar(fontsize = 10, col = "#394657")
    )
  }
  grDevices::png(
    "figures/architecture.png",
    width = 2400,
    height = 900,
    res = 300
  )
  draw_architecture()
  grDevices::dev.off()
  grDevices::cairo_pdf("figures/architecture.pdf", width = 8, height = 3)
  draw_architecture()
  grDevices::dev.off()

  log_names <- c(
    "windows-release",
    "windows-devel",
    "linux-release"
  )
  check_records <- lapply(log_names, function(name) {
    original <- file.path(
      project_root,
      "tmp",
      "SampleSizeCalc-cran",
      name,
      "SampleSizeCalc.Rcheck",
      "00check.log"
    )
    saved <- file.path("evidence", paste0(name, "-00check.log"))
    if (file.exists(original)) {
      file.copy(original, saved, overwrite = TRUE)
    }
    if (!file.exists(saved)) {
      stop("Historical validation log missing: ", saved)
    }
    lines <- readLines(saved, warn = FALSE, encoding = "UTF-8")
    stopifnot(
      any(lines == "Status: 1 NOTE"),
      any(lines == "* DONE"),
      any(grepl("checking PDF version of manual .* OK$", lines)),
      any(grepl("checking HTML version of manual .* OK$", lines))
    )
    list(
      environment = name,
      status = "0 errors; 0 warnings; 1 New submission note",
      check_date = sub(
        "^\\* current time: ([0-9-]+).*",
        "\\1",
        grep("^\\* current time:", lines, value = TRUE)[1]
      ),
      log = saved
    )
  })
  dev_status_original <- file.path(
    project_root,
    "tmp",
    "SampleSizeCalc-cran",
    "development-tests.status"
  )
  dev_status_saved <- "evidence/development-tests.txt"
  if (file.exists(dev_status_original)) {
    file.copy(dev_status_original, dev_status_saved, overwrite = TRUE)
  }
  stopifnot(file.exists(dev_status_saved))
  development_status <- readLines(dev_status_saved, warn = FALSE)
  stopifnot(any(grepl(
    "630 passed, 0 failures, 0 errors, 0 warnings, 0 skipped",
    development_status,
    fixed = TRUE
  )))

  evidence <- list(
    software = "SampleSizeCalc",
    version = "3.1.1",
    archive_sha256 = archive_sha256,
    legal_combinations = nrow(routes),
    design_identifiers = length(unique(routes$design)),
    numerical_comparisons = nrow(validation),
    comparisons_agree = all(validation$Difference == 0),
    comparators = list(
      presize = utils::packageDescription("presize")$Version,
      PowerTOST = utils::packageDescription("PowerTOST")$Version
    ),
    screening = list(
      n = screen_n,
      probability = assurance,
      previous_n_probability = assurance_previous
    ),
    historical_package_checks = check_records,
    historical_development_tests = development_status,
    reproduction_session = capture.output(utils::sessionInfo())
  )
  jsonlite::write_json(
    evidence,
    "evidence/verification.json",
    pretty = TRUE,
    auto_unbox = TRUE
  )
  writeLines(capture.output(utils::sessionInfo()), "evidence/session-info.txt")
  paper_data <- list(
    scope = scope,
    routes = routes,
    cases = cases,
    validation = validation,
    main_validation = validation[
      validation$ID %in% c("V1", "V3", "V4", "V6", "V8", "V10", "V11", "V12"),
      c("Method", "Unit", "Package", "Reference", "Source")
    ],
    trial = list(
      n_per_arm = trial$n_per_group,
      total_n = trial$total_n,
      recruit_per_arm = ceiling(trial$n_per_group / 0.9)
    ),
    diagnostic = list(
      cases = diagnostic$target_state_cases_needed,
      expected_screen = diagnostic$total_subjects_to_screen,
      assured_screen = screen_n,
      probability = assurance
    ),
    bioequivalence = list(
      per_sequence = be$n_required,
      total_n = be$total_n,
      shifted_total_n = be_shift$total_n
    ),
    evidence = evidence
  )
  saveRDS(paper_data, "evidence/paper-results.rds")
  cat(
    "Reproduced 46 legal combinations, 12 numerical comparisons and two figures.\n"
  )
  print(cases, row.names = FALSE)
  invisible(paper_data)
}

paper_data <- replicate_manuscript()
