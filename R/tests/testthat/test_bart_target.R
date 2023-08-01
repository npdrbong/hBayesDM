context("Test bart_target")
library(hBayesDM)

test_that("Test bart_target", {
  # Do not run this test on CRAN
  skip_on_cran()

  expect_output(bart_target(
      data = "example", niter = 10, nwarmup = 5, nchain = 1, ncore = 1))
})
