```@setup graphsection
using Karnak, Luxor, Graphs, NetworkLayout, Colors, SimpleWeightedGraphs
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
    vertexfillcolors = (v) -> v ∈ (1, 3, 6) ? colorant"red" : colorant"grey40",
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
background("grey10")
N = 12; H = 250; W = 550
g = complete_bipartite_graph(N, N)
pts = vcat(
    between.(O + (-W/2, -H/2),  O + (-W/2, H/2),  range(0, 1, length=N)), # left set
    between.(O + (W/2, H/2),   O + (W/2, -H/2), range(0, 1, length=N)))   # right set
circle.(pts, 1, :fill)
drawgraph(g, vertexlabels = 1:nv(g), layout = pts,
    edgestrokeweights = 0.5,
    edgestrokecolors = (n, f, t, s, d) -> HSB(rescale(n, 1, ne(g), 0, 360), 0.6, 0.9))
end 600 300
```

## The `vertexfunction` and `edgefunction` arguments

The two keyword arguments `vertexfunction` and `edgefunction` allow you to pass control over the drawing process completely to two functions, which can be anonymous functions.

```
vertexfunction = my_vertexfunction(vertex, coordinates)
edgefunction = my_edgefunction(edgenumber, from, to, edgesrc, edgedest)
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

You can use a function with `vertexlabels` to display a vertex; it should return a string to display. Labelling all of them isn't always necessary.

```@example graphsection
@drawsvg begin
background("grey10")
g = smallgraph(:octahedral)
sethue("purple")
drawgraph(g, layout=stress,
    vertexlabels = (v) -> v ∈ (1, 4, 6) && string(v),
    vertexshapesizes = 15,
    vertexlabelfontsizes = 20,
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
drawgraph(g, layout=shell, vertexshapes = [:square, :circle])
end 600 300
```

Yes, it's a limited choice. But no worries, because you can pass a function to `vertexshapes` to draw any shape you like. The single argument is the vertex number; graphics will be centered at the vertex location, ie Luxor's current origin.

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
    vertexfillcolors = (v) -> v ∈ (1, 3, 6) && colorant"red",
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

One more example with `vertexshapes`.

```@example graphsection
function whiten(col::Color, f=0.5)
    hsl = convert(HSL, col)
    h, s, l = hsl.h, hsl.s, hsl.l
    return convert(RGB, HSL(h, s, f))
end

function drawball(pos, ballradius, col::Color;
    	fromlum=0.2,
    	tolum=1.0)
    gsave()
    translate(pos)
    for i in ballradius:-0.25:1
        sethue(whiten(col, rescale(i, ballradius, 0.5, fromlum, tolum)))
        offset = rescale(i, ballradius, 0.5, 0, -ballradius/2)
        circle(O + (offset, offset), i, :fill)
    end
    grestore()
end

@drawsvg begin
background("grey10")
g = clique_graph(5, 6)
sethue("yellow")
setline(0.2)
drawgraph(g,
    layout = stress,
    vertexshapes = (v) -> drawball(O, 25, RGB([Luxor.julia_red,Luxor.julia_purple, Luxor.julia_green][rand(1:end)]...))
)
end 600 600
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

The function should return a Colorant for a vertex:

```@example graphsection
@drawsvg begin
background("grey10")
g = smallgraph(:icosahedral)
sethue("darkorange")
drawgraph(g, layout=spring,
    vertexshapes = :circle,
    vertexshapesizes =  20,
    vertexstrokeweights = 5,
    vertexstrokecolors = (v) -> HSB(rescale(v, 1, nv(g), 360, 0), 1, 1),
    vertexfillcolors = (v)   -> HSB(rescale(v, 1, nv(g), 0, 359), 1, 1),
    )
end 600 300
```
or an array:

```@example graphsection
@drawsvg begin
background("grey10")
sethue("orange")
g = grid((15, 15))
drawgraph(g,
    layout = squaregrid,
    vertexshapesizes = 15,
    vertexfillcolors = [RGB([Luxor.julia_red, Luxor.julia_green,
        Luxor.julia_purple][rand(1:end)]...) for i in 1:nv(g)])
end 600 600
```

Try playing with the following keyword arguments:

- `vertexstrokeweights`

- `vertexlabeltextcolors`

- `vertexlabelfontsizes`

- `vertexlabelfontfaces`

- `vertexlabelrotations`

- `vertexlabeloffsetangles`

- `vertexlabeloffsetdistances`

Being able to specify the font faces for vertex labels is of vital importance ... but it's difficult to demonstrate when the documentation is built on machines in the cloud with unknown typographical resources. But anyway:

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

As with `vertexfunction`, the `edgefunction` keyword argument allows you to do anything you like when the edges are drawn, and overrides all other keyword arguments. Here, the calculated coordinates of the graph and a path between two vertices are extracted into vectors for later treatment.

```@example graphsection
@drawsvg begin
background("black")
sethue("white")
g = clique_graph(16, 4)

A = Point[]
B = Point[]

drawgraph(g, layout=stress,
    edgefunction = (edgenumber, from, to, edgesrc, edgedest) -> begin
        push!(A, from),
        push!(A, to)
        end,
    vertexshapes = :none,
    )

route = a_star(g, 6, 29)

drawgraph(g, layout=stress,
    edgelist = route,
    vertexshapes = :none,
    edgefunction = (edgenumber, from, to, edgesrc, edgedest) -> begin
        push!(B, from),
        push!(B, to)
        end)

# Luxor takes over:
setlinejoin("bevel")
setline(0.25)

sethue("grey60")
@layer begin
    poly(A, :stroke)
end

sethue("gold")
setline(4)
@layer begin
    poly(B, :stroke)
end
circle.(B[[begin, end]], 5, :fill)
end 600 400
```

!!! note

    This keyword overrides the other `edge-` keywords.

### Edge labels

Use `edgelabels`, `edgelabelcolors`, `edgelabelrotations`, etc. to control the appearance of the labels alongside edges. Here, the edgelabels keyword argument accepts a function with five, yes five, arguments: edge number, source, destination, from point, and to point, and is able to annotate each edge with its length in this representation:

```@example graphsection
@drawsvg begin
background("grey10")
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
        edgelabeldict[(i, j)] = "($i, $j)"
    end
end

@drawsvg begin
    background("grey10")
    drawgraph(g, layout=stress,
        vertexshapes = :circle,
        vertexlabels = 1:n,
        edgestrokecolors = colorant"orange",
        edgelabelcolors = colorant"white",
        edgelabels = edgelabeldict)
end 600 350
```

The more code you're prepared to write, the more elaborate your labels can be:

```@example graphsection
sources      = [1,2,1]
destinations = [2,3,3]
weights      = [0.5, 0.8, 2.0]
g = SimpleWeightedGraph(sources, destinations, weights)
@drawsvg begin
background("grey10")
sethue("gold")
drawgraph(g,
    vertexlabels = 1:nv(g),
    vertexshapesizes = 20,
    vertexlabelfontsizes = 30,
    edgecurvature = 10,
    edgegaps = 25,
    edgelabels = (edgenumber, edgesrc, edgedest, from, to) -> begin
        @layer begin
            sethue("black")
            box(midpoint(from, to), 50, 30, :fill)
        end
        box(midpoint(from, to), 50, 30, :stroke)
        fontsize(16)
        text(string(get_weight(g, edgesrc, edgedest)),
            midpoint(from, to),
            halign=:center,
            valign=:middle)
    end)
end 600 300
```

### `edgelist`

This example draws the graph more than once; once with all the edges, and once with only the edges in `edgelist`, where `edgelist` is the path from vertex 15 to vertex 17, drawn in a pale translucent yellow. The path is marked with X marks the spot cyan-colored shapes.

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
    edgestrokecolors=RGBA(1, 1, 0, 0.5),
    edgestrokeweights=10)
    drawgraph(g,
    layout=stress,
    edgelines=0,
    vertexshapes = (v) -> v ∈ src.(astar) && polycross(O, 20, 4, 0.5, π/4, :fill),
     	vertexfillcolors = (v) -> v ∈ src.(astar) && colorant"cyan"
    )
end 600 600
```

### `edgecurvature` and `edgecaps`

`edgecurvature` determines the curvature of the edges, and `edgegaps` sets the distance between the tip of the arrowhead and the vertex position.

```@example graphsection
g = grid((3, 3))

# add some self-loops
for e in edges(g)
    add_edge!(g, src(e), src(e))
    add_edge!(g, dst(e), dst(e))
end

@drawsvg begin
    background("grey10")
    sethue("white")
    for c in 1:10
        drawgraph(g,
            margin=70,
            vertexshapes = :none,
            edgegaps = 5c,
            edgecurvature = 5c,
            edgestrokecolors = HSB(36c, .8, .8),
            edgestrokeweights = 1,
            layout=squaregrid)
    end
end 600 500
```

### `edgestrokecolors` and `edgestrokeweights`

```@example graphsection
g = barbell_graph(3, 3)
@drawsvg begin
    background("grey10")
    fontsize(30)
    sethue("white")
    drawgraph(g,
        layout=stress,
        edgelabels = 1:ne(g),
        edgecurvature = 10,
        edgestrokeweights = 2 * (1:ne(g)),
        edgelabelcolors = colorant"white",
        edgestrokecolors= (n, from, to, edgesrc, edgedest) -> HSB(rescale(n, 1, ne(g), 0, 359), .8, .8))
end 600 500
```

### `edgedashpatterns`

Line dashes work the same as in Luxor.jl, numbers in an array. If you want to alternate between dash patterns, supply an array of patterns.

```@example graphsection
g = grid((5, 5))
@drawsvg begin
    background("grey10")
    sethue("white")
    drawgraph(g,
        layout=squaregrid,
        edgestrokeweights = 5,
        edgelabels = (edgenumber, edgesrc, edgedest, from::Point, to::Point) ->
            begin
                labeltext = ["a", "b", "c"][mod1(edgenumber, end)]
                label(labeltext, :se, midpoint(from, to), offset=5)
            end,
        edgedashpatterns = [[20, 10, 1, 10], [20, 10], [0.5, 10]],
        edgelabelfontsizes = 20,
        vertexshapesizes = 2,
        edgestrokecolors=(edgenumber, from, to, src, dst) ->
            HSB(rescale(edgenumber, 1, ne(g), 0, 359), .8, .8)
          )
end 600 400
```
