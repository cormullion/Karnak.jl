using Graphs
using Karnak
using Colors

function lighten(col::Colorant, f)
    c = convert(RGB, col)
    return RGB(f * c.r, f * c.g, f * c.b)
end

function julia_sphere(pt::Point, w, col::Colorant;
        action = :none)
    setmesh(mesh(
        makebezierpath(box(pt, w * 1.5, w * 1.5)),
        [lighten(col, .5),
         lighten(col, 1.75),
         lighten(col, 1.25),
         lighten(col, .6)]))
    circle(pt, w, action)
end

function draw_edge(pt1, pt2)
    for k in 0:0.1:1
        setline(rescale(k, 0, 1, 25, 1))
        sethue(lighten(colorant"grey50", rescale(k, 0, 1, 0.5, 1.5)))
        setopacity(rescale(k, 0, 1, 0.5, 0.75))
        line(pt1, pt2, :stroke)
    end
end

outerpts = ngonside(O, 450, 4, π/4, vertices=true)
innerpts = ngonside(O, 150, 4, π/2, vertices=true)
pts = vcat(outerpts, innerpts)
colors = map(c -> RGB(c...), [Karnak.Luxor.julia_blue, Karnak.Luxor.julia_red, Karnak.Luxor.julia_green, Karnak.Luxor.julia_purple])

Drawing(600, 600, "/tmp/julia-graphs.svg")
    origin()
    squircle(O, 294, 294, :clip, rt=0.2)
    sethue("black")
    paint()
    g = SimpleGraph([
        Edge(1,2), Edge(2,3), Edge(3,4), Edge(1,4),
        Edge(5,6), Edge(6,7), Edge(7,8), Edge(5,8),
        Edge(1,5), Edge(2,6), Edge(3,7), Edge(4,8),
        ])

    drawgraph(Graph(g),
        layout=pts,
        vertexfunction = (v, c) -> begin
            d = distance(O, c[v])
            d > 200 ? k = 0 : k = 1
            julia_sphere(c[v], rescale(d, 0, 200, 52, 50), colors[mod1(v + k, 4)], action=:fill)
        end,
        edgefunction = (k, s, d, f, t) -> draw_edge(f, t)
        )
finish()
preview()
# run(`svgo -i /private/tmp/julia-graphs.svg -o /private/tmp/julia-graphs-opt.svg`)
