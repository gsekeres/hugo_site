using Random, Distributions, Plots

# Make plots look pretty
pyplot() 
PyPlot.rc("text", usetex=true) 
PyPlot.rc("font", family="serif") 
PyPlot.matplotlib.rcParams["mathtext.fontset"] = "cm"

# Set seed for reproducibility
Random.seed!(12345)

# 1.1 Bootstrapping the median

data = rand(Normal(0, 1), 100)

p1 = histogram(data, bins=25, background=:transparent, legend=false)
savefig(p1, "ps6_code/ps6_hist.png")

println("The median of the data is $(median(data))")

B = 2000
bootstrap_medians = [median(sample(data, 100, replace=true)) for _ in 1:B]

se = std(bootstrap_medians)
z = quantile(Normal(), 0.95)

ci_se = [median(data) - z*se, median(data) + z*se]
ci_perc = quantile(bootstrap_medians, [0.05, 0.95])

println("The 95% confidence interval using the standard error is $(ci_se)")
println("The 95% confidence interval using the percentile method is $(ci_perc)")

# 1.2 Test size with monte carlo simulation
function simulate_bootstrap_median(n, B, iters)
    cover_se = zeros(iters)
    cover_perc = zeros(iters)
    len_se = zeros(iters)
    len_perc = zeros(iters)
    z = quantile(Normal(), 0.95)

    for i in 1:iters
        Random.seed!(12345 * i)
        data = rand(Normal(0, 1), n)
        medians = [median(sample(data, n, replace=true)) for _ in 1:B]

        se = std(medians)
        ci_se = [median(data) - z*se, median(data) + z*se]
        ci_perc = quantile(medians, [0.05, 0.95])

        cover_se[i] = ci_se[1] <= 0 <= ci_se[2]
        cover_perc[i] = ci_perc[1] <= 0 <= ci_perc[2]

        len_se[i] = ci_se[2] - ci_se[1]
        len_perc[i] = ci_perc[2] - ci_perc[1]
    end

    return cover_se, cover_perc, len_se, len_perc
end

@time cover_se, cover_perc, len_se, len_perc = simulate_bootstrap_median(100, 2000, 1000)

println("The coverage of the standard error method is $(mean(cover_se))")
println("The coverage of the percentile method is $(mean(cover_perc))")

println("The average length of the standard error method is $(mean(len_se))")
println("The average length of the percentile method is $(mean(len_perc))")

# 2 Bootstrap uniform 0,1 maximum

function simulate_bootstrap_uniform_max(n, B, iters)
    cover = zeros(iters)
    len = zeros(iters)
    maxima = zeros(iters)

    for i in 1:iters
        Random.seed!(12345 * i)
        data = rand(Uniform(0, 1), n)
        maxes = [maximum(sample(data, n, replace=true)) for _ in 1:B]

        se = std(maxes)
        ci = quantile(maxes, [0.05, 0.95])

        cover[i] = ci[1] <= 1 <= ci[2]
        len[i] = ci[2] - ci[1]
        maxima[i] = maximum(data)
    end

    return cover, len, maxima
end

@time cover, len, maxima = simulate_bootstrap_uniform_max(100, 2000, 1000)
println("The coverage of the bootstrap is $(mean(cover))")
println("The average length of the bootstrap is $(mean(len))")
println("The average maximum of the bootstrap is $(mean(maxima))")

# Plot maxima
p2 = histogram(maxima, bins=100, background=:transparent, legend=false)
savefig(p2, "ps6_code/ps6_max.png")

