using CairoMakie, DataFrames, Dates, CSV,

fig,ax,plotobj = scatterlines(1:10)

@show plotobj.attributes
