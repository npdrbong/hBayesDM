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
  vector[6] mu_pr;
  vector<lower=0>[6] sigma;

  // Normally distributed error for Matt trick
  vector[N] phi_pr;
  vector[N] tau_pr;
  vector[N] vwin_pr;
  vector[N] vloss_pr;
  vector[N] alpha_pr;
  vector[N] beta_pr;
}

transformed parameters {
  // Subject-level parameters with Matt trick
  vector<lower=0>[N] phi;
  vector<lower=0>[N] tau;
  vector<lower=0,upper=1>[N] vwin;
  vector<lower=0,upper=1>[N] vloss;
  vector<lower=0>[N] alpha;
  vector<lower=0>[N] beta;
  
  phi = exp(mu_pr[1] + sigma[1] * phi_pr);
  tau = exp(mu_pr[2] + sigma[2] * tau_pr);
  vwin = Phi_approx(mu_pr[3] + sigma[3] * vwin_pr);
  vloss = Phi_approx(mu_pr[4] + sigma[4] * vloss_pr);
  alpha = exp(mu_pr[5] + sigma[5] * alpha_pr);
  beta = exp(mu_pr[6] + sigma[6] * beta_pr);
}

model {
  // Prior
  mu_pr  ~ normal(0, 1);
  sigma ~ normal(0, 0.2); // cauchy(0, 5);

  phi_pr ~ normal(0, 1);
  tau_pr ~ normal(0, 1);
  vwin_pr ~ normal(0, 1);
  vloss_pr ~ normal(0, 1);
  alpha_pr ~ normal(0, 1);
  beta_pr ~ normal(0, 1);

  // Likelihood
  for (j in 1:N) {
    real omega = phi[j]; // initial omega number

    for (k in 1:Tsubj[j]) {
      real PE_p;
      real PE_e;

      for (l in 1:(pumps[j, k] + 1 - explosion[j, k])) {            
        print("omega")
        print(omega);
        // omega number changes after every pump
        // Calculate likelihood with bernoulli distribution
        d[j, k, l] ~ bernoulli_logit(tau[j] * (l - omega));
        
        PE_p = 1 / (1 + exp(-alpha[j] * (l - omega)));
        omega += vwin[j] * PE_p;
        print("win")
        print(vwin[j] * PE_p);
      }

      if (explosion[j, k] == 1){
        PE_e = 1 / (1 + exp(-beta[j] * (omega - pumps[j, k])));
        omega += -vloss[j]*(pumps[j, k]-1)*PE_e;
        print("loss")
        print(-vloss[j]*(pumps[j, k]-1)*PE_e);
      }
    }
  }
}

generated quantities {
  // Actual group-level mean
  real<lower=0> mu_phi = exp(mu_pr[1]);
  real<lower=0> mu_tau = exp(mu_pr[2]);
  real<lower=0> mu_vwin = Phi_approx(mu_pr[3]);
  real<lower=0> mu_vloss = Phi_approx(mu_pr[4]);
  real<lower=0> mu_alpha = exp(mu_pr[5]);
  real<lower=0> mu_beta = exp(mu_pr[6]);

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
      log_lik[j] = 0;

      for (k in 1:Tsubj[j]) {
        real PE_p;
        real PE_e;
        
        
        for (l in 1:(pumps[j, k] + 1 - explosion[j, k])) {
          print(omega);
          log_lik[j] += bernoulli_logit_lpmf(d[j, k, l] | tau[j] * (l - omega));
          y_pred[j, k, l] = bernoulli_logit_rng(tau[j] * (l - omega));

          PE_p = 1 / (1 + exp(-alpha[j] * (l - omega)));
          omega += vwin[j] * PE_p;
        }

        if (explosion[j, k] == 1) {
            PE_e = 1 / (1 + exp(-beta[j] * (omega - pumps[j, k])));
            omega += -vloss[j]*(pumps[j, k]-1)*PE_e;
        }
      }
    }
  }
}
