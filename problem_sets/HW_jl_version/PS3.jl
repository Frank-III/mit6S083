# -*- coding: utf-8 -*-
# ---
# jupyter:
#   jupytext:
#     text_representation:
#       extension: .jl
#       format_name: light
#       format_version: '1.5'
#       jupytext_version: 1.13.7
#   kernelspec:
#     display_name: Julia 1.7.1
#     language: julia
#     name: julia-1.7
# ---

# # 6.S083 / 18.S190 Spring 2020: Problem set 3
#
# Submission deadline: Tuesday April 21, 2020 at 11:59pm.
#
#
# In this problem set, we will develop our first proper model that exhibits an **epidemic
# outbreak**.
#
# We will develop a **stochastic** (probabilistic) model of an infection propagating in a population  that is **well mixed**, i.e. in which everyone is in contact with everyone else.
# An example of this would be a small school or university in which people are
# constantly moving around and interacting with each other.
#
# As usual, we will make modelling assumptions that allow us to reach the goal as fast and simply as possible.
#
# The model is an **individual-based** or **agent-based** model -- in other words,
# we explicitly keep track of each individual in the population and what their
# infection status is. However, we will not keep track of their position in space;
# we will just assume that there is some mechanism by which they interact with
# other individuals which we do not include in the model (for now).

# ## Exercise 1: Modelling the spread of an infection or rumour
#
# In this exercise we will model the spread of an infection or rumour in which
# there is no recovery via a stochastic model, which we will implement in a Monte Carlo
# simulation (i.e. a simulation that involves generating random numbers).
#
# We will call the individuals **agents**.
#
#
# 1. Julia has a data type called an [**enumerated type**](https://en.wikipedia.org/wiki/Enumerated_type). Variables of this type can only take one of a pre-defined set of values; we will use this to model the possible internal state of an agent.
#
#     The code to define an enum is as follows:
#
#     ```julia
#     @enum InfectionStatus S I R
#     ```
#
#     This defines a new type `InfectionStatus`, as well as names `S`, `I` and `R` that are the only possible values that a variable of this type can take.
#
#     Define a variable `x` equal to `S`. What is its type?
#
# 2. Convert `x` to an integer using the `Int` function. What value does it have? What values do `I` and `R` have?
#
# 3. Take $N=100$. Make an array `agents` whose $i$th entry is the status of agent
# number $i$. Make them all initially susceptible.
#
# 4. Now choose a single agent at random and make it infectious. (Hint: Use the
#     `rand` function with a range to choose the index of the infectious agent.)
#
# 5. Write a function `step!` that takes a `Vector` `agents` and a probability `p_I`
# as arguments.  This function may *modify* the content of `agents` to implement one step of the infection dynamics.
#
#     1. Choose an agent $i$ at random.
#     2. If $i$ is not infectious then nothing happens on this step so you can just `return`
#  from the function.
#      3. Choose another agent $j$ at random. Make sure that $i \neq j$. To do so, repeat this
#     choice *until* $i \neq j$.
#     4. If $j$ is susceptible then $i$ infects $j$ with probability $p_I$.
#
# 6. Write a function `sweep!` which takes arguments `agents` and `p_I`$. It runs `step!` $N$ times, where $N$ is the number of agents. Thus each agent acts, on average, once per sweep. One sweep is thus the unit
# of time in our Monte Carlo simulation.
#
# 7. Write a function `infection_simulation`. It should take $N$ and $p_I$ as arguments,
# as well as $T$, the total number of steps.
#
#     1. First generate the `Vector` `agents` of length $N$, picking one to be initially infected, and a `Vector` `Is` to store
#     the number of infectious individuals at each step.
#
#     2. Run `sweep!` a number $T$ of times. Calculate the total number of infectious
#     agents at the end of each step and store that number in `Is`.
#
#     3. Return `Is` as the output of the function.
#
# 8. Run your simulation 50 times with $N=100$ and collect the data in a `Vector` of `Vector`s called `results`, using $p_I = 0.02$ and $T = 1000$.
#
#     Plot each of the 50 graphs on the same plot using transparency 0.5.
#
# 9. Calculate the mean trajectory using the `mean` function applied to `results`. [This "just works" since `mean` is implmented in a generic way!] Add it to the plot using a heavier line.
#
# 10. Calculate the standard deviation $\sigma$ of $I$ at each step. [This should thus be a *vector.] Add this to the plot using **error bars**, using the option `yerr=σ` in the plot command; use transparency.
#
#     This should confirm that the distribution of $I$ at each step is pretty wide!
#
# 9. You should see that the mean behaves in a similar way to what we saw in lectures using a *deterministic* model. So what is the deterministic model possibly describing, in terms of the stochastic model?

# +
#using Gadfly,
# -

using Statistics, CairoMakie

@enum InfectionStatus S I R
x = S
@show Int(x)

N = 100
agents = [S for _ in 1:N]
agents[@show rand(1:N)] = I


pick(agent) = rand(1:length(agent))

function step!(agent,p_I)
    pick1 = pick(agent)
    if Int(agent[pick1]) == 0
        return
    end
    pick2 = pick(agent)
    while pick2 == pick1
        pick2 = pick(agent)
    end
    if rand() < p_I
        agent[pick2] = I
    end
    #@show pick1, pick2
end

function sweep!(agent,p_I)
    N = length(agent)
    for i in 1:N
        step!(agent,p_I)
    end
end

function infection_simulation(N,p_I,T)
    agents = [S for _ in 1:N]
    agents[rand(1:N)] = I
    Is = zeros(T)
    for t in 1:T
        sweep!(agents,p_I)
        Is[t] = sum(Int.(agents) .== 1 )
    end
    return Is
end

res = infection_simulation(100,0.02,1000)

f = Figure()
ax = Axis(f[1, 1], xlabel = "x label", ylabel = "y label",
    title = "Title")
for idx in 1:20
    lines!(ax,1:1000,infection_simulation(100,0.02,1000),label="$idx")
end
f[1, 2] = Legend(f, ax, "# Of Simulation", framevisible = false)
f
##Using Gadfly
"""
function run_plot()
    res = infection_simulation(100,0.02,1000)
    return layer(x=1:1000,y=res,Geom.line)
end
"""
#layers = [run_plot() for _ in 1:5]
#plot(layers...)

# ## Exercise 2: Agent type
#
# Suppose we want to track more information about each agent, e.g. how many other agents were infected by that agent. We could just create an additional array with that information in, but we will need to pass that around and will start to lose track of what belongs together.
#
# Instead a good solution is to define a custom composite type.
#
#
# 1. Define a mutable type `Agent` as follows:
#
#     ```jl
#     mutable struct Agent
#         status::InfectionStatus
#         num_infected::Int
#     end
#     ```
#
# 2. Define a method of the constructor of `Agent` that takes no arguments and sets the status to `S` and
# the number infected to 0.
#
#
# 3. Rewrite your code from Exercise 1 to use the new `Agent` type. Now when your functions accept an `agents`
# vector, they should assume that that represents a `Vector` of `Agent` objects.
#
#     You can enforce this using a function signature like
#
#     ```jl
#     function f(agents::Vector{Agent})
#     end
#     ```
#
#     You should call your main function `num_infected_dist_simulation`, where you create an array `agents` of `Agent`s of size $N=100$ and set the first one's infection status to `I`.
#
# 4. Update an agent's `num_infected` field whenever it infects another agent.
#
# 5. At the end of the simulation, extract the probability distribution of the "number of agents infected", using your code from Exercise 1 of Problem Set 2. This should be returned from `num_infected_dist_simulation`.
#
# 7. Average the distribution over 50 simulations and plot the result. What kind of distribution does it seem to be? You will need to think about how to visualize this.

function counts(data::Vector)
  d = Dict{Int,Int}()
  for i in data
    haskey(d,i) ? d[i] +=1 : d[i] = 1
  end
  ks = collect(keys(d))
  vs = collect(values(d))
  p = sortperm(ks)
  #return [ks[p] ;; vs[p]]
  return Dict(zip(ks[p],vs[p]))
end

mutable struct Agent
        status::InfectionStatus
        num_infected::Int
    end

Agent() = Agent(S,0)

function step!(agent::Vector{Agent},p_I)
    pick1 = pick(agent)
    if agent[pick1].status == S
        return
    end
    pick2 = pick(agent)
    while pick2 == pick1
        pick2 = pick(agent)
    end
    if rand() < p_I && agent[pick2].status == S
        agent[pick2].status = I
        agent[pick1].num_infected += 1
    end
    #@show pick1, pick2
end

# Do-while in Julia
# ```Julia
# while true
#     # do stuff
#     cond() || break
# end
# ```

function sweep!(agent::Vector{Agent},p_I)
    N = length(agent)
    for i in 1:N
        step!(agent,p_I)
    end
end

# +
function num_infected_dist_simulation(N,p_I,T)
    agents = [Agent() for _ in 1:N]
    agents[rand(1:N)].status = I
    #Is = zeros(T)
    for t in 1:T
        sweep!(agents,p_I)
        #Is[t] = sum(Int.(agents.status) .== 1 )

    end
    num_infected = [x.num_infected for x in agents]
    return num_infected
end


# -

#?histogram
tmp = vcat([num_infected_dist_simulation(100,0.02,1000) for _ in 1:50]...)
#f = Figure()
hist(tmp, bins = 10)
#f
# ## Exercise 3: Epidemic model
#
# 1. Add recovery to your model using an additional
# parameter `p_R` in the `step!` and related functions.
#
#     In each sweep, each agent should check if it is infected, and if so it
#     recovers with probability $p_R$.
#
#     The function `simulation_with_recovery` should return vectors `Ss`, `Is` and `Rs` giving the time evolution of the numbers of $S$, $I$ and $R$, as well as the probability distribution of number of people infected.
#
# 2. Run the simulation with $N=1000$, $p_I = 0.1$ and $p_R = 0.01$ for time $T=1000$. Plot $S$, $I$ and $R$ as a function of time. You should see graphs that look familiar from the internet, with an epidemic outbreak, i.e. a significant fraction of infectious agents after a short time, which then recover.
#
# 3. Plot the distribution of `num_infected`. Does it have a recognisable shape?
#
# 4. Run the simulation 50 times and plot $I$ as a function of time for each, together with the mean over the 50 simulations (as you did in Exercise 2).
#
# 5. Describe 3 ways in which you could characterize the magnitude of the epidemic. Find these quantities for one of the runs of your simulation.

function step!(agent::Vector{Agent},p_I,p_R)
    pick1 = pick(agent)
    if agent[pick1].status == S
        return
    end
    if agent[pick1].status == I
        if rand() > p_R
            pick2 = pick(agent)
            while pick2 == pick1
                pick2 = pick(agent)
            end
            if rand() < p_I && agent[pick2].status == S
                agent[pick2].status = I
                agent[pick1].num_infected += 1
            end
        else
            agent[pick1].status = R
        end
    end
    #@show pick1, pick2
end

function sweep!(agent::Vector{Agent},p_I,p_R)
    N = length(agent)
    for i in 1:N
        step!(agent,p_I,p_R)
    end
end

function simulation_with_recovery(N,p_I,p_R,T)
    agents = [Agent() for _ in 1:N]
    agents[rand(1:N)].status = I
    Ss, Is, Rs = Vector{Int64}(undef,T),Vector{Int64}(undef,T),Vector{Int64}(undef,T)
    for idx in 1:T
        sweep!(agents,p_I,p_R)
        tmp = [a.status for a in agents]
        Ss[idx] = count(tmp .== S)
        Is[idx] = count(tmp .== I)
        Rs[idx] = count(tmp .== R)
    end
    return Ss,Is,Rs
end


Ss,Is,Rs =  simulation_with_recovery(1000,0.1,0.01,1000)

f = Figure()
ax = Axis(f[1, 1], xlabel = "period", ylabel = "# Of People",
    title = "Title")
lines!(ax,1:1000,Ss,label="S")
lines!(ax,1:1000,Is,label="I")
lines!(ax,1:1000,Rs,label="R")

f[1, 2] = Legend(f, ax, "case", framevisible = false)
f
