#' @templateVar MODEL_FUNCTION bart_5bias
#' @templateVar CONTRIBUTOR 
#' @templateVar TASK_NAME Balloon Analogue Risk Task
#' @templateVar TASK_CODE bart
#' @templateVar TASK_CITE 
#' @templateVar MODEL_NAME Bayesian updating of risk rewritten with 'Bias' term, with 'gam'
#' @templateVar MODEL_CODE 5bias
#' @templateVar MODEL_CITE (Kim et al., 2020)
#' @templateVar MODEL_TYPE Hierarchical
#' @templateVar DATA_COLUMNS "subjID", "pumps", "explosion"
#' @templateVar PARAMETERS \code{phi} (prior belief of balloon not bursting), \code{tau} (inverse temperature), \code{gam} (risk-taking parameter), \code{alpha} (Learning Bias), \code{beta} (Perceptual Bias)
#' @templateVar REGRESSORS 
#' @templateVar POSTPREDS "y_pred"
#' @templateVar LENGTH_DATA_COLUMNS 3
#' @templateVar DETAILS_DATA_1 \item{subjID}{A unique identifier for each subject in the data-set.}
#' @templateVar DETAILS_DATA_2 \item{pumps}{The number of pumps.}
#' @templateVar DETAILS_DATA_3 \item{explosion}{0: intact, 1: burst}
#' @templateVar LENGTH_ADDITIONAL_ARGS 0
#' 
#' @template model-documentation
#'
#' @export
#' @include hBayesDM_model.R
#' @include preprocess_funcs.R

#' @references
#' Kim, M., Kim, S., Lee, K. U., & Jeong, B. (2020). Pessimistically biased perception in panic disorder during risk learning. Depression and anxiety, 37(7), 609-619.
#'


bart_5bias <- hBayesDM_model(
  task_name       = "bart",
  model_name      = "5bias",
  model_type      = "",
  data_columns    = c("subjID", "pumps", "explosion"),
  parameters      = list(
    "phi" = c(0, 0.5, 1),
    "tau" = c(0, 1, Inf),
    "gam" = c(0, 1, Inf),
    "alpha" = c(0, 0.5, 1),
    "beta" = c(0, 0.5, 1)
  ),
  regressors      = NULL,
  postpreds       = c("y_pred"),
  preprocess_func = bart_preprocess_func)
