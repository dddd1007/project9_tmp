α_s_l = 0.1
α_s_r = 0.1
α_v_l = 0.1
α_v_r = 0.1
stim_loc_seq = [1, 1, 0, 0, 0, 1, 1, 1, 1, 1]
reaction_loc_seq = [1, 1, 1, 0, 0, 1, 0, 1, 0, 0]
exp_volatility_seq = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

# Init predict code sequence
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
			predict_l_l = predict_l_l + α_s_l * PE
			push!(predict_seq_l, predict_l_l + α_s_l * PE)
			push!(predict_seq_r, predict_r_l)
			prediction_error_seq[i] = PE
		else
			predict_seq[i] = predict_r_l
			PE = reaction_loc_seq[i] - predict_r_l
			predict_r_l = predict_r_l + α_s_r * PE
			push!(predict_seq_l, predict_l_l)
			push!(predict_seq_r, predict_r_l + α_s_r * PE)
			prediction_error_seq[i] = PE
		end
	else
		if stim_loc_seq[i] == 0 # Stim come from bottom
			predict_seq[i] = predict_l_l
			PE = reaction_loc_seq[i] - predict_l_l
			predict_l_l = predict_l_l + α_v_l * PE
			push!(predict_seq_l, predict_l_l + α_v_l * PE)
            print("Idx " * string(i) * " and ")
			push!(predict_seq_r, predict_r_l)
			prediction_error_seq[i] = PE
		else
			predict_seq[i] = predict_r_l
			PE = reaction_loc_seq[i] - predict_r_l
			predict_r_l = predict_r_l + α_v_r * PE
			push!(predict_seq_l, predict_l_l)
			push!(predict_seq_r, predict_r_l + α_v_r * PE)
			prediction_error_seq[i] = PE
		end
	end
end