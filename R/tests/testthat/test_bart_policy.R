context("Test bart_policy")
library(hBayesDM)

test_that("Test bart_policy", {
  # Do not run this test on CRAN
  skip_on_cran()

  expect_output(bart_policy(
      data = "example", niter = 10, nwarmup = 5, nchain = 1, ncore = 1))
})
