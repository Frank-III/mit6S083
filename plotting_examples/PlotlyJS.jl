using PlotlyJS, DataFrames, Dates, CSV
## Scatter Plot
df = dataset(DataFrame, "gapminder")
df07 = df[df.year .== 2007, :]

plot(df07, x=:gdpPercap, y=:lifeExp, color =:continent, mode = "markers",
     marker=attr(size=:pop, sizeref = maximum(df07.pop)/(60^2), sizemode="area"),
     Layout(xaxis_type="log"))

function make_hover_text(row)
    join([
         "Country: $(row.country)<br>",
         "Life Expectancy: $(row.lifeExp)<br>",
         "GDP per capita: $(row.lifeExp)<br>",
         "Population: $(row.pop)<br>",
         "Year: $(row.year)"
     ], " ")
end

plot(
    df07,
    x=:gdpPercap, y=:lifeExp, group=:continent, mode="markers",
    #Learn how to use text
    text=sub_df -> make_hover_text.(DataFrames.eachrow(sub_df)),
    marker=attr(size=:pop, sizeref=maximum(df07.pop) / (60^2), sizemode="area"),
    Layout(
        title="Life Expectancy v. Per Capita GDP, 2007",
        xaxis=attr(
            type="log",
            title_text="GDP per capita (2000 dollars)",
            gridcolor="white"
        ),
        yaxis=attr(title_text="Life Expectancy (years)", gridcolor="white"),
        paper_bgcolor="rgb(243, 243, 243)",
        plot_bgcolor="rgb(243, 243, 243)",
    )
)


## Line Chart
title = "Main Source for News"
labels = ["Television", "Newspaper", "Internet", "Radio"]
color_vec = ["rgb(67,67,67)", "rgb(115,115,115)", "rgb(49,130,189)", "rgb(189,189,189)"]

mode_size = [8, 8, 12, 8]
line_size = [2, 2, 4, 2]

x_data = [
    2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013
    2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013
    2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013
    2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013
]

y_data = [
    74 82 80 74 73 72 74 70 70 66 66 69
    45 42 50 46 36 36 34 35 32 31 31 28
    13 14 20 24 20 24 24 40 35 41 43 50
    18 21 18 21 16 14 13 18 17 16 19 23
]

function trace_for_row(i)
    t1 = scatter(x=x_data[i, :], y=y_data[i, :], mode="lines",
        name=labels[i],
        line=attr(color=color_vec[i], width=line_size[i]),
        connectgaps=true
    )
    t2 = scatter(
        x=[x_data[i, 1], x_data[i, end]],
        y=[y_data[i, 1], y_data[i, end]],
        mode="markers",
        marker=attr(color=color_vec[i], size=mode_size[i])
    )
    [t1, t2]
end

traces = vcat(map(trace_for_row, 1:4)...)

function labels_for_row(i)
    y = y_data[i, :]
    color = color_vec[i]
    label = labels[i]

    # labeling the left_side of the plot
    a_left = attr(
        xref="paper", x=0.05, y=y[1],
        xanchor="right", yanchor="middle",
        text=string(label, " $(y[1])%"),
        font=attr(family="Arial", size=16),
        showarrow=false
    )

    # labeling the right_side of the plot
    a_right = attr(
        xref="paper", x=0.95, y=y[end],
        xanchor="left", yanchor="middle",
        text="$(y[end])%",
        font=attr(family="Arial", size=16),
        showarrow=false
    )
    [a_left, a_right]
end
annotations = vcat(map(labels_for_row, 1:4)...)

# Title
a_title = attr(
    xref="paper", yref="paper", x=0.0, y=1.05,
    xanchor="left", yanchor="bottom",
    text="Main Source for News",
    font=attr(family="Arial", size=30, color="rgb(37,37,37)"),
    showarrow=false
)

# Source
a_source = attr(
    xref="paper", yref="paper", x=0.5, y=-0.1,
    xanchor="center", yanchor="top",
    text=string("Source: PewResearch Center & ", "Storytelling with data"),
    font=attr(family="Arial", size=12, color="rgb(150,150,150)"),
    showarrow=false
)

append!(annotations, [a_title, a_source])

layout = Layout(
    annotations=annotations,
    xaxis=attr(
        showline=true,
        showgrid=false,
        showticklabels=true,
        linecolor="rgb(204, 204, 204)",
        linewidth=2,
        ticks="outside",
        tickfont=attr(
            family="Arial",
            size=12,
            color="rgb(82, 82, 82)",
        ),
    ),
    yaxis=attr(
        showgrid=false,
        zeroline=false,
        showline=false,
        showticklabels=false,
    ),
    autosize=false,
    margin=attr(
        autoexpand=false,
        l=100,
        r=20,
        t=110,
    ),
    showlegend=false,
    plot_bgcolor="white"
)

plot(traces, layout)
