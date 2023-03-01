using DataFrames, GLM, StatsBase, CSV, DataFramesMeta
include("def_data_type.jl")
include("calc_goodness.jl")
include("estimate_models.jl")

# import the data
raw_data  = CSV.read("/Volumes/ResearchData/project9_fmri_spatial_stroop/data/input/behavioral_data/all_data.csv", DataFrame)
save_path = "/Volumes/ResearchData/project9_fmri_spatial_stroop/data/output/model_estimation/reinforcement_learning/single_sub"

# get basic parameters
sub_list = unique(raw_data[!,:sub_num])

###### estimate models
for sub_num_i in sub_list
    print("=== Estimate the data for $sub_num_i === \n")
    # 选出单被试数据
    single_sub_data = @subset(raw_data, :sub_num .== sub_num_i)

    # 选出用于分析的向量
    stim_loc_vector   = single_sub_data[!, :stim_loc_num]     # 上为0，下为1
    stim_text_vector  = single_sub_data[!, :stim_text_num]    # 上为0， 下为1
    resp_vector       = single_sub_data[!, :corr_resp_num]    # 左手为0， 右手为1
    congruency_vector = single_sub_data[!, :congruency_num]   # con为0， inc为1
    volatile_vector   = single_sub_data[!, :volatile_num]     # 稳定为0， 不稳定为1

    ### 开始进行模型估计

    # AB-NoVolatile
    sub_num_list = []
    alpha_list = []
    loglikelihood_list = []
    for alpha in collect(0.01:0.01:1)
        input_data = rl_ab_data(alpha, congruency_vector)
        idx = calc_rl_fit_goodness(input_data)
        push!(sub_num_list, sub_num_i)
        push!(alpha_list, alpha)
        push!(loglikelihood_list, idx)
    end
    AB_NoVolatile_result = DataFrame(sub_num = sub_num_list, alpha = alpha_list, loglikelihood = loglikelihood_list)
    write_filename = save_path * "/ab_no_v/sub_" * string(sub_num_i) * "_ab_no_v.csv"
    CSV.write(write_filename, AB_NoVolatile_result)

    # AB-Volatile
    sub_num_list = []
    alpha_s_list = []
    alpha_v_list = []
    loglikelihood_list = []
    for alpha_s in collect(0.01:0.01:1)
        for alpha_v in collect(0.01:0.01:1)
            input_data = rl_ab_volatility_data(alpha_s, alpha_v, congruency_vector, volatile_vector)
            idx = calc_rl_fit_goodness(input_data)
            push!(sub_num_list, sub_num_i)
            push!(alpha_s_list, alpha_s)
            push!(alpha_v_list, alpha_v)
            push!(loglikelihood_list, idx)
        end
    end
    AB_Volatile_result = DataFrame(sub_num = sub_num_list, alpha_s = alpha_s_list, alpha_v = alpha_v_list, loglikelihood = loglikelihood_list)
    write_filename = save_path * "/ab_v/sub_" * string(sub_num_i) * "_ab_v.csv"
    CSV.write(write_filename, AB_Volatile_result)

    # SR-NoVolatile
    sub_num_list = []
    alpha_list = []
    loglikelihood_list = []
    for alpha in collect(0.01:0.01:1)
        input_data = rl_sr_sep_alpha_data(alpha, alpha, stim_loc_vector, resp_vector)
        idx = calc_rl_fit_goodness(input_data)
        push!(sub_num_list, sub_num_i)
        push!(alpha_list, alpha)
        push!(loglikelihood_list, idx)
    end
    SR_NoVolatile_result = DataFrame(sub_num = sub_num_list, alpha = alpha_list, loglikelihood = loglikelihood_list)
    write_filename = save_path * "/sr_no_v/sub_" * string(sub_num_i) * "_sr_no_v.csv"
    CSV.write(write_filename, SR_NoVolatile_result)

    # SR-Volatile
    sub_num_list = []
    alpha_s_list = []
    alpha_v_list = []
    loglikelihood_list = []
    for alpha_s in collect(0.01:0.01:1)
        for alpha_v in collect(0.01:0.01:1)
            input_data = rl_sr_sep_alpha_volatility_data(alpha_s, alpha_s, alpha_v, alpha_v, stim_loc_vector, resp_vector, volatile_vector)
            idx = calc_rl_fit_goodness(input_data)
            push!(sub_num_list, sub_num_i)
            push!(alpha_s_list, alpha_s)
            push!(alpha_v_list, alpha_v)
            push!(loglikelihood_list, idx)
        end
    end
    SR_volatile_result = DataFrame(sub_num = sub_num_list, alpha_s = alpha_s_list, alpha_v = alpha_v_list, loglikelihood = loglikelihood_list)
    write_filename = save_path * "/sr_v/sub_" * string(sub_num_i) * "_sr_v.csv"
    CSV.write(write_filename, SR_volatile_result)
end

###### model recovery
optim_param_file_loc = "/Volumes/ResearchData/project9_fmri_spatial_stroop/data/output/model_estimation/reinforcement_learning"
model_type_list = ["ab_no_v", "ab_v", "sr_no_v", "sr_v"]

ab_no_v_p  = []
ab_v_p     = []
sr_no_v_p  = []
sr_v_p     = []
ab_no_v_pe = []
ab_v_pe    = []
sr_no_v_pe = []
sr_v_pe    = []
sr_v_ll    = []
sr_v_rl    = []

for model_type in model_type_list
    file_path = optim_param_file_loc * "/optim_para_" * model_type * ".csv"
    optim_param_table = CSV.read(file_path, DataFrame)

    for sub_num_i in sub_list
        single_sub_param = @subset(optim_param_table, :sub_num .== sub_num_i)
        single_sub_data = @subset(raw_data, :sub_num .== sub_num_i)

        # 选出用于分析的向量
        stim_loc_vector   = single_sub_data[!, :stim_loc_num]     # 上为0，下为1
        stim_text_vector  = single_sub_data[!, :stim_text_num]    # 上为0， 下为1
        resp_vector       = single_sub_data[!, :corr_resp_num]    # 左手为0， 右手为1
        congruency_vector = single_sub_data[!, :congruency_num]   # con为0， inc为1
        volatile_vector   = single_sub_data[!, :volatile_num]     # 稳定为0， 不稳定为1

        if model_type == "ab_no_v"
            model_result = ab_model(single_sub_param.alpha[1], congruency_vector)
            ab_no_v_p  = vcat(ab_no_v_p,  model_result["Predicted sequence"])
            ab_no_v_pe = vcat(ab_no_v_pe, abs.(model_result["Prediciton error"]))
        end

        if model_type == "ab_v"
            model_result = ab_volatility_model(single_sub_param.alpha_s[1], single_sub_param.alpha_v[1], 
                                               congruency_vector, volatile_vector)
            ab_v_p  = vcat(ab_v_p,  model_result["Predicted sequence"])
            ab_v_pe = vcat(ab_v_pe, abs.(model_result["Prediciton error"]))
        end

        if model_type == "sr_no_v"
            model_result = sr_sep_alpha_model(single_sub_param.alpha[1], single_sub_param.alpha[1],
                                              stim_loc_vector, resp_vector)
            sr_no_v_p  = vcat(sr_no_v_p,  model_result["Predicted sequence"])
            sr_no_v_pe = vcat(sr_no_v_pe, abs.(model_result["Prediciton error"]))
        end

        if model_type == "sr_v"
            model_result = sr_sep_alpha_volatility_model(single_sub_param.alpha_s[1], single_sub_param.alpha_s[1], 
                                                         single_sub_param.alpha_v[1], single_sub_param.alpha_v[1],
                                                         stim_loc_vector, resp_vector, volatile_vector)
            sr_v_p  = vcat(sr_v_p,  model_result["Predicted sequence"])
            sr_v_pe = vcat(sr_v_pe, abs.(model_result["Prediciton error"]))
            sr_v_ll = vcat(sr_v_ll, model_result["Predicied Left sequence"])
            sr_v_rl = vcat(sr_v_rl, model_result["Predicied Right sequence"])
        end
    end
end

all_data_with_rl = insertcols(raw_data, (:rl_ab_no_v_p  => ab_no_v_p),
                                        (:rl_ab_no_v_pe => ab_no_v_pe),
                                        (:rl_ab_v_p     => ab_v_p),
                                        (:rl_ab_v_pe    => ab_v_pe),
                                        (:rl_sr_no_v_p  => sr_no_v_p),
                                        (:rl_sr_no_v_pe => sr_no_v_pe),
                                        (:rl_sr_v_ll    => sr_v_ll),
                                        (:rl_sr_v_lr    => 1 .- sr_v_ll),
                                        (:rl_sr_v_rl    => sr_v_rl),
                                        (:rl_sr_v_rr    => 1 .- sr_v_rl),
                                        (:rl_sr_v_p     => sr_v_p),
                                        (:rl_sr_v_pe    => sr_v_pe))

# Save the result
import XLSX
XLSX.writetable("/Volumes/ResearchData/project9_fmri_spatial_stroop/data/output/behavior/all_data_with_rl.xlsx",
                all_data_with_rl,
                overwrite=true)