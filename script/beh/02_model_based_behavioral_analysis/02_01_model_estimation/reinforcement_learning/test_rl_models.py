import pandas as pd
import numpy as np
from rl_models import delta_update, rl_sr_vola_dep, rl_sr_vola_indep, rl_ab_vola_dep, rl_ab_vola_indep

from rl_models import (
    delta_update,
    rl_sr_vola_dep,
    rl_sr_vola_indep,
    rl_ab_vola_dep,
    rl_ab_vola_indep,
)

def test_delta_update():
    p = 0.5
    pe = 0.1
    alpha = 0.2
    expected_result = 0.52  # calculated manually
    result = delta_update(p, pe, alpha)
    assert np.isclose(
        result, expected_result,
        atol=1e-4), f"Expected {expected_result}, but got {expected_result}"


def test_rl_sr_vola_dep():
    data = pd.DataFrame({
        "stim_loc": [0, 1, 0, 1],
        "corr_resp": [1, 0, 1, 0],
        "volatile": [0, 0, 1, 1],
    })
    alpha_s = 0.2
    alpha_v = 0.3

    expected_output = pd.DataFrame({
        "stim_loc": [0, 1, 0, 1],
        "corr_resp": [1, 0, 1, 0],
        "volatile": [0, 0, 1, 1],
        "alpha": [0.2, 0.2, 0.3, 0.3],
        "p_0_0": [0.5, 0.4, 0.4, 0.28],
        "p_0_1": [0.5, 0.6, 0.6, 0.72],
        "p_1_0": [0.5, 0.5, 0.6, 0.6],
        "p_1_1": [0.5, 0.5, 0.4, 0.6],
        "p_selected": [0.5, 0.5, 0.6, 0.6],
        "pe": [0.5, 0.5, 0.4, 0.4],
    })
    actual_output = rl_sr_vola_dep(data, alpha_s, alpha_v)

    # 检查输出的每一列是否和期望的结果相同
    for column in expected_output.columns:
        assert np.allclose(expected_output[column],
                           actual_output[column],
                           atol=1e-4), f"Mismatch in column {column}"


def test_rl_sr_vola_indep():
    data = pd.DataFrame({"stim_loc": [0, 0, 1, 1], "corr_resp": [0, 1, 0, 1]})
    alpha = 0.1

    expected_output = pd.DataFrame({
        "stim_loc": [0, 0, 1, 1],
        "corr_resp": [0, 1, 0, 1],
        "alpha": [0.1, 0.1, 0.1, 0.1],
        "p_0_0": [0.5, 0.55, 0.495, 0.495],
        "p_0_1": [0.5, 0.45, 0.505, 0.505],
        "p_1_0": [0.5, 0.5, 0.5, 0.55],
        "p_1_1": [0.5, 0.5, 0.5, 0.45],
        "p_selected": [0.5, 0.45, 0.5, 0.45],
        "pe": [0.5, 0.55, 0.5, 0.55],
    })
    print("test_rl_sr_vola_indep")
    print(expected_output)

    output = rl_sr_vola_indep(data, alpha)
    print(output)
    pd.testing.assert_frame_equal(output, expected_output, check_dtype=False)


def test_rl_ab_vola_dep():
    data = pd.DataFrame({"congruency": [0, 1, 0, 1], "volatile": [0, 1, 0, 1]})
    alpha_s = 0.1
    alpha_v = 0.2

    expected_output = pd.DataFrame({
        "congruency": [0, 1, 0, 1],
        "volatile": [0, 1, 0, 1],
        "alpha": [0.1, 0.2, 0.1, 0.2],
        "p_con": [0.5, 0.55, 0.44, 0.496],
        "p_inc": [0.5, 0.45, 0.56, 0.504],
        "p_selected": [0.5, 0.45, 0.44, 0.496],
        "pe": [0.5, 0.55, 0.56, 0.564],
    })
    print("test_rl_ab_vola_dep")
    print(expected_output)

    output = rl_ab_vola_dep(data, alpha_s, alpha_v)
    print(output)

    pd.testing.assert_frame_equal(output, expected_output, check_dtype=False)


def test_rl_ab_vola_indep():
    data = pd.DataFrame({"congruency": [0, 1, 0, 1]})
    alpha = 0.1

    expected_output = pd.DataFrame({
        "congruency": [0, 1, 0, 1],
        "alpha": [0.1, 0.1, 0.1, 0.1],
        "p_con": [0.5, 0.55, 0.495, 0.5455],
        "p_inc": [0.5, 0.45, 0.505, 0.4545],
        "p_selected": [0.5, 0.45, 0.495, 0.4545],
        "pe": [0.5, 0.55, 0.5050, 0.5455],
    })

    print("test_rl_ab_vola_indep")
    print(expected_output)

    output = rl_ab_vola_indep(data, alpha)
    print(output)
    pd.testing.assert_frame_equal(output, expected_output, check_dtype=False)
