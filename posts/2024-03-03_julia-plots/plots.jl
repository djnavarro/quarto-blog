using PalmerPenguins
using DataFrames
using Plots
using StatsPlots

# load penguins data: initially importat as CSV.file, then converted to DataFrame
penguins = DataFrame(PalmerPenguins.load()) 

# scatter plot: I could use scatter() here to avoid needing to set the seriestype
# explicitly, but for learning purposes I find it a little easier to work with 
# plot() for everthying and control plot type via explicit attribute values 
plot(
    penguins.bill_length_mm, 
    penguins.bill_depth_mm, 
    seriestype=:scatter
)

# using dataframes more explicitly via the @df macro (previous syntax treated the
# data frame as the first argument to plot() but no longer supported)
@df penguins plot(
    :bill_length_mm,
    :bill_depth_mm,
    seriestype=:scatter,
    group=:species
)

# adding labels is achieved by modifying the relevant attributes
@df penguins plot(
    :bill_length_mm,
    :bill_depth_mm,
    seriestype=:scatter,
    group=:species,
    title="Palmer Penguins",
    xlabel="Bill Length (mm)",
    ylabel="Bill Depth (mm)"
)

# filter rows that have missing bill lengths, because violin series
# can't handle missing data or NaNs. first let's find the the rows
# we want to keep: I found this weird because broadcasting the not
# operator has the dot first .!, whereas broadcasting the ismissing
# function has the dot after
keep = .!ismissing.(penguins.bill_length_mm)

# anyway, this data frame is violin safe...
bill_lengths = penguins[keep, [:bill_length_mm, :species]]

# so now we can create a violin plot
@df bill_lengths plot(
    string.(:species),
    :bill_length_mm,
    seriestype=:violin,
    legend=false,
    xlabel="Species",
    ylabel="Bill Length (mm)"
)