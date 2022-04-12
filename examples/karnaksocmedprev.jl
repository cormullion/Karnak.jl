using Karnak, Luxor, Graphs, NetworkLayout, Colors
using Random

Random.seed!(42)
logo = readsvg("docs/src/assets/logo.svg")

function hiero()
    tiles = Tiler(1280, 640, 8, 12)
    for (pos, n) in tiles
        @layer begin
            translate(pos)
            bb = BoundingBox(box(O, tiles.tilewidth, tiles.tileheight))
            rule(O + (tiles.tilewidth)/2, π/2)
            R = rand(1:10)
            if R  == 1
                g = binary_tree(rand(2:4))
                dirg = SimpleDiGraph(collect(edges(g)))
                drawgraph(dirg, vertexshapesizes = 1, layout = buchheim, edgecurvature=0, boundingbox=bb, margin=5)
            elseif R  == 2
                g = star_graph(rand(3:10))
                drawgraph(g, boundingbox=bb, margin=10,  layout=stress, vertexstrokeweights=0.25)
            elseif R  == 3
                g = smallgraph(:truncatedcube)
                drawgraph(g, boundingbox=bb, margin=10,  vertexshapes = :none, layout=stress, vertexstrokeweights=0.3)
            elseif R  == 4
                g = smallgraph(:tutte)
                drawgraph(g, boundingbox=bb, margin=10,  vertexshapes = :none, layout=stress, vertexstrokeweights=0.3)
            elseif R  == 5
                g = smallgraph(:truncatedtetrahedron)
                drawgraph(g, boundingbox=bb, margin=10,  vertexshapesizes = 2, layout=stress, vertexstrokeweights=0.3)
            elseif R  == 6
                g = smallgraph(:cubical)
                drawgraph(g, boundingbox=bb, margin=10,  layout = Spring(Ptype=Float64))
            elseif R  == 7
                g = smallgraph(:octahedral)
                drawgraph(g, boundingbox=bb, margin=10,  layout = Spring(Ptype=Float64))
            else
                g = complete_graph(rand(4:12))
                drawgraph(g, boundingbox=bb, margin=10, vertexshapesizes = 1, vertexstrokeweights=0.15, layout = Spring(Ptype=Float64))
            end
        end
    end
end

@png begin
    background("#bc9e78")

    panes = Tiler(1280,  640, 1, 2, margin=0)


    @layer begin
        setopacity(0.3)
    box(first(panes[1]), 640, 640, :fill)
    box(first(panes[1]), 640, 640, :clip)
    sethue("gold2")
    hiero()
    clipreset()

    sethue("gold")
    box(first(panes[2]), 640, 640, :fill)
    box(first(panes[2]), 640, 640, :clip)
    sethue("darkgoldenrod")
    hiero()
    clipreset()
end

    @layer begin
        translate(first(panes[1]))
        scale(0.9)
        placeimage(logo, O, centered=true)
    end

    @layer begin
       sethue("black")
       fontface("EgyptianWide")
       bx = box(first(panes[2]), panes.tilewidth/1.5, panes.tileheight/1.5)
       #poly(bx, :stroke, close=true)
       textfit("Karnak", BoundingBox(bx))

       sethue("black")
       bx = box(first(panes[2]), panes.tilewidth/1.5, panes.tileheight/4)
       #poly(bx, :stroke, close=true)
       fontsize(30)
       textwrap("A small Luxor.jl utility package to help with drawing some network diagrams.", 800, boxtopleft(BoundingBox(bx)), leading=get_fontsize() + 10)


    end
end 1280 640 "docs/src/assets/figures/karnak-social-media-preview.png"
