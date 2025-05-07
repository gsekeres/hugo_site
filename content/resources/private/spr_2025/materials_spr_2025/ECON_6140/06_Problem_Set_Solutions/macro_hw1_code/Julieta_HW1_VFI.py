# -*- coding: utf-8 -*-
"""
Created on Tue Jan 28 21:14:34 2025

@author: Mason
"""
#pip install interpolation #use if necessary
import numpy as np
import matplotlib.pyplot as plt
from numba import njit, float64
from numba.experimental import jitclass
from quantecon.optimize.scalar_maximization import brent_max
from interpolation import interp

opt_growth_data = [('α', float64),
                  ('β', float64),
                  ('γ', float64),
                  ('δ', float64),
                  ('A', float64),
                  ('grid',float64[:])]

@jitclass(opt_growth_data)
class OptimalGrowth_VI:
    def __init__(self, α=0.33, β=0.98, γ=0.95, δ=0.1, A = 1, grid_max=50, grid_size=500):
        self.α, self.β, self.γ, self.δ, self.A = α, β, γ, δ, A
        self.grid = np.linspace(0.1, grid_max, grid_size)
        
    def f(self, k):
        #return k**self.α #old version
        'Production function'
        α, A = self.α, self.A
        return A * k ** α

    def u(self, c):
        return c**(1 - self.γ) / (1 - self.γ)
    
    def objective(self, k, kp, v_array):
        f, u, β, δ = self.f, self.u, self.β, self.δ
        v = lambda x: interp(self.grid, v_array, x)
        c = f(k)+(1-δ)*k-kp
        if c <= 0:
            u = -888 - 800 * abs(c)
        else:
            u = u(c)
        return u + β*v(kp)
        #return u(f(k)+(1-δ)*k-kp) + β*v(kp)
    
@njit
def T(v, og_VI):
    v_greedy = np.empty_like(v)
    v_new = np.empty_like(v)
    
    for i in range(len(og_VI.grid)):
        k = og_VI.grid[i]
        lower = 1e-10
        upper = og_VI.f(k) + (1-og_VI.δ)*k
        result = brent_max(og_VI.objective, lower, upper, args=(k,v))
        v_greedy[i], v_new[i] = result[0], result[1]
        
    return v_greedy, v_new

def solve_model_VI(og_VI, tol=1e-4, max_iter=1000, print_skip=20):
    v = og_VI.grid
    error = tol+1
    i=0
    
    while i < max_iter and error > tol:
        v_greedy, v_new = T(v, og_VI)
        error = np.max(np.abs(v - v_new))
        i += 1
        if i % print_skip == 0:
            print(f"Error at iteration {i} is {error}.")
        v = v_new
    
    if i == max_iter:
        print("Failed to converge!")

    if i < max_iter:
        print(f"\nConverged in {i} iterations.")

    return v_greedy, v_new

og_VI = OptimalGrowth_VI()
v_greedy, v_solution = solve_model_VI(og_VI)
plt.plot(og_VI.grid, v_greedy)
# add 45 degree line
plt.plot(og_VI.grid, og_VI.grid, ls=':', label='45 degree line')
plt.xlabel('k(t)')
plt.ylabel('k(t+1)')
plt.show()
