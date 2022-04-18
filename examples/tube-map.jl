using CSV, DataFrames
using Karnak, Luxor, Graphs, Colors, NetworkLayout

cd(@__DIR__)

g = loadgraph("tubemap-graph.lg")

positions = map(r -> Point(r[1], r[2]), CSV.File("tubemap-positions.csv"))

stations = Dict(CSV.File("tubemap-stations.csv"))

astar = a_star(g, stations["Waterloo"], stations["Cockfosters"])

@drawsvg begin
    background("grey20")

    sethue("grey50")

    drawgraph(g, layout=positions, edgestrokecolors = colorant"olive")

    drawgraph(g, layout=positions,
        vertexlabels = (vtx) -> ( (vtx ∈ src.(astar) || vtx ∈ dst.(astar)) ) && collect(keys(stations)),
        vertexshapes = (vtx) -> (vtx ∈ src.(astar) || vtx ∈ dst.(astar)) && circle(O, 2, :fill),
#        vertexfillcolors = colorant"red",
        vertexlabeltextcolors = colorant"white",
        vertexlabelfontsizes = 30,
        edgestrokeweights= 12,
        edgestrokecolors = colorant"blue",
        edgelist = astar
        )
end 1200 1200
