#= 
尝试使用 concate 模型学习 con/inc 来对概率进行估计
即左侧空间位置学习左反应，右侧空间位置学习右反应
=#
function sr_volatility_model(α_s::Float64, α_v::Float64,
	stim_loc_seq, hand_to_con, exp_volatility_seq;
	drop_last_one = true)

	# Init predict code sequence
	predict_seq = Vector{Float64}(undef, length(stim_loc_seq))
	prediction_error_seq = Vector{Float64}(undef, length(stim_loc_seq))
	predict_seq_l_l = [0.5]
	predict_seq_r_r = [0.5]
	predict_l_l = 0.5
	predict_r_r = 0.5
	predict_seq[1] = 0.5

	# Update predict code sequence
	for i in 1:length(stim_loc_seq)
		if exp_volatility_seq[i] == 0
			if stim_loc_seq[i] == 0 # Stim come from left
				predict_seq[i] = predict_l_l
				PE = hand_to_con[i] - predict_l_l
				predict_l_l = predict_l_l + α_s * PE
				push!(predict_seq_l_l, predict_l_l + α_s * PE)
				push!(predict_seq_r_r, predict_r_r)
				prediction_error_seq[i] = PE
			else
				predict_seq[i] = predict_r_r
				PE = hand_to_con[i] - predict_r_r
				predict_r_r = predict_r_r + α_s * PE
				push!(predict_seq_l_l, predict_l_l)
				push!(predict_seq_r_r, predict_r_r + α_s * PE)
				prediction_error_seq[i] = PE
			end
		else
			if stim_loc_seq[i] == 0 # Stim come from left
				predict_seq[i] = predict_l_l
				PE = hand_to_con[i] - predict_l_l
				predict_l_l = predict_l_l + α_v * PE
				push!(predict_seq_l_l, predict_l_l + α_v * PE)
				push!(predict_seq_r_r, predict_r_r)
				prediction_error_seq[i] = PE
			else
				predict_seq[i] = predict_r_r
				PE = hand_to_con[i] - predict_r_r
				predict_r_r = predict_r_r + α_v * PE
				push!(predict_seq_l_l, predict_l_l)
				push!(predict_seq_r_r, predict_r_r + α_v * PE)
				prediction_error_seq[i] = PE
			end
		end
	end

	# Return the result
	if drop_last_one
		return Dict("Predicted sequence" => predict_seq,
			"Prediciton error" => prediction_error_seq,
			"Predicied Left sequence" => predict_seq_l_l[1:(length(predict_seq_l_l)-1)],
			"Predicied Right sequence" => predict_seq_r_r[1:(length(predict_seq_r_r)-1)])
	else
		return Dict("Predicted sequence" => predict_seq,
			"Prediciton error" => prediction_error_seq,
			"Predicied Left sequence" => predict_seq_l_l,
			"Predicied Right sequence" => predict_seq_r_r)
	end
end

function calc_fit_idx(model_fitting, fit_idx)
	if fit_idx == "loglikelihood"
		return loglikelihood(model_fitting)
	elseif fit_idx == "aic"
		return aic(model_fitting)
	elseif fit_idx == "bic"
		return bic(model_fitting)
	elseif fit_idx == "mse"
		return deviance(model_fitting) / dof_residual(model_fitting)
	end
end

using DataFrames, DataFramesMeta, CSV, GLM, StatsBase
raw_data = DataFrame(CSV.File("/Users/dddd1007/Library/CloudStorage/Dropbox/工作/博士工作/实验数据与程序/Project0_cognitive_control_model/data/input/all_data_with_concate_learn_congruency.csv"))

nodenames = ["sub_num", "α_s", "α_v", "loglikelihood"]
result_table = DataFrame([[] for _ in nodenames], nodenames)
for sub_num in unique(raw_data."Subject_num")
	single_sub_data = @subset(raw_data, :Subject_num .== sub_num)
	stim_loc_seq = single_sub_data."stim_loc_num"
	hand_to_con = single_sub_data."hand_to_con"
	exp_volatility_seq = single_sub_data."volatile_factor"
	for α_s in collect(0.01:0.01:1)
		for α_v in collect(0.01:0.01:1)
			rl_model_result = sr_volatility_model(α_s, α_v,
				stim_loc_seq, hand_to_con, exp_volatility_seq;
				drop_last_one = true)
			predicted_probability = rl_model_result["Predicted sequence"]

			stim_loc_left = convert(Vector{Bool}, abs.(stim_loc_seq .- 1))
			stim_loc_right = convert(Vector{Bool}, stim_loc_seq)
			lm_data_l = DataFrame(;
				stim_feature_seq = hand_to_con[stim_loc_left],
				predicted_probability = rl_model_result["Predicied Left sequence"][stim_loc_left])
			lm_data_r = DataFrame(;
				stim_feature_seq = hand_to_con[stim_loc_right],
				predicted_probability = rl_model_result["Predicied Right sequence"][stim_loc_right])
			fit_l = glm(@formula(stim_feature_seq ~ predicted_probability), lm_data_l, Binomial(),
				ProbitLink())
			fit_r = glm(@formula(stim_feature_seq ~ predicted_probability), lm_data_r, Binomial(),
				ProbitLink())

			fit_idx = "loglikelihood"
			fit_goodness = (calc_fit_idx(fit_l, fit_idx) + calc_fit_idx(fit_r, fit_idx))
			push!(result_table, [sub_num, α_s, α_v, fit_goodness])
		end
	end
end

CSV.write("/Users/dddd1007/Library/CloudStorage/Dropbox/工作/博士工作/实验数据与程序/Project0_cognitive_control_model/data/output/rl_model_estimate_by_stim/rl_sr_hand_to_con.csv", result_table)

# 计算每个最优参数对应的序列
best_param_set = DataFrame(CSV.File("/Users/dddd1007/Library/CloudStorage/Dropbox/工作/博士工作/实验数据与程序/Project0_cognitive_control_model/data/output/rl_model_estimate_by_stim/sr_hand_to_con_param_set.csv"))

result_table = DataFrame([[],[],[],[],[]], ["sub_num", "rl_sr_con_ll", "rl_sr_con_rr", "rl_sr_con_pe", "rl_sr_con_p"])
for i in unique(best_param_set."sub_num")
    sub_param = @subset(best_param_set, :sub_num .== i)
    single_sub_data = @subset(raw_data, :Subject_num .== i)
	stim_loc_seq = single_sub_data."stim_loc_num"
	hand_to_con = single_sub_data."hand_to_con"
	exp_volatility_seq = single_sub_data."volatile_factor"
    α_s = sub_param.α_s[1]
    α_v = sub_param.α_v[1]
    rl_model_result = sr_volatility_model(α_s, α_v,
				                          stim_loc_seq, hand_to_con, exp_volatility_seq;
				                          drop_last_one = true)
    foo = hcat(repeat([i],length(rl_model_result["Predicied Left sequence"])), 
               rl_model_result["Predicied Left sequence"], 
               rl_model_result["Predicied Right sequence"], 
               rl_model_result["Prediciton error"],
               rl_model_result["Predicted sequence"])
    result_table = vcat(result_table, DataFrame(foo, ["sub_num", "rl_sr_con_ll", "rl_sr_con_rr", "rl_sr_con_pe", "rl_sr_con_p"]))
end
    
CSV.write("/Users/dddd1007/Library/CloudStorage/Dropbox/工作/博士工作/实验数据与程序/Project0_cognitive_control_model/data/input/rl_sr_con_p.csv", result_table)
