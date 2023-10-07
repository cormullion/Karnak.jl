```@setup graphsection
using Karnak, Graphs, NetworkLayout, Colors, SimpleWeightedGraphs
```

# Graph theory

This section contains an introduction to basic graph theory
using the
[Graphs.jl](https://github.com/JuliaGraphs/Graphs.jl)
package, illustrated with figures made with Karnak.jl. You
don't need any prior knowledge of graphs, but you should be
familiar with the basics of programming in Julia.

!!! note

    All the figures in this manual are generated when the
    pages are built by Documenter.jl, and the code to draw
    them is included here. To run the examples, you'll need the packages 
    `Karnak`, `Graphs`, `NetworkLayout`, `Colors`, and possibly `SimpleWeightedGraphs`.

## Graphs, vertices, and edges

Graph theory is used for analysing networks and
the relationships between things in the network.

```@raw html
<details closed><summary>Code for this figure</summary>
```

This code generates the figure below.

```@example graphsection
using Karnak, Graphs, NetworkLayout, Colors, SimpleWeightedGraphs
d = @drawsvg begin
    background("grey10")
    sethue("yellow")
    fontsize(12)
    g = Graph(3, 3)
    add_vertex!(g)
    add_edge!(g, 3, 4)
    drawgraph(g,
        layout=spring,
        margin=50,
        edgecurvature=0.2,
        edgegaps=30,
        edgestrokeweights=2,
        vertexlabels = (v) -> "thing $(v)",
        vertexshapes = :circle,
        vertexfillcolors = [RGB(Karnak.Luxor.julia_red...), RGB(Karnak.Luxor.julia_purple...), RGB(Karnak.Luxor.julia_green...), RGB(Karnak.Luxor.julia_blue...)],
        vertexshapesizes = 25,
        vertexlabeltextcolors = colorant"white",
        edgelabels=(n, s, d, f, t) -> begin
            θ = slope(f, t)
            fontsize(12)
            translate(midpoint(f, t))
            rotate(θ)
            sethue("white")
            label("$s and $d", [:n, :n, :s, :n][n], O, offset=10)
            sethue("orange")
            label("edge $n", [:n, :n, :s, :n][n], O, offset=-15)
        end,
        )
end 600 350
nothing #hide
```

```@raw html
</details>
```

```@example graphsection
d # hide
```

A typical graph consists of:

- _vertices_, which represent the things or entities, and

- _edges_, which describe how two things or entities connect and relate to each other

Vertices are also called _nodes_ in the world of graph theory.

The Graphs.jl package provides many ways to create graphs.
We'll start off with this basic approach:

```julia
using Graphs
g = Graph()
```

The `Graph()` function creates a new empty graph and stores it in `g`.
(`SimpleGraph()` is an alternative to `Graph()`.)
Let's add a single vertex:

```julia
add_vertex!(g)
```

We can easily add a number of new vertices:

```julia
add_vertices!(g, 3)
```

The graph has four vertices now. We can refer to them
as `1`, `2`, `3`, and `4`.

We'll join some pairs of vertices with an
edge:

```julia
add_edge!(g, 1, 2)  # join vertex 1 with vertex 2
add_edge!(g, 1, 3)
add_edge!(g, 2, 3)
add_edge!(g, 1, 4)
```

In Graphs.jl, vertices are always numbered from 1 to `n`.

`g` is now a `{4, 4} undirected simple Int64 graph}`.

It's time to see some kind of visual representation of the
graph we've made.

```@example graphsection
using Karnak, Graphs

g = Graph()
add_vertices!(g, 4)
add_edge!(g, 1, 2)
add_edge!(g, 1, 3)
add_edge!(g, 2, 3)
add_edge!(g, 1, 4)

@drawsvg begin
    background("grey10")
    sethue("orange")
    drawgraph(g, vertexlabels = [1, 2, 3, 4])
end 600 300
```

This is just one of the many ways this graph can be represented visually. The locations of the vertices as drawn here are _not_ part of the graph's definition. The default styling uses the current Luxor color, with small circles marking the vertex positions. `drawgraph()` places the graphics for the graph on the current Luxor drawing.

!!! note

    SVG is used in this manual because it's a good format for
    line drawings, but you can also use Karnak.jl to create PDF or PNG. 
    See the [Luxor documentation](http://juliagraphics.github.io/Luxor.jl/stable/) for details. 
    PNG is a good choice if the graphics get very
    complex, since large SVGs can tax web browsers.

## Undirected and directed graphs

We'll meet two main types of graph, **undirected** and **directed**. In our undirected graph `g` above, vertex 1 and vertex 2 are _neighbors_, connected with an edge, but there's no way to specify or see a direction for that connection. For example, if the graph was modelling people making financial transactions, we couldn't tell whether the person at vertex 1 sent money to the person at vertex 2, or received money from them.

In Graphs.jl, we can create directed graphs with `DiGraph()` (also `SimpleDiGraph()`).

```@example graphsection
gd = DiGraph() 
add_vertices!(gd, 4) 
add_edge!(gd, 1, 2) 
add_edge!(gd, 1, 3) 
add_edge!(gd, 2, 3) 
add_edge!(gd, 1, 4) # vertex 1 to vertex 4 
add_edge!(gd, 4, 1) # vertex 4 to vertex 1 

@drawsvg begin
    background("grey10")
    sethue("thistle1")
    drawgraph(gd, vertexlabels = [1, 2, 3, 4], edgecurvature=5)
end 600 300
```

!!! note

    In this representation of our directed graph `gd`, we can see the direction of the edges joining the vertices. The `edgecurvature` keyword has been used to specify a small amount of curvature for each edge. Otherwise, with the default drawing settings, the two edges connecting vertices 1 and 4 would have been drawn overlapping, and difficult to distiguish at a glance. 

## Very simple graphs

Creating graphs by typing the connections manually is tedious, so we can use functions such as the `Graph/SimpleGraph` and `DiGraph/SimpleDiGraph` constructor functions:

```@example graphsection
g = Graph(10, 5) # 10 vertices, 5 edges

d1 = @drawsvg begin
    background("grey10")
    sethue("gold")
    drawgraph(g, vertexlabels = vertices(g))
end 400 300

gd = SimpleDiGraph(5, 3) # 5 vertices, 3, edges

d2 = @drawsvg begin
    background("grey10")
    setline(0.5)
    sethue("firebrick")
    drawgraph(gd, vertexlabels = vertices(g))
end 400 300

hcat(d1, d2)
```

Neither of these two graphs is a **connected** graph. In a connected graph, every vertex is connected to every other via some **path**, a sequence of edges.

We can define how many vertices and edges the graph should have. An undirected graph with 10 vertices can have between 0 to 45 (`binomial(10, 2)`) edges, a directed graph up to 90 edges.

## Well-known graphs

Graphs have been studied for a few centuries, so there are many familiar and well-known graphs and types of graph.

In a **complete graph**, every vertex is connected to every other vertex.

```@example graphsection
N = 10
g = complete_graph(N)
@drawsvg begin
   background("grey10")
   setline(0.5)
   sethue("pink")
   drawgraph(g, vertexlabels = vertices(g))
end 600 300
```

There's also a `complete_digraph()` function.

```@example graphsection
N = 7
g = complete_digraph(N)
@drawsvg begin
    background("grey10")
    setline(0.5)
    sethue("orange")
    drawgraph(g, vertexlabels = vertices(g), edgecurvature = 2)
end 600 300
```

In a **bi-partite graph**, every vertex belongs to one of
two groups. Each vertex in the first group is connected to
one or more vertices in the second group.

The next figure shows the **complete** version of a
bi-partite graph. Each vertex is connected to every other
vertex in the other group.

```@example graphsection
N = 10
g = complete_bipartite_graph(N, N)
H = 300
W = 550
@drawsvg begin
    background("grey10")
    pts = vcat(
        between.(O + (-W/2, H/2), O + (W/2, H/2), range(0, 1, length=N)),
        between.(O + (-W/2, -H/2), O + (W/2, -H/2), range(0, 1, length=N)))
    sethue("aquamarine")
    drawgraph(g, vertexlabels = 1:nv(g), layout = pts, edgestrokeweights=0.5)
end 600 400
```

Here, we calculated the coordinates of the vertices and passed the resulting `pts` to the `layout` keyword.

A **grid** graph doesn't need much explanation:

```@example graphsection
M = 4
N = 5
g = Graphs.grid([M, N])
@drawsvg begin
    background("grey10")
    setline(0.5)
    sethue("greenyellow")
    drawgraph(g, vertexlabels = 1:nv(g), layout=stress)
end 600 300
```

Star graphs (`star_graph(n)`) and wheel graphs (`wheel_graph(n)`) deliver what their names promise.

```@example graphsection
g = star_graph(12)
@drawsvg begin
    background("grey10")
    sethue("orange")
    drawgraph(g, vertexlabels=1:nv(g), layout=stress)
end 600 300
```

```@example graphsection
g = wheel_graph(12)
@drawsvg begin
    background("grey10")
    sethue("palegreen")
    drawgraph(g, vertexlabels=1:nv(g), layout=stress)
end 600 300
```

There are `star_digraph()` and `wheel_digraph()` DiGraph versions too.

### Even more well-known graphs

There are probably as many graphs as there are possible
games of chess. In both fields, the more commonly-seen
patterns have been studied extensively by enthusiasts for
years.

Many well-known graphs are provided by the `smallgraph()`
function. Supply one of the available symbols, such as
`:bull`, or `:house`.

```@raw html
<details closed><summary>Code for this figure</summary>
```

This code generates the figure below.

```@example smallgraphs
using Karnak, Graphs, NetworkLayout
smallgraphs = (
    (:bull, "bull"),
    (:chvatal, "chvatal"),
    (:cubical, "cubical"),
    (:desargues, "desargues"),
    (:diamond, "diamond"),
    (:dodecahedral, "dodecahedral"),
    (:frucht, "frucht"),
    (:heawood, "heawood"),
    (:house, "house"),
    (:housex, "housex"),
    (:icosahedral, "icosahedral"),
    (:karate, "karate"),
    (:krackhardtkite, "krackhardtkite"),
    (:moebiuskantor, "moebiusantor"),
    (:octahedral, "octahedral"),
    (:pappus, "pappus"),
    (:petersen, "petersen"),
    (:sedgewickmaze, "sedgewick"),
    (:tetrahedral, "tetrahedral"),
    (:truncatedcube, "truncatedcube"),
    (:truncatedtetrahedron, "truncatedtetrahedron"),
    (:truncatedtetrahedron_dir, "truncatedtetrahedron"),
    (:tutte, "tutte"))

colors = ["paleturquoise", "chartreuse", "thistle1", "pink",
"gold", "wheat", "olivedrab1", "palegreen", "turquoise1",
"lightgreen", "plum1", "plum", "violet", "hotpink"]

smallgraphs = @drawsvg begin
    background("grey10")
    sethue("orange")
    ng = length(smallgraphs)
    N = convert(Int, ceil(sqrt(ng)))
    tiles = Tiler(800, 800, N, N)
    setline(0.5)
    for (pos, n) in tiles
        @layer begin
            n > ng && break
            translate(pos)
            sethue(colors[mod1(n, end)])
            bbox = BoundingBox(box(O, tiles.tilewidth, tiles.tileheight))
            g = smallgraph(first(smallgraphs[n]))
            drawgraph(g, boundingbox = bbox, vertexshapesizes = 2, layout = stress)
            sethue("cyan")
            text(string(last(smallgraphs[n])), halign = :center, boxbottomcenter(bbox))
        end
    end
end 800 800
nothing # hide
```

```@raw html
</details>
```

```@example smallgraphs
smallgraphs # hide
```

It's easy to find out more about these well-known graphs
online, such as on the
[wikipedia](https://en.wikipedia.org/wiki/Gallery_of_named_graphs).
Some of the graphs in this figure would benefit from
individual ‘tuning’ of the various layout parameters.

Here's a larger view of the Petersen graph (named after
Danish mathematician Julius Petersen, who first described it in 1898).

```@example graphsection
@drawsvg begin
    background("grey10")
    pg = smallgraph(:petersen)
    sethue("orange")
    drawgraph(pg, vertexlabels = 1:nv(pg), layout = Shell(nlist=[6:10,]))
end 600 300
```

Here's a cubical graph:

```@example graphsection
@drawsvg begin
    background("grey10")
    g = smallgraph(:cubical)
    sethue("orange")
    drawgraph(g, layout = spring)
end 600 300
```

## Getting some information about the graph

There are lots of functions for obtaining information about a graph.

How many vertices?

```julia
julia> pg = smallgraph(:petersen)
julia> nv(pg)
10
```

How many edges?

```julia
julia> ne(pg)
15
```

Which vertices are connected with vertex 1? - ie what are the neighbors of a particular vertex?

```julia
julia> neighbors(pg, 1)
5-element Vector{Int64}:
 2
 5
 6
```

We can iterate over vertices and edges. To step through each vertex, use the `vertices` iterator function:

```julia
for e in vertices(pg)
    println(e)
end

1
2
3
4
5
6
7
8
9
10
```

Iterating over edges with the `edges` iterator function will give a value of
type `Edge`. The `src()` and and `dst()` functions applied to an edge argument
return the numbers of the source and destination vertices respectively.

```julia
for e in edges(pg)
    println(src(e), " => ", dst(e))
end

1 => 2
1 => 5
1 => 6
2 => 3
2 => 7
3 => 4
3 => 8
4 => 5
4 => 9
5 => 10
6 => 8
6 => 9
7 => 9
7 => 10
8 => 10
```

To add a vertex:

```julia
pg1 = smallgraph(:petersen)
add_vertex!(pg1) # returns true if successful
```

To add an edge:

```julia
add_edge!(pg1, 10, 11) # join 10 to 11
```

It's sometimes useful to be able to see these relationships between neighbors visually. This example looks for the neighbors of vertex 10 and draws them in thick red lines:

```@example graphsection
@drawsvg begin

background("grey10")
pg = smallgraph(:petersen)

vertexofinterest = 10

E = Int[]
for (n, e) in enumerate(edges(pg))
    if dst(e) == vertexofinterest || src(e) == vertexofinterest
        push!(E, n)
    end
end

edgewts = [dst(e) ∈ E ? 4 : 1 for e in edges(pg)]

drawgraph(pg,
    vertexlabels = 1:nv(pg),
    layout = Shell(nlist=[6:10,]),
    vertexfillcolors = (v) -> ((v == vertexofinterest) ||
    v ∈ neighbors(pg, vertexofinterest)) && colorant"rebeccapurple",
    vertexshapesizes = [v == vertexofinterest ? 20 : 10 for v in 1:nv(pg)],
    edgestrokecolors = (e, f, t, s, d) -> (e ∈ E) ? 
        colorant"red" : colorant"thistle1",
    edgestrokeweights = edgewts
    )
end 600 300
```

Other useful functions include `has_vertex(g, v)` and `has_edge(g, s, d)`.

### Degree

The **degree** of a vertex is the number of edges that meet
at that vertex. This is shown in the figure below both in the vertex
labels and also color-coded:

```@example graphsection
@drawsvg begin
background("grey10")
sethue("gold")
g = smallgraph(:krackhardtkite)

drawgraph(g, layout=spring,
    vertexfillcolors = (vtx) -> distinguishable_colors(nv(g), transform=tritanopic)[degree(g, vtx)],
    vertexshapesizes = 20,
    margin=40,
    vertexlabels = (vtx) -> string(degree(g, vtx)),
    vertexlabelfontsizes = 20,
    vertexlabeltextcolors = [colorant"black", colorant"white"]
    )
end 600 300
```

## Graphs as matrices

Graphs can be represented as matrices - some say that graph theory is really the study of a particular set of matrices... We'll meet the adjacency matrix and the incidence matrix (and there's an array called the adjacency list too).

### Adjacency matrix

A graph `G` with `n` vertices can be represented by a square matrix `A` with `n` rows and columns. The matrix consists of 1s and 0s. A value of 1 means that there's a connection between two vertices with those indices. For example, if vertex 5 is connected with vertex 4, then `A[5, 4]` contains 1. The `adjacency_matrix()` function displays the matrix for a graph:

```julia-repl
julia> adjacency_matrix(pg)
10×10 SparseArrays.SparseMatrixCSC{Int64, Int64} with 30 stored entries:
 ⋅  1  ⋅  ⋅  1  1  ⋅  ⋅  ⋅  ⋅
 1  ⋅  1  ⋅  ⋅  ⋅  1  ⋅  ⋅  ⋅
 ⋅  1  ⋅  1  ⋅  ⋅  ⋅  1  ⋅  ⋅
 ⋅  ⋅  1  ⋅  1  ⋅  ⋅  ⋅  1  ⋅
 1  ⋅  ⋅  1  ⋅  ⋅  ⋅  ⋅  ⋅  1
 1  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  1  1  ⋅
 ⋅  1  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  1  1
 ⋅  ⋅  1  ⋅  ⋅  1  ⋅  ⋅  ⋅  1
 ⋅  ⋅  ⋅  1  ⋅  1  1  ⋅  ⋅  ⋅
 ⋅  ⋅  ⋅  ⋅  1  ⋅  1  1  ⋅  ⋅
```

(This one:)

```@example graphsection
@drawsvg begin
background("grey10")
pg = smallgraph(:petersen)
sethue("orange")
drawgraph(pg, vertexlabels = 1:nv(pg), layout = Shell(nlist=[6:10,]))
end 600 400
```

Notice that this matrix, for a Petersen graph, is symmetrical about the top-left/bottom-right diagonal, because, in an undirected graph, a connection from vertex 4 to vertex 5 is also a connection from vertex 5 to 4. The vertical sum of each column (and the horizontal sum of each row) is the number of edges shared by that vertex,

We can provide an adjacency matrix to the graph construction functions to create a graph. For example, this matrix recreates the House graph (aka `smallgraph(:house)`) from its adjacency matrix:

```@example graphsection
m = [0 1 1 0 0;
     1 0 0 1 0;
     1 0 0 1 1;
     0 1 1 0 1;
     0 0 1 1 0]

@drawsvg begin
    background("grey10")
    hg = Graph(m)
    sethue("palegreen")
    drawgraph(hg, vertexlabels=1:nv(hg), layout=stress)
end 800 400
```

### Incidence matrix

We can also represent a graph `G` with a matrix `M` consisting of 1s, -1s, and 0s, where the rows are vertices and the columns are edges. `M` is called an **incidence matrix**.

```julia-repl
julia> incidence_matrix(pg)
10×15 SparseArrays.SparseMatrixCSC{Int64, Int64} with 30 stored entries:
 1  1  1  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅
 1  ⋅  ⋅  1  1  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅
 ⋅  ⋅  ⋅  1  ⋅  1  1  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅
 ⋅  ⋅  ⋅  ⋅  ⋅  1  ⋅  1  1  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅
 ⋅  1  ⋅  ⋅  ⋅  ⋅  ⋅  1  ⋅  1  ⋅  ⋅  ⋅  ⋅  ⋅
 ⋅  ⋅  1  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  1  1  ⋅  ⋅  ⋅
 ⋅  ⋅  ⋅  ⋅  1  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  1  1  ⋅
 ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  1  ⋅  ⋅  ⋅  1  ⋅  ⋅  ⋅  1
 ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  1  ⋅  ⋅  1  1  ⋅  ⋅
 ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  1  ⋅  ⋅  ⋅  1  1
```

The first column of this matrix is an edge between vertex 1 and vertex 2, whereas the first column of the adjacency matrix defines the vertices that are connected with vertex 1.

For a directed graph:

```julia
julia> dg = DiGraph(3, 3)

julia> incidence_matrix(dg)

3×3 SparseArrays.SparseMatrixCSC{Int64, Int64} with 6 stored entries:
 -1   1   1
  1  -1   ⋅
  ⋅   ⋅  -1
```

Here, negative values are used, so 1 and -1 are used to indicate directions. The first column,`-1 1 0`, specifies that the first edge goes **from** 2 to 1.

An incidence matrix is another useful way of quickly defining a graph. That's why we can pass an incidence matrix to the `Graph()` and `DiGraph()` functions to create new graphs.

For example, here's a familiar image:

```@example graphsection
g = [0 1 1;
     1 0 1;
     1 1 0]

@drawsvg begin
background("grey20")
drawgraph(Graph(g),
    layout = ngon(O + (0, 20), 80, 3, π/6, vertices=true),
    vertexshapes = :circle,
    vertexshapesizes = 40,
    edgestrokeweights = 15,
    edgestrokecolors = colorant"gold",
    vertexfillcolors = [colorant"#CB3C33",
        colorant"#389826", colorant"#9558B2"])
end 600 250
```

### Adjacency list

Another way of representing a graph is by using an array of arrays in the form of an **adjacency list**. This array has `n` elements to represent a graph with `n` vertices. The first element of the array is an array of those vertex numbers that are connected with vertex 1, and similarly for elements 2 to `n`.

For example, this adjacency list:

```julia
[
    [2, 5, 7],  # row 1: vertex 1 connects with 2, 5, and 7
    [1, 3, 9],
    [2, 4, 11],
    [3, 5, 13],
    [1, 4, 15],
    [7, 15, 20],
    [1, 6, 8],
    [7, 9, 16],
    [2, 8, 10],
    [9, 11, 17],
    [3, 10, 12],
    [11, 13, 18],
    [4, 12, 14],
    [13, 15, 19],
    [5, 6, 14],
    [8, 17, 20],
    [10, 16, 18],
    [12, 17, 19],
    [14, 18, 20],
    [6, 16, 19]
]
```

defines a graph with 20 vertices, such that vertex 1 has edges joining it to vertices 2, 5, and 7, and so on for each element of the whole array.

The `Graph()` function accepts an adjacency list, preceded by the number of edges.

```@example graphsection
g = Graph(30, [
    [2, 5, 7],
    [1, 3, 9],
    [2, 4, 11],
    [3, 5, 13],
    [1, 4, 15],
    [7, 15, 20],
    [1, 6, 8],
    [7, 9, 16],
    [2, 8, 10],
    [9, 11, 17],
    [3, 10, 12],
    [11, 13, 18],
    [4, 12, 14],
    [13, 15, 19],
    [5, 6, 14],
    [8, 17, 20],
    [10, 16, 18],
    [12, 17, 19],
    [14, 18, 20],
    [6, 16, 19]])

@drawsvg begin
    background("grey10")
    sethue("orange")
    drawgraph(g, layout=stress)
end 600 300
```

Graphs.jl uses adjacency lists internally. If we peek inside a graph and look at its fields, we'll see something like this, for a Directed Graph:

```
fieldnames(DiGraph)
(:ne, :fadjlist, :badjlist)
```

Here, `fadjlist` is a forward adjacency list which defines how each vertex connects **to** other vertices, and `badjlist` is a backward adjacency list which defines how each vertex receives connections **from** other vertices.

## Paths, cycles, routes, and traversals

Graphs help us answer questions about connectivity and relationships. For example, think of a railway network as a graph, with the stations as vertices, and the tracks as edges. We want to ask questions such as "Can we get from A to B by train?", which therefore becomes the question "Are there sufficient edges between vertices in the graph such that we can find a continuous path that joins them?".

Graphs.jl has many features for traversing graphs and finding paths. We can look at just a few of them here.

!!! note

    The study of graphs uses a lot of terminology, and many
    of the terms also have informal and familiar
    meanings. Usually the informal meanings are
    reasonably accurate and appropriate, but note that the
    words also have more precise definitions in the literature.

### Paths and cycles

A **path** is a sequence of edges between some start vertex and some end vertex, such that a continuous unbroken route is available.

A **cycle** is a path where the start and end vertices are the same - a closed path. Other vertices in the path occur just once. These are also called circuits in some sources.

The `cycle_basis()` function finds all the cycles in a graph (at least, it finds a **basis** of an undirected graph, which is a minimal collection of cycles that can be added to make all the cycles). The result is an array of arrays of vertex numbers.

```
julia> pg = smallgraph(:petersen)
julia> cycles = cycle_basis(pg)
6-element Vector{Vector{Int64}}:
 [1, 6, 8, 10, 5]
 [4, 9, 6, 8, 10, 5]
 [7, 9, 6, 8, 10]
 [4, 3, 8, 10, 5]
 [1, 2, 3, 8, 10, 5]
 [7, 2, 3, 8, 10]
```

```@example graphsection
@drawsvg begin
    background("grey10")
    sethue("magenta")
    pg = smallgraph(:petersen)

    cycles = cycle_basis(pg)
    table = Table(2, length(cycles) ÷ 2, 220, 160)

    for (n, cycle) in enumerate(cycles)
        cycleedges = [Edge(cycle[i], cycle[mod1(i + 1, end)]) for i in 1:length(cycle)]
        @layer begin
            translate(table[n])
            bb = BoundingBox(box(O, table.colwidths[1], table.rowheights[1]))
            sethue("grey60")
            drawgraph(pg,
                layout = stress,
                vertexshapes = :none,
                boundingbox = bb)
            sethue(HSB(rescale(n, 1, length(cycles) + 1, 0, 360), 0.8, 0.6))
            drawgraph(pg,
                layout = stress,
                boundingbox = bb,
                vertexshapes = (v) -> begin
                    v ∈ cycle && box(O, 12, 12, :fill)
                end,
                vertexshapesizes = 30,
                vertexlabels = (v) -> v ∈ cycle && string(v),
                edgestrokeweights = 5,
                edgelist = cycleedges,
            )
        end
    end
end 600 300
```

For digraphs, you can use `simplecycles()` to find every cycle.

This example shows every cycle of a complete digraph `{4, 12}`.

```@example graphsection

sdg = complete_digraph(4)

cycles = simplecycles(sdg)

@drawsvg begin
    background("grey10")
    sethue("orange")
    tiles = Tiler(600, 600, 4, 4)
    for (pos, n) in tiles
        cycle = cycles[n]
        cycle_path = [Edge(cycle[i], cycle[mod1(i + 1, end)]) for i in 1:length(cycle)]
        @layer begin
            translate(pos)
            tilebox = BoundingBox(box(O, tiles.tilewidth, tiles.tileheight))
            text(string(cycle), halign=:center, boxbottomcenter(tilebox))
            sethue(HSV(rand(0:360), 0.6, 0.9))
            drawgraph(sdg, layout=squaregrid,
                boundingbox = tilebox,
                edgelist = cycle_path,
                vertexlabels = (v) -> v ∈ cycle ? string(v) : "",
                vertexlabeltextcolors= colorant"white",
                vertexlabeloffsetdistances = 10,
                vertexlabeloffsetangles = [π, 0],
                vertexshapes = :none,
                edgelines = (edgenumber, edgesrc, edgedest, from, to) ->
                    begin
                        newpath()
                        arc2sagitta(from, to, 5, :stroke)
                    end)
        end
    end
end 600 600
```

There can be a lot of cycles in a graph. For example, a `complete_digraph(10)` has 1,110,073 cycles. Graphs.jl has tools for working with cycles efficiently.

### Visiting every vertex once

It's useful to know how to visit every vertex just once.

You can do this for DiGraphs if you can find a cycle that's the same length as the graph. However, there might be a lot of possibilities, since there could be many such cycles. This example uses `simplecycles()` to find all of them (there are over 400 for this graph), so only the first one with the right length is used.

```@example graphsection
@drawsvg begin
background("grey10")
g = complete_digraph(6)

tour = first(filter(cycle -> length(cycle) == nv(g), simplecycles(g)))

vertexlist_to_edgelist(vlist) = [Edge(p[1] => p[2]) for p in zip(vlist, circshift(vlist, -1))]

sethue("grey50")

drawgraph(g, layout = spring)

sethue("orange")
drawgraph(g, layout = spring,
    edgelist = vertexlist_to_edgelist(tour),
    edgestrokeweights = 10,
    )
end 800 400
```

## Trees

A tree is a connected graph with no cycles. A *rooted tree* is a tree graph in which one vertex has been designated as the root, or origin. Rooted tree graphs can be drawn using the Buchheim layout algorithm (named after the developer, Christoph Buchheim).

In the next example, we start with a *binary tree*, in which each vertex is connected to no more than two others - but we'll add one more vertex so that it's no longer a binary tree. 

```@raw html
<details closed><summary>Code for this figure</summary>
```

This code generates the figure below.

```@example graphsection
using Karnak, Graphs, NetworkLayout, Colors

d = @drawsvg begin
    background("grey10")
    sethue("purple")
    fontsize(12)

    bt = binary_tree(4)
    g = SimpleDiGraph(collect(edges(bt)))

    # add another vertex
    add_vertex!(g)
    add_edge!(g, 7, 16)

    drawgraph(g,
        layout=buchheim,
        margin=20,
        edgestrokeweights=2,
        edgegaps=12, 
        vertexlabels = 1:nv(g),
        vertexshapes=:circle,
        vertexfillcolors=[RGB(Karnak.Luxor.julia_red...), 
            RGB(Karnak.Luxor.julia_purple...), 
            RGB(Karnak.Luxor.julia_green...), 
            RGB(Karnak.Luxor.julia_blue...)],
        vertexshapesizes=12,
        vertexlabeltextcolors=colorant"white",
    )
end 600 350
nothing # hide
```

```@raw html
</details>
```

```@example graphsection
d # hide
```

## Shortest paths: the A* algorithm

One way to find the shortest path between two vertices is to use the `a_star()` function, and provide the graph, the start vertex, and the end vertex. The function returns a list of edges.

(The unusual name of this function is just a reference to the name of the algorithm, `A*`, first published in 1968 by Peter Hart, Nils Nilsson, and Bertram Raphael.)

The function finds the shortest path and returns an array of edges that define the path.

```@example graphsection
@drawsvg begin
background("grey10")
sethue("lemonchiffon")
g = binary_tree(5)
dirg = SimpleDiGraph(collect(edges(g)))
astar = a_star(dirg, 1, 21)
drawgraph(dirg, layout=buchheim,
    vertexlabels = 1:nv(g),
    vertexshapes = (vtx) -> box(O, 30, 20, :fill),
    vertexlabelfontsizes = 16,
    edgegaps=20,
    edgestrokeweights= 5,
    edgestrokecolors = (edgenumber, s, d, f, t) -> (s ∈ src.(astar) && d ∈ dst.(astar)) ?
        colorant"gold" : colorant"grey40",
    vertexfillcolors = (vtx) -> (vtx ∈ src.(astar) ||
        vtx ∈ dst.(astar)) && colorant"gold"
    )
end 800 400
```

One use for the A* algorithm is for finding paths through mazes. In the next example, a grid graph is subjected to some random vandalism, removing quite a few edges. Then a route through the maze was easily found by `a_star()`.

```@example graphsection
using Random
Random.seed!(6)

@drawsvg begin
background("grey10")

W, H = 20, 20
g = grid((W, H))

# vandalize the grid:
let
    c = 0
    while c < 200
        v = rand(1:W*H)
        rem_edge!(g, v, [v-1, v+1, v-W, v+H][rand(1:end)]) && (c += 1)
    end
end

# find a route
astar = a_star(g, 1, W * H)

sethue("grey60")
setlinecap("square")
drawgraph(g,
    vertexshapesizes = 0,
    layout=squaregrid,
    edgestrokeweights = 12)

sethue("red")
drawgraph(g,
    vertexshapes = :none,
    layout=squaregrid,
    edgelist=astar,
    edgegaps=0,
    edgestrokeweights=5)

end 600 600
```

## Shortest paths: Dijkstra's algorithm

A well-known algorithm for finding the shortest path between graph vertices is named for its creator, Edsger W. Dijkstra. He wrote about his inspiration:

> "I designed it in about twenty minutes. One morning I was
> shopping in Amsterdam with my young fiancée, and tired, we
> sat down on the café terrace to drink a cup of coffee and
> I was just thinking about whether I could do this, and I
> then designed the algorithm for the shortest path.

In Graphs.jl, this algorithm is available with `dijkstra_shortest_paths()`. After running this function, the result is an object with various pieces of information about all the shortest paths: this is a `DijkstraState` object, with fields `parents`, `dists`, `predecessors`, `pathcounts`, `closest_vertices`. There's an `enumerate_paths()` function which can extract the vertex information for a specific path from the DijkstraState object.

The following code animates the results of examining a grid graph using Dijkstra's algorithm. The shortest paths between the first vertex and every other vertex are drawn in a series of frames, one by one.

```julia
function frame(scene, framenumber, g)
    framenumber == 1 && return

    # run Dijkstra's algorithm

    ds = dijkstra_shortest_paths(g, 1, allpaths=true, trackvertices=true)

    # for which destination vertex?
    destv = framenumber

    # get the vertices on the path
    _, ep = enumerate_paths(ds, [1, destv])

    # convert to edges
    vlist = [Edge(p[1] => p[2]) for p in zip(ep, circshift(ep, -1))]

    # draw background graph
    background("grey10")
    sethue("grey40")
    drawgraph(g, layout=squaregrid, vertexshapes=:none)
    path = Point[]

    # draw shortest path
    drawgraph(g,
        layout=squaregrid,
        vertexlabelfontsizes=30,
        vertexshapes=:none,
        edgelist = vlist[1:end-1],
        edgefunction = (n, s, d, f, t) -> begin
            push!(path, f)
            push!(path, t)
        end)
    sethue("orange")
    setline(10)
    setlinejoin("bevel")
    poly(path, :stroke, close=false)
    sethue("red")
    circle.(path[[1, end]], 10, :fill)
end

function main()
    g = grid((20, 20))
    amovie = Movie(600, 600, "dijkstra")
    animate(amovie,
        Scene(amovie, (s, f) -> frame(s, f, g), 1:400),
        framerate=10)
end

main()
```

![animated dijkstra](assets/figures/dijkstra.gif)

## Weighted graphs

Up to now, our graphs have been like maps of train or metro networks, focusing on connections, rather than on, say, distances and journey times. Edges have been effectively always one unit long, and shortest path calculations can't take into account the true length of edges. But some systems modelled by graphs require this knowledge, which is where __weighted graphs__ are useful.

A weighted graph, which can be either undirected or directed, has numeric values assigned to each edge. This value is called the "weight" of an edge, and it's usually a positive integer, but can be anything.

The word "weight" is interpreted according to context and the nature of the system modelled by the graph. For example, a higher value for the weight of an edge could mean a longer journey time or more expensive fuel costs, for map-style graphs, but it could signify high attraction levels for a social network graph.

To use weighted graphs, we must install a separate package, SimpleWeightedGraphs.jl, and load it alongside Graphs.jl.

To create a new weighted graph:

```julia
using Graphs, SimpleWeightedGraphs

julia> g = SimpleWeightedGraph()
```

This creates a new, empty, weighted, undirected, graph. Or we can pass an existing graph to this function:

```julia
julia> wg = SimpleWeightedGraph(Graph(6, 15), 4.0)
```

To get the weights of the edge between two vertices, use `get_weight()`:

```julia
julia> get_weight(wg, 1, 2)
```

To change the weight of the edge between two vertices, use `add_edge()`:

```julia
julia> add_edge!(graph, from, to, weight)
```

You can provide a list of weights to the `edgelabels` keyword, which can accept a vector of edge weights.

```@example graphsection
g = SimpleWeightedGraph(3)
add_edge!(g, 1, 2, 12)
add_edge!(g, 1, 3, 13)
add_edge!(g, 2, 3, 23)

edgeweights = [g.weights[e.src, e.dst] for e in edges(g)]

@drawsvg begin
    background("black")
    sethue("magenta")
    fontsize(20)
    drawgraph(
        g,
        vertexshapesizes = 15,
        vertexlabels = 1:nv(g),
        edgelabelfontsizes = 40,
        edgelabels = edgeweights
    )
end
```

In this next example, we set the default weight of every edge to 4.0 when the graph is created, and changed just one edge's weight:

```@example graphsection
wg = SimpleWeightedGraph(Graph(6, 15), 4.0)
add_edge!(wg, 1, 2, 10_000_000)
@drawsvg begin
background("grey10")
sethue("gold")
drawgraph(wg, edgecurvature=10,
    vertexlabels = 1:nv(wg),
    edgelabels = (k, s, d, f, t) -> begin
        weight = get_weight(wg, s, d)
            if weight > 10
                sethue("white")
                box(midpoint(f, t), 30, 16, :fill)
                setcolor("magenta")
            else
                sethue(HSB(rescale(k, 1, ne(wg), 0, 360), 0.7, 0.6))
            end
            text(string(weight), midpoint(f,t), halign=:center, valign=:middle)
        end,
    edgegaps = 10
    )
end 600 300
```

A look at the graph's adjacency matrix shows that the weights have replaced the 1s:

```julia
julia> adjacency_matrix(wg)
6×6 SparseArrays.SparseMatrixCSC{Float64, Int64} with 30 stored entries:
  ⋅     1.0e7  4.0  4.0  4.0  4.0
 1.0e7   ⋅     4.0  4.0  4.0  4.0
 4.0    4.0     ⋅   4.0  4.0  4.0
 4.0    4.0    4.0   ⋅   4.0  4.0
 4.0    4.0    4.0  4.0   ⋅   4.0
 4.0    4.0    4.0  4.0  4.0   ⋅
```

For a directed graph, each edge can have two weights, one from `src` to `dst`, the other from `dst` to `src`.

## Spanning trees

A spanning tree is a set of edges that connect all the vertices of a graph together, without forming any cycles. There are various functions for finding spanning trees in Graphs.jl, including algorithms by Otakar Borůvka (`boruvka_mst()`), Joseph Kruskal (`kruskal_mst()`), and Robert Prim (`prim_mst()`). (Immortality can be attained by inventing a new graph-spanning algorithm.)

When used on a weighted graph, these functions find the minimum possible tree - the tree that scores the lowest when the weights of the edges are added up. (Some of these functions can also find the highest-scoring trees.)

```@example graphsection
@drawsvg begin
background("grey10")

g = SimpleWeightedGraph(smallgraph(:octahedral))

for e in edges(g)
    add_edge!(g, src(e), dst(e), rand(1:10))
end
add_edge!(g, 1, 4, 200)

sethue("grey50")
drawgraph(g, layout=spring, vertexshapesizes = 20, edgestrokeweights = 3,
    edgelabels = (k, src, dest, f, t) ->
    (sethue("cyan"); label(string(get_weight(g, src, dest)), :nw, midpoint(f, t))))

mst, weights = boruvka_mst(g)
sethue("gold")
drawgraph(g, vertexshapes = :none, layout=spring, edgelist = mst, edgestrokeweights = 15)

mst = kruskal_mst(g)
sethue("green")
drawgraph(g, layout=spring, vertexshapes = :none, edgelist = mst, edgestrokeweights = 10)

mst = prim_mst(g)
sethue("red")
drawgraph(g, layout=spring, vertexshapes = :none, edgelist = mst, edgestrokeweights = 3)

sethue("black")
drawgraph(g, layout=spring, vertexlabels = 1:nv(g), edgelines=:none)

end 600 400
```

Notice how all the spanning trees found have avoided the edge joining 1 and 4, which has a weight of 200.0.

Next, here's `boruka_mst()` looking for the **maximum** spanning tree; `Edge(1 => 4)` is always included every time the function runs.

```@example graphsection
using Karnak, Luxor, Graphs, NetworkLayout, Colors, SimpleWeightedGraphs

@drawsvg begin
    background("grey10")
    tiles = Tiler(600, 600, 2, 2)
    let
        g = SimpleWeightedGraph(smallgraph(:octahedral))
        for (pos, n) in tiles
            for e in edges(g)
                add_edge!(g, src(e), dst(e), rand(1:10))
            end
            add_edge!(g, 1, 4, 200)
            @layer begin
                translate(pos)
                bb = BoundingBox(box(O, tiles.tilewidth, tiles.tileheight))
                sethue("grey50")
                mst, weights = boruvka_mst(g, minimize=false)
                drawgraph(g,
                    boundingbox=bb,
                    layout=spring,
                    vertexshapesizes=10,
                    edgestrokeweights=3,
                    edgelabels=(k, src, dest, f, t) -> begin
                        sethue("orange")
                        label(string(get_weight(g, src, dest)), :nw, midpoint(f, t))
                        end,)

                sethue("gold")
                drawgraph(g,
                    boundingbox=bb,
                    layout=spring,
                    vertexshapes=:none,
                    edgelist=mst,
                    edgestrokeweights=5,)

                drawgraph(
                    g,
                    boundingbox=bb,
                    layout=spring,
                    vertexlabels=1:nv(g),
                    vertexshapes=:circle,
                    vertexshapesizes=7.5,
                    edgegaps=0,
                    edgelines=:none,)
            end
        end
    end
end 600 600
```

## Centrality

Centrality is a measure of the importance of vertices in a graph. It might describe the importance of "influencers" in social networks, or the importance of certain key positions in a transport network. Graphs.jl offers a number of ways to measure the centrality of vertices in a graph. Refer to the manual's "Centrality Measures" section for details.

Here's `betweenness_centrality()` applied to the Karate Club network. The vertices are sized and colored using the vector of values returned in `bc`.

```@example graphsection
@drawsvg begin
background("grey10")
g = smallgraph(:karate)
bc = betweenness_centrality(g)
sethue("gold")
drawgraph(g, layout = spring,
    vertexlabels = string.(round.(100bc, digits = 1)),
    vertexshapesizes = 15 .+ 30bc,
    vertexfillcolors = HSB.(rescale.(bc, 0, maximum(bc), 150, 360), 0.7, 0.8),
    )
end 800 600
```

## Graph coloring

A simple **graph coloring** is a way of coloring the vertices of a graph so that no two adjacent vertices are the same color. The `greedy_color()` function finds a random graph coloring for a graph. The total number of colors, and an array of integers representing the colors, are returned in fields `num_colors` and `colors` (as integers between 1 and `n`).

In the following example, only three colors are needed such that no edge connects two vertices with the same color. Colors.jl has a `distinguishable_colors()` function that finds `n` colors which look sufficiently different:

```@example graphsection
@drawsvg begin
    background("grey10")
    g = smallgraph(:octahedral)
    gc = greedy_color(g)
    dcolors = distinguishable_colors(gc.num_colors)
    sethue("gold")
    drawgraph(g, layout=stress,
        vertexfillcolors = dcolors[gc.colors],
        vertexshapesizes = 30)
end 800 400
```

Here `gc.num_colors` is 3. However, a complete graph might require many colors because there are so many connected vertices. For example, `gc.num_colors` is now 20:

```@example graphsection
@drawsvg begin
    background("grey10")
    g = complete_graph(20)
    gc = greedy_color(g)
    dcolors = distinguishable_colors(gc.num_colors)
    sethue("grey50")
    drawgraph(g, layout=stress,
        vertexfillcolors = dcolors[gc.colors],
        vertexshapesizes = 20)
end 600 300
```
