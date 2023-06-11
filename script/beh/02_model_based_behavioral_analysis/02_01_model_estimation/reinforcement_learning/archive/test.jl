aft_s_l = 1
aft_s_r = 1
aft_v_l = 0.13
aft_v_r = 0.13

bef_s_l = 0.14
bef_s_r = 0.14
bef_v_l = 0.23
bef_v_r = 0.23

## import sub1 data

# Init predict code sequence
using CSV, DataFrames, DataFramesMeta
raw_data = CSV.read("/Volumes/XXK-DISK/project9_fmri_spatial_stroop/data/input/behavioral_data/all_data.csv", DataFrame)
sub9_data = @where(raw_data, :sub_num .== 9)

# extract data to sequence
stim_loc_seq = sub9_data.stim_loc_num
reaction_loc_seq = sub9_data.corr_resp_num
exp_volatility_seq = sub9_data.volatile_num

## Estimate aft sequence
# init the value
predict_seq = Vector{Float64}(undef, length(stim_loc_seq))
prediction_error_seq = Vector{Float64}(undef, length(stim_loc_seq))
predict_seq_l = [0.5]
predict_seq_r = [0.5]
predict_l_l = 0.5
predict_r_l = 0.5
predict_seq[1] = 0.5

for i in 1:length(stim_loc_seq)
	if exp_volatility_seq[i] == 0
		if stim_loc_seq[i] == 0 # Stim come from top
			predict_seq[i] = predict_l_l
			PE = reaction_loc_seq[i] - predict_l_l
			predict_l_l = predict_l_l + aft_s_l * PE
			push!(predict_seq_l, predict_l_l + aft_s_l * PE)
			push!(predict_seq_r, predict_r_l)
			prediction_error_seq[i] = PE
		else
			predict_seq[i] = predict_r_l
			PE = reaction_loc_seq[i] - predict_r_l
			predict_r_l = predict_r_l + aft_s_r * PE
			push!(predict_seq_l, predict_l_l)
			push!(predict_seq_r, predict_r_l + aft_s_r * PE)
			prediction_error_seq[i] = PE
		end
	else
		if stim_loc_seq[i] == 0 # Stim come from bottom
			predict_seq[i] = predict_l_l
			PE = reaction_loc_seq[i] - predict_l_l
			predict_l_l = predict_l_l + aft_v_l * PE
			push!(predict_seq_l, predict_l_l + aft_v_l * PE)
            print("Idx " * string(i) * " and ")
			push!(predict_seq_r, predict_r_l)
			prediction_error_seq[i] = PE
		else
			predict_seq[i] = predict_r_l
			PE = reaction_loc_seq[i] - predict_r_l
			predict_r_l = predict_r_l + aft_v_r * PE
			push!(predict_seq_l, predict_l_l)
			push!(predict_seq_r, predict_r_l + aft_v_r * PE)
			prediction_error_seq[i] = PE
		end
	end
end

aft_prediction_error_seq = prediction_error_seq
aft_lm_data_l = DataFrame(;
	stim_feature_seq=rl_sr_sep_alpha_volatility_data.reaction_loc_seq,
	predicted_probability=rl_model_result["Predicied Left sequence"])
aft_lm_data_r = DataFrame(;
	stim_feature_seq=rl_sr_sep_alpha_volatility_data.reaction_loc_seq,
	predicted_probability=rl_model_result["Predicied Right sequence"])

## Estimate bef sequence
# init the value
predict_seq = Vector{Float64}(undef, length(stim_loc_seq))
prediction_error_seq = Vector{Float64}(undef, length(stim_loc_seq))
predict_seq_l = [0.5]
predict_seq_r = [0.5] bi
predict_l_l = 0.5
predict_r_l = 0.5
predict_seq[1] = 0.5

for i in 1:length(stim_loc_seq)
	if exp_volatility_seq[i] == 0
		if stim_loc_seq[i] == 0 # Stim come from top
			predict_seq[i] = predict_l_l
			PE = reaction_loc_seq[i] - predict_l_l
			predict_l_l = predict_l_l + bef_s_l * PE
			push!(predict_seq_l, predict_l_l + bef_s_l * PE)
			push!(predict_seq_r, predict_r_l)
			prediction_error_seq[i] = PE
		else
			predict_seq[i] = predict_r_l
			PE = reaction_loc_seq[i] - predict_r_l
			predict_r_l = predict_r_l + bef_s_r * PE
			push!(predict_seq_l, predict_l_l)
			push!(predict_seq_r, predict_r_l + bef_s_r * PE)
			prediction_error_seq[i] = PE
		end
	else
		if stim_loc_seq[i] == 0 # Stim come from bottom
			predict_seq[i] = predict_l_l
			PE = reaction_loc_seq[i] - predict_l_l
			predict_l_l = predict_l_l + bef_v_l * PE
			push!(predict_seq_l, predict_l_l + bef_v_l * PE)
			push!(predict_seq_r, predict_r_l)
			prediction_error_seq[i] = PE
		else
			predict_seq[i] = predict_r_l
			PE = reaction_loc_seq[i] - predict_r_l
			predict_r_l = predict_r_l + bef_v_r * PE
			push!(predict_seq_l, predict_l_l)
			push!(predict_seq_r, predict_r_l + bef_v_r * PE)
			prediction_error_seq[i] = PE
		end
	end
end

bef_prediction_error_seq = prediction_error_seq
bef_lm_data_l = DataFrame(;
	stim_feature_seq=rl_sr_sep_alpha_volatility_data.reaction_loc_seq,
	predicted_probability=rl_model_result["Predicied Left sequence"])
bef_lm_data_r = DataFrame(;
	stim_feature_seq=rl_sr_sep_alpha_volatility_data.reaction_loc_seq,
	predicted_probability=rl_model_result["Predicied Right sequence"])

# calc the loglikelihood

aft_fit_l = glm(@formula(stim_feature_seq ~ predicted_probability), aft_lm_data_l, Binomial(),
	ProbitLink())
aft_fit_r = glm(@formula(stim_feature_seq ~ predicted_probability), aft_lm_data_r, Binomial(),
	ProbitLink())
bef_fit_l = glm(@formula(stim_feature_seq ~ predicted_probability), bef_lm_data_l, Binomial(),
	ProbitLink())
bef_fit_r = glm(@formula(stim_feature_seq ~ predicted_probability), bef_lm_data_r, Binomial(),
	ProbitLink())