```@setup graphsection
using Karnak, Luxor, Graphs, NetworkLayout, Colors, SimpleWeightedGraphs

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
and rotation, marking the vertices of the graph with circles.


```@example graphsection
@drawsvg begin
background("grey10")
sethue("darkcyan")
g = complete_graph(10)
drawgraph(g)
end 600 300
```

To control the appearance of the graph, you supply values to the keyword arguments. Most keyword arguments
accepts vectors, ranges, and scalar values, and a few accept
functions as well.

Here's a contrived (and consequently hideously ugly)
example of the type of syntax you can use:

```@example graphsection
@drawsvg begin
background("grey10")
sethue("purple")
g = smallgraph(:karate)
drawgraph(g, layout=stress,
	vertexshapes = [:square, :circle],
	vertexfillcolors = (v) -> if v ∈ (1, 3, 6) sethue("red") end,
	vertexstrokecolors = colorant"orange",
	vertexstrokeweights = range(0.5, 4, length=nv(g)),
	vertexshapesizes = 2 .* [Graphs.outdegree(g, v) for v in Graphs.vertices(g)],
	vertexlabelfontsizes = 2 .* [Graphs.outdegree(g, v) for v in Graphs.vertices(g)],
	vertexlabels = 1:nv(g),
	vertexlabelrotations = π/8,
	vertexlabeltextcolors = distinguishable_colors(10)
)
end 600 300
```

Here, the **outdegree** for each vertex (the number of edges leaving it) is used to control the size of the vertices and the font sizes too. `vertexshapes` flip-flops between squares and circles for each vertex shape, but the size of the shape is determined by a `vertexshapesizes` function, which receives a Vector of sizes, the outdegree values for each vertex. The font sizes of the labels are also set this way. A `vertexfillcolors` function lets you determine the shape's fill color for specific vertices, whereas the stroke color is always orange, with stroke weights gradually increasing. The colors of the labels are set by the `Colors.distinguishable_colors()` function passed to `vertexlabeltextcolors`. And all the labels are rotated, for no particularly good reason.

Usually, if a vector runs out before the vertices and edges have been drawn, some `mod1` magic means the values repeat from the beginning again.

## The BoundingBox

The graphics for the graph are placed to fit inside the current BoundingBox (ie the drawing), after allowing for the margin (the default is 30). You can pass a different BoundingBox to the `boundingbox` keyword argument.

## Layout algorithms

The only clever part of this package is provided by [NetworkLayout.jl](https://juliagraphs.org/NetworkLayout.jl/)), which is where you should look for information about the various algorithms that determine where vertices are positioned.

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

Alternatively, you can pass a vector of Luxor Points to the `layout` keyword argument. Vertices will be placed on these points, rather than at points suggested by the NetworkLayout functions.

For example, in this next drawing, the two sets of points for a bipartite graph are generated beforehand.

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
    edgestrokeweights = 0.5,
	edgestrokecolors = (n, f, t) -> sethue(HSB(rescale(n, 1, ne(g), 0, 360), 0.6, 0.9)))
end 600 300
```

## The `vertexfunction` and `edgefunction` arguments

The two keyword arguments `vertexfunction` and `edgefunction` allow you to pass control over the drawing process completely to two functions, which can be anonymous functions.

```
vertexfunction = my_vertexfunction(vertex, coordinates)
edgefunction = my_edgefunction(from::Point, to::Point)
```

These allow you to place graphics at `coordinates[vertex]`, and to draw edges from `from` to `to`, using any available tools for drawing.

In the following picture, the vertex positions were passed to a function that placed clipped PNG images on the drawing (using `Luxor.readpng()` and `Luxor.placeimage()`), and the edges were drawn using sine curves. Refer to the Luxor documentation for more than you could possibly want to know about putting colored things on drawings.

![image vertices](assets/figures/karnakmap.png)

It's also possible to draw graphs recursively if you use `vertexfunction`.


```@example graphsection
g = star_graph(8)

function rgraph(g, l=1)
    if l > 3
        return
    else
    drawgraph(g,
        layout = stress,
        vertexfunction = (v, c) -> begin
            @layer begin
                sethue(HSB(rescale(v, 1, 8, 0, 360), .7, .8))
                translate(c[v])
                circle(c[v], 5, :fill)
                rgraph(g, l + 1)
            end
        end,
        boundingbox = BoundingBox()/3)
    end
end

@drawsvg begin
    background("grey10")
    rgraph(g)
end 800 600
```

## Vertex labels and shapes

### The `vertexlabels` argument

Use `vertexlabels` to choose the text to associate with each vertex. Supply a range, array of strings or numbers, or a string.

This example draws all vertices, and numbers them from 1 to 6.

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

### `vertexshapes` and `vertexshapesizes`

To determine the shape of the graphic placed at a vertex, you can use these two keyword arguments.

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

Yes, it's a limited choice. But no worries, because you can pass a function to `vertexshapes` to draw any shape you like. The single argument is the vertex number; graphics will be centered at the vertex location.

```@example graphsection
@drawsvg begin
background("grey10")
g = smallgraph(:moebiuskantor)
sethue("cyan")
drawgraph(g, layout=shell,
	vertexshapes = (v) -> star(O, 20, 5, 0.5, 0, :fill))
end 600 300
```

In the next example, the sizes of the labels and shapes are determined by the degree of each vertex, supplied in a vector.

```@example graphsection
@drawsvg begin
background("grey10")
g = smallgraph(:karate)
sethue("slateblue")
drawgraph(g, layout=stress,
    vertexfillcolors = (v) -> if v ∈ (1, 3, 6) sethue("red") end,
    vertexlabels  = 1:nv(g),
    vertexlabelfontsizes=[Graphs.outdegree(g, v) for v in Graphs.vertices(g)],
    vertexshapesizes=[Graphs.outdegree(g, v) for v in Graphs.vertices(g)])
end 600 300
```

To show every other vertex, you could use something like this:

```@example graphsection
@drawsvg begin
background("grey10")
g = smallgraph(:truncatedcube)
sethue("slateblue")
drawgraph(g, layout=stress,
    vertexlabels  = ["1", ""],
    vertexshapesizes = [10, 0])
end 600 300
```

### `vertexshaperotations`

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

### `vertexstrokecolors` and `vertexfillcolors`

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
    vertexstrokecolors = [colorant"blue", colorant"red"])
end 600 300
```

This function should set the current Luxor color:

```@example graphsection
@drawsvg begin
background("grey10")
g = smallgraph(:icosahedral)
sethue("darkorange")
drawgraph(g, layout=spring,
    vertexshapes = :square,
    vertexshapesizes =  20,
    vertexfillcolors = (v) -> sethue(HSB(rescale(v, 1, nv(g), 0, 359), 1, 1)))
end 600 300
```

By now, I think you get the general idea. Try playing with the following keyword arguments:

- `vertexstrokeweights`

- `vertexlabeltextcolors`

- `vertexlabelfontsizes`

- `vertexlabelfontfaces`

- `vertexlabelrotations`

- `vertexlabeloffsetangles`

- `vertexlabeloffsetdistances`

Being able to specify the font faces for vertex labels is of vital importance, of course, but difficult to demonstrate when the documentation is built on machines in the cloud with unknown typographical resources.

```@example graphsection
@drawsvg begin
background("grey10")
g = smallgraph(:pappus)
sethue("slateblue")
drawgraph(g,
    vertexlabels = 1:nv(g),
    vertexshapes = 0,
    vertexlabelfontfaces = ["Times-Roman", "Courier", "Helvetica-Bold"],
    vertexlabelfontsizes = 30)
end 600 300
```

## Edge options

### `edgefunction`

As with `vertexfunction`, the `edgefunction` keyword argument allows you to do anything you like when the edges are drawn. Here, the calculated coordinates are extracted into a vector for later questionable purposes.

```@example graphsection
@drawsvg begin
background(0.1, 0.25, 0.15)
g = barbell_graph(22, 22)
A = Point[]
drawgraph(g, layout=stress,
    edgefunction = (from, to) -> begin
     push!(A, from),
     push!(A, to)
     end,
    vertexshapes = :none)
    setlinejoin("bevel")
    setline(0.25)
    @layer begin
        scale(1.2)
        for θ in range(0, 2π, length=6)
            @layer begin
                rotate(θ)
                sethue(HSB(rescale(θ, 0, 2π, 90, 210), .8, .8))
                poly(A, :stroke)
            end
            scale(0.8)
        end
    end
end 600 400
```

### Edge labels

Use `edgelabels`, `edgelabelcolors`, `edgelabelrotations`, etc. to control the appearance of the labels alongside edges. Here,  the edgelabels keyword argument accepts a function with five, yes five, arguments: edge number, source, destination, from point, and to point, and is able to annotate each edge with its length in this representation.

```@example graphsection
@drawsvg begin
background("grey20")
g = smallgraph(:dodecahedral)
g = complete_graph(5)
fontsize(20)
drawgraph(g, layout=stress,
    vertexshapes = :none,
    edgestrokecolors = colorant"orange",
    edgelabels = (k, src, dest, f, t) -> begin
        @layer begin
            sethue("white")
            θ = slope(f, t)
            text(string(round(distance(f, t), digits=1)),
                midpoint(f, t),
                angle=θ,
                halign=:center)
        end
    end)
end 600 500
```

`edgelabels` can also be a dictionary, where the keys are tuples, `(src, dst)`, and the values are the text labels.

```@example graphsection
g = complete_graph(5)
edgelabeldict = Dict()
n = nv(g)
for i in 1:n
    for j in 1:n
        edgelabeldict[(i, j)] = string(i, " - ", j)
    end
end

@drawsvg begin
    background("grey20")
    drawgraph(g, layout=stress,
        vertexshapes = :circle,
        vertexlabels = 1:n,
        edgestrokecolors = colorant"orange",
        edgelabelcolors = colorant"white",
        edgelabels = edgelabeldict)
end 600 400
```

### `edgelist`

This example draws the graph twice; once with all the edges, and once with only the edges in `edgelist`. Here, `edgelist` is the path from vertex 15 to vertex 17, drawn in a sickly translucent yellow.

```@example graphsection
@drawsvg begin
	background("grey10")
	g = smallgraph(:karate)
	sethue("slateblue")
	drawgraph(g, layout = stress,
		vertexlabels = 1:nv(g),
		vertexshapes = :circle,
		vertexshapesizes = 10,
		vertexlabelfontsizes = 10)
	astar = a_star(g, 15, 17)
	drawgraph(g,
		layout=stress,
	 	vertexshapes = :none,
		edgelist = astar,
		edgestrokecolors=RGBA(1, 1, 0, 0.35),
		edgestrokeweights=20)
end 600 600
```

### `edgelines`

### `edgecurvature`

### `edgestrokecolors`

TODO: bug in color setting code

```@example graphsection
g = barbell_graph(3, 3)
@drawsvg begin
    fontsize(30)
    background("grey20")
    sethue("white")
    drawgraph(g,
        layout=stress,
        edgelabels = 1:ne(g),
        edgecurvature = 10,
        edgestrokeweights = 2 * (1:ne(g)),
        edgelabelcolors = colorant"white",
        edgestrokecolors=(edgenumber, from, to) ->
            sethue(HSB(rescale(edgenumber, 1, ne(g), 0, 359), .8, .8))
          )
end 600 500
```

### `edgestrokeweights`

One possible use for varying the stroke weight of the edges might be to indicate
the weight of a weighted graph's edge:

```@example graphsection
wg = SimpleWeightedDiGraph(Graph(5, 10), 1.0)
for e in edges(wg)
    add_edge!(wg, src(e), dst(e), rand(1:20))
end    
@drawsvg begin
    sethue("gold")
    drawgraph(wg,
        edgecurvature=20,
        vertexlabels = 1:nv(wg),
        edgestrokeweights = [get_weight(wg, src(e), dst(e)) for e in edges(wg)]
    )
end
```

### `edgedashpatterns`
