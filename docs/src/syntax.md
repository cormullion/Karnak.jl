```@setup graphsection
using Karnak, Luxor, Graphs, NetworkLayout, Colors

# these bright colors work on both white and dark backgrounds
#  "fuchsia" "magenta" "magenta1" "brown1" "firebrick1"
#  "blue" "blue1" "red" "red1" "purple1" "royalblue1"
#  "orangered" "orangered1" "deeppink" "deeppink1" "maroon1"
#  "darkorchid1" "dodgerblue" "dodgerblue1" "blue2"
#  "purple2" "royalblue2" "dodgerblue2" "slateblue2"
#  "mediumslateblue" "darkorchid2" "violetred2" "maroon2"
#  "orangered2" "brown2"
```

# Syntax

## Overview

The main function for drawing graphs is `drawgraph()`. This
takes a single argument, a Graph, and tries to place it on
the current Luxor drawing. It uses the current color, scale,
and rotation.


```@example graphsection
@drawsvg begin
background("grey70")
sethue("darkcyan")
g = complete_graph(10)
drawgraph(g)
end 600 300
```

To control the appearance of the graph, you supply values to some of the keyword arguments.
Most keyword arguments accepts vectors, ranges, individual specifications, and a few accept functions as well.

For example, a contrived (and consequently hideously ugly) example would be:

```@example graphsection
@drawsvg begin
	background("grey70")
	sethue("purple")
	g = smallgraph(:karate)
	drawgraph(g, layout=stress,
		vertexfillcolors = (v) -> if v ∈ (1, 3, 6) sethue("red") end,
		vertexshapes = [:square, :circle],
		vertexstrokeweights = 0.5:5,
		vertexstrokecolors = colorant"orange",
		vertexshapesizes = 3 .* [Graphs.outdegree(g, v) for v in Graphs.vertices(g)],
		vertexlabelfontsizes = 4 .* [Graphs.outdegree(g, v) for v in Graphs.vertices(g)],
		vertexlabels = 1:nv(g),
		vertexlabeloffsetdistances = 0,
		vertexlabeltextcolors = distinguishable_colors(10),
		vertexlabeloffsetangles = 0)
end
```

Here, the `vertexfillcolors` function lets you determine the shape's fill color for specific vertices. `vertexshapes` flip-flops between squares and circles for each vertex shape, but the size of the shape is determined by a `vertexshapesizes` function, which supplies a Vector of sizes. The font sizes of the labels are also set this way. The colors of the labels are set by the `Colors.distinguishable_colors()` function passed to `vertexlabeltextcolors`.

Usually, if the vector runs out before the vertices and edges have been drawn, some `mod1` magic means the values repeat from the beginning again.

## General options

### BoundingBox

The graphics for the graph are placed to fit inside the current BoundingBox (ie the drawing), allowing for the margin (default is 30). You can pass a different BoundingBox to the `boundingbox` keyword argument.

### Layout

The only clever stuff in this process is provided by [NetworkLayout.jl](https://juliagraphs.org/NetworkLayout.jl/)), which is where you should look for information about the various algorithms that determine where vertices are positioned.

Here are some formulations which work:

```julia
layout = squaregrid

layout = shell

layout = stress

layout = spectral

layout = (g) -> spectral(adjacency_matrix(g), dim=2)

layout = shell ∘ adjacency_matrix

layout = (g) -> sfdp(g, Ptype=Float64, dim=2, tol=0.05, C=0.4, K=2)

layout = Shell(nlist=[6:10,])
```

Alternatively, you can pass a vector of Luxor points to the `layout` keyword argument. Vertices will be placed on these points, rather than by the points suggested by the NetworkLayout functions.

For example, in this example, the two sets of points for a bipartite graph are generated beforehand.

```@example graphsection
@drawsvg begin
background("grey20")
N = 12; H = 500; W = 550
g = complete_bipartite_graph(N, N)
pts = vcat(
    between.(O + (-W/2, -H/2),  O + (-W/2, H/2),  range(0, 1, length=N)), # left set
    between.(O + (W/2, H/2),   O + (W/2, -H/2), range(0, 1, length=N)))   # right set
circle.(pts, 1, :fill)
drawgraph(g, vertexlabels = 1:nv(g), layout = pts,
    edgestrokecolors = (n, f, t) -> sethue(HSB(rescale(n, 1, ne(g), 0, 360), 0.6, 0.9)))
end
```

## vertexfunction and edgefunction

The two keyword arguments `vertexfunction` and `edgefunction` allow you to pass control over the drawing process completely to two functions (which can be anonymous functions).

```
vertexfunction = my_vertexfunction(vertex, coordinates)
edgefunction = my_edgefunction(from::Point, to::Point)
```

These allow you to place graphics at `coordinates[vertex]`, and to draw edges from `from` to `to`, using any available tools for drawing.

In this example, the vertices are marked by a function that places clipped PNG images, and the edges are drawn with sine curves. Refer to the Luxor documentation for more than you could possibly want to know about drawing colored lines.

![image vertices](../assets/figures/karnakmap.png)


## Vertex options

### vertexlabels

### vertexshapes

### vertexshapesizes

```@example graphsection
g = Graph() # hide
add_vertices!(g, 4) # hide
add_edge!(g, 1, 2) # hide
add_edge!(g, 1, 3) # hide
add_edge!(g, 2, 3) # hide
add_edge!(g, 1, 4) # hide

@drawsvg begin # hide
background("grey70")
g = smallgraph(:karate)

drawgraph(g, layout=stress,
	vertexfillcolors = (v) -> if v ∈ (1, 3, 6) sethue("red") end,
	vertexshapesizes=[Graphs.outdegree(g, v) for v in Graphs.vertices(g)],
	)

	end # hide
	```
### vertexshaperotations

### vertexstrokecolors

### vertexstrokeweights

### vertexfillcolors

### vertexlabeltextcolors

### vertexlabelfontsizes

### vertexlabelfontfaces

### vertexlabelrotations

### vertexlabeloffsetangles

### vertexlabeloffsetdistances


## Edge options

### edgefunction

### edgelabels

### edgelines

### edgecurvature=0.0,

### edgestrokecolors

### edgestrokeweights

### edgedashpatterns

### edgelabelcolors

### edgelabelrotations=nothing























##
