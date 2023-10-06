using Karnak, Luxor, Graphs, Colors, NetworkLayout, Random

#=
The Seven Bridges of Königsberg is a historically notable
problem in mathematics. Its negative resolution by Leonhard
Euler in 1736 laid the foundations of graph theory and
prefigured the idea of topology.

The city of Königsberg in Prussia (now Kaliningrad, Russia)
was set on both sides of the Pregel River, and included two
large islands — Kneiphof and Lomse — which were connected to
each other, or to the two mainland portions of the city, by
seven bridges. The problem was to devise a walk through the
city that would cross each of those bridges once and only
once.

(wikipedia)

=#

# This code trys to find cycles that visit every island.

# I'm not sure I've set this up correctly...

konigsberg_al = [
    [2, 4],       # 1
    [3, 5, 1],    # 2
    [2, 6],       # 3
    [1, 5, 7],    # 4
    [2, 4, 6, 8], # 5
    [3, 5, 9],    # 6
    [4, 11],      # 7
    [5, 10, 11],  # 8
    [6, 10],      # 9
    [8, 9, 11],   # 10
    [7, 8, 10]    # 11
    ]

bridge_positions = [
Point(-65, 50),  # 1
Point(-35, -0),  # 2
Point(-20, -35), # 3
Point(-30, 50),  # 4
Point(0, 0),     # 5
Point(20, -35),  # 6
Point(60, 100),  # 7
Point(35, 5),    # 8
Point(70, -30),  # 9
Point(80, 5),    # 10
Point(90, 15),   # 11
]

function drawmap(;scalefactor=1)
    @layer begin
        scale(scalefactor)
        placeimage(img, O, centered=true, 1)
    end
    return img.width, img.height
end

g = DiGraph(Graph(16, konigsberg_al))

vertexlist_to_edgelist(vlist) = [Edge(p[1] => p[2]) for p in zip(vlist, circshift(vlist, -1))]

@drawsvg begin
background("grey10")
cycles = simplecycles(g)
filter!(cycle -> length(cycle) > 8, cycles)
sort!(cycles, lt = (a, b) -> length(a) > length(b))
tiles = Tiler(800, 800, 4, 4)
img = readpng(joinpath(@__DIR__, "konigsberg_bridges.png"))
for (pos, n) in tiles
    n > length(cycles) && break
    cycle = cycles[n]
    @layer begin
        translate(pos)
        sethue("grey40")
        sf = tiles.tilewidth/img.width
        w, h = drawmap(scalefactor=sf)
        drawgraph(g,
            layout = sf * bridge_positions,
            vertexshapesizes = 5,
            vertexlabels = 1:nv(g),
            edgelines = 0,
            boundingbox=BoundingBox(box(O, tiles.tilewidth, tiles.tilewidth)))
        drawgraph(g,
            layout = sf * bridge_positions,
            vertexshapes=:none,
            boundingbox=BoundingBox(box(O, tiles.tilewidth, tiles.tilewidth)),
            edgelist = vertexlist_to_edgelist(cycle),
            edgestrokeweights = 3,
            edgestrokecolors = colorant"purple",
            edgegaps=0)
    end
end
end 800 800
