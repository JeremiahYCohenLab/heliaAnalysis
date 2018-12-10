data {
  int<lower=1> N;
  int<lower=1> M;
  int<lower=1> T;
  int<lower=1, upper=T> Tsesh[N];
  int<lower=0, upper=2> choice[N, T];
  int<lower=0, upper=1> outcome[N, T];
  int<lower=1, upper=T> TseshM[M];
  int<lower=0, upper=2> choiceM[M, T];
  int<lower=0, upper=1> outcomeM[M, T];
}
transformed data {
  vector[2] initQ;  // initial values for Q
  initQ = rep_vector(0.0, 2);
}
parameters {
// Declare all parameters as vectors for vectorizing
  // Hyper(animal)-parameters
  vector[5] mu_p;
  vector<lower=0>[5] sigma;
  vector[5] d_mu_p;
  vector<lower=0>[5] d_sigma;

  // Session-level raw parameters
  vector[N] aN_pr;    // learning rate for NPE
  vector[N] aP_pr;    // learning rate for PPE
  vector[N] aF_pr;    // forgetting rate
  vector[N] beta_pr;  // inverse temperature
  vector[N] v_pr;     // expected average value learning rate

  vector[M] d_aN_pr;    // change in learning rate for NPE
  vector[M] d_aP_pr;    // change in learning rate for PPE
  vector[M] d_aF_pr;    // change in forgetting rate
  vector[M] d_beta_pr;  // change in inverse temperature
  vector[M] d_v_pr;     // change in expected average value learning rate
}
transformed parameters {
  // session-level parameters
  vector<lower=0, upper=1>[N] aN;
  vector<lower=0, upper=1>[N] aP;
  vector<lower=0, upper=1>[N] aF;
  vector<lower=0, upper=10>[N] beta;
  vector<lower=0, upper=1>[N] v;

  vector<lower=0, upper=1>[M] d_aN;
  vector<lower=0, upper=1>[M] d_aP;
  vector<lower=0, upper=1>[M] d_aF;
  vector<lower=0, upper=10>[M] d_beta;
  vector<lower=0, upper=1>[M] d_v;

  for (i in 1:N) {
    aN[i]   = Phi_approx(mu_p[1]  + sigma[1]  * aN_pr[i]);
    aP[i]   = Phi_approx(mu_p[2]  + sigma[2]  * aP_pr[i]);
    aF[i]   = Phi_approx(mu_p[3]  + sigma[3]  * aF_pr[i]);
    beta[i] = Phi_approx(mu_p[4] + sigma[4] * beta_pr[i]) * 10;
    v[i]   = Phi_approx(mu_p[5]  + sigma[5]  * v_pr[i]);
    }
  for (i in 1:M){
    d_aN[i]   = Phi_approx(d_mu_p[1]  + d_sigma[1]  * d_aN_pr[i]);
    d_aP[i]   = Phi_approx(d_mu_p[2]  + d_sigma[2]  * d_aP_pr[i]);
    d_aF[i]   = Phi_approx(d_mu_p[3]  + d_sigma[3]  * d_aF_pr[i]);
    d_beta[i] = Phi_approx(d_mu_p[4]  + d_sigma[4]  * d_beta_pr[i]) * 10;
    d_v[i]    = Phi_approx(d_mu_p[5] + d_sigma[5] * d_v_pr[i]);
  }
}
model {
  // Hyperparameters
  mu_p  ~ normal(0, 1);
  sigma ~ cauchy(0, 1);

  // individual parameters
  aN_pr   ~ normal(0, 1);
  aP_pr   ~ normal(0, 1);
  aF_pr   ~ normal(0, 1);
  beta_pr ~ normal(0, 1);
  v_pr    ~ normal(0, 1);
  d_aN_pr   ~ normal(0, 1);
  d_aP_pr   ~ normal(0, 1);
  d_aF_pr   ~ normal(0, 1);
  d_beta_pr ~ normal(0, 1);
  d_v_pr    ~ normal(0, 1);



  // session loop and trial loop
  for (i in 1:N) {
    vector[2] Q; // expected value
    real PE;      // prediction error
    real rBar; // expected average value

    Q = initQ;
    rBar = 0.4;

    for (t in 1:(Tsesh[i])) {
      // compute action probabilities
      choice[i, t] ~ categorical_logit(beta[i] * Q);

      // prediction error
      PE = outcome[i, t] - Q[choice[i, t]] - rBar;

      // value updating (learning)
      if (PE < 0){
        Q[choice[i, t]] = Q[choice[i, t]] + aN[i] * PE;
      }
      else{
        Q[choice[i, t]] = Q[choice[i, t]] + aP[i] * PE;
      }
      if (choice[i, t] == 1){
        Q[2] = Q[2] * aF[i];
      }else{
        Q[1] = Q[1] * aF[i];
      }
      rBar = v[i] * outcome[i, t] + (1-v[i]) * rBar;
    }
  }
  for (i in 1:M) {
    vector[2] Q; // expected value
    real PE;      // prediction error
    real rBar; // expected average value

    Q = initQ;
    rBar = 0.4;

    for (t in 1:(TseshM[i])) {
      // compute action probabilities
      choiceM[i, t] ~ categorical_logit((beta[i] + d_beta[i]) * Q);

      // prediction error
      PE = outcomeM[i, t] - Q[choiceM[i, t]] - rBar;

      // value updating (learning)
      if (PE < 0){
        Q[choiceM[i, t]] = Q[choiceM[i, t]] + (aN[i] + d_aN[i]) * PE;
      }
      else{
        Q[choiceM[i, t]] = Q[choiceM[i, t]] + (aP[i]+ d_aP[i]) * PE;
      }
      if (choiceM[i, t] == 1){
        Q[2] = Q[2] * (aF[i] + d_aF[i]);
      }else{
        Q[1] = Q[1] * (aF[i] + d_aF[i]);
      }
      rBar = (v[i] + d_v[i]) * outcomeM[i, t] + (1-v[i] + d_v[i]) * rBar;
    }
  }
}
generated quantities {
  // For group level parameters
  real<lower=0, upper=1> mu_aN;
  real<lower=0, upper=1> mu_aP;
  real<lower=0, upper=1> mu_aF;
  real<lower=0, upper=10> mu_beta;
  real<lower=0, upper=1> mu_v;
  real<lower=0, upper=1> d_mu_aN;
  real<lower=0, upper=1> d_mu_aP;
  real<lower=0, upper=1> d_mu_aF;
  real<lower=0, upper=10> d_mu_beta;
  real<lower=0, upper=1> d_mu_v;

  // For log likelihood calculation
  real log_lik[N];

  // For posterior predictive check
  real y_pred[N, T];

  // Set all posterior predictions to 0 (avoids NULL values)
  for (i in 1:N) {
    for (t in 1:T) {
      y_pred[i, t] = -1;
    }
  }

  mu_aN   = Phi_approx(mu_p[1]);
  mu_aP   = Phi_approx(mu_p[2]);
  mu_aF   = Phi_approx(mu_p[3]);
  mu_beta = Phi_approx(mu_p[4]) * 10;
  mu_v   = Phi_approx(mu_p[5]);

  d_mu_aN   = Phi_approx(d_mu_p[1]);
  d_mu_aP   = Phi_approx(d_mu_p[2]);
  d_mu_aF   = Phi_approx(d_mu_p[3]);
  d_mu_beta = Phi_approx(d_mu_p[4]) * 10;
  d_mu_v   = Phi_approx(d_mu_p[5]);

  { // local section, this saves time and space
    for (i in 1:N) {
      vector[2] Q; // expected value
      real PE;      // prediction error
      real rBar; // expected average value

      // Initialize values
      Q = initQ;
      rBar = 0.4;

      log_lik[i] = 0;

      for (t in 1:(Tsesh[i])) {
        // compute log likelihood of current trial
        log_lik[i] = log_lik[i] + categorical_logit_lpmf(choice[i, t] | beta[i] * Q);

        // generate posterior prediction for current trial
        y_pred[i, t] = categorical_rng(softmax(beta[i] * Q));

        // prediction error
        PE = outcome[i, t] - Q[choice[i, t]] - rBar;

        // value updating (learning)
        if (PE < 0){
          Q[choice[i, t]] = Q[choice[i, t]] + aN[i] * PE;
        }
        else{
          Q[choice[i, t]] = Q[choice[i, t]] + aP[i] * PE;
        }
        if (choice[i, t] == 1){
          Q[2] = Q[2] * aF[i];
        }else{
          Q[1] = Q[1] * aF[i];
        }
        rBar = v[i] * outcome[i, t] + (1-v[i]) * rBar;
      }
    }
    for (i in 1:M) {
      vector[2] Q; // expected value
      real PE;      // prediction error
      real rBar; // expected average value

      // Initialize values
      Q = initQ;
      rBar = 0.4;

      log_lik[i] = 0;

      for (t in 1:(TseshM[i])) {
        // compute log likelihood of current trial
        log_lik[i] = log_lik[i] + categorical_logit_lpmf(choiceM[i, t] | (beta[i] + d_beta[i]) * Q);

        // generate posterior prediction for current trial
        y_pred[i, t] = categorical_rng(softmax((beta[i] +d_beta[i]) * Q));

        // prediction error
        PE = outcomeM[i, t] - Q[choiceM[i, t]] - rBar;

        // value updating (learning)
        if (PE < 0){
          Q[choiceM[i, t]] = Q[choiceM[i, t]] + (aN[i] + d_aN[i]) * PE;
        }
        else{
          Q[choiceM[i, t]] = Q[choiceM[i, t]] + (aP[i] + d_aP[i]) * PE;
        }
        if (choiceM[i, t] == 1){
          Q[2] = Q[2] * (aF[i] + d_aF[i]);
        }else{
          Q[1] = Q[1] * (aF[i] + d_aF[i]);
        }
        rBar = (v[i] +d_v[i]) * outcomeM[i, t] + (1-v[i] + d_v[i]) * rBar;
      }
    }
  }
}