import pandas as pd
import numpy as np
import statsmodels.formula.api as smf
import multiprocessing as mp


def delta_update(p, pe, alpha):
    """
    Update the delta value based on the reward and the prediction error.

    Parameters:
    p (float): The probability value before update.
    pe (float): The prediction error.
    delta (float): The learning rate.

    Returns:
    float: The updated delta value.
    """
    return p + alpha * pe


def rl_sr_vola_dep(data, alpha_s, alpha_v):
    stim_loc_vector = data["stim_loc"]
    corr_resp_vector = data["corr_resp"]
    volatility_vector = data["volatility"]
    p_value = [[0.5, 0.5], [0.5, 0.5]]
    results = []
    for stim_loc, corr_resp, volatility in zip(
        stim_loc_vector, corr_resp_vector, volatility_vector
    ):
        # Choose the learning rate based on the volatility
        if volatility == 0:
            alpha = alpha_s
        else:
            alpha = alpha_v

        # Calc the prediction error
        pe = 1 - p_value[stim_loc][corr_resp]
        p_selected = p_value[stim_loc][corr_resp]

        # append results to the list
        results.append(
            [
                stim_loc,
                corr_resp,
                volatility,
                alpha,
                p_value[0][0],
                p_value[0][1],
                p_value[1][0],
                p_value[1][1],
                p_selected,
                pe,
            ]
        )
        # Update the delta value
        p_value[stim_loc][corr_resp] = delta_update(
            p_value[stim_loc][corr_resp], pe, alpha
        )
        p_value[stim_loc][1 - corr_resp] = 1 - p_value[stim_loc][corr_resp]

    # Convert the results to a DataFrame
    results_df = pd.DataFrame(
        results,
        columns=[
            "stim_loc",
            "corr_resp",
            "volatility",
            "alpha",
            "p_0_0",
            "p_0_1",
            "p_1_0",
            "p_1_1",
            "p_selected",
            "pe",
        ],
    )

    return results_df


def rl_sr_vola_indep(data, alpha):
    stim_loc_vector = data["stim_loc"]
    corr_resp_vector = data["corr_resp"]
    p_value = [[0.5, 0.5], [0.5, 0.5]]
    results = []
    for stim_loc, corr_resp in zip(stim_loc_vector, corr_resp_vector):
        # Calc the prediction error
        pe = 1 - p_value[stim_loc][corr_resp]
        p_selected = p_value[stim_loc][corr_resp]

        # append results to the list
        results.append(
            [
                stim_loc,
                corr_resp,
                alpha,
                p_value[0][0],
                p_value[0][1],
                p_value[1][0],
                p_value[1][1],
                p_selected,
                pe,
            ]
        )

        # Update the delta value
        p_value[stim_loc][corr_resp] = delta_update(
            p_value[stim_loc][corr_resp], pe, alpha
        )
        p_value[stim_loc][1 - corr_resp] = 1 - p_value[stim_loc][corr_resp]

    # Convert the results to a DataFrame
    results_df = pd.DataFrame(
        results,
        columns=[
            "stim_loc",
            "corr_resp",
            "alpha",
            "p_0_0",
            "p_0_1",
            "p_1_0",
            "p_1_1",
            "p_selected",
            "pe",
        ],
    )

    return results_df


def rl_ab_vola_dep(data, alpha_s, alpha_v):
    congruency_vector = data["congruency"]
    volatility_vector = data["volatility"]
    p_value = [0.5, 0.5]  # 0 = congruent, 1 = incongruent
    results = []
    for congruency, volatility in zip(congruency_vector, volatility_vector):
        # Choose the learning rate based on the volatility
        if volatility == 0:
            alpha = alpha_s
        else:
            alpha = alpha_v

        # Calc the prediction error
        pe = 1 - p_value[congruency]
        p_selected = p_value[congruency]

        # append results to the list
        results.append(
            [
                congruency,
                volatility,
                alpha,
                p_value[0],
                p_value[1],
                p_selected,
                pe,
            ]
        )

        # Update the delta value
        p_value[congruency] = delta_update(p_value[congruency], pe, alpha)
        p_value[1 - congruency] = 1 - p_value[congruency]

    # Convert the results to a DataFrame
    results_df = pd.DataFrame(
        results,
        columns=[
            "congruency",
            "volatility",
            "alpha",
            "p_con",
            "p_inc",
            "p_selected",
            "pe",
        ],
    )

    return results_df


def rl_ab_vola_indep(data, alpha):
    congruency_vector = data["congruency"]
    p_value = [0.5, 0.5]
    results = []
    for congruency in congruency_vector:
        # Calc the prediction error
        pe = 1 - p_value[congruency]
        p_selected = p_value[congruency]

        # append results to the list
        results.append(
            [
                congruency,
                alpha,
                p_value[0],
                p_value[1],
                p_selected,
                pe,
            ]
        )

        # Update the delta value
        p_value[congruency] = delta_update(p_value[congruency], pe, alpha)
        p_value[1 - congruency] = 1 - p_value[congruency]

    # Convert the results to a DataFrame
    results_df = pd.DataFrame(
        results,
        columns=[
            "congruency",
            "alpha",
            "p_con",
            "p_inc",
            "p_selected",
            "pe",
        ],
    )

    return results_df


# 根据给定的模型和数据，计算模型的对数似然
def compute_goodness_vola_dep(model_name, data, alpha_s, alpha_v):
    if model_name == "rl_sr_vola_dep":
        results_df = rl_sr_vola_dep(data, alpha_s, alpha_v)
        formula = "corr_resp ~ p_selected"
    elif model_name == "rl_ab_vola_dep":
        results_df = rl_ab_vola_dep(data, alpha_s, alpha_v)
        formula = "congruency ~ p_selected"
    else:
        raise ValueError("Unknown model: {}".format(model_name))

    logit_model = smf.logit(formula, data=results_df)
    result = logit_model.fit()

    return result


def compute_goodness_vola_indep(model_name, data, alpha):
    if model_name == "rl_sr_vola_indep":
        results_df = rl_sr_vola_indep(data, alpha)
        formula = "corr_resp ~ p_selected"
    elif model_name == "rl_ab_vola_indep":
        results_df = rl_ab_vola_indep(data, alpha)
        formula = "congruency ~ p_selected"
    else:
        raise ValueError("Unknown model: {}".format(model_name))

    logit_model = smf.logit(formula, data=results_df)
    results = logit_model.fit()

    return results


# 批量计算模型的对数似然


def batch_calc_log_likelihood_vola_dep(model_name, data):
    results_list = []
    for alpha_s in np.arange(0.01, 1, 0.01):
        for alpha_v in np.arange(0.01, 1, 0.01):
            results = compute_goodness_vola_dep(model_name, data, alpha_s, alpha_v)
            results_list.append(
                [alpha_s, alpha_v, results.llf, results.aic, results.bic]
            )

    results_df = pd.DataFrame(
        results_list, columns=["alpha_s", "alpha_v", "llf", "aic", "bic"]
    )

    return results_df


def batch_calc_log_likelihood_vola_indep(model_name, data):
    results_list = []
    for alpha in np.arange(0.01, 1, 0.01):
        results = compute_goodness_vola_indep(model_name, data, alpha)
        results_list.append([alpha, results.llf, results.aic, results.bic])

    results_df = pd.DataFrame(results_list, columns=["alpha", "llf", "aic", "bic"])

    return results_df
