data {
  int<lower=1> N;             // Number of subjects
  int<lower=1> T;             // Maximum number of trials
  int<lower=0> Tsubj[N];      // Number of trials for each subject
  int<lower=2> P;             // Number of max pump + 1 ** CAUTION **
  int<lower=0> pumps[N, T];   // Number of pump
  // int<lower=0> reward[N, T];  // Amount of rewards
  int<lower=0,upper=1> explosion[N, T];  // Whether the balloon exploded (0 or 1)
}

transformed data {
  // Whether a subject pump the button or not (0 or 1)
  int d[N, T, P];

  for (j in 1:N) {
    for (k in 1:Tsubj[j]) {
      for (l in 1:P) {
        if (l <= pumps[j, k])
          d[j, k, l] = 1;
        else
          d[j, k, l] = 0;
      }
    }
  }
}

parameters {
  // Group-level parameters
  vector[3] mu_pr;
  vector<lower=0>[3] sigma;

  // Normally distributed error for Matt trick
  vector[N] phi_pr;
  vector[N] tau_pr;
  vector[N] alpha_pr;
}

transformed parameters {
  // Subject-level parameters with Matt trick
  vector<lower=0>[N] phi;
  vector<lower=0>[N] tau;
  vector<lower=0, upper=1>[N] alpha;
  
  phi = exp(mu_pr[1] + sigma[1] * phi_pr);
  tau = exp(mu_pr[2] + sigma[2] * tau_pr);
  alpha = Phi_approx(mu_pr[3] + sigma[3] * alpha_pr);
}

model {
  // Prior
  mu_pr  ~ normal(0, 1);
  sigma ~ normal(0, 0.2); // cauchy(0, 5);

  phi_pr ~ normal(0, 1);
  tau_pr ~ normal(0, 1);
  alpha_pr ~ normal(0, 1);

  // Likelihood
  for (j in 1:N) {
    real omega = phi[j]; // initial omega number
    real gradient_j = 0;
    real gradient = 0;
    for (k in 1:Tsubj[j]) {
      real gradient_t = 0;
      real gradient_T = 0;
      for (l in 1:(pumps[j, k] + 1 - explosion[j, k])) {            
        // omega number changes after every pump
        // Calculate likelihood with bernoulli distribution
        d[j, k, l] ~ bernoulli_logit(tau[j] * (l - omega));
      }
      for (t in 1:pumps[j, k]-1) {
        gradient_t = tau[j]*exp(tau[j]*t) / (exp(tau[j]*omega) + exp(tau[j]*t));
        gradient_T += gradient_t;
      }
      if (explosion[j, k] == 1){
        gradient_T += tau[j]*exp(tau[j]*pumps[j, k]) / (exp(tau[j]*omega) + exp(tau[j]*pumps[j, k]));
      } else {
        gradient_T += - tau[j]*exp(tau[j]*pumps[j, k]) / (exp(tau[j]*omega) + exp(tau[j]*pumps[j, k]));
      } 
      gradient += gradient_T * (1 - explosion[j, k]) * pumps[j, k];
      gradient_j = gradient / k;
      omega += alpha[j] * gradient_j;

    }
  }
}

generated quantities {
  // Actual group-level mean
  real<lower=0> mu_phi = exp(mu_pr[1]);
  real<lower=0> mu_tau = exp(mu_pr[2]);
  real<lower=0> mu_alpha = Phi_approx(mu_pr[3]);

  // Log-likelihood for model fit
  real log_lik[N];

  // For posterior predictive check
  real y_pred[N, T, P];

  // Set all posterior predictions to 0 (avoids NULL values)
  for (j in 1:N)
    for (k in 1:T)
      for(l in 1:P)
        y_pred[j, k, l] = -1;

  { // Local section to save time and space
    for (j in 1:N) {
      real omega = phi[j]; // initial omega number
      real gradient_j = 0;
      real gradient = 0;
      log_lik[j] = 0;

      for (k in 1:Tsubj[j]) {
        real gradient_t = 0;
        real gradient_T = 0;
        
      
        for (l in 1:(pumps[j, k] + 1 - explosion[j, k])) {
          log_lik[j] += bernoulli_logit_lpmf(d[j, k, l] | tau[j] * (l - omega));
          y_pred[j, k, l] = bernoulli_logit_rng(tau[j] * (l - omega));
        }
        for (t in 1:pumps[j, k]-1) {
          gradient_t = tau[j]*exp(tau[j]*t) / (exp(tau[j]*omega) + exp(tau[j]*t));
          gradient_T += gradient_t;
        }
        if (explosion[j, k] == 1){
          gradient_T += tau[j]*exp(tau[j]*pumps[j, k]) / (exp(tau[j]*omega) + exp(tau[j]*pumps[j, k]));
        } else {
          gradient_T += - tau[j]*exp(tau[j]*pumps[j, k]) / (exp(tau[j]*omega) + exp(tau[j]*pumps[j, k]));
        } 
        gradient += gradient_T * (1 - explosion[j, k]) * pumps[j, k];
        gradient_j = gradient / k;
        omega += alpha[j] * gradient_j;        

      }
    }
  }
}
