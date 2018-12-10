data {
  int<lower=1> N;
  int<lower=1> T;
  int<lower=1, upper=T> Tsesh[N];
  int<lower=0, upper=2> choice[N, T];
  int<lower=0, upper=1> outcome[N, T];
  real params[4];
}
transformed data {
  vector[2] initQ;  // initial values for Q

  // Define fixed parameters
  real aN;
  real aF;
  real beta;
  real v;

  initQ = rep_vector(0.0, 2);

  // Define fixed parameters
  aN = params[1];
  aF = params[2];
  beta = params[3];
  v = params[4];

}
parameters {
// Declare all parameters as vectors for vectorizing
  // Hyper(animal)-parameters
  vector[1] mu_p;
  vector<lower=0>[1] sigma;

  // Session-level raw parameters
  vector[N] aP_pr;    // learning rate for PPE

}
transformed parameters {
  // session-level parameters
  vector<lower=0, upper=1>[N] aP;

  for (i in 1:N) {
    aP[i]   = Phi_approx(mu_p[1]  + sigma[1]  * aP_pr[i]);
  }
}
model {
  // Hyperparameters
  mu_p  ~ normal(0, 1);
  sigma ~ cauchy(0, 1);

  // individual parameters
  aP_pr   ~ normal(0, 1);

  // session loop and trial loop
  for (i in 1:N) {
    vector[2] Q; // expected value
    real PE;      // prediction error
    real rBar; // expected average value

    Q = initQ;
    rBar = 0.4;

    for (t in 1:(Tsesh[i])) {
      // compute action probabilities
      choice[i, t] ~ categorical_logit(beta * Q);

      // prediction error
      PE = outcome[i, t] - Q[choice[i, t]] - rBar;

      // value updating (learning)
      if (PE < 0){
        Q[choice[i, t]] = Q[choice[i, t]] + aN * PE;
      }
      else{
        Q[choice[i, t]] = Q[choice[i, t]] + aP[i] * PE;
      }
      if (choice[i, t] == 1){
        Q[2] = Q[2] * aF;
      }else{
        Q[1] = Q[1] * aF;
      }
      rBar = v * outcome[i, t] + (1-v) * rBar;
    }
  }
}
generated quantities {
  // For group level parameters
  real<lower=0, upper=1> mu_aP;

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

  mu_aP = Phi_approx(mu_p[1]);

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
        log_lik[i] = log_lik[i] + categorical_logit_lpmf(choice[i, t] | beta * Q);

        // generate posterior prediction for current trial
        y_pred[i, t] = categorical_rng(softmax(beta * Q));

        // prediction error
        PE = outcome[i, t] - Q[choice[i, t]] - rBar;

        // value updating (learning)
        if (PE < 0){
          Q[choice[i, t]] = Q[choice[i, t]] + aN * PE;
        }
        else{
          Q[choice[i, t]] = Q[choice[i, t]] + aP[i] * PE;
        }
        if (choice[i, t] == 1){
          Q[2] = Q[2] * aF;
        }else{
          Q[1] = Q[1] * aF;
        }
        rBar = v * outcome[i, t] + (1-v) * rBar;
      }
    }
  }
}