using NLsolve

@time begin

# Calculate excess savings
function excess_savings(k; beta, alpha, g_ratio)
    # Penalize non-positive capital
    if k <= 0
        return 1e8
    end

    # Calculate savings
    s = (beta / (1 + beta)) * ((1 - alpha) * k ^ alpha - g_ratio * k ^ alpha)

    # Calculate excess savings
    return s - k
end

# Solve for k using a root-finding algorithm
function find_steady_state(; guess = 0.5, beta = 0.9, alpha = 0.3, g_ratio = 0.1)
    f!(F, x) = (F[1] = excess_savings(x[1]; beta=beta, alpha=alpha, g_ratio=g_ratio))
    sol = nlsolve(f!, [guess])
    return sol.zero[1]
end

# Set model parameters
beta = 0.9
alpha = 0.3
g_ratio = 0.1

# Calculate steady state capital
k_ss = find_steady_state(guess = 0.1, beta = beta, alpha = alpha, g_ratio = g_ratio)

println("Steady-state capital K* = $k_ss")

# Calculate other steady state variables
Y_ss = k_ss ^ alpha
w_ss = (1 - alpha) * Y_ss
r_ss = alpha * k_ss ^ (alpha - 1)
g_ss = g_ratio * Y_ss
delta_y_ss = g_ss

println("Steady-state output Y* = $Y_ss")
println("Steady-state wage w* = $w_ss")
println("Steady-state interest rate r* = $r_ss")
println("Steady-state government spending g* = $g_ss")
println("Steady-state taxes delta_y* = $delta_y_ss")

# Household saving s_star should equal K_star
s_ss = (beta/(1+beta)) * (w_ss - delta_y_ss)
println("Check s* = $s_ss, which should equal K*.")

cy_ss = (1 / (1 + beta)) * (w_ss - delta_y_ss)
println("Optimal Consumption Cy* = $cy_ss")

co_ss = (beta / (1 + beta)) * (r_ss) * (w_ss - delta_y_ss)
println("Optimal Consumption Co* = $co_ss")


# Calculate steady state after shock to g_ratio
g_ratio_new = 0.15
k_ss_new = find_steady_state(guess = 0.1, beta = beta, alpha = alpha, g_ratio = g_ratio_new)

println("Steady-state capital K* = $k_ss_new")

# Calculate other steady state variables after shock
Y_ss_new = k_ss_new ^ alpha
w_ss_new = (1 - alpha) * Y_ss_new
r_ss_new = alpha * k_ss_new ^ (alpha - 1)
g_ss_new = g_ratio_new * Y_ss_new
delta_y_ss_new = g_ss_new

println("Steady-state output Y* = $Y_ss_new")
println("Steady-state wage w* = $w_ss_new")
println("Steady-state interest rate r* = $r_ss_new")
println("Steady-state government spending g* = $g_ss_new")
println("Steady-state taxes delta_y* = $delta_y_ss_new")

# Household saving s_star should equal K_star
s_ss_new = (beta/(1+beta)) * (w_ss_new - delta_y_ss_new)
println("Check s* = $s_ss_new, which should equal K*.")

cy_ss_new = (1 / (1 + beta)) * (w_ss_new - delta_y_ss_new)
println("Optimal Consumption Cy* = $cy_ss_new")

co_ss_new = (beta / (1 + beta)) * (r_ss_new) * (w_ss_new - delta_y_ss_new)
println("Optimal Consumption Co* = $co_ss_new")








# Repeat but with income taxes rather than lump sum
# Calculate excess savings
function excess_savings_income(k; beta, alpha, g_ratio)
    # Penalize non-positive capital
    if k <= 0
        return 1e8
    end

    # Calculate savings
    s = (beta / (1 + beta)) * ((1 - alpha) * k ^ alpha * (1 - g_ratio  / (1 - alpha)))

    # Calculate excess savings
    return s - k
end

# Solve for k using a root-finding algorithm
function find_steady_state_income(; guess = 0.5, beta = 0.9, alpha = 0.3, g_ratio = 0.1)
    f!(F, x) = (F[1] = excess_savings_income(x[1]; beta=beta, alpha=alpha, g_ratio=g_ratio))
    sol = nlsolve(f!, [guess])
    return sol.zero[1]
end

# Calculate steady state capital
k_ss_income = find_steady_state_income(guess = 0.1, beta = beta, alpha = alpha, g_ratio = g_ratio)

println("Income Tax Steady-state capital K* = $k_ss_income")

# Calculate other steady state variables
Y_ss_income = k_ss_income ^ alpha
w_ss_income = (1 - alpha) * Y_ss_income
r_ss_income = alpha * k_ss_income ^ (alpha - 1)
g_ss_income = g_ratio * Y_ss_income
tau_ss_income = g_ss_income / w_ss_income

println("Income Tax Steady-state output Y* = $Y_ss_income")
println("Income Tax Steady-state wage w* = $w_ss_income")
println("Income Tax Steady-state interest rate r* = $r_ss_income")
println("Income Tax Steady-state government spending g* = $g_ss_income")
println("Income Tax Steady-state taxes tau* = $tau_ss_income")

# Household saving s_star should equal K_star
s_ss_income = (beta/(1+beta)) * w_ss_income * (1 - tau_ss_income)
println("Check s* = $s_ss_income, which should equal K*.")

cy_ss_income = (1 / (1 + beta)) * w_ss_income * (1 - tau_ss_income)
println("Optimal Consumption Cy* = $cy_ss_income")

co_ss_income = (beta / (1 + beta)) * (r_ss_income) * w_ss_income * (1 - tau_ss_income)
println("Optimal Consumption Co* = $co_ss_income")


# Calculate steady state after shock to g_ratio
g_ratio_new = 0.15
k_ss_income_new = find_steady_state_income(guess = 0.1, beta = beta, alpha = alpha, g_ratio = g_ratio_new)

println("Income Tax Steady-state capital K* = $k_ss_income_new")

# Calculate other steady state variables
Y_ss_income_new = k_ss_income_new ^ alpha
w_ss_income_new = (1 - alpha) * Y_ss_income_new
r_ss_income_new = alpha * k_ss_income_new ^ (alpha - 1)
g_ss_income_new = g_ratio_new * Y_ss_income_new
tau_ss_income_new = g_ss_income_new / w_ss_income_new

println("Income Tax Steady-state output Y* = $Y_ss_income_new")
println("Income Tax Steady-state wage w* = $w_ss_income_new")
println("Income Tax Steady-state interest rate r* = $r_ss_income_new")
println("Income Tax Steady-state government spending g* = $g_ss_income_new")
println("Income Tax Steady-state taxes tau* = $tau_ss_income_new")

# Household saving s_star should equal K_star
s_ss_income_new = (beta/(1+beta)) * w_ss_income_new * (1 - tau_ss_income_new)
println("Check s* = $s_ss_income_new, which should equal K*.")

cy_ss_income_new = (1 / (1 + beta)) * w_ss_income_new * (1 - tau_ss_income_new)
println("Optimal Consumption Cy* = $cy_ss_income_new")

co_ss_income_new = (beta / (1 + beta)) * (r_ss_income_new) * w_ss_income_new * (1 - tau_ss_income_new)
println("Optimal Consumption Co* = $co_ss_income_new")



end