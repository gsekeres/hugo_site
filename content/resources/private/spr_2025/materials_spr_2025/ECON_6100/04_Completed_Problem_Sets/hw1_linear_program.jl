using JuMP, HiGHS, Plots, LaTeXStrings

function solve_lp(b)
    model = Model(HiGHS.Optimizer)
    
    @variable(model, x[1:2])
    
    @objective(model, Max, x[1] + 2x[2])
    
    @constraint(model, x[1] + x[2] <= 4)
    @constraint(model, x[1] + 3x[2] <= b)
    
    set_silent(model)
    optimize!(model)
    
    status = termination_status(model)
    if status == OPTIMAL
        return string(status), objective_value(model), value.(x)
    else
        return string(status), Float64[], Float64[]
    end
end

function solve_dual(b)
    model = Model(HiGHS.Optimizer)

    @variable(model, y[1:2] >= 0)
    
    @objective(model, Min, 4y[1] + b*y[2])
    
    @constraint(model, y[1] + y[2] == 1)
    @constraint(model, y[1] + 3y[2] == 2)
    
    set_silent(model)
    optimize!(model)
    
    status = termination_status(model)
    if status == OPTIMAL
        return string(status), objective_value(model), value.(y)
    else
        return string(status), Float64[], Float64[]
    end
end

b = 1
status, objective, solution = solve_lp(b)
println("Status: $status")
println("Objective value: $objective")
println("Solution: $solution")

dual_status, dual_objective, dual_solution = solve_dual(b)
println("Dual Status: $dual_status")
println("Dual Objective value: $dual_objective")
println("Dual Solution: $dual_solution")


range_of_b = 0:0.01:14
values = zeros(length(range_of_b))

for (i, b) in enumerate(range_of_b)
    values[i] = solve_lp(b)[2]
end

using Plots
plot(range_of_b, values, label="Objective Value", xlabel=L"b", ylabel="Objective Value", legend=false)
savefig("ps1_objective_value.png")