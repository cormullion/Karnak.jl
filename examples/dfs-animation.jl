# using Karnak, Luxor, Graphs, NetworkLayout, Colors
# using DataFrames, CSV
#
# # positions are in LatLong
#
# tubedata = CSV.File("examples/tubedata-modified.csv") |> DataFrame
#
# amatrix = Matrix(tubedata[:, 4:270])
#
# g = Graph(amatrix)
#
# extrema_lat = extrema(tubedata.Latitude)
# extrema_long = extrema(tubedata.Longitude)
#
# # scale LatLong and flip in y to fit into current Luxor drawing
# positions = @. Point(rescale(tubedata.Longitude, extrema_long..., -280, 280), rescale(tubedata.Latitude, extrema_lat..., 280, -280))
#
# stations = tubedata[!,:Station]
#
# find(str) = findfirst(isequal(str), stations)
# find(x::Int64) = stations[x]


function frame(scene, framenumber, sp)
	background("black")
	sethue("grey40")

	sethue("red")
	circle(positions[find("Aldgate")], 10, :fill)
	sethue("magenta")

    for (n, V) in enumerate(sp[1:framenumber])
	    drawgraph(g, layout = positions,
	        vertexfunction = (v, c) -> begin
				if v == V
					circle(c[v], 3, :fill)
				end
			end,
			edgelines=0,
	        edgegaps = 0)
	    if find(V) == "Kew Gardens"
			println(V, framenumber)
			sethue("green")
			circle(positions[V], 10, :fill)
			sethue("blue")
	    end
	end
end

function main()
    amovie = Movie(600, 600, "dfs")

	# sp = bfs_parents(g, find("Aldgate"))
	sp = dfs_parents(g, find("Aldgate"))

    animate(amovie,
		Scene(amovie, (s, f) -> frame(s, f, sp), 1:length(sp)),
		framerate=30,
		creategif=true,
		pathname="/tmp/dfs.gif")
end
main()
