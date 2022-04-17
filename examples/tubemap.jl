using CSV, DataFrames

using Karnak, Luxor, Graphs, Colors, NetworkLayout

df = CSV.read(joinpath(@__DIR__ ,"../data/tube.csv"), DataFrame)
M = Int64[]
for d in eachrow(df)
    r = copy(d[2:end])
    append!(M, collect(r))
end

stationnames = df[:, 1]

@show typeof(M)
M = reshape(M, (267, 267))

g = Graph(M)

@drawsvg begin
sethue("grey50")
drawgraph(g,
    layout=spring,
    vertexshapesizes=1,
    vertexlabels = stationnames,
    vertexlabelfontsizes = 5,
    vertexlabeltextcolors = colorant"cyan")
end
