context("Test oms_bias")
library(hBayesDM)

test_that("Test oms_bias", {
  # Do not run this test on CRAN
  skip_on_cran()

  expect_output(oms_bias(
      data = "example", niter = 10, nwarmup = 5, nchain = 1, ncore = 1))
})
