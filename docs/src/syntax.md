```@setup graphsection
using Karnak, Luxor, Graphs, NetworkLayout, Colors, SimpleWeightedGraphs
```

# Syntax

## Overview

Karnak's function for drawing graphs is `drawgraph()`. This
takes a single argument, a `Graph`, and tries to place
representative graphics on the current Luxor drawing.

The default display for graphs is:

- current Luxor origin, scale and rotation

- current Luxor color for edges

- circles for all vertex shapes

- no vertex labels

- all edges drawn

```@example graphsection
@drawsvg begin
    background("grey10")
    sethue("darkcyan")
    g = complete_graph(10)
    drawgraph(g)
end 600 300
```

To control the appearance of the graph, you supply values to
the various keyword arguments. Apart from the general
keywords `BoundingBox`, `layout`, and `margin`, the keywords can
be grouped into two categories:

![two groups of keyword](assets/figures/drawgraphkeywords.svg)

Most of these keyword arguments accept
vectors, ranges, and scalar values, and some accept
functions as well.

Here's a contrived (and consequently hideously ugly)
example of the type of syntax available:

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

Here, the **outdegree** for each vertex (the number of edges
leaving it) is used to control the size of the vertices and
the font sizes too. `vertexshapes` flip-flops between
squares and circles for each vertex shape, but the size of
the shape is determined by a `vertexshapesizes` function,
which receives a Vector of sizes, the outdegree values for
each vertex. The font sizes of the labels are also set this
way. A `vertexfillcolors` function lets you determine the
shape's fill color for specific vertices, whereas the stroke
color is always orange, with stroke weights gradually
increasing. The colors of the labels are set by the
`Colors.distinguishable_colors()` function passed to
`vertexlabeltextcolors`. And all the labels are rotated, for
no particularly good reason.

Usually, if a vector runs out before the vertices and edges
have been drawn, some `mod1` magic means the values repeat
from the beginning again.

Use `drawgraph()` more than once, if needed, to build up the
graph in layers. Remember to use the same layout algorithm.

## The BoundingBox

The graphics for the graph are placed to fit inside the
current BoundingBox (by default, the drawing), after
allowing for the margin (the default is 30). Pass a
different BoundingBox to the `boundingbox` keyword argument
to control the graph layout's size.

## Layout algorithms

The only clever part of this package is provided by
[NetworkLayout.jl](https://juliagraphs.org/NetworkLayout.jl/)),
which is where you should look for information about the
various algorithms that determine where vertices are
positioned.

You can choose a layout algorithm, or supply the vertex positions yourself.

The main layout algorithms available are:

- shell

- spring

- stress

- squaregrid

Here are some formulations which work as keywords in `drawgraph()`:

```julia
layout = squaregrid

layout = shell

layout = stress

layout = spectral

layout = (g) -> spectral(adjacency_matrix(g), dim=2)

layout = shell ∘ adjacency_matrix

layout = (g) -> sfdp(g, Ptype=Float64, dim=2, tol=0.05, C=0.4, K=2)

layout = Shell(nlist=[6:10,])

layout = Stress(iterations = 100, weights = M) # M is matrix of weights

layout = Spring(iterations = 200, initialtemp = 2.5)
```

Alternatively, you can pass a vector of points to the
`layout` keyword argument. Vertices will be placed on these
points (vertex 1 on point 1, etc...), rather than at points
suggested by the NetworkLayout algorithms. For example, in
this next drawing, the two sets of points for a bipartite
graph are generated beforehand.

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

The calculated positions are returned by the `drawgraph()` function.

Some of the layout algorithms allow you to poss _initial_ positions that are used by the algorithms as starting points. These can be supplied as xy pairs, rather than Luxor Points (which NetworkLayout won't accept).

Here's a figure showing how the Stress algorithm refines the vertex positions on each iteration, after starting at each "grid location".

```@example graphsection
G = smallgraph(:petersen)

@drawsvg begin
    background("black")
    initialpositions = [(pt.x, pt.y) for (pt, n) in Tiler(800, 800, 3, 3)]

    sethue("grey80")
    circle.(Point.(initialpositions), 6, :stroke)

    for i in 1:60
        drawgraph(G,
            layout = Stress(initialpos = initialpositions, iterations = i),
            vertexshapes = (v) -> (
                    setcolor(HSVA(rescale(v, 1, nv(G), 0, 360), 0.6, 0.8, rescale(i, 1, 6, 0.5, 1)));
                    circle(O, rescale(i, 1, 60, 1, 6), :fill)
                    ),
            edgestrokecolors = colorant"white",
            edgestrokeweights = 0)
    end

    drawgraph(G,
        layout = Stress(initialpos = initialpositions, iterations = 60),
        vertexshapes = (v) -> (
            setcolor(HSVA(rescale(v, 1, nv(G), 0, 360), 0.6, 0.8, 1)); circle(O, 10, :fill)
        ))
end
```

## The `vertexfunction` and `edgefunction` arguments

The two keyword arguments `vertexfunction` and `edgefunction` allow you to pass control over the drawing process completely to these two functions, ignoring all the other keywords.

```
vertexfunction = my_vertexfunction(vertex, coordinates)
edgefunction = my_edgefunction(edgenumber, edgesrc, edgedest, from::Point, to::Point)
```

These allow you to place graphics at `coordinates[vertex]`, and to draw edges from `from` to `to`, using any available tools for drawing.

In the following picture, the vertex positions were passed to a function that placed clipped PNG images on the drawing (using `Luxor.readpng()` and `Luxor.placeimage()`), and the edges were drawn using sine curves. Refer to the Luxor documentation for more about putting colored things on drawings.

![image vertices](assets/figures/karnakmap.png)

It's also possible, for example, to draw a graph at a vertex point (ie recursive graphh drawing) if you use `vertexfunction`.

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

### `vertexlabels`

Use `vertexlabels` to choose the text to associate with each vertex. Supply a range, array of strings or numbers, a single string, or a function.

This example draws all vertices, and numbers them from 1 to 6.

!!! note

    In Graphs.jl, vertices are numbered from 1 to `n`. If you remove a vertex, vertices are effectively re-numbered.

```@example graphsection
@drawsvg begin
    background("grey10")
    g = smallgraph(:octahedral)
    sethue("gold")
    drawgraph(g, layout=stress,
        vertexlabels = 1:nv(g),
        vertexshapesizes = 10)
end 600 300
```

A function can be passed to `vertexlabels` to display a
vertex; it should accept a single numerical argument, the
vertex number, and return a string to display. Labelling all
of them isn't always necessary.

```@example graphsection
@drawsvg begin
background("grey10")
g = smallgraph(:octahedral)
sethue("skyblue")
drawgraph(g, layout=stress,
    vertexlabels = (v) -> v ∈ (1, 4, 6) && string(v, "/6"),
    vertexshapesizes = 15,
    vertexlabelfontsizes = 20,
    )
end 600 300
```

### `vertexshapes` and `vertexshapesizes`

The default shape for a vertex is a filled circle.

Options for `vertexshapes` are `:circle` and `:square`. With just two in a vector, they will be used alternately.

```@example graphsection
@drawsvg begin
background("grey10")
g = smallgraph(:moebiuskantor)
sethue("gold")
drawgraph(g, layout=shell, vertexshapes = [:square, :circle])
end 600 300
```

`vertexshapesizes` can set the sizes for the vertex shapes.

```@example graphsection
@drawsvg begin
background("grey10")
g = smallgraph(:moebiuskantor)
sethue("gold")
drawgraph(g, layout=shell,
    vertexshapes = [:square, :circle],
    vertexshapesizes = [15, 5],
    )
end 600 300
```

`vertexshaperotations` can set the rotations.

```@example graphsection
@drawsvg begin
background("grey10")
g = smallgraph(:moebiuskantor)
sethue("gold")
drawgraph(g, layout=shell,
    vertexshapes = :square,
    vertexshapesizes = [10, 20, 5],
    vertexshaperotations = [π/2, π/3],
    )
end 600 300
```

To show every other vertex, you could use something like this:

```@example graphsection
@drawsvg begin
background("grey10")
g = smallgraph(:truncatedcube)
sethue("darkturquoise")
drawgraph(g, layout=stress,
    vertexlabels = ["1", ""],
    vertexshapesizes = [10, 0])
end 600 300
```

When circles and squares don't cut it, supply a function to `vertexshapes`. The single argument is the vertex number; any graphics you draw will be centered at the vertex location, Luxor's current origin, `Point(0, 0)`.

```@example graphsection
@drawsvg begin
background("grey10")
g = smallgraph(:moebiuskantor)
sethue("hotpink")
drawgraph(g, layout=shell,
    vertexshapes = (v) -> star(O, 15, v+2, 0.5, 0, :fill))
end 600 300
```

Here, the vertex number is shown by the number of points on each star.

In the next example, the sizes of the labels and shapes are determined by the degree of each vertex, supplied in a vector.

```@example graphsection
@drawsvg begin
background("grey10")
g = smallgraph(:karate)
sethue("slateblue")
drawgraph(g, layout=stress,
    vertexlabels = 1:nv(g),
    vertexlabelfontsizes = [Graphs.outdegree(g, v) for v in Graphs.vertices(g)],
    vertexshapesizes = [Graphs.outdegree(g, v) for v in Graphs.vertices(g)],
    vertexfillcolors = (v) -> v ∈ (1, 3, 6) && colorant"red",
    )
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

or an array of colors:

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

The following keyword arguments operate in a similar way:

- `vertexstrokeweights` : Array | Range | :none

- `vertexlabeltextcolors` : Array | Range | colorant

- `vertexlabelfontsizes` : Array | Range | number

- `vertexlabelfontfaces` : Array  | string

- `vertexlabelrotations` : Array | Range | number

- `vertexlabeloffsetangles` : Array | Range | number

- `vertexlabeloffsetdistances` : Array | Range | number

It's possible to specify the font faces for vertex labels, but it's difficult to demonstrate when the documentation is built on machines in the cloud with unknown typographical resources. But anyway:

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

As with `vertexfunction`, the `edgefunction` keyword argument allows you to do anything you like when the edges are drawn, and overrides all other `edge-` keyword arguments. Here, the calculated coordinates of the graph and a path between two vertices aren't drawn at first, just extracted into vectors for further processing.

```@example graphsection
@drawsvg begin
background("black")
sethue("white")
g = clique_graph(16, 4)

A = Point[]
B = Point[]

drawgraph(g, layout=stress,
    edgefunction = (edgenumber, edgesrc, edgedest, from, to) -> begin
        push!(A, from),
        push!(A, to)
        end,
    vertexshapes = :none,
    )

route = a_star(g, 6, 29)

drawgraph(g, layout=stress,
    edgelist = route,
    vertexshapes = :none,
    edgefunction = (edgenumber, edgesrc, edgedest, from, to) -> begin
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

### `edgelist` and `edgelines`

A `Graphs.EdgeIterator` supplied to `edgelist` makes only the specified edges available for drawing. Otherwise, control which edges are to be drawn by supplying numbers (or a function) to `edgelines`.

```@example graphsection
@drawsvg begin
background("grey10")
sethue("orange")
g = grid((15, 15))
drawgraph(g,
    layout = stress,
    vertexshapes = :none,
    edgelines = rand(1:ne(g), 30)
)
end 600 300
```

`edgelist` is useful for drawing paths - a sequence of edges. For example, if you use `a_star()` to find the shortest path between two vertices, you can draw the edges with this keyword. It's useful to draw the graph twice, once with all edges, once with selected edges.

```@example graphsection
@drawsvg begin
background("grey10")
g = grid((15, 15))

astar = a_star(g, 1, nv(g))

sethue("orange")
drawgraph(g,
    layout = stress,
    vertexshapes = :none)

sethue("cyan")
drawgraph(g,
    layout = stress,
    vertexshapes = :none,
    edgestrokeweights = 5,
    edgelist = astar)
end 600 300
```

For more interesting arrows for edges, Luxor's arrows are available:

```@example graphsection
@drawsvg begin
background("grey10")
g = star_graph(12)
fontsize(20)
sethue("slateblue")
drawgraph(g,
    layout=spring,
    vertexshapes = 0,
    vertexlabels = 1:nv(g),
    vertexlabelfontsizes = 12,
    edgestrokecolors = distinguishable_colors(ne(g)),
    edgelines = (k, s, d, f, t) ->
        arrow(f, between(f, t, .95), [20, -45],
            linewidth = 5,
            arrowheadlength = 15,
            arrowheadangle = π/7,
            decorate = () -> begin
                    sethue("purple")
                    circle(O, 15, :fill)
                    sethue("white")
                    text(string(k), angle = -getrotation(), halign = :center, valign=:middle)
                end,
            decoration = .7))
end 600 400
```

### Edge labels

Use `edgelabels`, `edgelabelcolors`, `edgelabelrotations`, etc. to control the appearance of the labels alongside edges.

```@example graphsection
@drawsvg begin
background("grey10")
g = smallgraph(:dodecahedral)
g = complete_graph(5)
sethue("orange")
fontsize(20)
drawgraph(g, layout=stress,
    vertexshapes = :none,
    vertexlabels = "vertex",
    vertexlabeltextcolors = colorant"cyan",
    edgelabels = ["edge"],
    edgestrokecolors = colorant"orange",
    edgelabelcolors = colorant"pink",
    )
end 600 500
```

`edgelabels` can also be a dictionary, where the keys are tuples: `(src, dst)`, and the values are the text labels.

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

The `edgelabels` keyword argument can also accept a function with five arguments: `edgenumber`, `source`, `destination`, `from` and `to`. In this example, the graphical distances between the two vertex positions provide the annotations for each edge.

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

This example draws the graph more than once; once with all the edges, once with only the edges in `edgelist`, where `edgelist` is the path from vertex 15 to vertex 17, drawn in a pale translucent yellow, and once to draw the vertices on the path "X marks the spot" cyan-colored crosses.

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
            edgegaps = 3c,
            edgecurvature = 3c,
            edgestrokecolors = HSB(36c, .8, .8),
            edgestrokeweights = 0.5,
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

Line dashes work the same as in Luxor.jl, ie they're numbers in an array, with line length following by space length. If you want to alternate between dash patterns, supply an array of pattern arrays.

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
