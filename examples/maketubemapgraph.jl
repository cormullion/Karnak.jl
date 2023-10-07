using DataFrames, CSV
using Graphs, Karnak, Colors, NetworkLayout

cd(joinpath(@__DIR__))

# positions are in LatLong

tubedata = CSV.File("tubedata-modified.csv") |> DataFrame

amatrix = Matrix(tubedata[:, 4:270])

g = Graph(amatrix)

extrema_lat = extrema(tubedata.Latitude)
extrema_long = extrema(tubedata.Longitude)

# scale LatLong and flip in y to fit into current drawing
positions = @. Point(rescale(tubedata.Longitude, extrema_long..., -280, 280), rescale(tubedata.Latitude, extrema_lat..., 280, -280))

stations = tubedata[!,:Station]

find(str) = findfirst(isequal(str), stations)
find(x::Int64) = stations[x]

uxbridge_to_upminster = a_star(g, find("Uxbridge"), find("Upminster"))

morden_to_morningtoncrescent = a_star(g, find("Morden"), find("Mornington Crescent"))

@drawsvg begin
    background("grey70")
    sethue("grey50")
    drawgraph(g,
        layout = positions,
        vertexshapesizes = :none)
    sethue("black")
    drawgraph(g,
        vertexshapes = :none,
        edgelines = :none,
        vertexlabels = (vtx) -> begin
            if vtx ∈ src.(morden_to_morningtoncrescent) || vtx ∈ dst.(morden_to_morningtoncrescent)
                println(find(vtx))
                find(vtx)
                circle(positions[vtx], 5, :fill)
                label(find(vtx), :e, positions[vtx], offset=10)
            end
        end
        )
end
