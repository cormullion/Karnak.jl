using Graphs
using Karnak
using Colors

function lighten(col::Colorant, f)
    c = convert(RGB, col)
    return RGB(f * c.r, f * c.g, f * c.b)
end

function julia_sphere(pt::Point, w, col::Colorant; action = :none)
    setmesh(mesh(
        makebezierpath(box(pt, w * 1.5, w * 1.5)),
        [
            lighten(col, 0.5),
            lighten(col, 1.75),
            lighten(col, 1.25),
            lighten(col, 0.6),
        ],
    ))
    circle(pt, w, action)
end

function draw_edge(pt1, pt2)
    for k = 0:0.1:1
        setline(rescale(k, 0, 1, 25, 1))
        sethue(lighten(colorant"grey50", rescale(k, 0, 1, 0.5, 1.5)))
        setopacity(rescale(k, 0, 1, 0.5, 0.75))
        line(pt1, pt2, :stroke)
    end
end

colors = map(
    c -> RGB(c...),
    [Luxor.julia_blue, Luxor.julia_red, Luxor.julia_green, Luxor.julia_purple],
)

Drawing(600, 600, "/tmp/julia-graphs.png")
origin()
squircle(O, 294, 294, :clip, rt = 0.2)
sethue("black")
paint()
g = smallgraph(:petersen)
gc = greedy_color(g)
@layer begin
    rotate(-π / 10)
    translate(20, 20)
    drawgraph(
        Graph(g),
        layout = Shell(nlist = [6:10]),
        boundingbox = BoundingBox() * 0.9,
        vertexfunction = (v, c) -> begin
            d = distance(O, c[v])
            julia_sphere(c[v], 40, colors[gc.colors[v]], action = :fill)
        end,
        edgefunction = (k, s, d, f, t) -> draw_edge(f, t),
    )
end
finish()
preview()
# run(`svgo -i /private/tmp/julia-graphs.svg -o /private/tmp/julia-graphs-opt.svg`)
