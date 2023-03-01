#TODO: To quick fix the problem of the unequal number of :stim_feature_seq and :predicted_probability,
#      I just remove the index of :stim_feature_seq in rl_sr_sep_alpha_volatility_data().
#      Please make each function consistent if needed.

## Calc goodness of fit
function calc_rl_fit_goodness(rl_ab_data::rl_ab_data; fit_idx="loglikelihood")
    rl_model_result       = ab_model(rl_ab_data.α, rl_ab_data.stim_consistency_seq)
    predicted_probability = rl_model_result["Predicted sequence"]
    lm_data               = DataFrame(; stim_feature_seq=rl_ab_data.stim_consistency_seq,
                                      predicted_probability=predicted_probability)
    fit                   = glm(@formula(stim_feature_seq ~ predicted_probability),
                                lm_data, Binomial(), ProbitLink())
    fit_goodness          = calc_fit_idx(fit, fit_idx)

    return (fit_goodness)
end

function calc_rl_fit_goodness(rl_ab_volatility_data::rl_ab_volatility_data;
                              fit_idx="loglikelihood")
    rl_model_result = ab_volatility_model(rl_ab_volatility_data.α_s,
                                          rl_ab_volatility_data.α_v,
                                          rl_ab_volatility_data.stim_consistency_seq,
                                          rl_ab_volatility_data.exp_volatility_seq)
    predicted_probability = rl_model_result["Predicted sequence"]
    lm_data = DataFrame(; stim_feature_seq=rl_ab_volatility_data.stim_consistency_seq,
                        predicted_probability=predicted_probability)
    fit = glm(@formula(stim_feature_seq ~ predicted_probability), lm_data, Binomial(),
              ProbitLink())

    fit_goodness = calc_fit_idx(fit, fit_idx)

    return (fit_goodness)
end

function calc_rl_fit_goodness(rl_sr_sep_alpha_data::rl_sr_sep_alpha_data; fit_idx="loglikelihood")
    rl_model_result = sr_sep_alpha_model(rl_sr_sep_alpha_data.α_l, 
                                         rl_sr_sep_alpha_data.α_r,
                                         rl_sr_sep_alpha_data.stim_loc_seq,
                                         rl_sr_sep_alpha_data.reaction_loc_seq)
    predicted_probability = rl_model_result["Predicted sequence"]

    # calc stim left part
    stim_loc_left = convert(Vector{Bool}, abs.(rl_sr_data.stim_loc_seq .- 1))
    stim_loc_right = convert(Vector{Bool}, rl_sr_data.stim_loc_seq)

    lm_data_l = DataFrame(;
                          stim_feature_seq=rl_sr_sep_alpha_volatility_data.reaction_loc_seq[stim_loc_left],
                          predicted_probability=predicted_probability["Predicied Left sequence"])
    lm_data_r = DataFrame(;
                          stim_feature_seq=rl_sr_sep_alpha_volatility_data.reaction_loc_seq[stim_loc_right],
                          predicted_probability=predicted_probability["Predicied Right sequence"])
    fit_l = glm(@formula(stim_feature_seq ~ predicted_probability), lm_data_l, Binomial(),
                ProbitLink())
    fit_r = glm(@formula(stim_feature_seq ~ predicted_probability), lm_data_r, Binomial(),
                ProbitLink())

    fit_goodness = (calc_fit_idx(fit_l, fit_idx) + calc_fit_idx(fit_r, fit_idx))

    return (fit_goodness)
end

function calc_rl_fit_goodness(rl_sr_sep_alpha_data::rl_sr_sep_alpha_data;
                              fit_idx="loglikelihood")
    rl_model_result = sr_sep_alpha_model(rl_sr_sep_alpha_data.α_l, 
                                         rl_sr_sep_alpha_data.α_r,
                                         rl_sr_sep_alpha_data.stim_loc_seq,
                                         rl_sr_sep_alpha_data.reaction_loc_seq)
    predicted_probability = rl_model_result["Predicted sequence"]

    # calc stim left part
    stim_loc_left = convert(Vector{Bool}, abs.(rl_sr_sep_alpha_data.stim_loc_seq .- 1))
    stim_loc_right = convert(Vector{Bool}, rl_sr_sep_alpha_data.stim_loc_seq)

    lm_data_l = DataFrame(;
                          stim_feature_seq=rl_sr_sep_alpha_data.reaction_loc_seq[stim_loc_left],
                          predicted_probability=rl_model_result["Predicied Left sequence"])
    lm_data_r = DataFrame(;
                          stim_feature_seq=rl_sr_sep_alpha_data.reaction_loc_seq[stim_loc_right],
                          predicted_probability=rl_model_result["Predicied Right sequence"])
    fit_l = glm(@formula(stim_feature_seq ~ predicted_probability), lm_data_l, Binomial(),
                ProbitLink())
    fit_r = glm(@formula(stim_feature_seq ~ predicted_probability), lm_data_r, Binomial(),
                ProbitLink())

    fit_goodness = (calc_fit_idx(fit_l, fit_idx) + calc_fit_idx(fit_r, fit_idx))

    return (fit_goodness)
end

function calc_rl_fit_goodness(rl_sr_volatility_data::rl_sr_volatility_data;
                              fit_idx="loglikelihood")
    rl_model_result = sr_volatility_model(rl_sr_volatility_data.α_s,
                                          rl_sr_volatility_data.α_v,
                                          rl_sr_volatility_data.stim_loc_seq,
                                          rl_sr_volatility_data.reaction_loc_seq,
                                          rl_sr_volatility_data.exp_volatility_seq)
    predicted_probability = rl_model_result["Predicted sequence"]

    # calc stim left part
    stim_loc_left  = convert(Vector{Bool}, abs.(rl_sr_volatility_data.stim_loc_seq .- 1))
    stim_loc_right = convert(Vector{Bool}, rl_sr_volatility_data.stim_loc_seq)

    lm_data_l = DataFrame(;
                          stim_feature_seq=rl_sr_volatility_data.reaction_loc_seq[stim_loc_left],
                          predicted_probability=rl_model_result["Predicied Left sequence"])
    lm_data_r = DataFrame(;
                          stim_feature_seq=rl_sr_volatility_data.reaction_loc_seq[stim_loc_right],
                          predicted_probability=rl_model_result["Predicied Right sequence"])
    fit_l = glm(@formula(stim_feature_seq ~ predicted_probability), lm_data_l, Binomial(),
                ProbitLink())
    fit_r = glm(@formula(stim_feature_seq ~ predicted_probability), lm_data_r, Binomial(),
                ProbitLink())

    fit_goodness = (calc_fit_idx(fit_l, fit_idx) + calc_fit_idx(fit_r, fit_idx))

    return (fit_goodness)
end

function calc_rl_fit_goodness(rl_sr_sep_alpha_volatility_data::rl_sr_sep_alpha_volatility_data;
                              fit_idx="loglikelihood")
    rl_model_result = sr_sep_alpha_volatility_model(rl_sr_sep_alpha_volatility_data.α_s_l,
                                                    rl_sr_sep_alpha_volatility_data.α_s_r,
                                                    rl_sr_sep_alpha_volatility_data.α_v_l,
                                                    rl_sr_sep_alpha_volatility_data.α_v_r,
                                                    rl_sr_sep_alpha_volatility_data.stim_loc_seq,
                                                    rl_sr_sep_alpha_volatility_data.reaction_loc_seq,
                                                    rl_sr_sep_alpha_volatility_data.exp_volatility_seq)
    predicted_probability = rl_model_result["Predicted sequence"]

    # calc stim left part
    stim_loc_left = convert(Vector{Bool},
                            abs.(rl_sr_sep_alpha_volatility_data.stim_loc_seq .- 1))
    stim_loc_right = convert(Vector{Bool}, rl_sr_sep_alpha_volatility_data.stim_loc_seq)

    lm_data_l = DataFrame(;
                          stim_feature_seq=rl_sr_sep_alpha_volatility_data.reaction_loc_seq,
                          predicted_probability=rl_model_result["Predicied Left sequence"])
    lm_data_r = DataFrame(;
                          stim_feature_seq=rl_sr_sep_alpha_volatility_data.reaction_loc_seq,
                          predicted_probability=rl_model_result["Predicied Right sequence"])
    fit_l = glm(@formula(stim_feature_seq ~ predicted_probability), lm_data_l, Binomial(),
                ProbitLink())
    fit_r = glm(@formula(stim_feature_seq ~ predicted_probability), lm_data_r, Binomial(),
                ProbitLink())

    fit_goodness = (calc_fit_idx(fit_l, fit_idx) + calc_fit_idx(fit_r, fit_idx))

    return (fit_goodness)
end