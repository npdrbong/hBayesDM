#include /pre/license.stan

data {
  int<lower=1> N;            // Number of subjects
  int<lower=1> T;            // Maximum number of trials
  int<lower=0> Tsubj[N];     // Number of trials for each subject
  int<lower=2> P;            // Number of max pump + 1 ** CAUTION **
  int<lower=0> pumps[N, T];  // Number of pump
  int<lower=0,upper=1> explosion[N, T];  // Whether the balloon exploded (0 or 1)
  int<lower=0,upper=1> oms[N, T];  // Whether the balloon exploded in OMS (0 or 1)
}

transformed data {
   // Whether a subject pump the button or not (0 or 1)
  int d[N, T, P];
  real gamma = 5;

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
    // optimal number of pump
}

parameters {
  // Group-level parameters
  vector[4] mu_pr;
  vector<lower=0>[4] sigma;

  // Normally distributed error for Matt trick
  vector[N] tau_pr;
  vector[N] phi_pr;
  vector[N] alpha_pr;
  vector[N] beta_pr;
} 

transformed parameters {
  // Subject-level parameters with Matt trick
  vector<lower=0,upper=1>[N] phi;
  vector<lower=0>[N] tau;
  vector<lower=0,upper=1>[N] alpha;
  vector<lower=0,upper=1>[N] beta;

  phi = Phi_approx(mu_pr[1] + sigma[1] * phi_pr);
  tau = exp(mu_pr[2] + sigma[2] * tau_pr);
  alpha = Phi_approx(mu_pr[3] + sigma[3] * alpha_pr);
  beta = Phi_approx(mu_pr[4] + sigma[4] * beta_pr);
}

model {
  // Prior
  mu_pr  ~ normal(0, 1);
  sigma ~ normal(0, 0.2);

  phi_pr ~ normal(0, 1);
  tau_pr ~ normal(0, 1);
  alpha_pr ~ normal(0, 1);
  beta_pr ~ normal(0, 1);
  

  // Likelihood
  for (j in 1:N) {
    real p_risk[T +1];
    int cum_pump = 0; // Number of total pumps
    p_risk[1] = phi[j];
    for (k in 1:Tsubj[j]) {
      real Nsucc;
      real weight;
      real evidence;
      real omega = - gamma / log( p_risk[k] ); // Optimal Number of Pumps
      for (l in 1:(pumps[j, k] + 1 - explosion[j, k])) {
        d[j, k, l] ~ bernoulli_logit(tau[j] * (omega - l));
      }
      if (explosion[j, k]==1) {
        Nsucc = pumps[j,k] - explosion[j,k];
        weight = pumps[j,k] * inv(pumps[j,k] + cum_pump);
        evidence = Nsucc * inv(pumps[j,k]);  
        // update p_risk -- risk learning
        if (pumps[j,k]>0){
          p_risk[k+1] = (evidence*beta[j])*(weight*alpha[j]) + (1-weight*alpha[j])*p_risk[k] ;      
        } else{
          p_risk[k+1] = p_risk[k];
        }
        // update cum_pump for next iteration
        cum_pump += pumps[j, k];    
      } else {
        Nsucc = pumps[j,k] + 1 - oms[j,k]; // pumps += 1 and reflect OMS
        weight = (pumps[j,k] + 1) * inv(pumps[j,k] + 1 + cum_pump);
        evidence = Nsucc * inv(pumps[j,k] + 1);  
        // update p_risk -- risk learning
        if (pumps[j,k]>0){
          p_risk[k+1] = (evidence*beta[j])*(weight*alpha[j]) + (1-weight*alpha[j])*p_risk[k] ;      
        } else{
          p_risk[k+1] = p_risk[k];
        }
        // update cum_pump for next iteration
        cum_pump += pumps[j, k] + 1;    
      }
    }    
  }
}

generated quantities {
  // Actual group-level mean
  real<lower=0, upper=1> mu_phi = Phi_approx(mu_pr[1]);
  real<lower=0> mu_tau = exp(mu_pr[2]);
  real<lower=0, upper=1> mu_alpha = Phi_approx(mu_pr[3]);
  real<lower=0, upper=1> mu_beta = Phi_approx(mu_pr[4]);

  // Log-likelihood for model fit
  real log_lik[N];

  // For posterior predictive check
  real y_pred[N, T, P];

  // Set all posterior predictions to 0 (avoids NULL values)
  for (j in 1:N)
    for (k in 1:T)
      for(l in 1:P)
        y_pred[j, k, l] = -1;
  
    for (j in 1:N) {
      int cum_pump = 0; // Number of total pumps
      real p_risk[T+1];
      log_lik[j] = 0;
      p_risk[1] = phi[j];
      for (k in 1:T) {
        real Nsucc;
        real weight;
        real evidence;
        real omega = - gamma / log( p_risk[k] ); // Optimal Number of Pumps 
        for (l in 1:(pumps[j, k] + 1 - explosion[j, k])) {
         log_lik[j] += bernoulli_logit_lpmf(d[j, k, l] | tau[j] * (omega - l));
         y_pred[j, k, l] = bernoulli_logit_rng(tau[j] * (omega - l));
        }
        if (explosion[j, k]==1) {
          Nsucc = pumps[j,k] - explosion[j,k];
          weight = pumps[j,k] * inv(pumps[j,k] + cum_pump);
          evidence = Nsucc * inv(pumps[j,k]);  
          // update p_risk -- risk learning
          if (pumps[j,k]>0){
            p_risk[k+1] = (evidence*beta[j])*(weight*alpha[j]) + (1-weight*alpha[j])*p_risk[k] ;      
          } else{
            p_risk[k+1] = p_risk[k];
          }
          // update cum_pump for next iteration
          cum_pump += pumps[j, k];    
        } else {
          Nsucc = pumps[j,k] + 1 - oms[j,k]; // pumps += 1 and reflect OMS
          weight = (pumps[j,k] + 1) * inv(pumps[j,k] + 1 + cum_pump);
          evidence = Nsucc * inv(pumps[j,k] + 1);  
          // update p_risk -- risk learning
          if (pumps[j,k]>0){
            p_risk[k+1] = (evidence*beta[j])*(weight*alpha[j]) + (1-weight*alpha[j])*p_risk[k] ;      
          } else{
            p_risk[k+1] = p_risk[k];
          }
          // update cum_pump for next iteration
          cum_pump += pumps[j, k] + 1;    
        }     
      }
    }
}
