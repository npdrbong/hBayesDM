#' @templateVar MODEL_FUNCTION bart_target
#' @templateVar CONTRIBUTOR 
#' @templateVar TASK_NAME Balloon Analogue Risk Task
#' @templateVar TASK_CODE bart
#' @templateVar TASK_CITE 
#' @templateVar MODEL_NAME reinforcement learning from target model
#' @templateVar MODEL_CODE target
#' @templateVar MODEL_CITE (van Ravenzwaaij et al., 2011)
#' @templateVar MODEL_TYPE Hierarchical
#' @templateVar DATA_COLUMNS "subjID", "pumps", "explosion"
#' @templateVar PARAMETERS \code{phi} (parameter for initial target number), \code{tau} (inverse temperature), \code{vwin} (learning rate of reward), \code{vloss} (learning rate of loss)
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
#' van Ravenzwaaij, D., Dutilh, G., & Wagenmakers, E. J. (2011). Cognitive model decomposition of the BART: Assessment and application. Journal of Mathematical Psychology, 55(1), 94-105.
#'


bart_target <- hBayesDM_model(
  task_name       = "bart",
  model_name      = "target",
  model_type      = "",
  data_columns    = c("subjID", "pumps", "explosion"),
  parameters      = list(
    "phi" = c(0, 10, Inf),
    "tau" = c(0, 1, Inf),
    "vwin" = c(0, 0.5, 1),
    "vloss" = c(0, 0.5, 1)
  ),
  regressors      = NULL,
  postpreds       = c("y_pred"),
  preprocess_func = bart_preprocess_func)
