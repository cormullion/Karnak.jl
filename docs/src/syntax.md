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

Karnak's function for drawing graphs is `drawgraph()`. This
takes a single argument, a `Graph`, and tries to place it on
the current Luxor drawing. It uses the current color, scale,
and rotation.


```@example graphsection
@drawsvg begin
background("grey10")
sethue("darkcyan")
g = complete_graph(10)
drawgraph(g)
end 600 300
```

To control the appearance of the graph, you supply values to
some of the keyword arguments. Most keyword arguments
accepts vectors, ranges, and scalar values, and a few accept
functions as well.

For example, a contrived (and consequently hideously ugly)
example of some possible syntax would be:

```@example graphsection
@drawsvg begin
background("grey10")
sethue("purple")
g = smallgraph(:karate)
drawgraph(g, layout=stress,
	vertexshapes = [:square, :circle],
	vertexfillcolors = (v) -> if v ∈ (1, 3, 6) sethue("red") end,
	vertexstrokecolors = colorant"orange",
	vertexstrokeweights = 0.5:5,
	vertexshapesizes = 2 .* [Graphs.outdegree(g, v) for v in Graphs.vertices(g)],
	vertexlabelfontsizes = 2 .* [Graphs.outdegree(g, v) for v in Graphs.vertices(g)],
	vertexlabels = 1:nv(g),
	vertexlabelrotations = π/8,
	vertexlabeltextcolors = distinguishable_colors(10)
	)
end 600 300
```

Here, the **outdegree** for each vertex is used to control the size of the vertices and the font sizes too. `vertexshapes` flip-flops between squares and circles for each vertex shape, but the size of the shape is determined by a `vertexshapesizes` function, which receives a Vector of sizes, the outdegree values for each vertex. The font sizes of the labels are also set this way. A `vertexfillcolors` function lets you determine the shape's fill color for specific vertices, whereas the stroke color is always orange, with stroke weights gradually increasing. The colors of the labels are set by the `Colors.distinguishable_colors()` function passed to `vertexlabeltextcolors`. And all the labels are rotated, for no good reason.

Usually, if the vector runs out before the vertices and edges have been drawn, some `mod1` magic means the values repeat from the beginning again.


## BoundingBox

The graphics for the graph are placed to fit inside the current BoundingBox (ie the drawing), allowing for the margin (default is 30). You can pass a different BoundingBox to the `boundingbox` keyword argument.

## Layout

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
N = 12; H = 250; W = 550
g = complete_bipartite_graph(N, N)
pts = vcat(
    between.(O + (-W/2, -H/2),  O + (-W/2, H/2),  range(0, 1, length=N)), # left set
    between.(O + (W/2, H/2),   O + (W/2, -H/2), range(0, 1, length=N)))   # right set
circle.(pts, 1, :fill)
drawgraph(g, vertexlabels = 1:nv(g), layout = pts,
    edgestrokecolors = (n, f, t) -> sethue(HSB(rescale(n, 1, ne(g), 0, 360), 0.6, 0.9)))
end 600 300
```

## vertexfunction and edgefunction

The two keyword arguments `vertexfunction` and `edgefunction` allow you to pass control over the drawing process completely to two functions (which can be anonymous functions).

```
vertexfunction = my_vertexfunction(vertex, coordinates)
edgefunction = my_edgefunction(from::Point, to::Point)
```

These allow you to place graphics at `coordinates[vertex]`, and to draw edges from `from` to `to`, using any available tools for drawing.

In the next example, the vertices are marked using a function that places clipped PNG images, and the edges are drawn with sine curves. Refer to the Luxor documentation for more than you could possibly want to know about putting colored things on drawings.

![image vertices](assets/figures/karnakmap.png)

## Vertex labels and shapes

### vertexlabels

Use `vertexlabels` to choose the labels to draw. Supply a range, array of strings or numbers, or a string.

```@example graphsection
@drawsvg begin
background("grey10")
g = smallgraph(:octahedral)
sethue("gold")
drawgraph(g, layout=stress,
	vertexlabels = 1:nv(g),
	vertexshapesizes = 10
	)
end 600 300
```

You can use a function with `vertexlabels` to display a vertex; it should return a string to display.

```@example graphsection
@drawsvg begin
background("grey10")
g = smallgraph(:octahedral)
sethue("purple")
drawgraph(g, layout=stress,
	vertexlabels = (v) -> v ∈ (1, 2, 3) && string(v),
	vertexshapesizes = 30,
	vertexlabelfontsizes = 30,
	)
end 600 300
```

### vertexshapes and vertexshapesizes

For the shape of the graphic placed at a vertex, you can use these two keyword arguments.

Options for `vertexshapes` are `:circle` and `:square`. With just two in a vector, they will be used alternately.

```@example graphsection
@drawsvg begin
background("grey10")
g = smallgraph(:moebiuskantor)
sethue("gold")
drawgraph(g, layout=shell,
	vertexshapes = [:square, :circle],
	vertexshapesizes = [35, 20],
	)
end 600 300
```

It's such a limited choice. But no worries, because you can pass a function to `vertexshapes` to draw any shape you like. The single argument is the vertex number, graphics will be centered at the vertex location.

```@example graphsection
@drawsvg begin
background("grey10")
g = smallgraph(:moebiuskantor)
sethue("cyan")
drawgraph(g, layout=shell,
	vertexshapes = (v) -> star(O, 20, 5, 0.5, 0, :fill)
	)
end 600 300
```
In this example, the sizes of the labels and shapes are determined by the degree of each vertex, supplied in a vector.

```@example graphsection
@drawsvg begin
background("grey10")
g = smallgraph(:karate)
sethue("slateblue")
drawgraph(g, layout=stress,
	vertexfillcolors = (v) -> if v ∈ (1, 3, 6) sethue("red") end,
	vertexlabels  = 1:nv(g),
	vertexlabelfontsizes=[Graphs.outdegree(g, v) for v in Graphs.vertices(g)],
	vertexshapesizes=[Graphs.outdegree(g, v) for v in Graphs.vertices(g)],
	)
end 600 300
```

### vertexshaperotations

```@example graphsection
@drawsvg begin
background("grey10")
g = smallgraph(:octahedral)
sethue("slateblue")
drawgraph(g, layout=stress,
	vertexshapes = :square,
	vertexshapesizes = 40,
	vertexshaperotations = range(0, 2π, length = nv(g))
	)
end 600 300
```

### vertexstrokecolors and vertexfillcolors

These keywords accept a Colors.jl `colorant`, an array of them, or a function that generates a color.

```@example graphsection
@drawsvg begin
background("grey10")
g = smallgraph(:cubical)
sethue("darkorange")
drawgraph(g, layout=stress,
	vertexshapes = :square,
	vertexshapesizes =  20,
	vertexfillcolors = [colorant"red", colorant"blue"],
	vertexstrokecolors = [colorant"blue", colorant"red"]
	)
end 600 300
```

A function should set the Luxor current color:

```@example graphsection
@drawsvg begin
background("grey10")
g = smallgraph(:icosahedral)
sethue("darkorange")
drawgraph(g, layout=spring,
	vertexshapes = :square,
	vertexshapesizes =  20,
	vertexfillcolors = (v) -> sethue(HSB(rescale(v, 1, nv(g), 0, 359), 1, 1))
	)
end 600 300
```

### vertexstrokeweights

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
