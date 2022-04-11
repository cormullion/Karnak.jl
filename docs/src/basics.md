```@setup graphsection
using Karnak, Luxor, Graphs, NetworkLayout, Colors, SimpleWeightedGraphs
```

# Tutorial

This section contains an introduction to basic graph theory
using the Graphs.jl package. You don't need any prior
knowledge of graphs, but you should be familiar with the basics
of Julia programming.

## Graphs, vertices, and edges

Graph theory is used for analysing networks and
relationships between things. A typical graph consists of:

- vertices, which represent the things or entities

- edges, which describe how these things or entities connect and relate to each other

The Graphs.jl package provides many ways to create graphs.
We'll start off with this basic approach:

```julia
using Graphs
g = Graph()
```

The `Graph()` function creates a new empty graph and stores it in `g`.
(You can use `SimpleGraph()` as well as `Graph()`.)
Let's add a single vertex:

```julia
add_vertex!(g)
```

We can easily add a number of new vertices:

```julia
add_vertices!(g, 3)
```

Now we'll join pairs of vertices with an edge. The four
vertices we've made can be referred to with `1`, `2`, `3`,
and `4`:

```julia
add_edge!(g, 1, 2)  # join vertex 1 with vertex 2
add_edge!(g, 1, 3)
add_edge!(g, 2, 3)
add_edge!(g, 1, 4)
```

`g` is now a `{{4, 1} undirected simple Int64 graph}`. It's
time to see some kind of visual representation of the graph
we've made.

```@example graphsection
g = Graph()
add_vertices!(g, 4)
add_edge!(g, 1, 2)
add_edge!(g, 1, 3)
add_edge!(g, 2, 3)
add_edge!(g, 1, 4)

# using Karnak, Luxor, Graphs, NetworkLayout, Colors, SimpleWeightedGraphs

@drawsvg begin
 background("grey10")
 sethue("orange")
 drawgraph(g, vertexlabels = [1, 2, 3, 4])
end 600 300
```

This is one of the many ways this graph can be represented visually. The coordinates of the vertices when drawn here are _not_ part of the graph's definition, and have been assigned randomly by the layout algorithm.

## Undirected and directed graphs

We'll meet two main types of graph, **undirected** and **directed**. In our undirected graph `g` above, vertex 1 and vertex 2 are neighbors, connected by an edge, but there's no way to specify or see a direction for that connection. For example, if the graph was modelling people making financial transactions, we couldn't tell whether the person at vertex 1 sent money to the person at vertex 2, or received money from them.

In Graphs.jl we can create directed graphs with `DiGraph()` (also `SimpleDiGraph()`).

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
sethue("slateblue")
drawgraph(gd, vertexlabels = [1, 2, 3, 4])
end 600 300
```

In this representation of our directed graph `gd`, we can now see the direction of the edges joining vertices. Notice how vertices 1 and 4 are doubly connected, because there's one edge for each direction.

Neither of these graphs is **connected**. In a connected graph, every vertex is connected to every other via some path, a sequence of edges.

## Very simple graphs

Creating graphs by typing the connections manually is tedious, so you might prefer to use the `Graph/SimpleGraph` and `DiGraph/SimpleDiGraph` constructors:

```@example graphsection
g = Graph(10, 5) # 10 vertices, 5 edges

d1 = @drawsvg begin
background("grey10")
sethue("gold")
drawgraph(g, vertexlabels = 1:nv(g))
end 400 300

gd = SimpleDiGraph(5, 3) # 5 vertices, 3, edges

d2 = @drawsvg begin
background("grey10")
setline(0.5)
sethue("firebrick")
drawgraph(gd, vertexlabels = 1:nv(g))
end 400 300

hcat(d1, d2)
```

## Well-known graphs

Graphs have been studied for a few centuries, so there are many familiar and well-known graphs and types of graph.

In a **complete graph**, every vertex is connected to every other vertex.

```@example graphsection
N = 10
g = complete_graph(N)
d1 = @drawsvg begin
background("grey10")
setline(0.5)
sethue("maroon")
drawgraph(g, vertexlabels = 1:nv(g))
end 600 300
```

There's also a `complete_digraph()` function.

```@example graphsection
N = 7
g = complete_digraph(N)
d1 = @drawsvg begin
background("grey10")
setline(0.5)
sethue("orange")
drawgraph(g, vertexlabels = 1:nv(g))
end 600 300
```

In a **bi-partite graph**, every vertex belongs to one of two groups. Every vertex in the first group is connected to one or more edges in the second group. This illustration shows a **complete** bi-partite graph. The word "complete" here means that each vertex is connected to every other vertex.

```@example graphsection
N = 10
g = complete_bipartite_graph(N, N)
H = 300
W = 550
d1 = @drawsvg begin
background("grey10")
pts = vcat(
    between.(O + (-W/2, H/2), O + (W/2, H/2), range(0, 1, length=N)),
    between.(O + (-W/2, -H/2), O + (W/2, -H/2), range(0, 1, length=N)))
sethue("gold3")
drawgraph(g, vertexlabels = 1:nv(g), layout = pts, edgestrokeweights=0.5)
end 600 400
```

A **grid** graph doesn't need much explanation:

```@example graphsection
M = 4
N = 5
g = Graphs.grid([M, N]) # grid((m, n))
d1 = @drawsvg begin
background("grey10")
setline(0.5)
sethue("orange")
drawgraph(g, vertexlabels = 1:nv(g), layout=stress)
end 600 300
```
Star graphs (`star_graph(n)`) and wheel graphs (`wheel_graph(n)`) deliver what their names promise.

```@example graphsection
g = star_graph(12)
d1 = @drawsvg begin
    background("grey10")
    sethue("orange")
    drawgraph(g, vertexlabels=1:nv(g), layout=stress)
end 600 300
```

```@example graphsection
g = wheel_graph(12)
d1 = @drawsvg begin
    background("grey10")
    sethue("orange")
    drawgraph(g, vertexlabels=1:nv(g), layout=stress)
end 600 300
```

### Even more well-known graphs

There are probably as many graphs as there are possible games of chess. In both fields, the more commonly-seen patterns have been studied extensively by enthusiasts for years.

Many well-known graphs are provided by the `smallgraph()` function. Supply one of the available symbols, such as `:bull`, or `:house`.

```@setup smallgraphs
using Karnak, Luxor, Graphs, NetworkLayout
smallgraphs = (
(:bull, "bull"),
(:chvatal, "chvatal"),
(:cubical, "(Platonic) cubical "),
(:desargues, "desarguesg"),
(:diamond, "diamond"),
(:dodecahedral, "(Platonic) dodecahedral"),
(:frucht, "frucht"),
(:heawood, "heawood"),
(:house, "house"),
(:housex, "housex "),
(:icosahedral, "(Platonic) icosahedral"),
(:karate, "karate"),
(:krackhardtkite, "krackhardtkite"),
(:moebiuskantor, "moebiusantor"),
(:octahedral, "(platonic) octahedral"),
(:pappus, "pappus"),
(:petersen, "petersen"),
(:sedgewickmaze, "sedgewick"),
(:tetrahedral, "(Platonic) tetrahedral"),
(:truncatedcube, "truncatedcube"),
(:truncatedtetrahedron, "truncatedtetrahedron"),
(:truncatedtetrahedron_dir, "truncatedtetrahedron"),
(:tutte, "tutte"))

colors = ["orange", "brown1", "firebrick1",
"blue", "red", "purple1", "royalblue1",
"orangered", "orangered1", "deeppink", "deeppink1", "maroon1",
"darkorchid1", "dodgerblue", "dodgerblue1", "blue2",
"purple2", "royalblue2", "dodgerblue2", "slateblue2",
"mediumslateblue", "darkorchid2", "violetred2", "maroon2",
"orangered2", "brown2"]

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
drawgraph(g, boundingbox=bbox, vertexshapesizes = 2, layout = stress)
sethue("cyan")
text(string(last(smallgraphs[n])), halign=:center, boxbottomcenter(bbox))
end
end
end 800 800
```

```@example smallgraphs
smallgraphs # hide
```

You will have no trouble finding out more about these well-known graphs online, such as on the wikipedia.
Some of the graphs in this illustration would benefit from attentive ‘tuning’ of the various layout parameters.

Here's a larger view of a Petersen graph (named after Julius Petersen, who first described it in 1898).

```@example graphsection
@drawsvg begin
background("grey10")
pg = smallgraph(:petersen)
sethue("orange")
drawgraph(pg, vertexlabels = 1:nv(pg), layout = Shell(nlist=[6:10,]))
end 600 300
```

```@example graphsection
@drawsvg begin
background("grey10")
g = smallgraph(:cubical)
sethue("orange")
drawgraph(g, layout = Spring(Ptype=Float64))
end 600 300
```

## Getting some information about the graph

There are lots of functions for obtaining information about a graph.

How many vertices?

```julia
julia> nv(pg)
6
```

How many edges?

```julia
julia> ne(pg)
15
```

Which vertices are connected with vertex 1 - ie what are the neighbors of a particular vertex?

```julia
julia> neighbors(pg, 1)
5-element Vector{Int64}:
 2
 3
 4
 5
 6
```


We can iterate over vertices and edges.

To step through each vertex:

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
```

Iterating over edges will give a value of type `Edge`, and the `src()` and
and `dst()` functions applied to an edge argument return the numbers of the source and destination vertices respectively.

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

To add an edge, do:

```julia
add_edge!(df, 1, 2) # from vertex 1 to 2
```

It's sometimes useful to be able to see these relationships between neighbors visually.

```@example graphsection
@drawsvg begin
background("grey10")
pg = smallgraph(:petersen)

vertexofinterest = 10
E = []
for (n, e) in enumerate(edges(pg))
    if dst(e) == vertexofinterest || src(e) == vertexofinterest
        push!(E, n)
    end
end

drawgraph(pg,
    vertexlabels = 1:nv(pg),
    layout = Shell(nlist=[6:10,]),
    vertexfillcolors = (v) -> ((v == vertexofinterest) || v ∈ neighbors(pg, vertexofinterest)) && sethue(colorant"blue"),
    vertexshapesizes = [v == vertexofinterest ? 20 : 10 for v in 1:nv(pg)],
    edgestrokecolors = (e, f, t) -> (e ∈ E) ? colorant"red" : colorant"blue")
end 600 300
```

Other useful functions in Graphs.jl include `has_vertex(g, v)` and `has_edge(g, s, d)`.

## Graphs as matrices

Graphs can be represented as matrices. In the world of graph theory, we'll meet the adjacency matrix, the incidence matrix, and the adjacency list.

### Adjacency matrix

A graph `G` with `n` vertices can be represented by a square matrix `A` with `n` rows and columns. The matrix consists of 1s and 0s. A value of 1 means that there's a connection between two vertices with those indices. For example, if vertex 5 is connected with vertex 4, then `A[5, 4]` is 1. The `adjacency_matrix()` function displays the matrix for a graph:

```julia
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

```@example graphsection
@drawsvg begin
background("grey10")
pg = smallgraph(:petersen)
sethue("orange")
drawgraph(pg, vertexlabels = 1:nv(pg), layout = Shell(nlist=[6:10,]))
end 600 400
```

Notice that this matrix, for a Petersen graph, is symmetrical about the top-left/bottom-right diagonal, because, in an undirected graph, a connection from vertex 4 to vertex 5 is also a connection from vertex 5 to 4. The vertical sum of each column (and the horizontal sum of each row) is the number of edges shared by that vertex, which is usually called the **degree** of the vertex.

We can provide an adjacency matrix to the graph construction functions to create a graph. For example, this matrix recreates the House graph from its adjacency matrix:

```@example graphsection
m = [0 1 1 0 0;
     1 0 0 1 0;
     1 0 0 1 1;
     0 1 1 0 1;
     0 0 1 1 0]

@drawsvg begin
background("grey10")
hg = Graph(m)
sethue("orange")
drawgraph(hg, vertexlabels=1:nv(hg), layout=stress)
end 800 400
```

### Incidence matrix

We can also represent a graph G with a matrix M consisting of 1s, -1s, and 0s in which the rows are vertices and the columns are edges. M is called an **incidence matrix**.

```julia
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
dg = DiGraph(3, 3)

incidence_matrix(dg)

3×3 SparseArrays.SparseMatrixCSC{Int64, Int64} with 6 stored entries:
 -1   1   1
  1  -1   ⋅
  ⋅   ⋅  -1
```

Here, negative values are used, so 1 and -1 are used to indicate directions. The first column,`-1 1 0`, specifies the first edge goes **from** 2 to 1.

An incidence matrix is another useful way of quickly defining a graph. That's why we can pass an incidence matrix to the `Graph()` and `DiGraph()` functions to create new graphs.

For example, here's a vaguely familiar image:

```@example graphsection
g = [0 1 1;
     1 0 1;
     1 1 0]

@drawsvg begin
background("grey20")
drawgraph(Graph(g),
    layout = ngon(O + (0, 10), 120, 3, π/6, vertices=true),
    vertexshapes = :circle,
    vertexshapesizes = 70,
    edgestrokeweights = 25,
    edgestrokecolors = colorant"gold",
    vertexfillcolors = [colorant"#CB3C33", colorant"#389826", colorant"#9558B2"])
end 600 400
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

defines a graph with 10 vertices, such that vertex 1 has edges joining it to vertices 2, 5, 6, and 10, and so on for each element of the whole array.

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

Graphs help us answer questions about connectivity and relationships. For example, thinking of a graph as a railway network, with the vertices as stations and the edges as railway lines, we want to ask questions such as "Can we get from A to B", which becomes the question "Are there sufficient edges between two vertices such that we can find a path that joins them?".

Graphs.jl has many features for traversing graphs and finding paths. We can look at just a few of them here.

!!! note

    The study of graphs uses a lot of terminology, and many
    of the terms also have informal and familiar
    meanings. Usually the informal meanings are
    reasonably accurate and appropriate, but note that the
    words also have more precise definitions in the literature.

### Paths and cycles

A path is a sequence of edges between some start vertex and some end vertex, such that a continuous unbroken route is available.

A cycle is a path where the start and end vertices are the same - a closed path. These are also called **circuits** in some sources.

You can find all the cycles in a graph (at least, you can find a **basis**, which is a minimal collection of cycles that can be added to make all the cycles) with the `cycle_basis()` function. The result is an array of arrays of vertex numbers.

```
cycles = cycle_basis(g)

11-element Vector{Vector{Int64}}:
 [13, 14, 15, 16, 17]
 [11, 10, 14, 15, 16, 17, 18, 19, 20, 1]
 [2, 9, 10, 14, 15, 16, 17, 18, 19, 20, 1]
 [8, 9, 10, 14, 15]
 [6, 7, 8, 15, 16]
 [2, 3, 7, 8, 15, 16, 17, 18, 19, 20, 1]
 [4, 3, 7, 8, 15, 16, 17, 18, 19, 20]
 [5, 6, 16, 17, 18]
 [12, 13, 17, 18, 19]
 [4, 5, 18, 19, 20]
 [11, 12, 19, 20, 1]
```

```@example graphsection


```
### Shortest paths

One way to find the shortest path between two vertices is to use the `a_star()` function, and provide the graph, the start vertex, and the end vertex. The function returns a list of edges.

(The odd name of this function is just a reference to the name of the algorithm, `A*`, first published in 1968.)

The function finds the shortest path and returns an array of edges that define the path.

### Spanning trees

A spanning tree is a set of edges that connect all the vertices of a graph together.

## Weighted graphs

Up to now our graphs have been like maps of train or metro networks, focusing on connections rather than on, say, distances and journey times. Edges are effectively always one unit long. Shortest path calculations can't take into account the true length of edges. But some systems modelled by graphs require this knowledge, which is where weighted graphs are useful. A weighted graph, which can be either undirected or directed, has numeric values assigned to each edge. This value is called the "weight" of an edge, and they're usually positive integers, but can be anything.

The word "weight" is interpreted according to context and the nature of the system modelled by the graph. For example, a higher value for the weight of an edge could mean a longer journey time or more expensive fuel costs, for map-style graphs, but it could signify high attraction levels for a social network graph.

To use weighted graphs, we must install a separate package, SimpleWeightedGraphs.jl, and load it alongside Graphs.jl.

To create a new weighted graph:

```julia
using Graphs, SimpleWeightedGraphs

wg = SimpleWeightedGraph()
```

This creates a new empty weighted undirected graph, or we can pass an existing graph to this function:

```julia
wg = SimpleWeightedGraph(Graph(6, 15), 4.0)
```

To get the weights of a vertex, use:

```
get_weight(wg, 1, 2)
```

You can change the weight of an edge with:

```
add_edge!(graph, from, to, weight)
```

In this example, we set the default weight of every edge to 4.0 when the graph is created, and changed just one edge's weight:

```@example graphsection
wg = SimpleWeightedGraph(Graph(6, 15), 4.0)
add_edge!(wg, 1, 2, 10_000_000)
@drawsvg begin
    sethue("gold")
    drawgraph(wg, edgecurvature=10,
        vertexlabels = 1:nv(wg),
        edgelabels = [get_weight(wg, src(e), dst(e)) for e in edges(wg)],
        edgelabelcolors = [get_weight(wg, src(e), dst(e)) > 10 ? colorant"red" : colorant"green" for e in edges(wg)])
end
```

If you look at the graph's adjacency matrix, you'll see that the weights have replaced the 1s:

```
adjacency_matrix(wg)
6×6 SparseArrays.SparseMatrixCSC{Float64, Int64} with 30 stored entries:
  ⋅     1.0e7  4.0  4.0  4.0  4.0
 1.0e7   ⋅     4.0  4.0  4.0  4.0
 4.0    4.0     ⋅   4.0  4.0  4.0
 4.0    4.0    4.0   ⋅   4.0  4.0
 4.0    4.0    4.0  4.0   ⋅   4.0
 4.0    4.0    4.0  4.0  4.0   ⋅
```

For a directed graph, each edge can have two weights, one from src to dst, the other from dst to src.     


a_star() doesnt work with weighted graphs yet.
