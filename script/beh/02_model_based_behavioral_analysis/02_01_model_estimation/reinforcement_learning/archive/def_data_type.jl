## 拟合估计模型参数
using DataFrames, GLM, StatsBase

# 构建输入数据结构体以实现多重派发

struct rl_ab_data
    α::Float64
    stim_consistency_seq::Vector{Int}
end

struct rl_ab_volatility_data
    α_s::Float64
    α_v::Float64
    stim_consistency_seq::Vector{Int}
    exp_volatility_seq::Vector{Int}
end

struct rl_sr_data
    α::Float64
    stim_loc_seq::Vector{Int}
    reaction_loc_seq::Vector{Int}
end

struct rl_sr_volatility_data
    α_s::Float64
    α_v::Float64
    stim_loc_seq::Vector{Int}
    reaction_loc_seq::Vector{Int}
    exp_volatility_seq::Vector{Int}
end

struct rl_sr_sep_alpha_data
    α_l::Float64
    α_r::Float64
    stim_loc_seq::Vector{Int}
    reaction_loc_seq::Vector{Int}
end

struct rl_sr_sep_alpha_volatility_data
    α_s_l::Float64
    α_s_r::Float64
    α_v_l::Float64
    α_v_r::Float64
    stim_loc_seq::Vector{Int}
    reaction_loc_seq::Vector{Int}
    exp_volatility_seq::Vector{Int}
end

# 构建计算 loglikelihood 的函数

## helper functions
function calc_fit_idx(model_fitting, fit_idx)
    if fit_idx == "loglikelihood"
        return loglikelihood(model_fitting)
    elseif fit_idx == "aic"
        return aic(model_fitting)
    elseif fit_idx == "bic"
        return bic(model_fitting)
    elseif fit_idx == "mse"
        return deviance(model_fitting)/dof_residual(model_fitting)
    end
end


