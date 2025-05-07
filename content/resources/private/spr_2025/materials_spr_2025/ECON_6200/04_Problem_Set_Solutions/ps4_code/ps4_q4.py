import pandas as pd
import matplotlib.pyplot as plt
plt.rc('text', usetex=True)
plt.rc('font', family='serif')
import numpy as np
import statsmodels.api as sm
from linearmodels.iv import IVGMM


# Load the Summers-Heston data
data = pd.read_excel("ps4_code/sum_hes.xlsx", sheet_name=0)


# 4.1
# Y1 is Y85, Y0 is Y60
# Plot Y1 - Y0 vs Y0
plt.scatter(data['Y60'], data['Y85'] - data['Y60'])
plt.xlabel('$Y_0$')
plt.ylabel('$Y_1 - Y_0$')
plt.savefig('ps4_code/ps4_q4_scatter.png')

# Get average annual growth rate for each country
data['N'] = (data['POP85'] - data['POP60']) / data['POP60']
data['logNgd'] = np.log(data['N'] + 0.05)

# Get average savings rate for each country (across all years)
data['S'] = (data['SRATE60'] + data['SRATE61'] + data['SRATE62'] + data['SRATE63'] + data['SRATE64'] + data['SRATE65'] + data['SRATE66'] + data['SRATE67'] + data['SRATE68'] + data['SRATE69'] + data['SRATE70'] + data['SRATE71'] + data['SRATE72'] + data['SRATE73'] + data['SRATE74'] + data['SRATE75'] + data['SRATE76'] + data['SRATE77'] + data['SRATE78'] + data['SRATE79'] + data['SRATE80'] + data['SRATE81'] + data['SRATE82'] + data['SRATE83'] + data['SRATE84'] + data['SRATE85']) / 26
data['logS'] = np.log(data['S'])

# Growth rates and output levels
data['logY0'] = np.log(data['Y60'])
data['logY1'] = np.log(data['Y85'])
data['logGrowth'] = data['logY1'] - data['logY0']

plt.scatter(data['logY0'], data['logGrowth'])
plt.xlabel(r'$\log Y_0$')
plt.ylabel(r'$\log Y_1 - \log Y_0$')
plt.savefig('ps4_code/ps4_q4_scatter_log.png')

# Estimate OLS model
X = sm.add_constant(data[['logY0', 'logNgd', 'logS', 'COM', 'OPEC']])
model1 = sm.OLS(data['logGrowth'], X)
results1 = model1.fit()
print(results1.summary())

rho_minus_one = results1.params['logY0']
rho = 1 + rho_minus_one
print(f"\nEstimated rho: {rho:.4f}")

lambda_value = -np.log(rho) / 25
print(f"Speed of convergence (lambda): {lambda_value*100:.4f}% per year")

lambda_se = results1.bse['logY0'] / (25 * rho)
print(f"Standard error of lambda: {lambda_se*100:.4f}%")



# 4.2

# Convert the data to a panel
years = list(range(60, 86))

# Create a panel dataset
panel_data = []

# For each country
for _, row in data.iterrows():
    country_id = row['ID']
    
    # Use the same population growth for all years (as specified)
    N = row['N']  # This is already calculated in the previous part
    com = int(row['COM'])
    opec = int(row['OPEC'])
    
    # For each consecutive pair of years
    for i in range(len(years) - 1):
        year_t = years[i]
        year_t_plus_1 = years[i + 1]
        
        # Column names for current and next year
        y_t_col = f'Y{year_t}'
        y_t_plus_1_col = f'Y{year_t_plus_1}'
        srate_t_col = f'SRATE{year_t}'
        
        # Get GDP values and saving rate for current year
        y_t = row[y_t_col]
        y_t_plus_1 = row[y_t_plus_1_col]
        srate_t = row[srate_t_col]
        
        # Skip if any values are missing or non-positive
        if y_t <= 0 or y_t_plus_1 <= 0 or srate_t <= 0:
            continue
        
        # Calculate log values
        log_y_t = np.log(y_t)
        log_y_t_plus_1 = np.log(y_t_plus_1)
        growth = log_y_t_plus_1 - log_y_t
        log_s = np.log(srate_t)
        log_ngd = np.log(N + 0.05)  # Using the same N for all years
        
        # Add to panel data
        panel_data.append({
            'country': country_id,
            'year': year_t,
            'log_y_t': log_y_t,
            'growth': growth,
            'log_s': log_s,
            'log_ngd': log_ngd,
            'com': com,
            'opec': opec
        })

# Create panel DataFrame
panel_df = pd.DataFrame(panel_data)

# Create year dummies for time fixed effects
year_dummies = pd.get_dummies(panel_df['year'], prefix='year', drop_first=True).astype(int)

# Create country dummies for country fixed effects
country_dummies = pd.get_dummies(panel_df['country'], prefix='country', drop_first=True).astype(int)

# Combine the variables for the fixed effects model
X_cols = ['log_y_t', 'log_s', 'log_ngd', 'com', 'opec']
X_fe = pd.concat([panel_df[X_cols], year_dummies, country_dummies], axis=1)
X_fe = sm.add_constant(X_fe)

# Run the fixed effects regression
fe_model = sm.OLS(panel_df['growth'], X_fe)
fe_results = fe_model.fit()

# Extract rho and calculate convergence rate for fixed effects
rho_fe_minus_one = fe_results.params['log_y_t']
rho_fe = 1 + rho_fe_minus_one
lambda_fe = -np.log(rho_fe)  # For 1-year periods
print(f"\nEstimated rho (Fixed Effects): {rho_fe:.4f}")
print(f"Speed of convergence lambda (Fixed Effects): {lambda_fe*100:.4f}% per year")


# Do efficient gmm
formula = (
    "growth ~ 1 + [log_y_t + log_s + log_ngd + com + opec "
    " ~ log_y_t + log_s + log_ngd + com + opec]"
)

gmm_mod = IVGMM.from_formula(formula, data=panel_df)

# Two-step efficient GMM. 'iter_limit=2' tells it to do the two-step weighting:
gmm_res = gmm_mod.fit(iter_limit=2)

# Extract rho and calculate convergence rate for efficient gmm
rho_gmm = gmm_res.params['log_y_t'] + 1
lambda_gmm = 1 - rho_gmm  # For 1-year periods
print(f"\nEstimated rho (Efficient GMM): {rho_gmm:.4f}")
print(f"Speed of convergence lambda (Efficient GMM): {lambda_gmm*100:.4f}% per year")



# 4.3 
# Implement multiple equation GMM
panel_df['lag_log_y_t'] = panel_df.groupby('country')['log_y_t'].shift(1)
panel_df_clean = panel_df.dropna()

X = sm.add_constant(panel_df_clean[['lag_log_y_t', 'log_s', 'log_ngd', 'com', 'opec']])
ar_model = sm.GLSAR(panel_df_clean['log_y_t'], X, rho=1)
ar_results = ar_model.iterative_fit(maxiter=5)

# The AR coefficient here directly gives you rho, not (rho-1)
multi_gmm_rho = ar_results.params['lag_log_y_t']
# Lambda calculation for a 1-year period model
multi_gmm_lambda = 1 - multi_gmm_rho
print(f"\nEstimated rho (AR Model): {multi_gmm_rho:.4f}")
print(f"Speed of convergence lambda (AR Model): {multi_gmm_lambda*100:.4f}% per year")








