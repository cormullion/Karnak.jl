using Karnak, Graphs, NetworkLayout, Colors

# I started adapting David Sanders https://github.com/JuliaTeX/TreeView.jl
# but didn't finish

add_numbered_vertex!(g) = (add_vertex!(g); top = nv(g))

function walk_tree!(g, labels, ex, show_call=true)
    top_vertex = add_numbered_vertex!(g)
    where_start = 1  # which argument to start with
    if !(show_call) && ex.head == :call
        f = ex.args[1]   # the function name
        push!(labels, f)
        where_start = 2   # drop "call" from tree
    else
        push!(labels, ex.head)
    end
    for i in where_start:length(ex.args)
        if isa(ex.args[i], Expr)
            child = walk_tree!(g, labels, ex.args[i], show_call)
            add_edge!(g, top_vertex, child)
        else
            n = add_numbered_vertex!(g)
            add_edge!(g, top_vertex, n)
            push!(labels, ex.args[i])
        end
    end
    return top_vertex
end

function walk_tree(ex::Expr, show_call=false)
    g = DiGraph()
    labels = Any[]
    walk_tree!(g, labels, ex, show_call)
    return (g, labels)
end

g, labels = walk_tree(:(2 + sin(30)))
g, labels = walk_tree(:(begin g = DiGraph()
    labels = Any[]
    walk_tree!(g, labels, ex, show_call)
    return (g, labels)
end))

@drawsvg begin
    background("grey10")
    sethue("gold")
    drawgraph(g,
        layout = buchheim,
        vertexlabels = labels,
        vertexshapes = :none,
        edgefunction = (n, s, d, f, t) -> begin

                move(f)
                line(t)
                strokepath()
            end,
        edgegaps = 20,
        vertexlabelfontsizes = 10,
        vertexlabeltextcolors = colorant"gold")
end
