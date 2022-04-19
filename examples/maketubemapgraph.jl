using DataFrames, CSV
using Graphs, Karnak, Luxor, Colors, NetworkLayout

cd(joinpath(@__DIR__))

# positions are in LatLong

tubedata = CSV.File("tubedata-modified.csv") |> DataFrame

amatrix = Matrix(tubedata[:, 4:270])

g = Graph(amatrix)

extrema_lat = extrema(tubedata.Latitude)

extrema_long = extrema(tubedata.Longitude)

# scale and flip LatLong to current drawing
positions = @. Point(rescale(tubedata.Longitude, extrema_long..., -280, 280), rescale(tubedata.Latitude, extrema_lat..., 280, -280))

stations = tubedata[!,:Station]

uxbridge_to_upminster = a_star(g, findfirst(isequal("Uxbridge"), stations), findfirst(isequal("Upminster"), stations))
@drawsvg begin
	background("azure")
	sethue("purple")
	drawgraph(g,
		layout = positions,
		vertexshapesizes = :none,
		#vertexshapesizes = 2,
		#vertexlabelfontsizes = 5,
		#vertexlabeltextcolors = colorant"black",
		)
	drawgraph(g,
		layout=positions,
		vertexshapesizes = :none,
		edgelist = uxbridge_to_upminster,
		edgestrokeweights = 10)
end
