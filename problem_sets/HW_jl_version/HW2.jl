using DataFrames, Plots, Dates, StatsBase, CSV
println(readdir())

#ds = CSV.read("../lectures/covid_data.csv",DataFrames);
#rename!(ds,1=>"province",2=>"country")
# HW 1 & 2
function counts(data::Vector{Int})
  d = Dict{Int,Int}()
  for i in data
    haskey(d,i) ? d[i] +=1 : d[i] = 1
  end
  ks = collect(keys(d))
  vs = collect(values(d))
  p = sortperm(ks)
  #return [ks[p] ;; vs[p]]
  return hcat(ks[p],vs[p])
end

vv = [1, 0, 1, 0, 1000, 1, 1, 1000]
data = rand((1,2,3),100)
println("Result from HW 1&2")
@show counts(vv)
println("\n\n")
#HW 3
function bernoulli(p)
  sample = rand()
  return sample < p
end

function geometric(p)
  i = 0
  while !bernoulli(p) 
    i += 1
  end
  return i + 1 
end

function experiment(p,N)
  return [ geometric(p) for _ in 1:N]
end
println("result from HW 3")
test = experiment(0.25,10000)
@show mean(test)


#HW 4
function total_time(p_E,p_I,p_R)

end
