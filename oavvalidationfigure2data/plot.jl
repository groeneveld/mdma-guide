using CSV, DataFrames, Plots, StatsPlots

# Read the data
df = CSV.read("data-Table 1.csv", DataFrame)

# Get unique subscales in order they appear
subscales = unique(df[!, "Sub scale"])

# Clean group names (remove sample sizes for cleaner legend)
df.clean_group = replace.(df.Group, r" \(n=\d+\)" => "")

# Create x-axis positions (1, 2, 3, ... for each subscale)
x_pos = 1:length(subscales)

# Initialize the plot
p = plot(size=(800, 600), 
         xlabel="New OAV Factors", 
         ylabel="% of Scale Maximum",
         legend=(0.54,0.94),#:topright,
         xticks=(x_pos, subscales),
         xrotation=45,
         bottom_margin=8Plots.mm,
         left_margin=5Plots.mm,
         fontfamily="Computer Modern",
         legendfontsize=12,
         titlefontsize=12,
         guidefontsize=12,
         xtickfontsize=8
         )

# Define colors and markers for each group
markers = [:circle, :circle, :circle]
groups = ["Psilocybin", "Ketamine", "MDMA"]

# Plot each group
for (i, group) in enumerate(groups)
    # Filter data for this group
    group_data = filter(row -> occursin(group, row.Group), df)
    
    # Create arrays for plotting (ensure same order as subscales)
    y_vals = Float64[]
    y_err_lower = Float64[]
    y_err_upper = Float64[]
    
    for subscale in subscales
        row = filter(r -> r["Sub scale"] == subscale, group_data)
        if !isempty(row)
            push!(y_vals, row[1, :mean])
            push!(y_err_lower, row[1, :mean] - row[1, :ymin])
            push!(y_err_upper, row[1, :ymax] - row[1, :mean])
        end
    end
    
    # Plot line with error bars
    plot!(p, x_pos, y_vals, 
          yerror=(y_err_lower, y_err_upper),
          label=group,
          marker=markers[i],
          markersize=4,
          linewidth=2,
          markerstrokecolor=:auto)
end

# Save as PDF
savefig(p, "psychedelic_effects_plot.pdf")

println("Plot saved as 'psychedelic_effects_plot.pdf'")