import pandas as pd
import numpy as np
import statsmodels.api as sm
import statsmodels.formula.api as smf
from linearmodels.iv import IV2SLS
from linearmodels.iv import IVGMM
from scipy import stats

# Load the Griliches data
data = pd.read_excel("ps4_code/grilic.xlsx", sheet_name=0)

# 3.1
summary_stats = data.describe().T[['mean', 'std']]
summary_stats.columns = ['Mean', 'Standard Deviation']

print("\n")
print("====3.1: Table of Summary Statistics====\n")
formatted_stats = pd.DataFrame(index=summary_stats.index)
formatted_stats['Values'] = summary_stats['Mean'].map('{:.2f}'.format) + ' (' + summary_stats['Standard Deviation'].map('{:.2f}'.format) + ')'
print(formatted_stats)

# Calculate correlation between IQ and years of schooling (S)
correlation = data['IQ'].corr(data['S'])
print(f"\nCorrelation between IQ and S: {correlation:.4f}")

# 3.2: Replication of Hayashi Table 3.2
print("\n")
print("====3.2: Replication of Hayashi Table 3.2====\n")

# Drop any rows with missing values in key variables
data_clean = data.dropna(subset=['LW', 'S', 'IQ', 'EXPR', 'TENURE', 'RNS', 'SMSA', 'MED', 'KWW', 'AGE', 'MRT'])

# Define basic controls
basic_controls = "EXPR + TENURE + RNS + SMSA"

# Create a list of years in the data
years = sorted(data_clean['YEAR'].unique())

# Generate year dummies directly
for year in years[1:]:  # Skip the first year (use as base)
    data_clean[f'YEAR_{year}'] = (data_clean['YEAR'] == year).astype(int)

# Get the list of year dummy variable names
year_dummy_vars = [f'YEAR_{y}' for y in years[1:]]

# Create the full controls list
controls_list = ['EXPR', 'TENURE', 'RNS', 'SMSA'] + year_dummy_vars

# Line 1: OLS with only S and controls
model1 = smf.ols(f"LW ~ S + {' + '.join(controls_list)}", data=data_clean).fit()

# Line 2: OLS with S, IQ and controls
model2 = smf.ols(f"LW ~ S + IQ + {' + '.join(controls_list)}", data=data_clean).fit()

# Line 3: 2SLS with IQ as endogenous
exog = sm.add_constant(data_clean[['S'] + controls_list])
endog = data_clean[['IQ']]
instruments = data_clean[['MED', 'KWW', 'MRT', 'AGE']]

# Now use the IV2SLS model from linearmodels
model3 = IV2SLS(dependent=data_clean['LW'], 
                exog=exog,
                endog=endog,
                instruments=instruments).fit()

# Create a table similar to Hayashi Table 3.2
results = {
    "Line": [1, 2, 3],
    "Estimation technique": ["OLS", "OLS", "2SLS"],
    "S coef": [
        f"{model1.params['S']:.3f} ({model1.tvalues['S']:.1f})",
        f"{model2.params['S']:.3f} ({model2.tvalues['S']:.1f})",
        f"{model3.params['S']:.3f} ({model3.tstats['S']:.1f})"
    ],
    "IQ coef": [
        "-",
        f"{model2.params['IQ']:.4f} ({model2.tvalues['IQ']:.1f})",
        f"{model3.params['IQ']:.4f} ({model3.tstats['IQ']:.1f})" 
    ],
    "SER": [
        f"{np.sqrt(model1.mse_resid):.3f}",
        f"{np.sqrt(model2.mse_resid):.3f}",
        f"{model3.std_errors['S']:.3f}"  # Approximation for 2SLS
    ],
    "R-squared": [
        f"{model1.rsquared:.3f}",
        f"{model2.rsquared:.3f}",
        "-"  # R not directly comparable for 2SLS
    ],
    "Endogenous?": [
        "none",
        "none",
        "IQ"
    ],
    "Excluded predetermined variables": [
        "-",
        "-",
        "MED, KWW, MRT, AGE"
    ]
}

# Convert to DataFrame for display
table = pd.DataFrame(results)

# Display only the table
print("=" * 80)
print(table.to_string(index=False))
print("=" * 80)
print("Note: Figures in parentheses are t-values rather than standard errors.")


# 3.3
print("\n")
print("====3.3: Sargan's J-statistic Calculation====\n")

# The linearmodels package automatically calculates the Sargan statistic
# Extract the J-statistic and other test details
j_stat = model3.sargan

print(f"Sargan's J-statistic:\n")
print(j_stat)

# 3.4
print("\n")
print("====3.4: Manual TSLS Implementation====\n")

# First stage: Regress IQ on all exogenous variables and instruments
first_stage_formula = f"IQ ~ S + {' + '.join(controls_list)} + MED + KWW + MRT + AGE"
first_stage_model = smf.ols(first_stage_formula, data=data_clean).fit()

# Get predicted values of IQ
data_clean['IQ_hat'] = first_stage_model.predict()

# Second stage: Use predicted IQ in the main regression
second_stage_formula = f"LW ~ S + IQ_hat + {' + '.join(controls_list)}"
second_stage_model = smf.ols(second_stage_formula, data=data_clean).fit()

# Print the results from manual TSLS and package-based TSLS
print("Coefficient estimates:")
print(f"Manual TSLS - Schooling (S): {second_stage_model.params['S']:.4f}")
print(f"Manual TSLS - IQ_hat: {second_stage_model.params['IQ_hat']:.4f}")
print(f"Package TSLS - Schooling (S): {model3.params['S']:.4f}")
print(f"Package TSLS - IQ: {model3.params['IQ']:.4f}")

print("\nStandard errors:")
print(f"Manual TSLS - Schooling (S): {second_stage_model.bse['S']:.4f}")
print(f"Manual TSLS - IQ_hat: {second_stage_model.bse['IQ_hat']:.4f}")
print(f"Package TSLS - Schooling (S): {model3.std_errors['S']:.4f}")
print(f"Package TSLS - IQ: {model3.std_errors['IQ']:.4f}")



# 3.5
print("\n")
print("====3.5: 2SLS with Both S and IQ as Endogenous====\n")

# Now both S and IQ are endogenous variables
exog_controls = sm.add_constant(data_clean[controls_list])
endog_both = data_clean[['S', 'IQ']]
instruments = data_clean[['MED', 'KWW', 'MRT', 'AGE']]

# Fit the new model
model4 = IV2SLS(dependent=data_clean['LW'], 
                exog=exog_controls,
                endog=endog_both,
                instruments=instruments).fit()

# Compare results with the previous model where only IQ was endogenous
print("Coefficient Estimates (Previous vs New Model):")
print(f"S coefficient (only IQ endogenous): {model3.params['S']:.4f}")
print(f"S coefficient (both S and IQ endogenous): {model4.params['S']:.4f}")

print(f"IQ coefficient (only IQ endogenous): {model3.params['IQ']:.4f}")
print(f"IQ coefficient (both S and IQ endogenous): {model4.params['IQ']:.4f}")

# Calculate and report Sargan's statistic for the new model
j_stat_both = model4.sargan

print("Sargan's Test for Overidentifying Restrictions:")
print(f"Sargan's J-statistic: \n")
print(j_stat_both)


# 3.6
print("\n")
print("====3.6: GMM Estimation and C-statistic====\n")

# Create data matrices for the models
y = data_clean['LW']

# Model 1: S is treated as exogenous (included in exog)
exog_vars1 = sm.add_constant(data_clean[['S'] + controls_list])
endog_vars1 = data_clean[['IQ']]
# Only include instruments not already in exog
instruments1 = data_clean[['MED', 'KWW', 'MRT', 'AGE']]

# Model 2: S is treated as endogenous
exog_vars2 = sm.add_constant(data_clean[controls_list])  # exog without S
endog_vars2 = data_clean[['IQ', 'S']]  # both IQ and S are endogenous
instruments2 = data_clean[['MED', 'KWW', 'MRT', 'AGE']]  # same instruments

# First GMM estimation - S is exogenous - with robust weighting
model_gmm1 = IVGMM(dependent=y,
                  exog=exog_vars1,
                  endog=endog_vars1,
                  instruments=instruments1,
                  weight_type='robust').fit()

# Second GMM estimation - S is endogenous - with robust weighting
model_gmm2 = IVGMM(dependent=y,
                  exog=exog_vars2,
                  endog=endog_vars2,
                  instruments=instruments2,
                  weight_type='robust').fit()

# Calculate C-statistic (difference in J-statistics)
# For C-test, we compare the model with S as exogenous vs S as endogenous
j_stat1 = model_gmm1.j_stat.stat
j_stat2 = model_gmm2.j_stat.stat

# The C-statistic is the difference in criterion functions (J-statistics)
c_stat = abs(j_stat2 - j_stat1)  # Take absolute value to ensure positive value

# The degrees of freedom equals the number of restrictions (1 for S)
df_c = 1

# Calculate p-value from chi-squared distribution
p_value_c = 1 - stats.chi2.cdf(c_stat, df_c)

print("\nC-statistic (Test for Exogeneity of Schooling):")
print(f"C-statistic: {c_stat:.3f}")
print(f"Degrees of freedom: {df_c}")
print(f"p-value: {p_value_c:.6f}\n")

# 3.7
print("\n")
print("====3.7: TSLS with Reduced Instrument Set====\n")

# Use only MRT and AGE as instruments (dropping MED and KWW)
exog_controls = sm.add_constant(data_clean[controls_list])
endog_both = data_clean[['S', 'IQ']]
reduced_instruments = data_clean[['MRT', 'AGE']]  # Only MRT and AGE as instruments

# Fit the model with reduced instrument set
model5 = IV2SLS(dependent=data_clean['LW'], 
                exog=exog_controls,
                endog=endog_both,
                instruments=reduced_instruments).fit()

# Display coefficient estimates
print("Coefficient Estimates with Reduced Instrument Set:")
print(f"S coefficient: {model5.params['S']:.4f} ({model5.std_errors['S']:.4f})")


# Check first-stage regressions for instrument relevance
print("\nFirst-Stage Regressions (Instrument Relevance):")

# First stage model for S
first_stage_S = sm.OLS(data_clean['S'], 
                      sm.add_constant(pd.concat([reduced_instruments, 
                                               data_clean[controls_list]], axis=1))).fit()

# First stage model for IQ
first_stage_IQ = sm.OLS(data_clean['IQ'], 
                       sm.add_constant(pd.concat([reduced_instruments, 
                                                data_clean[controls_list]], axis=1))).fit()

# F statistics and R-squared for first stage
f_stat_S = first_stage_S.fvalue
f_stat_IQ = first_stage_IQ.fvalue
r2_S = first_stage_S.rsquared
r2_IQ = first_stage_IQ.rsquared

print(f"First stage F-statistic for S: {f_stat_S:.2f}")
print(f"First stage R-squared for S: {r2_S:.4f}")
print(f"First stage F-statistic for IQ: {f_stat_IQ:.2f}")
print(f"First stage R-squared for IQ: {r2_IQ:.4f}")

# Rule of thumb: F < 10 indicates weak instruments
print(f"Weak instruments for S? {'Yes' if f_stat_S < 10 else 'No'}")
print(f"Weak instruments for IQ? {'Yes' if f_stat_IQ < 10 else 'No'}")

# Calculate partial correlations of instruments with endogenous variables
print("\nPartial Correlations of Instruments with Endogenous Variables:")
print("Instrument | Correlation with S | Correlation with IQ")
print("-" * 60)

for instrument in ['MRT', 'AGE']:
    corr_S = data_clean[instrument].corr(data_clean['S'])
    corr_IQ = data_clean[instrument].corr(data_clean['IQ'])
    print(f"{instrument:10} | {corr_S:18.4f} | {corr_IQ:17.4f}")

# Calculate condition number to check for multicollinearity in first stage
from numpy.linalg import cond
X1 = sm.add_constant(pd.concat([reduced_instruments, data_clean[controls_list]], axis=1))
condition_number = cond(X1.values)
print(f"\nCondition number for first stage: {condition_number:.2f}")
print(f"High multicollinearity? {'Yes' if condition_number > 30 else 'No'}")
