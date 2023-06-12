using DataFrames, GLM, StatsBase, CSV, Tidier, DataFramesMeta
include("def_data_type.jl")
include("calc_goodness.jl")
include("estimate_models.jl")

# import the data
raw_data  = CSV.read("/Volumes/XXK-DISK/project9_fmri_spatial_stroop/data/input/behavioral_data/all_data.csv", DataFrame)
save_path = "/Volumes/XXK-DISK/project9_fmri_spatial_stroop/data/output/model_estimation/reinforcement_learning/single_sub"

# get basic parameters
sub_list = unique(raw_data[!,:sub_num])

###### estimate models
sub_num_i = 9
print("=== Estimate the data for $sub_num_i === \n")
# 选出单被试数据
single_sub_data = @subset(raw_data, :sub_num .== sub_num_i)

# 选出用于分析的向量
stim_loc_vector   = single_sub_data[!, :stim_loc_num]     # 上为 0，下为 1
stim_text_vector  = single_sub_data[!, :stim_text_num]    # 上为 0， 下为 1
resp_vector       = single_sub_data[!, :corr_resp_num]    # 左手为 0， 右手为 1
congruency_vector = single_sub_data[!, :congruency_num]   # con 为 0， inc 为 1
volatile_vector   = single_sub_data[!, :volatile_num]     # 稳定为 0， 不稳定为 1


# SR-Volatile
print("=== SR-Volatile === \n")
sub_num_list = []
alpha_s_list = []
alpha_v_list = []
loglikelihood_list = []
alpha_s = 0.02
alpha_v = 0.02
input_data = rl_sr_volatility_data(alpha_s, alpha_v, stim_loc_vector, resp_vector, volatile_vector)

rl_model_result = sr_volatility_model(input_data.α_s,
										input_data.α_v,
										input_data.stim_loc_seq,
										input_data.reaction_loc_seq,
										input_data.exp_volatility_seq)
# calc stim left part
stim_loc_left  = convert(Vector{Bool}, abs.(rl_sr_volatility_data.stim_loc_seq .- 1))
stim_loc_right = convert(Vector{Bool}, rl_sr_volatility_data.stim_loc_seq)

# lm_data_l = DataFrame(;
#                       stim_feature_seq=rl_sr_volatility_data.reaction_loc_seq[stim_loc_left],
#                       predicted_probability=rl_model_result["Predicied Left sequence"])
# lm_data_r = DataFrame(;
#                       stim_feature_seq=rl_sr_volatility_data.reaction_loc_seq[stim_loc_right],
#                       predicted_probability=rl_model_result["Predicied Right sequence"])
# fit_l = glm(@formula(stim_feature_seq ~ predicted_probability), lm_data_l, Binomial(),
#             ProbitLink())
# fit_r = glm(@formula(stim_feature_seq ~ predicted_probability), lm_data_r, Binomial(),
#             ProbitLink())
print("breakpoint1")
lm_data = DataFrame(stim_feature_seq=input_data.reaction_loc_seq,
				 predicted_probability=rl_model_result["Predicted sequence"])
fit_goodness = glm(@formula(stim_feature_seq ~ predicted_probability), lm_data, Binomial(),
			ProbitLink())

push!(sub_num_list, sub_num_i)
push!(alpha_s_list, alpha_s)
push!(alpha_v_list, alpha_v)
push!(loglikelihood_list, idx)
SR_volatile_result = DataFrame(sub_num = sub_num_list, alpha_s = alpha_s_list, alpha_v = alpha_v_list, loglikelihood = loglikelihood_list)
