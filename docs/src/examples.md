```@setup tubesection
using Karnak, Luxor, Graphs, NetworkLayout, Colors
using DataFrames, CSV

# positions are in LatLong

tubedata = CSV.File("../../examples/tubedata-modified.csv") |> DataFrame

amatrix = Matrix(tubedata[:, 4:270])

g = Graph(amatrix)

extrema_lat = extrema(tubedata.Latitude)
extrema_long = extrema(tubedata.Longitude)

# scale LatLong and flip in y to fit into current Luxor drawing
positions = @. Point(rescale(tubedata.Longitude, extrema_long..., -280, 280), rescale(tubedata.Latitude, extrema_lat..., 280, -280))

stations = tubedata[!,:Station]

find(str) = findfirst(isequal(str), stations)
find(x::Int64) = stations[x]
```

# Examples

## The Tube

One example of a small network in real life is the London Underground, known as "the tube". The 250 or so stations are connected with tracks, and the network can easily be modelled using a simple graph.

This is the setup required. The CSV file contains the station names, latitude and longitudes, and connectivity details.

```julia
using Karnak, Luxor, Graphs, NetworkLayout, Colors
using DataFrames, CSV

cd(joinpath(@__DIR__))

# positions are in LatLong

tubedata = CSV.File("examples/tubedata-modified.csv") |> DataFrame

amatrix = Matrix(tubedata[:, 4:270])


extrema_lat = extrema(tubedata.Latitude)
extrema_long = extrema(tubedata.Longitude)

# scale LatLong and flip in y to fit into current Luxor drawing
positions = @. Point(rescale(tubedata.Longitude, extrema_long..., -280, 280), rescale(tubedata.Latitude, extrema_lat..., 280, -280))

stations = tubedata[!,:Station]

find(str) = findfirst(isequal(str), stations)
find(x::Int64) = stations[x]

g = Graph(amatrix)
```

The tube "map" is stored in `g`, as a `{267, 308} undirected simple Int64 graph`.

The `find()` functions are just a quick way to convert between station names and ID numbers:

```@example tubesection
find("Waterloo")
```

```@example tubesection
find(244)
```

A quick first look at the graph reveals a very different view to what most London residents and visitors might expect to see.

```@example tubesection
@drawsvg begin
background("grey90")
sethue("black")
drawgraph(g, layout=positions)
end
```

The Tube "map" we're used to seeing is a geographically-inaccurate design classic, hand-drawn by Harry Beck in the 1931, and updated regularly ever since. As an electrical enginer, Beck was able to treat the sprawling London track network like a circuit board. As with graphs, what was important to Beck were the connections.

Use the `degree()` function to find the stations at the end of the line:

```@example tubesection
@drawsvg begin
background("grey90")
sethue("black")
drawgraph(g, layout=positions,
    vertexshapesizes = 2,
    vertexlabels = (vtx) ->
        begin
            if degree(g, vtx) == 1
                text(find(vtx), positions[vtx])
            end
        end)
end
```

These labels show the places whose names all Tube-riders know, and see on the platform indicators,  but have rarely visited.

The best connected station is also one of the oldest:

```@example tubesection
find(argmax(degree(g, 1:nv(g))))
```

```@example tubesection
find.(neighbors(g, find("Baker Street")))
```

A route from Heathrow Terminal 5 to Mornington Crescent is easily found using `a_star()`. We can print out the intermediate stops as well as mark them on the graph.

```@example tubesection
heathrow_to_morningtoncrescent = a_star(g,
	find("Heathrow Terminal 5"),
	find("Mornington Crescent"))

@drawsvg begin
	background("grey70")
	sethue("grey50")
	translate(0, -100)
	scale(3)
	drawgraph(g,
		layout = positions,
		vertexshapesizes = :none)
	sethue("black")
	fontsize(4)
	drawgraph(g, layout = positions,
		vertexshapes = :none,
		edgelines = :none,
		vertexlabels = (vtx) -> begin
			if vtx ∈ src.(heathrow_to_morningtoncrescent) ||
			   vtx ∈ dst.(heathrow_to_morningtoncrescent)
				 circle(positions[vtx], 2, :fill)
				 label(find(vtx), :e, positions[vtx])
			end
		end
		)
end
```

The route found by `a_star` is:

```@example tubesection
[find(dst(e)) for e in heathrow_to_morningtoncrescent]
```

but the required change at Victoria from the Piccadilly line to the Victoria Line is information that's not yet been added to the graph. Routes across the Tube network, like the trains, will follow the tracks (edges) - the concept of "lines" (Victoria, Circle, etc) isn't part of the graph, but a colorful fiction imposed on top of the track network.
