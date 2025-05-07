import pandas as pd
import numpy as np
import statsmodels.api as sm
from linearmodels.iv import IV2SLS
import matplotlib.pyplot as plt

# Load the Card data
data = pd.read_excel("ps3_code/Card1995.xlsx", sheet_name=0)

# Generate experience variable and squared experience
data['exp76'] = data['age76'] - data['ed76'] - 6
data['exp76sq'] = (data['exp76'] ** 2) / 100

# Rename variables to match Stata code
data = data.rename(columns={
    'nearc4a': 'pub',      # grew up near 4-yr public college
    'nearc4b': 'priv',     # grew up near 4-yr private college
    'reg76r': 'south76',   # in south in 1976
    'smsa76r': 'urban76'   # residence in a standard metropolitan statistical area
})

# Drop observations with missing log wage
data = data.dropna(subset=['lwage76'])
# Ensure log wage is numeric
data['lwage76'] = pd.to_numeric(data['lwage76'], errors='coerce')

# Create interaction terms for additional instruments
data['pubxage'] = data['pub'] * data['age76']
data['pubxagesq'] = data['pub'] * ((data['age76'] ** 2) / 100)


print("\n============== QUESTION 3.1 ==============")

# First, replicate column 2SLS(a) in Table 12.1
print("\n--- Table 12.1, Column 2SLS(a) ---")
formula_2sls = "lwage76 ~ 1 + exp76 + exp76sq + black + south76 + urban76 + [ed76 ~ pub + priv]"
model_2sls = IV2SLS.from_formula(formula_2sls, data)
results_2sls = model_2sls.fit(cov_type='robust')
print(results_2sls.summary)

# Now, replicate the final column of Table 12.2 (reduced form regression for education)
print("\n--- Table 12.2, Final Column (Reduced Form for Education) ---")
# The final column of Table 12.2 appears to be a reduced form regression of education on various covariates
X_reduced_form = sm.add_constant(data[['exp76', 'exp76sq', 'black', 'south76', 'urban76', 'pub', 'priv']])
reduced_form_model = sm.OLS(data['ed76'], X_reduced_form)
reduced_form_results = reduced_form_model.fit(cov_type='HC1')
print(reduced_form_results.summary())

print("\n============== QUESTION 3.2 ==============")

# Add nearc2 to the first stage/reduced form equation
print("\n--- First Stage/Reduced Form with nearc2 added ---")
X_reduced_form2 = sm.add_constant(data[['exp76', 'exp76sq', 'black', 'south76', 'urban76', 'pub', 'priv', 'nearc2']])
reduced_form_model2 = sm.OLS(data['ed76'], X_reduced_form2)
reduced_form_results2 = reduced_form_model2.fit(cov_type='HC1')
print(reduced_form_results2.summary())

# 2SLS with nearc2 added as an instrument
print("\n--- 2SLS with nearc2 added as an instrument ---")
formula_2sls2 = "lwage76 ~ 1 + exp76 + exp76sq + black + south76 + urban76 + [ed76 ~ pub + priv + nearc2]"
model_2sls2 = IV2SLS.from_formula(formula_2sls2, data)
results_2sls2 = model_2sls2.fit(cov_type='robust')
print(results_2sls2.summary)

# Compare coefficients
print("\nComparison of coefficients with and without nearc2:")
print(f"2SLS without nearc2 (ed76 coefficient): {results_2sls.params['ed76']:.4f}")
print(f"2SLS with nearc2 (ed76 coefficient): {results_2sls2.params['ed76']:.4f}")
print(f"Difference: {results_2sls2.params['ed76'] - results_2sls.params['ed76']:.4f}")
print(f"Percent change: {((results_2sls2.params['ed76'] - results_2sls.params['ed76'])/results_2sls.params['ed76']*100):.2f}%")

print("\n============== QUESTION 3.3 ==============")

# Estimate the structural equation by TSLS with additional instruments
print("\n--- 2SLS with additional instruments (interactions) ---")
formula_2sls3 = "lwage76 ~ 1 + exp76 + exp76sq + black + south76 + urban76 + [ed76 ~ pub + priv + pubxage + pubxagesq + nearc2]"
model_2sls3 = IV2SLS.from_formula(formula_2sls3, data)
results_2sls3 = model_2sls3.fit(cov_type='robust')
print(results_2sls3.summary)

# Compare coefficients
print("\nComparison of coefficients with added interactions:")
print(f"Original 2SLS (ed76 coefficient): {results_2sls.params['ed76']:.4f}")
print(f"2SLS with interactions (ed76 coefficient): {results_2sls3.params['ed76']:.4f}")
print(f"Difference: {results_2sls3.params['ed76'] - results_2sls.params['ed76']:.4f}")
print(f"Percent change: {((results_2sls3.params['ed76'] - results_2sls.params['ed76'])/results_2sls.params['ed76']*100):.2f}%")

# Create a bar plot to visualize the comparison
models = ['2SLS (a)\nTable 12.1', '2SLS with nearc2', '2SLS with\ninteractions']
coeffs = [results_2sls.params['ed76'], results_2sls2.params['ed76'], results_2sls3.params['ed76']]

plt.figure(figsize=(10, 6))
plt.bar(models, coeffs)
plt.ylabel('Coefficient on Education')
plt.title('Comparison of Education Coefficients Across Models')
plt.grid(axis='y', linestyle='--', alpha=0.7)
plt.savefig('ps3_code/education_coefficients.png')