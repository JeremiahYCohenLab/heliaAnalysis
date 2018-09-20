// Code generated by Stan version 2.17.1

#include <stan/model/model_header.hpp>

namespace rats_model_namespace {

using std::istream;
using std::string;
using std::stringstream;
using std::vector;
using stan::io::dump;
using stan::math::lgamma;
using stan::model::prob_grad;
using namespace stan::math;

static int current_statement_begin__;

stan::io::program_reader prog_reader__() {
    stan::io::program_reader reader;
    reader.add_event(0, 0, "start", "C:/Users/cooper_PC/Desktop/githubRepositories/cooperAnalysis/matlabLibraries/MatlabStan-2.15.1.0/Examples/rats.stan");
    reader.add_event(48, 48, "end", "C:/Users/cooper_PC/Desktop/githubRepositories/cooperAnalysis/matlabLibraries/MatlabStan-2.15.1.0/Examples/rats.stan");
    return reader;
}

class rats_model : public prob_grad {
private:
    int N;
    int TT;
    vector<double> x;
    vector<vector<double> > y;
    double xbar;
public:
    rats_model(stan::io::var_context& context__,
        std::ostream* pstream__ = 0)
        : prob_grad(0) {
        ctor_body(context__, 0, pstream__);
    }

    rats_model(stan::io::var_context& context__,
        unsigned int random_seed__,
        std::ostream* pstream__ = 0)
        : prob_grad(0) {
        ctor_body(context__, random_seed__, pstream__);
    }

    void ctor_body(stan::io::var_context& context__,
                   unsigned int random_seed__,
                   std::ostream* pstream__) {
        typedef double local_scalar_t__;

        boost::ecuyer1988 base_rng__ =
          stan::services::util::create_rng(random_seed__, 0);
        (void) base_rng__;  // suppress unused var warning

        current_statement_begin__ = -1;

        static const char* function__ = "rats_model_namespace::rats_model";
        (void) function__;  // dummy to suppress unused var warning
        size_t pos__;
        (void) pos__;  // dummy to suppress unused var warning
        std::vector<int> vals_i__;
        std::vector<double> vals_r__;
        local_scalar_t__ DUMMY_VAR__(std::numeric_limits<double>::quiet_NaN());
        (void) DUMMY_VAR__;  // suppress unused var warning

        // initialize member variables
        try {
            current_statement_begin__ = 6;
            context__.validate_dims("data initialization", "N", "int", context__.to_vec());
            N = int(0);
            vals_i__ = context__.vals_i("N");
            pos__ = 0;
            N = vals_i__[pos__++];
            current_statement_begin__ = 7;
            context__.validate_dims("data initialization", "TT", "int", context__.to_vec());
            TT = int(0);
            vals_i__ = context__.vals_i("TT");
            pos__ = 0;
            TT = vals_i__[pos__++];
            current_statement_begin__ = 8;
            validate_non_negative_index("x", "TT", TT);
            context__.validate_dims("data initialization", "x", "double", context__.to_vec(TT));
            validate_non_negative_index("x", "TT", TT);
            x = std::vector<double>(TT,double(0));
            vals_r__ = context__.vals_r("x");
            pos__ = 0;
            size_t x_limit_0__ = TT;
            for (size_t i_0__ = 0; i_0__ < x_limit_0__; ++i_0__) {
                x[i_0__] = vals_r__[pos__++];
            }
            current_statement_begin__ = 9;
            validate_non_negative_index("y", "N", N);
            validate_non_negative_index("y", "TT", TT);
            context__.validate_dims("data initialization", "y", "double", context__.to_vec(N,TT));
            validate_non_negative_index("y", "N", N);
            validate_non_negative_index("y", "TT", TT);
            y = std::vector<std::vector<double> >(N,std::vector<double>(TT,double(0)));
            vals_r__ = context__.vals_r("y");
            pos__ = 0;
            size_t y_limit_1__ = TT;
            for (size_t i_1__ = 0; i_1__ < y_limit_1__; ++i_1__) {
                size_t y_limit_0__ = N;
                for (size_t i_0__ = 0; i_0__ < y_limit_0__; ++i_0__) {
                    y[i_0__][i_1__] = vals_r__[pos__++];
                }
            }
            current_statement_begin__ = 10;
            context__.validate_dims("data initialization", "xbar", "double", context__.to_vec());
            xbar = double(0);
            vals_r__ = context__.vals_r("xbar");
            pos__ = 0;
            xbar = vals_r__[pos__++];

            // validate, data variables
            current_statement_begin__ = 6;
            check_greater_or_equal(function__,"N",N,0);
            current_statement_begin__ = 7;
            check_greater_or_equal(function__,"TT",TT,0);
            current_statement_begin__ = 8;
            current_statement_begin__ = 9;
            current_statement_begin__ = 10;
            // initialize data variables


            // validate transformed data

            // validate, set parameter ranges
            num_params_r__ = 0U;
            param_ranges_i__.clear();
            current_statement_begin__ = 13;
            validate_non_negative_index("alpha", "N", N);
            num_params_r__ += N;
            current_statement_begin__ = 14;
            validate_non_negative_index("beta", "N", N);
            num_params_r__ += N;
            current_statement_begin__ = 16;
            ++num_params_r__;
            current_statement_begin__ = 17;
            ++num_params_r__;
            current_statement_begin__ = 19;
            ++num_params_r__;
            current_statement_begin__ = 20;
            ++num_params_r__;
            current_statement_begin__ = 21;
            ++num_params_r__;
        } catch (const std::exception& e) {
            stan::lang::rethrow_located(e, current_statement_begin__, prog_reader__());
            // Next line prevents compiler griping about no return
            throw std::runtime_error("*** IF YOU SEE THIS, PLEASE REPORT A BUG ***");
        }
    }

    ~rats_model() { }


    void transform_inits(const stan::io::var_context& context__,
                         std::vector<int>& params_i__,
                         std::vector<double>& params_r__,
                         std::ostream* pstream__) const {
        stan::io::writer<double> writer__(params_r__,params_i__);
        size_t pos__;
        (void) pos__; // dummy call to supress warning
        std::vector<double> vals_r__;
        std::vector<int> vals_i__;

        if (!(context__.contains_r("alpha")))
            throw std::runtime_error("variable alpha missing");
        vals_r__ = context__.vals_r("alpha");
        pos__ = 0U;
        validate_non_negative_index("alpha", "N", N);
        context__.validate_dims("initialization", "alpha", "double", context__.to_vec(N));
        std::vector<double> alpha(N,double(0));
        for (int i0__ = 0U; i0__ < N; ++i0__)
            alpha[i0__] = vals_r__[pos__++];
        for (int i0__ = 0U; i0__ < N; ++i0__)
            try {
            writer__.scalar_unconstrain(alpha[i0__]);
        } catch (const std::exception& e) { 
            throw std::runtime_error(std::string("Error transforming variable alpha: ") + e.what());
        }

        if (!(context__.contains_r("beta")))
            throw std::runtime_error("variable beta missing");
        vals_r__ = context__.vals_r("beta");
        pos__ = 0U;
        validate_non_negative_index("beta", "N", N);
        context__.validate_dims("initialization", "beta", "double", context__.to_vec(N));
        std::vector<double> beta(N,double(0));
        for (int i0__ = 0U; i0__ < N; ++i0__)
            beta[i0__] = vals_r__[pos__++];
        for (int i0__ = 0U; i0__ < N; ++i0__)
            try {
            writer__.scalar_unconstrain(beta[i0__]);
        } catch (const std::exception& e) { 
            throw std::runtime_error(std::string("Error transforming variable beta: ") + e.what());
        }

        if (!(context__.contains_r("mu_alpha")))
            throw std::runtime_error("variable mu_alpha missing");
        vals_r__ = context__.vals_r("mu_alpha");
        pos__ = 0U;
        context__.validate_dims("initialization", "mu_alpha", "double", context__.to_vec());
        double mu_alpha(0);
        mu_alpha = vals_r__[pos__++];
        try {
            writer__.scalar_unconstrain(mu_alpha);
        } catch (const std::exception& e) { 
            throw std::runtime_error(std::string("Error transforming variable mu_alpha: ") + e.what());
        }

        if (!(context__.contains_r("mu_beta")))
            throw std::runtime_error("variable mu_beta missing");
        vals_r__ = context__.vals_r("mu_beta");
        pos__ = 0U;
        context__.validate_dims("initialization", "mu_beta", "double", context__.to_vec());
        double mu_beta(0);
        mu_beta = vals_r__[pos__++];
        try {
            writer__.scalar_unconstrain(mu_beta);
        } catch (const std::exception& e) { 
            throw std::runtime_error(std::string("Error transforming variable mu_beta: ") + e.what());
        }

        if (!(context__.contains_r("sigmasq_y")))
            throw std::runtime_error("variable sigmasq_y missing");
        vals_r__ = context__.vals_r("sigmasq_y");
        pos__ = 0U;
        context__.validate_dims("initialization", "sigmasq_y", "double", context__.to_vec());
        double sigmasq_y(0);
        sigmasq_y = vals_r__[pos__++];
        try {
            writer__.scalar_lb_unconstrain(0,sigmasq_y);
        } catch (const std::exception& e) { 
            throw std::runtime_error(std::string("Error transforming variable sigmasq_y: ") + e.what());
        }

        if (!(context__.contains_r("sigmasq_alpha")))
            throw std::runtime_error("variable sigmasq_alpha missing");
        vals_r__ = context__.vals_r("sigmasq_alpha");
        pos__ = 0U;
        context__.validate_dims("initialization", "sigmasq_alpha", "double", context__.to_vec());
        double sigmasq_alpha(0);
        sigmasq_alpha = vals_r__[pos__++];
        try {
            writer__.scalar_lb_unconstrain(0,sigmasq_alpha);
        } catch (const std::exception& e) { 
            throw std::runtime_error(std::string("Error transforming variable sigmasq_alpha: ") + e.what());
        }

        if (!(context__.contains_r("sigmasq_beta")))
            throw std::runtime_error("variable sigmasq_beta missing");
        vals_r__ = context__.vals_r("sigmasq_beta");
        pos__ = 0U;
        context__.validate_dims("initialization", "sigmasq_beta", "double", context__.to_vec());
        double sigmasq_beta(0);
        sigmasq_beta = vals_r__[pos__++];
        try {
            writer__.scalar_lb_unconstrain(0,sigmasq_beta);
        } catch (const std::exception& e) { 
            throw std::runtime_error(std::string("Error transforming variable sigmasq_beta: ") + e.what());
        }

        params_r__ = writer__.data_r();
        params_i__ = writer__.data_i();
    }

    void transform_inits(const stan::io::var_context& context,
                         Eigen::Matrix<double,Eigen::Dynamic,1>& params_r,
                         std::ostream* pstream__) const {
      std::vector<double> params_r_vec;
      std::vector<int> params_i_vec;
      transform_inits(context, params_i_vec, params_r_vec, pstream__);
      params_r.resize(params_r_vec.size());
      for (int i = 0; i < params_r.size(); ++i)
        params_r(i) = params_r_vec[i];
    }


    template <bool propto__, bool jacobian__, typename T__>
    T__ log_prob(vector<T__>& params_r__,
                 vector<int>& params_i__,
                 std::ostream* pstream__ = 0) const {

        typedef T__ local_scalar_t__;

        local_scalar_t__ DUMMY_VAR__(std::numeric_limits<double>::quiet_NaN());
        (void) DUMMY_VAR__;  // suppress unused var warning

        T__ lp__(0.0);
        stan::math::accumulator<T__> lp_accum__;

        try {
            // model parameters
            stan::io::reader<local_scalar_t__> in__(params_r__,params_i__);

            vector<local_scalar_t__> alpha;
            size_t dim_alpha_0__ = N;
            alpha.reserve(dim_alpha_0__);
            for (size_t k_0__ = 0; k_0__ < dim_alpha_0__; ++k_0__) {
                if (jacobian__)
                    alpha.push_back(in__.scalar_constrain(lp__));
                else
                    alpha.push_back(in__.scalar_constrain());
            }

            vector<local_scalar_t__> beta;
            size_t dim_beta_0__ = N;
            beta.reserve(dim_beta_0__);
            for (size_t k_0__ = 0; k_0__ < dim_beta_0__; ++k_0__) {
                if (jacobian__)
                    beta.push_back(in__.scalar_constrain(lp__));
                else
                    beta.push_back(in__.scalar_constrain());
            }

            local_scalar_t__ mu_alpha;
            (void) mu_alpha;  // dummy to suppress unused var warning
            if (jacobian__)
                mu_alpha = in__.scalar_constrain(lp__);
            else
                mu_alpha = in__.scalar_constrain();

            local_scalar_t__ mu_beta;
            (void) mu_beta;  // dummy to suppress unused var warning
            if (jacobian__)
                mu_beta = in__.scalar_constrain(lp__);
            else
                mu_beta = in__.scalar_constrain();

            local_scalar_t__ sigmasq_y;
            (void) sigmasq_y;  // dummy to suppress unused var warning
            if (jacobian__)
                sigmasq_y = in__.scalar_lb_constrain(0,lp__);
            else
                sigmasq_y = in__.scalar_lb_constrain(0);

            local_scalar_t__ sigmasq_alpha;
            (void) sigmasq_alpha;  // dummy to suppress unused var warning
            if (jacobian__)
                sigmasq_alpha = in__.scalar_lb_constrain(0,lp__);
            else
                sigmasq_alpha = in__.scalar_lb_constrain(0);

            local_scalar_t__ sigmasq_beta;
            (void) sigmasq_beta;  // dummy to suppress unused var warning
            if (jacobian__)
                sigmasq_beta = in__.scalar_lb_constrain(0,lp__);
            else
                sigmasq_beta = in__.scalar_lb_constrain(0);


            // transformed parameters
            current_statement_begin__ = 24;
            local_scalar_t__ sigma_y;
            (void) sigma_y;  // dummy to suppress unused var warning

            stan::math::initialize(sigma_y, DUMMY_VAR__);
            stan::math::fill(sigma_y,DUMMY_VAR__);
            current_statement_begin__ = 25;
            local_scalar_t__ sigma_alpha;
            (void) sigma_alpha;  // dummy to suppress unused var warning

            stan::math::initialize(sigma_alpha, DUMMY_VAR__);
            stan::math::fill(sigma_alpha,DUMMY_VAR__);
            current_statement_begin__ = 26;
            local_scalar_t__ sigma_beta;
            (void) sigma_beta;  // dummy to suppress unused var warning

            stan::math::initialize(sigma_beta, DUMMY_VAR__);
            stan::math::fill(sigma_beta,DUMMY_VAR__);


            current_statement_begin__ = 28;
            stan::math::assign(sigma_y, stan::math::sqrt(sigmasq_y));
            current_statement_begin__ = 29;
            stan::math::assign(sigma_alpha, stan::math::sqrt(sigmasq_alpha));
            current_statement_begin__ = 30;
            stan::math::assign(sigma_beta, stan::math::sqrt(sigmasq_beta));

            // validate transformed parameters
            if (stan::math::is_uninitialized(sigma_y)) {
                std::stringstream msg__;
                msg__ << "Undefined transformed parameter: sigma_y";
                throw std::runtime_error(msg__.str());
            }
            if (stan::math::is_uninitialized(sigma_alpha)) {
                std::stringstream msg__;
                msg__ << "Undefined transformed parameter: sigma_alpha";
                throw std::runtime_error(msg__.str());
            }
            if (stan::math::is_uninitialized(sigma_beta)) {
                std::stringstream msg__;
                msg__ << "Undefined transformed parameter: sigma_beta";
                throw std::runtime_error(msg__.str());
            }

            const char* function__ = "validate transformed params";
            (void) function__;  // dummy to suppress unused var warning
            current_statement_begin__ = 24;
            check_greater_or_equal(function__,"sigma_y",sigma_y,0);
            current_statement_begin__ = 25;
            check_greater_or_equal(function__,"sigma_alpha",sigma_alpha,0);
            current_statement_begin__ = 26;
            check_greater_or_equal(function__,"sigma_beta",sigma_beta,0);

            // model body

            current_statement_begin__ = 33;
            lp_accum__.add(normal_log<propto__>(mu_alpha, 0, 100));
            current_statement_begin__ = 34;
            lp_accum__.add(normal_log<propto__>(mu_beta, 0, 100));
            current_statement_begin__ = 35;
            lp_accum__.add(inv_gamma_log<propto__>(sigmasq_y, 0.001, 0.001));
            current_statement_begin__ = 36;
            lp_accum__.add(inv_gamma_log<propto__>(sigmasq_alpha, 0.001, 0.001));
            current_statement_begin__ = 37;
            lp_accum__.add(inv_gamma_log<propto__>(sigmasq_beta, 0.001, 0.001));
            current_statement_begin__ = 38;
            lp_accum__.add(normal_log<propto__>(alpha, mu_alpha, sigma_alpha));
            current_statement_begin__ = 39;
            lp_accum__.add(normal_log<propto__>(beta, mu_beta, sigma_beta));
            current_statement_begin__ = 40;
            for (int n = 1; n <= N; ++n) {
                current_statement_begin__ = 41;
                for (int t = 1; t <= TT; ++t) {
                    current_statement_begin__ = 42;
                    lp_accum__.add(normal_log<propto__>(get_base1(get_base1(y,n,"y",1),t,"y",2), (get_base1(alpha,n,"alpha",1) + (get_base1(beta,n,"beta",1) * (get_base1(x,t,"x",1) - xbar))), sigma_y));
                }
            }

        } catch (const std::exception& e) {
            stan::lang::rethrow_located(e, current_statement_begin__, prog_reader__());
            // Next line prevents compiler griping about no return
            throw std::runtime_error("*** IF YOU SEE THIS, PLEASE REPORT A BUG ***");
        }

        lp_accum__.add(lp__);
        return lp_accum__.sum();

    } // log_prob()

    template <bool propto, bool jacobian, typename T_>
    T_ log_prob(Eigen::Matrix<T_,Eigen::Dynamic,1>& params_r,
               std::ostream* pstream = 0) const {
      std::vector<T_> vec_params_r;
      vec_params_r.reserve(params_r.size());
      for (int i = 0; i < params_r.size(); ++i)
        vec_params_r.push_back(params_r(i));
      std::vector<int> vec_params_i;
      return log_prob<propto,jacobian,T_>(vec_params_r, vec_params_i, pstream);
    }


    void get_param_names(std::vector<std::string>& names__) const {
        names__.resize(0);
        names__.push_back("alpha");
        names__.push_back("beta");
        names__.push_back("mu_alpha");
        names__.push_back("mu_beta");
        names__.push_back("sigmasq_y");
        names__.push_back("sigmasq_alpha");
        names__.push_back("sigmasq_beta");
        names__.push_back("sigma_y");
        names__.push_back("sigma_alpha");
        names__.push_back("sigma_beta");
        names__.push_back("alpha0");
    }


    void get_dims(std::vector<std::vector<size_t> >& dimss__) const {
        dimss__.resize(0);
        std::vector<size_t> dims__;
        dims__.resize(0);
        dims__.push_back(N);
        dimss__.push_back(dims__);
        dims__.resize(0);
        dims__.push_back(N);
        dimss__.push_back(dims__);
        dims__.resize(0);
        dimss__.push_back(dims__);
        dims__.resize(0);
        dimss__.push_back(dims__);
        dims__.resize(0);
        dimss__.push_back(dims__);
        dims__.resize(0);
        dimss__.push_back(dims__);
        dims__.resize(0);
        dimss__.push_back(dims__);
        dims__.resize(0);
        dimss__.push_back(dims__);
        dims__.resize(0);
        dimss__.push_back(dims__);
        dims__.resize(0);
        dimss__.push_back(dims__);
        dims__.resize(0);
        dimss__.push_back(dims__);
    }

    template <typename RNG>
    void write_array(RNG& base_rng__,
                     std::vector<double>& params_r__,
                     std::vector<int>& params_i__,
                     std::vector<double>& vars__,
                     bool include_tparams__ = true,
                     bool include_gqs__ = true,
                     std::ostream* pstream__ = 0) const {
        typedef double local_scalar_t__;

        vars__.resize(0);
        stan::io::reader<local_scalar_t__> in__(params_r__,params_i__);
        static const char* function__ = "rats_model_namespace::write_array";
        (void) function__;  // dummy to suppress unused var warning
        // read-transform, write parameters
        vector<double> alpha;
        size_t dim_alpha_0__ = N;
        for (size_t k_0__ = 0; k_0__ < dim_alpha_0__; ++k_0__) {
            alpha.push_back(in__.scalar_constrain());
        }
        vector<double> beta;
        size_t dim_beta_0__ = N;
        for (size_t k_0__ = 0; k_0__ < dim_beta_0__; ++k_0__) {
            beta.push_back(in__.scalar_constrain());
        }
        double mu_alpha = in__.scalar_constrain();
        double mu_beta = in__.scalar_constrain();
        double sigmasq_y = in__.scalar_lb_constrain(0);
        double sigmasq_alpha = in__.scalar_lb_constrain(0);
        double sigmasq_beta = in__.scalar_lb_constrain(0);
            for (int k_0__ = 0; k_0__ < N; ++k_0__) {
            vars__.push_back(alpha[k_0__]);
            }
            for (int k_0__ = 0; k_0__ < N; ++k_0__) {
            vars__.push_back(beta[k_0__]);
            }
        vars__.push_back(mu_alpha);
        vars__.push_back(mu_beta);
        vars__.push_back(sigmasq_y);
        vars__.push_back(sigmasq_alpha);
        vars__.push_back(sigmasq_beta);

        // declare and define transformed parameters
        double lp__ = 0.0;
        (void) lp__;  // dummy to suppress unused var warning
        stan::math::accumulator<double> lp_accum__;

        local_scalar_t__ DUMMY_VAR__(std::numeric_limits<double>::quiet_NaN());
        (void) DUMMY_VAR__;  // suppress unused var warning

        try {
            current_statement_begin__ = 24;
            local_scalar_t__ sigma_y;
            (void) sigma_y;  // dummy to suppress unused var warning

            stan::math::initialize(sigma_y, DUMMY_VAR__);
            stan::math::fill(sigma_y,DUMMY_VAR__);
            current_statement_begin__ = 25;
            local_scalar_t__ sigma_alpha;
            (void) sigma_alpha;  // dummy to suppress unused var warning

            stan::math::initialize(sigma_alpha, DUMMY_VAR__);
            stan::math::fill(sigma_alpha,DUMMY_VAR__);
            current_statement_begin__ = 26;
            local_scalar_t__ sigma_beta;
            (void) sigma_beta;  // dummy to suppress unused var warning

            stan::math::initialize(sigma_beta, DUMMY_VAR__);
            stan::math::fill(sigma_beta,DUMMY_VAR__);


            current_statement_begin__ = 28;
            stan::math::assign(sigma_y, stan::math::sqrt(sigmasq_y));
            current_statement_begin__ = 29;
            stan::math::assign(sigma_alpha, stan::math::sqrt(sigmasq_alpha));
            current_statement_begin__ = 30;
            stan::math::assign(sigma_beta, stan::math::sqrt(sigmasq_beta));

            // validate transformed parameters
            current_statement_begin__ = 24;
            check_greater_or_equal(function__,"sigma_y",sigma_y,0);
            current_statement_begin__ = 25;
            check_greater_or_equal(function__,"sigma_alpha",sigma_alpha,0);
            current_statement_begin__ = 26;
            check_greater_or_equal(function__,"sigma_beta",sigma_beta,0);

            // write transformed parameters
            if (include_tparams__) {
        vars__.push_back(sigma_y);
        vars__.push_back(sigma_alpha);
        vars__.push_back(sigma_beta);
            }
            if (!include_gqs__) return;
            // declare and define generated quantities
            current_statement_begin__ = 46;
            local_scalar_t__ alpha0;
            (void) alpha0;  // dummy to suppress unused var warning

            stan::math::initialize(alpha0, DUMMY_VAR__);
            stan::math::fill(alpha0,DUMMY_VAR__);


            current_statement_begin__ = 47;
            stan::math::assign(alpha0, (mu_alpha - (xbar * mu_beta)));

            // validate generated quantities
            current_statement_begin__ = 46;

            // write generated quantities
        vars__.push_back(alpha0);

        } catch (const std::exception& e) {
            stan::lang::rethrow_located(e, current_statement_begin__, prog_reader__());
            // Next line prevents compiler griping about no return
            throw std::runtime_error("*** IF YOU SEE THIS, PLEASE REPORT A BUG ***");
        }
    }

    template <typename RNG>
    void write_array(RNG& base_rng,
                     Eigen::Matrix<double,Eigen::Dynamic,1>& params_r,
                     Eigen::Matrix<double,Eigen::Dynamic,1>& vars,
                     bool include_tparams = true,
                     bool include_gqs = true,
                     std::ostream* pstream = 0) const {
      std::vector<double> params_r_vec(params_r.size());
      for (int i = 0; i < params_r.size(); ++i)
        params_r_vec[i] = params_r(i);
      std::vector<double> vars_vec;
      std::vector<int> params_i_vec;
      write_array(base_rng,params_r_vec,params_i_vec,vars_vec,include_tparams,include_gqs,pstream);
      vars.resize(vars_vec.size());
      for (int i = 0; i < vars.size(); ++i)
        vars(i) = vars_vec[i];
    }

    static std::string model_name() {
        return "rats_model";
    }


    void constrained_param_names(std::vector<std::string>& param_names__,
                                 bool include_tparams__ = true,
                                 bool include_gqs__ = true) const {
        std::stringstream param_name_stream__;
        for (int k_0__ = 1; k_0__ <= N; ++k_0__) {
            param_name_stream__.str(std::string());
            param_name_stream__ << "alpha" << '.' << k_0__;
            param_names__.push_back(param_name_stream__.str());
        }
        for (int k_0__ = 1; k_0__ <= N; ++k_0__) {
            param_name_stream__.str(std::string());
            param_name_stream__ << "beta" << '.' << k_0__;
            param_names__.push_back(param_name_stream__.str());
        }
        param_name_stream__.str(std::string());
        param_name_stream__ << "mu_alpha";
        param_names__.push_back(param_name_stream__.str());
        param_name_stream__.str(std::string());
        param_name_stream__ << "mu_beta";
        param_names__.push_back(param_name_stream__.str());
        param_name_stream__.str(std::string());
        param_name_stream__ << "sigmasq_y";
        param_names__.push_back(param_name_stream__.str());
        param_name_stream__.str(std::string());
        param_name_stream__ << "sigmasq_alpha";
        param_names__.push_back(param_name_stream__.str());
        param_name_stream__.str(std::string());
        param_name_stream__ << "sigmasq_beta";
        param_names__.push_back(param_name_stream__.str());

        if (!include_gqs__ && !include_tparams__) return;

        if (include_tparams__) {
            param_name_stream__.str(std::string());
            param_name_stream__ << "sigma_y";
            param_names__.push_back(param_name_stream__.str());
            param_name_stream__.str(std::string());
            param_name_stream__ << "sigma_alpha";
            param_names__.push_back(param_name_stream__.str());
            param_name_stream__.str(std::string());
            param_name_stream__ << "sigma_beta";
            param_names__.push_back(param_name_stream__.str());
        }


        if (!include_gqs__) return;
        param_name_stream__.str(std::string());
        param_name_stream__ << "alpha0";
        param_names__.push_back(param_name_stream__.str());
    }


    void unconstrained_param_names(std::vector<std::string>& param_names__,
                                   bool include_tparams__ = true,
                                   bool include_gqs__ = true) const {
        std::stringstream param_name_stream__;
        for (int k_0__ = 1; k_0__ <= N; ++k_0__) {
            param_name_stream__.str(std::string());
            param_name_stream__ << "alpha" << '.' << k_0__;
            param_names__.push_back(param_name_stream__.str());
        }
        for (int k_0__ = 1; k_0__ <= N; ++k_0__) {
            param_name_stream__.str(std::string());
            param_name_stream__ << "beta" << '.' << k_0__;
            param_names__.push_back(param_name_stream__.str());
        }
        param_name_stream__.str(std::string());
        param_name_stream__ << "mu_alpha";
        param_names__.push_back(param_name_stream__.str());
        param_name_stream__.str(std::string());
        param_name_stream__ << "mu_beta";
        param_names__.push_back(param_name_stream__.str());
        param_name_stream__.str(std::string());
        param_name_stream__ << "sigmasq_y";
        param_names__.push_back(param_name_stream__.str());
        param_name_stream__.str(std::string());
        param_name_stream__ << "sigmasq_alpha";
        param_names__.push_back(param_name_stream__.str());
        param_name_stream__.str(std::string());
        param_name_stream__ << "sigmasq_beta";
        param_names__.push_back(param_name_stream__.str());

        if (!include_gqs__ && !include_tparams__) return;

        if (include_tparams__) {
            param_name_stream__.str(std::string());
            param_name_stream__ << "sigma_y";
            param_names__.push_back(param_name_stream__.str());
            param_name_stream__.str(std::string());
            param_name_stream__ << "sigma_alpha";
            param_names__.push_back(param_name_stream__.str());
            param_name_stream__.str(std::string());
            param_name_stream__ << "sigma_beta";
            param_names__.push_back(param_name_stream__.str());
        }


        if (!include_gqs__) return;
        param_name_stream__.str(std::string());
        param_name_stream__ << "alpha0";
        param_names__.push_back(param_name_stream__.str());
    }

}; // model

}

typedef rats_model_namespace::rats_model stan_model;

