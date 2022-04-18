using CSV, DataFrames
using Karnak, Luxor, Graphs, Colors, NetworkLayout

println("finished compiling")

df = CSV.read(joinpath(@__DIR__ ,"../data/tube.csv"), DataFrame)

M = Int64[]

for d in eachrow(df)
    r = copy(d[2:end])
    append!(M, collect(r))
end

stationnames = df[:, 1]

M = reshape(M, (267, 267))

g = Graph(M)

# sethue("grey50")
# drawgraph(g,
#     layout=spring,
#     vertexshapesizes=1,
#     vertexlabels = stationnames,
#     vertexlabelfontsizes = 5,
#     vertexlabeltextcolors = colorant"cyan")

stations = Dict(i => n for (n, i) in enumerate(stationnames))

astar = a_star(g, stations["Waterloo"], stations["Cockfosters"])

@show astar

@drawsvg begin
    background("black")
    sethue("grey50")

    drawgraph(g, layout=spring,
        vertexshapesizes = 1,
        edgestrokecolors = colorant"olive")

    drawgraph(g, layout=spring,
        vertexlabels = (vtx) -> (vtx ∈ src.(astar) || vtx ∈ dst.(astar)) && stationnames[vtx],
        vertexlabelfontsizes = 10,
        vertexshapes = (vtx) -> (vtx ∈ src.(astar) || vtx ∈ dst.(astar)) && circle(O, 5, :fill),
        vertexfillcolors = colorant"red",
        vertexlabeltextcolors = colorant"white",
        edgestrokeweights= 1,
        edgelist = astar)

end 1200 1200
