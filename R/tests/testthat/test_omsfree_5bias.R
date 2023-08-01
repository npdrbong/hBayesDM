context("Test omsfree_5bias")
library(hBayesDM)

test_that("Test omsfree_5bias", {
  # Do not run this test on CRAN
  skip_on_cran()

  expect_output(omsfree_5bias(
      data = "example", niter = 10, nwarmup = 5, nchain = 1, ncore = 1))
})
