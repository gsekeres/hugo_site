# Preliminarites
import numpy as np
import matplotlib.pyplot as plt
plt.rc('text', usetex=True)
plt.rc('font', family='serif')


# Define model parameters
N = 600
alpha = 0.33
beta = 0.98
delta = 0.10
sigma = 0.95

# Define functions
def f(k):
    return np.where(k <= 0, 0, k ** alpha)

def f_prime(k):
    return np.where(k <= 0, 0, alpha * k ** (alpha - 1))

def f_prime_inv(x):
    return np.where(x <= 0, 0, (x / alpha) ** (1 / (alpha - 1)))

def u(c):
    return np.where(c <= 0, 0, c ** (1 - sigma) / (1 - sigma))

def u_prime(c):
    return np.where(c <= 0, 0, c ** (-sigma))

def u_prime_inv(x):
    return np.where(x <= 0, 0, x ** (-1 / sigma))
    
def next_k_c(k, c):
    k_next = f(k) + (1 - delta) * k - c
    return np.where(k_next <= 0, 0, k_next), np.where(k_next <= 0, 0, u_prime_inv(u_prime(c) / (beta * (f_prime(k_next) + (1 - delta)))))

def shooting(c0, k0, T=600):
    if c0 > f(k0) + (1 - delta) * k0:
        print("initial consumption is not feasible")
        return None

    c_vec = np.empty(T+1)
    k_vec = np.empty(T+2)

    c_vec[0] = c0
    k_vec[0] = k0

    for t in range(T):
        k_vec[t+1], c_vec[t+1] = next_k_c(k_vec[t], c_vec[t])

    k_vec[T+1] = f(k_vec[T]) + (1 - delta) * k_vec[T] - c_vec[T]

    return c_vec, k_vec

def bisection(k0, T=600, tol=1e-4, max_iter=500, k_ter=0, c_ter=0, verbose=False):
    # initial boundaries for guess c0
    c0_upper = 2*f(k0)
    c0_lower = 0
    c0 = (c0_upper + c0_lower) / 2

    i = 0
    while True:
        c_vec, k_vec = shooting(c0, k0, T)
        error = k_vec[-1] - k_ter
        if verbose:
            print("c:", c_vec[-1], "k:", k_vec[-1], "error:", error, "c0:", c0)

        # check if the terminal condition is satisfied
        if np.abs(error) < tol:
            if verbose:
                print('Converged successfully on iteration ', i+1)
            return c_vec, k_vec, c0, i+1

        i += 1
        if i == max_iter:
            if verbose:
                print('Convergence failed.')
            return c_vec, k_vec, c0, i+1

        # if iteration continues, updates boundaries and guess of c0
        if error > 0:
            c0_lower = c0
        else:
            c0_upper = c0
        

        c0 = (c0_lower + c0_upper) / 2
        if verbose:
            print(f"Updated bounds: c0_lower = {c0_lower}, c0_upper = {c0_upper}")



# Set steady states
k_star = f_prime_inv(1 / beta - (1 - delta))
c_star = f(k_star) - delta * k_star
k0 = 0.85 * k_star
c0 = 0.5 * f(k0)
print("k_star:", k_star, "k0:", k0, "c0:", c0, "f(k0):", f(k0), "c_star:", c_star)

# Test shooting with steady state
c_ss,k_ss = shooting(c_star, k_star, T=300)
print("C Difference:", c_ss[-1] - c_star)
print("K Difference:", k_ss[-1] - k_star)

c_vec, k_vec, c_init, _ = bisection(k0, T=150, k_ter=k_star, c_ter=c_star, verbose=False)



# Plot the phase diagram for capital and consumption
fig, ax = plt.subplots(figsize=(10, 6))


K_range = np.arange(3.5, 5.5, 0.01)
C_range = np.arange(1e-1, 2.3, 0.01)

# C tilde (fixed point equation)
ax.plot(K_range, [f(k) + (1 - delta) * k - f_prime_inv(1 / beta - 1 + delta) for k in K_range], color='b', label='$C=C(K)$')

# K tilde (fixed point equation)
ax.plot([f_prime_inv(1 / beta - 1 + delta) for c in C_range], C_range, color='r', label='$K=K(C)$')

# Stable branch
ax.plot(k_vec[:151], c_vec, label='Path')
ax.plot(k_star, c_star, 'ro', label='Steady State')
ax.plot(k0,c_init, 'go', label='Initial Condition')

K_grid = np.arange(3.5, 5.5, 0.1)
C_grid = np.arange(1e-1, 2.3, 0.1)


K_mesh, C_mesh = np.meshgrid(K_grid, C_grid)

next_K, next_C = next_k_c(K_mesh, C_mesh)
ax.quiver(K_grid, C_grid, next_K-K_mesh, next_C-C_mesh)

ax.set_xlabel('Capital')
ax.set_ylabel('Consumption')
ax.legend()
plt.savefig('macro_hw1_code/phase_diagram.png', bbox_inches='tight')



# See what happens if agents get more impatient
betas = np.arange(0.90, 0.98, 0.0005)
iters = np.empty(len(betas))

for i in range(len(betas)):
    beta = betas[i]
    _, _, _, iter = bisection(k0, T=150, k_ter=k_star, c_ter=c_star, verbose=False)
    if iter < 501:
        iters[i] = iter
    else:
        iters[i] = np.nan

# Plot impatience vs iterations
fig, ax = plt.subplots(figsize=(10, 6))
ax.plot(betas, iters, marker='o')

# Set labels and title
ax.set_xlabel(r'$\beta$ (Impatience)')
ax.set_ylabel('Iterations to Convergence')
ax.set_title('Convergence vs. Impatience')

plt.savefig('macro_hw1_code/iters.png', bbox_inches='tight')

# Fix beta
beta = 0.98
## Value function iteration

# Define functions
def value_function_iteration(k_grid, tol=1e-6, max_iter=1000):
    num_k = len(k_grid)
    v = np.zeros(num_k)
    
    for i in range(max_iter):
        v_new = np.zeros(num_k)
        for j in range(num_k):
            k = k_grid[j]
            c_grid = np.linspace(0, f(k) + (1 - delta) * k, num_k)
            v_next = np.zeros(num_k)
            for m in range(num_k):
                k_next = f(k) + (1 - delta) * k - c_grid[m]
                k_next_index = np.argmin(np.abs(k_grid - k_next))
                v_next[m] = u(c_grid[m]) + beta * v[k_next_index]
            v_new[j] = np.max(v_next)
        error = np.max(np.abs(v - v_new))
        v = v_new
        if error < tol:
            break
    return v

def optimal_policy(k_grid, v):
    num_k = len(k_grid)
    policy = np.zeros(num_k)
    for j in range(num_k):
        k = k_grid[j]
        c_grid = np.linspace(0, f(k) + (1 - delta) * k, num_k)
        v_next = np.zeros(num_k)
        for m in range(num_k):
            k_next = f(k) + (1 - delta) * k - c_grid[m]
            k_next_index = np.argmin(np.abs(k_grid - k_next))
            v_next[m] = u(c_grid[m]) + beta * v[k_next_index]
        policy[j] = c_grid[np.argmax(v_next)]
    
    return policy

def euler_residuals(policy, k_grid):
    num_k = len(k_grid)
    residuals = np.zeros(num_k)
    for j in range(num_k):
        k = k_grid[j]
        c = policy[j]
        k_next = f(k) + (1 - delta) * k - c
        c_next = np.interp(k_next, k_grid, policy)
        residuals[j] = u(c) - beta * u(c_next) * (alpha * k_next**(alpha-1) + 1 - delta)
    
    return residuals



# Grid for capital
k_grid = np.linspace(0.25*k_star, 1.75*k_star, 101)


# Iterate
v = value_function_iteration(k_grid, tol=1e-6, max_iter=1000)
policy = optimal_policy(k_grid, v)
residuals = euler_residuals(policy, k_grid)
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 4))

ax1.plot(k_grid, policy)
ax1.set_xlabel('Capital')
ax1.set_ylabel('Optimal Consumption')
ax1.set_title('Optimal Accumulation Policy')

ax2.plot(k_grid, residuals)
ax2.set_xlabel('Capital')
ax2.set_ylabel('Euler Equation Residuals')
ax2.set_title('Euler Equation Residuals')

plt.tight_layout()
plt.savefig('macro_hw1_code/value_function_iteration.png', bbox_inches='tight')


# Generate transition path from policy function
def generate_transition_path(k0, policy, k_grid, T):
    path = np.zeros(T)
    path[0] = k0
    for t in range(1, T):
        k_index = np.argmin(np.abs(k_grid - path[t-1]))
        path[t] = policy[k_index]
    return path

policy_path = generate_transition_path(k0, policy, k_grid, 151)



# Plot the transition paths
plt.figure(figsize=(8, 6))
plt.plot(policy_path, c_vec, label='Policy Function Path')
plt.plot(k_vec[:151], c_vec, label='Shooting Method Path')
plt.plot(k_star, c_star, 'ro', label='Steady State')
plt.xlabel('Capital')
plt.ylabel('Consumption')
plt.ylim(1.08, 1.195)
plt.title('Transition Paths of Capital')
plt.legend()
plt.grid(True)
plt.savefig('macro_hw1_code/transition_paths.png', bbox_inches='tight')