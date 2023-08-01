context("Test bart_rl")
library(hBayesDM)

test_that("Test bart_rl", {
  # Do not run this test on CRAN
  skip_on_cran()

  expect_output(bart_rl(
      data = "example", niter = 10, nwarmup = 5, nchain = 1, ncore = 1))
})
