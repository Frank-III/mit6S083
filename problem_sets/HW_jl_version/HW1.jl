using DataFrames, Gadfly, Dates, CSV, Compose
#println(readdir())
data = CSV.read("lectures/covid_data.csv",DataFrame)
rename!(data, 1=>"province",2=>"country")
#unique = unique(data[:,2])
wanted_countries = sort(["US","China","United Kingdom","Italy","Germany"])

col_names = names(data,Number)
date_format = DateFormat("m/d/y")
dates = parse.(Date,col_names,date_format) + Year(2000)

col_name_symbol = Symbol.(col_names)


sub_data = combine(sub_data, col_name_symbol .=> sum .=> col_name_symbol)[1,:]
resample_data = Vector(sub_data)

#first one
# could process the data together using `in.`
country_data = Dict{String,Vector{Int}}()
for c in wanted_countries
	sub_data = data[data.country .== c,:]
	#still got some problems
	sub_data = combine(sub_data, col_name_symbol .=> sum .=> col_name_symbol)[1,:]
	resample_data = Vector(sub_data)
	@show resample_data
	#resample_data = collect(sub_data)
	#@show resample_data
  country_data[c] = cumsum(resample_data)
end


#second
country_ds = data[in.(data.country,Ref(wanted_countries)),:]
grp = groupby(country_ds,:country)
data_mat = Matrix(combine(grp, col_name_symbol .=> sum .=> col_name_symbol))[:,2:end]
@show data_mat
#println(size(data_mat))

#Plotting
latex_fonts = Theme(major_label_font="JuliaMono", major_label_font_size=16pt,
                    minor_label_font="JuliaMono", minor_label_font_size=14pt,
                    key_title_font="JuliaMono", key_title_font_size=12pt,
                    key_label_font="JuliaMono", key_label_font_size=10pt)
Gadfly.push_theme(latex_fonts)

@show map_to_country = Dict(zip(wanted_countries,1:5))
function plot_country(c::String)
	c_data = convert.(Int, data_mat[map_to_country[c],:])
	p = plot(x=dates,y=c_data,alpha=[0.5], Geom.line, Geom.point, Guide.manual_color_key("legend",["Points"],labels=["$c"]),
		Guide.title("The confirmed case of Covid 19 in $c"))
	return p
end
#Guide.colorkey(title="legend",labels=["country"])
set_default_plot_size(21cm, 8cm)
p1 = plot_country("China")
p2 = plot_country("Italy")
p3 = plot_country("Australia")
vstack(p1,p2,p3)

tmp = rand(100)
plot(layer(x=tmp,Geom.histogram,color=["hist"],Theme(alphas=[0.6])),
	 layer(x=tmp, Geom.density,color=["density"]),
	 Scale.color_discrete_manual("green","red"),
	 Guide.title("mimic sns.distplot"),
	 Guide.ylabel("y"),
	 )





p=plot()
@manipulate for i in size(data_mat):
	for j in length(wanted_countries):
		plot!(dates, data_mat[i,j], m=:o-,label="$want_countries[j]")
	legend!()
p

# an example of
p1 = plot(x=[1,2], y=[3,4], Geom.line);
p2 = Compose.context();
gridstack([p1 p1; p1 p1])
gridstack(Union{Plot,Compose.Context}[p1 p2; p2 p1])
