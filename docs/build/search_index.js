var documenterSearchIndex = {"docs":
[{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"using Karnak, Luxor, Graphs, NetworkLayout\n\n# these bright colors work on both white and dark backgrounds\n#  \"fuchsia\" \"magenta\" \"magenta1\" \"brown1\" \"firebrick1\"\n#  \"blue\" \"blue1\" \"red\" \"red1\" \"purple1\" \"royalblue1\"\n#  \"orangered\" \"orangered1\" \"deeppink\" \"deeppink1\" \"maroon1\"\n#  \"darkorchid1\" \"dodgerblue\" \"dodgerblue1\" \"blue2\"\n#  \"purple2\" \"royalblue2\" \"dodgerblue2\" \"slateblue2\"\n#  \"mediumslateblue\" \"darkorchid2\" \"violetred2\" \"maroon2\"\n#  \"orangered2\" \"brown2\"","category":"page"},{"location":"basics.html#Tutorial","page":"Basic graphs","title":"Tutorial","text":"","category":"section"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"This section contains an introduction to basic graph theory using the Graphs.jl package. You don't need any prior knowledge of graphs, but you should be familiar with the basics of Julia programming.","category":"page"},{"location":"basics.html#Graphs,-vertices,-and-edges","page":"Basic graphs","title":"Graphs, vertices, and edges","text":"","category":"section"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"Graph theory is used for analysing networks and relationships. A typical graph consists of:","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"vertices, which represent the things or entities\nedges, which describe how these things or entities connect and relate to each other","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"The Graphs.jl package provides many ways to create graphs. We'll start off with this basic approach:","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"using Graphs # hide\ng = Graph()","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"The Graph() function creates a new empty graph and stores it in g. Let's add a single vertex:","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"add_vertex!(g)","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"(You can use SimpleGraph() as well as Graph().)","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"We can easily add a number of new vertices:","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"add_vertices!(g, 3)","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"Now we'll join pairs of vertices with an edge. The four vertices we've made can be referred to with 1, 2, 3, and 4:","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"add_edge!(g, 1, 2)  # join vertex 1 with vertex 2\nadd_edge!(g, 1, 3)\nadd_edge!(g, 2, 3)\nadd_edge!(g, 1, 4)","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"g is now a {{4, 1} undirected simple Int64 graph}. It's time to see some kind of visual representation of the graph we've made.","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"g = Graph() # hide\nadd_vertices!(g, 4) # hide\nadd_edge!(g, 1, 2) # hide\nadd_edge!(g, 1, 3) # hide\nadd_edge!(g, 2, 3) # hide\nadd_edge!(g, 1, 4) # hide\n\n@drawsvg begin # hide\nsethue(\"fuchsia\")\ndrawgraph(g, vertexlabels = [1, 2, 3, 4])\nend # hide","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"This is one of the many ways this graph can be represented visually. The coordinates of the vertices when drawn here are not part of the graph's definition, and have been assigned randomly by the layout algorithm.","category":"page"},{"location":"basics.html#Undirected-and-directed-graphs","page":"Basic graphs","title":"Undirected and directed graphs","text":"","category":"section"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"There are two main types of graph, undirected and directed. In our undirected graph g above, vertex 1 and vertex 2 are connected, but there's no way to specify or see a direction for that connection. For example, if the graph was modelling people making financial transactions, we couldn't tell whether the person at vertex 1 sent money to the person at vertex 2, or received money from them.","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"In Graphs.jl we can create directed graphs with DiGraph() (also SimpleDiGraph()).","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"gd = DiGraph()\nadd_vertices!(gd, 4)\nadd_edge!(gd, 1, 2)\nadd_edge!(gd, 1, 3)\nadd_edge!(gd, 2, 3)\nadd_edge!(gd, 1, 4) # vertex 1 to vertex 4\nadd_edge!(gd, 4, 1) # vertex 4 to vertex 1","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"gd = DiGraph() # hide\nadd_vertices!(gd, 4) # hide\nadd_edge!(gd, 1, 2) # hide\nadd_edge!(gd, 1, 3) # hide\nadd_edge!(gd, 2, 3) # hide\nadd_edge!(gd, 1, 4) # hide\nadd_edge!(gd, 4, 1) # hide\n@drawsvg begin # hide\nsethue(\"fuchsia\") # hide\ndrawgraph(gd, vertexlabels = [1, 2, 3, 4])\nend # hide","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"In is representation of our directed graph gd, we can now see the direction of the edges joining vertices. Notice how vertices 1 and 4 are doubly connected, because there's one edge for each direction.","category":"page"},{"location":"basics.html#Simpler-simple-graphs","page":"Basic graphs","title":"Simpler simple graphs","text":"","category":"section"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"Creating graphs by typing the connections manually isn't always convenient, so you might prefer to use the Graph/SimpleGraph and DiGraph/SimpleDiGraph constructors:","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"g = Graph(10, 5) # 10 vertices, 5 edges\ngd = SimpleDiGraph(5, 3) # 5 vertices, 3, edges\nd1 = @drawsvg begin\n    sethue(\"fuchsia\")\n    drawgraph(g, vertexlabels = 1:nv(g))\nend 400 400\n\nd2 = @drawsvg begin\nsetline(0.5)\nsethue(\"firebrick1\")\ndrawgraph(gd, vertexlabels = 1:nv(g))\nend 400 400\nhcat(d1, d2) # hide","category":"page"},{"location":"basics.html#Well-known-graphs","page":"Basic graphs","title":"Well-known graphs","text":"","category":"section"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"Graphs have been studied for a few centuries, so there are many familar and well-known graphs and types of graph.","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"In a complete graph, every vertex is connected to every other vertex.","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"N = 10\ng = complete_graph(N)\nd1 = @drawsvg begin\nsetline(0.5)\nsethue(\"fuchsia\")\ndrawgraph(g, vertexlabels = 1:nv(g))\nend","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"There's also a complete_digraph() function.","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"N = 7\ng = complete_digraph(N)\nd1 = @drawsvg begin\nsetline(0.5)\nsethue(\"fuchsia\")\ndrawgraph(g, vertexlabels = 1:nv(g))\nend","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"In a bi-partite graph, every vertex belongs to one of two groups. Every vertex in the first group is connected to one or more edges in the second group. This illustration shows a complete bi-partite graph. The word \"complete\" here means that each vertex is connected to every other vertex.","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"N = 10\ng = complete_bipartite_graph(N, N)\nH = 200\nW = 400\nd1 = @drawsvg begin # hide\npts = vcat(\n    between.(O + (-W/2, H), O + (W/2, H), range(0, 1, length=N)),\n    between.(O + (-W/2, -H), O + (W/2, -H), range(0, 1, length=N)))\nsethue(\"fuchsia\")\ndrawgraph(g, vertexlabels = 1:nv(g), layout = pts)\nend # hide","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"A grid graph doesn't need much explanation:","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"M = 4\nN = 5\ng = Graphs.grid([M, N]) # grid((m, n))\nd1 = @drawsvg begin # hide\nsetline(0.5)\nsethue(\"fuchsia\")\ndrawgraph(g, vertexlabels = 1:nv(g), layout=stress)\nend # hide","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"Star graphs (star_graph(n)) and wheel graphs (wheel_graph(n)) are usefully named:","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"g = star_graph(12)\nd1 = @drawsvg begin\n    sethue(\"fuchsia\")\n    drawgraph(g, vertexlabels=1:nv(g), layout=stress)\nend","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"g = wheel_graph(12)\nd1 = @drawsvg begin\n    sethue(\"fuchsia\")\n    drawgraph(g, vertexlabels=1:nv(g), layout=stress)\nend","category":"page"},{"location":"basics.html#Even-more-well-known-graphs","page":"Basic graphs","title":"Even more well-known graphs","text":"","category":"section"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"There are probably as many graphs as there possible games of chess, but in both fields, the more commonly seen patterns have been studied extensively.","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"These well-known graphs are provided by the smallgraph() function. Supply a symbol, such as :bull, or :house.","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"using Karnak, Luxor, Graphs, NetworkLayout\nsmallgraphs = (\n(:bull, \"bull\"),\n(:chvatal, \"Chvátal\"),\n(:cubical, \"Platonic cubical \"),\n(:desargues, \"Desarguesgraph\"),\n(:diamond, \"diamond\"),\n(:dodecahedral, \"Platonic dodecahedral\"),\n(:frucht, \"Frucht\"),\n(:heawood, \"Heawood\"),\n(:house, \"house\"),\n(:housex, \"house + two edges\"),\n(:icosahedral, \"Platonic icosahedral\"),\n(:karate, \"Zachary's karate club\"),\n(:krackhardtkite, \"Krackhardt-Kite\"),\n(:moebiuskantor, \"Möbius-Kantor\"),\n(:octahedral, \"Platonic octahedral\"),\n(:pappus, \"Pappus\"),\n(:petersen, \"Petersen\"),\n(:sedgewickmaze, \"Sedgewick maze\"),\n(:tetrahedral, \"Platonic tetrahedral\"),\n(:truncatedcube, \"truncated cube\"),\n(:truncatedtetrahedron, \"truncated tetrahedron\"),\n(:truncatedtetrahedron_dir, \"truncated tetrahedron\"),\n(:tutte, \"Tutte\"))\n\ncolors = [\"fuchsia\", \"brown1\", \"firebrick1\",\n\"blue\", \"red\", \"purple1\", \"royalblue1\",\n\"orangered\", \"orangered1\", \"deeppink\", \"deeppink1\", \"maroon1\",\n\"darkorchid1\", \"dodgerblue\", \"dodgerblue1\", \"blue2\",\n\"purple2\", \"royalblue2\", \"dodgerblue2\", \"slateblue2\",\n\"mediumslateblue\", \"darkorchid2\", \"violetred2\", \"maroon2\",\n\"orangered2\", \"brown2\"]\nsmallgraphs = @drawsvg begin\nsethue(\"fuchsia\")\nng = length(smallgraphs)\nN = convert(Int, ceil(sqrt(ng)))\ntiles = Tiler(800, 800, N, N)\nsetline(0.5)\nfor (pos, n) in tiles\n@layer begin\nn > ng && break\ntranslate(pos)\nsethue(colors[mod1(n, end)])\nbbox = BoundingBox(box(O, tiles.tilewidth, tiles.tileheight))\ng = smallgraph(first(smallgraphs[n]))\ndrawgraph(g, boundingbox=bbox, vertexshapesizes = 2, layout = stress)\ntext(string(last(smallgraphs[n])), halign=:center, boxbottomcenter(bbox))\nend\nend\nend 800 800","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"smallgraphs # hide","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"You will have no trouble finding out more about these well-known graphs on the Wikipedia. Some of the graphs in this illustration would benefit from some careful adjustment of the layout parameters.","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"Here's a larger view of the Petersen graph (named after Julius Petersen, who first described in 1898).","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"@drawsvg begin # hide\npg = smallgraph(:petersen)\nsethue(\"fuchsia\")\ndrawgraph(pg, vertexlabels = 1:nv(pg), layout = Shell(nlist=[6:10,]))\nend  # hide","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"@drawsvg begin  # hide\ng = smallgraph(:cubical)\nsethue(\"fuchsia\")\ndrawgraph(g, layout = Spring(Ptype=Float64))\nend  # hide","category":"page"},{"location":"basics.html#Getting-some-information-about-the-graph","page":"Basic graphs","title":"Getting some information about the graph","text":"","category":"section"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"There are lots of functions for obtaining information about a graph.","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"How many vertices?","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"julia> nv(pg)\n6","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"How many edges?","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"julia> ne(pg)\n15","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"Which vertices are connected with vertex 1 - ie what are the neighbors of a particular vertex?","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"julia> neighbors(pg, 1)\n5-element Vector{Int64}:\n 2\n 3\n 4\n 5\n 6","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"We can iterate over vertices and edges.","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"To step through each vertex:","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"for e in vertices(pg)\n    println(e)\nend\n\n1\n2\n3\n4\n5\n6","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"Iterating over edges will give a value of type Edge, and the src() and and dst() functions applied to an edge argument return the numbers of the source and destination vertices respectively.","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"for e in edges(pg)\n    println(src(e), \" => \", dst(e))\nend\n1 => 2\n1 => 5\n1 => 6\n2 => 3\n2 => 7\n3 => 4\n3 => 8\n4 => 5\n4 => 9\n5 => 10\n6 => 8\n6 => 9\n7 => 9\n7 => 10\n8 => 10","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"To add an edge, do:","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"add_edge!(df, 1, 2) # from vertex 1 to 2","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"Others: hasvertex(g, v) hasedge(g, s, d)","category":"page"},{"location":"basics.html#Graphs-as-matrices","page":"Basic graphs","title":"Graphs as matrices","text":"","category":"section"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"Graphs can be represented as matrices. In the world of graph theory, we'll meet the adjacency matrix, the incidence matrix, and the adjacency list.","category":"page"},{"location":"basics.html#Adjacency-matrix","page":"Basic graphs","title":"Adjacency matrix","text":"","category":"section"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"A graph G with n vertices can be represented by a square matrix A with n rows and columns. The matrix consists of 1s and 0s. A value of 1 means that there's a connection between two vertices with those indices. For example, if vertex 5 is connected with vertex 4, then A[5, 4] is 1. The adjacency_matrix() function displays the matrix for a graph:","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"julia> adjacency_matrix(pg)\n10×10 SparseArrays.SparseMatrixCSC{Int64, Int64} with 32 stored entries:\n ⋅  1  ⋅  ⋅  1  1  ⋅  ⋅  ⋅  1\n 1  ⋅  1  ⋅  ⋅  ⋅  1  ⋅  ⋅  ⋅\n ⋅  1  ⋅  1  ⋅  ⋅  ⋅  1  ⋅  ⋅\n ⋅  ⋅  1  ⋅  1  ⋅  ⋅  ⋅  1  ⋅\n 1  ⋅  ⋅  1  ⋅  ⋅  ⋅  ⋅  ⋅  1\n 1  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  1  1  ⋅\n ⋅  1  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  1  1\n ⋅  ⋅  1  ⋅  ⋅  1  ⋅  ⋅  ⋅  1\n ⋅  ⋅  ⋅  1  ⋅  1  1  ⋅  ⋅  ⋅\n 1  ⋅  ⋅  ⋅  1  ⋅  1  1  ⋅  ⋅","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"@drawsvg begin # hide\npg = smallgraph(:petersen)\nsethue(\"fuchsia\")\ndrawgraph(pg, vertexlabels = 1:nv(pg), layout = Shell(nlist=[6:10,]))\nend 600 400  # hide","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"Notice that this matrix, for a Petersen graph, is symmetrical about the top-left/bottom-right diagonal, because, in an undirected graph, a connection from vertex 4 to vertex 5 is also a connection from vertex 5 to 4. The vertical sum of each column (and the horizontal sum of each row) is the number of edges shared by that vertex, which is sometimes called the degree of the vertex.","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"We can provide an adjacency matrix to the graph construction functions to create a graph. For example, this matrix recreates the House graph from its adjacency matrix:","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"m = [0 1 1 0 0;\n     1 0 0 1 0;\n     1 0 0 1 1;\n     0 1 1 0 1;\n     0 0 1 1 0]\n\n@drawsvg begin # hide\nhg = Graph(m)\nsethue(\"fuchsia\") # hide\ndrawgraph(hg, vertexlabels=1:nv(hg), layout=stress)\nend 800 400 # hide","category":"page"},{"location":"basics.html#Incidence-matrix","page":"Basic graphs","title":"Incidence matrix","text":"","category":"section"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"We can also represent a graph G with a matrix M consisting of 1s, -1s, and 0s in which the rows are vertices and the columns are edges. M is an incidence matrix.","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"julia> incidence_matrix(pg)\n10×15 SparseArrays.SparseMatrixCSC{Int64, Int64} with 30 stored entries:\n 1  1  1  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅\n 1  ⋅  ⋅  1  1  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅\n ⋅  ⋅  ⋅  1  ⋅  1  1  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅\n ⋅  ⋅  ⋅  ⋅  ⋅  1  ⋅  1  1  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅\n ⋅  1  ⋅  ⋅  ⋅  ⋅  ⋅  1  ⋅  1  ⋅  ⋅  ⋅  ⋅  ⋅\n ⋅  ⋅  1  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  1  1  ⋅  ⋅  ⋅\n ⋅  ⋅  ⋅  ⋅  1  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  1  1  ⋅\n ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  1  ⋅  ⋅  ⋅  1  ⋅  ⋅  ⋅  1\n ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  1  ⋅  ⋅  1  1  ⋅  ⋅\n ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  ⋅  1  ⋅  ⋅  ⋅  1  1","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"For a directed graph:","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"dg = DiGraph(3, 3)\n\nincidence_matrix(dg)\n\n3×3 SparseArrays.SparseMatrixCSC{Int64, Int64} with 6 stored entries:\n -1   1   1\n  1  -1   ⋅\n  ⋅   ⋅  -1","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"Here, values of 1 and -1 are used to indicate directions, so the first column,-1 1 0, specifies the first edge goes from 2 to 1.","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"An incidence matrix is another useful way of quickly defining a graph. That's why we can pass an incidence matrix to the Graph() and DiGraph() functions to create new graphs.","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"Graph([1 0 1;   \n       0 1 1;\n       1 1 0])\n\n{3, 4} undirected simple Int64 graph","category":"page"},{"location":"basics.html#Adjacency-list","page":"Basic graphs","title":"Adjacency list","text":"","category":"section"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"Another way of representing a graph is by using an array of arrays in the form of an adjacency list. This array has n elements to represent a graph with n vertices. The first element of the array is an array of those vertex numbers that are connected with vertex 1, and similarly for elements 2 to n.","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"For example, this adjacency list:","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"[\n    [2, 5, 6, 10],  # row 1 = vertex 1 connects with 2, 5, 6, and 10\n    [1, 3, 7],\n    [2, 4, 8],\n    [3, 5, 9],\n    [1, 4, 10],\n    [1, 8, 9],\n    [2, 9, 10],\n    [3, 6, 10],\n    [4, 6, 7],\n    [1, 5, 7, 8]\n]","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"defines a graph with 10 vertices, such that vertex 1 has edges joining it to vertices 2, 5, 6, and 10, and so on for each element of the whole array.","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"g = Graph(30, [\n[2, 5, 7],\n[1, 3, 9],\n[2, 4, 11],\n[3, 5, 13],\n[1, 4, 15],\n[7, 15, 20],\n[1, 6, 8],\n[7, 9, 16],\n[2, 8, 10],\n[9, 11, 17],\n[3, 10, 12],\n[11, 13, 18],\n[4, 12, 14],\n[13, 15, 19],\n[5, 6, 14],\n[8, 17, 20],\n[10, 16, 18],\n[12, 17, 19],\n[14, 18, 20],\n[6, 16, 19]])\n\n@drawsvg begin # hide\nsethue(\"fuchsia\")\ndrawgraph(g, layout=stress)\nend # hide","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"Graphs.jl uses adjacency lists internally. If we peek inside a graph and look at its fields, we'll see something like this, for a Directed Graph:","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"fieldnames(DiGraph)\n(:ne, :fadjlist, :badjlist)","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"Here, fadjlist is a forward adjacency list which defines how each vertex connects to other vertices, and badjlist is a backward adjacency list which defines how each vertex receives connections from other vertices.","category":"page"},{"location":"basics.html#Paths,-cycles,-routes,-and-traversals","page":"Basic graphs","title":"Paths, cycles, routes, and traversals","text":"","category":"section"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"Graphs help us answer questions about connectivity and relationships. For example, thinking of a graph as a railway network, with the vertices as stations and the edges as railway lines, we want to ask questions such as \"Can we get from A to B\", which becomes the question \"Are there sufficient edges between two vertices such that we can find a path that joins them?\".","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"Graphs.jl has many features for traversing graphs and finding paths. We can look at just a few of them here.","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"note: Note\nThe study of graphs uses a lot of terminology, and many of the terms also have informal and familiar definitions. Usually the informal definitions are sufficiently accurate and appropriate, but note that they also have more precise definitions in the literature.","category":"page"},{"location":"basics.html#Paths-and-cycles","page":"Basic graphs","title":"Paths and cycles","text":"","category":"section"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"A path is a sequence of edges between some start vertex and some end vertex, such that a continuous unbroken route is available.","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"A cycle is a path where the start and end vertices are the same - a closed path. These are also called circuits in some sources.","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"You can find all the cycles in a graph (at least, you can find a basis, which is a minimal collection of cycles that can be added to make all the cycles) with the cycle_basis() function. The result is an array of arrays of vertex numbers.","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"cycles = cycle_basis(g)\n\n11-element Vector{Vector{Int64}}:\n [13, 14, 15, 16, 17]\n [11, 10, 14, 15, 16, 17, 18, 19, 20, 1]\n [2, 9, 10, 14, 15, 16, 17, 18, 19, 20, 1]\n [8, 9, 10, 14, 15]\n [6, 7, 8, 15, 16]\n [2, 3, 7, 8, 15, 16, 17, 18, 19, 20, 1]\n [4, 3, 7, 8, 15, 16, 17, 18, 19, 20]\n [5, 6, 16, 17, 18]\n [12, 13, 17, 18, 19]\n [4, 5, 18, 19, 20]\n [11, 12, 19, 20, 1]","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"\n","category":"page"},{"location":"basics.html#Shortest-paths","page":"Basic graphs","title":"Shortest paths","text":"","category":"section"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"One way to find the shortest path between two vertices is to use the a_star() function, and provide the graph, the start vertex, and the end vertex. The function returns a list of edges.","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"(The odd name of this function is just a reference to the name of the algorithm, A*, first published in 1968.)","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"The function finds the shortest path and returns an array of edges that define the path.","category":"page"},{"location":"basics.html#Spanning-trees","page":"Basic graphs","title":"Spanning trees","text":"","category":"section"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"A spanning tree is a set of edges that connect all the vertices of a graph together.","category":"page"},{"location":"basics.html#Weighted-graphs","page":"Basic graphs","title":"Weighted graphs","text":"","category":"section"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"Up to now our graphs have been like maps of train or metro networks, focusing on connections rather than on, say, distances and journey times. Edges are effectively always one unit long. Shortest path calculations can't take into account the true length of edges. But some systems modelled by graphs require this knowledge, which is where weighted graphs are useful. A weighted graph, which can be either undirected or directed, has numeric values assigned to each edge. This value is called the \"weight\" of an edge, and they're usually positive integers, but can be anything.","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"The word \"weight\" is interpreted according to context and the nature of the system modelled by the graph. For example, a higher value for the weight of an edge could mean a longer journey time or more expensive fuel costs, for map-style graphs, but it could signify high attraction levels for a social network graph.","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"To use weighted graphs, we must install a separate package, SimpleWeightedGraphs.jl, and load it alongside Graphs.jl.","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"To create a new weighted graph:","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"using Graphs, SimpleWeightedGraphs\n\nwg = SimpleWeightedGraph()\n","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"This creates a new empty weighted undirected graph, or we can pass an existing graph to this function:","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"wg = SimpleWeightedGraph(dodecg)\nswg =SimpleWeightedGraph(Graph(4, 6), 4.0) # assigns weight of 4.0 everywhere","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"If you look inside the graph, you can see that each edge has been assigned the default weight - 1.","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"To get the weights of a vertex, use:","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"get_weight(wg, 1, 2)","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"You can change the weight with","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"add_edge!(graph, from, to, weight)","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"Can make it with this:","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"sources = [1,2,1]\ndestinations = [2,3,3]\nweights = [0.5, 0.8, 2.0]\ng = SimpleWeightedGraph(sources, destinations, weights)","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"If you look at the graph's adjacency matrix, you'll see that the weights have replaced the 1s:","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"adjacency_matrix(swg)\n4×4 SparseArrays.SparseMatrixCSC{Float64, Int64} with 12 stored entries:\n  ⋅   4.0  4.0  4.0\n 4.0   ⋅   4.0  4.0\n 4.0  4.0   ⋅   4.0\n 4.0  4.0  4.0   ⋅","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"For a directed graph, each edge can have two weights, one from src to dst, the other from dst to src.     ","category":"page"},{"location":"basics.html","page":"Basic graphs","title":"Basic graphs","text":"a_star() doesnt work with weighted graphs yet.","category":"page"},{"location":"reference/api.html","page":"Function reference","title":"Function reference","text":"Modules = [Karnak]\nOrder   = [:macro, :function, :type, :constant, ]","category":"page"},{"location":"reference/api.html#Karnak.drawgraph-Tuple{AbstractGraph}","page":"Function reference","title":"Karnak.drawgraph","text":"Draw a graph g using coordinates in layout to fit in a Luxor boundingbox.\n\nThe appearance can be fully specified using the two functions vertexfunction(vertex, coordinates), and edgefunction(from, to).\n\n\n\n\n\n","category":"method"},{"location":"reference/functionindex.html#Index","page":"Alphabetical function list","title":"Index","text":"","category":"section"},{"location":"reference/functionindex.html","page":"Alphabetical function list","title":"Alphabetical function list","text":"","category":"page"},{"location":"index.html#Introduction-to-Karnak","page":"Introduction to Karnak","title":"Introduction to Karnak","text":"","category":"section"},{"location":"index.html","page":"Introduction to Karnak","title":"Introduction to Karnak","text":"Karnak.jl is a small extension for the Luxor.jl package to help with drawing some graph-style diagrams. The focus is more on decorative and aesthetic usage.","category":"page"},{"location":"index.html","page":"Introduction to Karnak","title":"Introduction to Karnak","text":"warning: Warning\nFor mathematical and scientific visualizations, use one of the following Julia packages, rather than this one.TikzGraphs.jl: backend: Tikz/LaTeX\nGraphPlot.jl: backend: Compose.jl\nSGtSNEpi.jl: backend: Makie.jl\nGraphRecipes.jl: backend: Plots.jl\nGraphMakie.jl: backend: Makie.jl","category":"page"},{"location":"index.html#TODO","page":"Introduction to Karnak","title":"TODO","text":"","category":"section"},{"location":"index.html","page":"Introduction to Karnak","title":"Introduction to Karnak","text":"dash patterns\nfontface options\nadd colorscheme or normalized option?\nflipycoordinate option?\nbinary_tree + buchheim layout?\nremove function options from  vertex kwargs\nsquaregrid isn't aligned properly:","category":"page"},{"location":"index.html","page":"Introduction to Karnak","title":"Introduction to Karnak","text":"\tusing  Graphs, Karnak, NetworkLayout\n\tm = [0 1 1 0 0;\n\t     1 0 0 1 0;\n\t     1 0 0 1 1;\n\t     0 1 1 0 1;\n\t     0 0 1 1 0]\n\n\t@drawsvg begin\n\thg = Graph(m)\n\t#translate(boxbottomleft())\n\tsethue(\"fuchsia\")\n\tdrawgraph(hg, margin=20, layout=squaregrid, vertexlabels = 1:nv(hg))\n\tend 900 500","category":"page"}]
}
