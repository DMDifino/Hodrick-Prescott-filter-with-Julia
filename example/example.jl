using CSV, Plots, Dates, DataFrames, DataFramesMeta

# st wd to script directory
cd(@__DIR__)

# load hpfilter function
include("../hpfilter.jl")

# load database
df = CSV.read("data//df.csv");

# apply hp filter
df.HP = hpfilter(df.GDP, 1600)
# create year column for sorting purposes
df.year = [Dates.year(df.DATE[i]) for i = 1:size(df.DATE)[1]]

# remove outliers (year > 1950)
df = @linq df |> where(:year .> 1959)
# data manipulation
df = @linq df |> select(
      row = [i for i = 1:size(df)[1]],
      date = Dates.format.(:DATE, "mm-yyyy"),
      year = [Dates.format(df.DATE[i], "yyyy") for i = 1:size(df.DATE)[1]],
      gdp = :GDP,
      trend = :HP,
      delta = [(:GDP[i] - :HP[i]) / :GDP[i] * 100 for i = 1:size(df)[1]],
      rec = :USRECQ,
      rec_max_1 = :USRECQ * maximum(:GDP / 1000),
      cri_min_2 = :USRECQ * minimum([
            (:GDP[i] - :HP[i]) / :GDP[i] * 100 for i = 1:size(df)[1]]),
      cri_max_2 = :USRECQ * maximum([
            (:GDP[i] - :HP[i]) / :GDP[i] * 100 for i = 1:size(df)[1]]),
)
# years array for x_axis
x_ticks = [df.year[i] for i = 1:40:length(df.gdp)]
push!(x_ticks, "2020")

# plot
plot(
      df.date,
      [df.rec_max_1, df.gdp / 1000, df.trend / 1000],
      label = ["NBER recession" "GDP (trillions)" "Filtered trend"],
      xticks = (collect(0:40:length(df.gdp)), x_ticks),
      seriestype = [:bar :path :path],
      framestyle = :grid,
      linecolor = [:lightgray :black :black],
      fillcolor = [:lightgray :black :black],
      linestyle = [:solid :solid :dash],
      legend = (:topleft),
      foreground_color_axis = :white,
      dpi = 1000,
      size = (600, 200)
)
savefig("plot//plot_1")

plot(
      df.date,
      [df.cri_min_2, df.cri_max_2, df.delta, [0]],
      xticks = (collect(0:40:length(df.gdp)), x_ticks),
      seriestype = [:bar :bar :path :hline],
      framestyle = :grid,
      linecolor = [:lightgray :lightgray :black :black],
      fillcolor = [:lightgray :lightgray :black :black],
      linestyle = [:solid :solid :solid :dash],
      legend = (:none),
      foreground_color_axis = :white,
      dpi = 300,
      size = (600, 200),
)
savefig("plot//plot_2")
