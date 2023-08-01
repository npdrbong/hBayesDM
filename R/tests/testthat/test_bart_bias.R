context("Test bart_bias")
library(hBayesDM)

test_that("Test bart_bias", {
  # Do not run this test on CRAN
  skip_on_cran()

  expect_output(bart_bias(
      data = "example", niter = 10, nwarmup = 5, nchain = 1, ncore = 1))
})
