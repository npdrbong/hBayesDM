context("Test bart_5bias")
library(hBayesDM)

test_that("Test bart_5bias", {
  # Do not run this test on CRAN
  skip_on_cran()

  expect_output(bart_5bias(
      data = "example", niter = 10, nwarmup = 5, nchain = 1, ncore = 1))
})
