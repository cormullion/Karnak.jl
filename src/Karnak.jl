module Karnak

using Reexport
using Graphs
using Colors
using NetworkLayout

@reexport using Luxor

export drawgraph, drawedge, drawvertex

function _normalize_layout_coordinates(rawcoordinates, boundingbox, margin)
    if length(rawcoordinates[1]) == 3
        @warn "3D coordinates returned by layout function"
    end
    bb = BoundingBox(map(p -> Point(p[1], p[2]), rawcoordinates))
    BB = boundingbox - margin
    offset = boxmiddlecenter(BB) - boxmiddlecenter(bb)
    ar = boxaspectratio(bb)
    AR = boxaspectratio(BB)
    if ar <= 1.0 && AR < 1.0
        sf = boxheight(BB) / boxheight(bb)
    elseif ar > 1 && AR <= 1.0
        sf = boxheight(BB) / boxheight(bb)
    elseif ar > 1 && AR > 1
        sf = boxwidth(BB) / boxwidth(bb)
    else
        ar <= 1.0 && AR > 1
        sf = boxwidth(BB) / boxwidth(bb)
    end
    return [-offset + sf * (Point(first(p), last(p))) for p in rawcoordinates]
end

function _drawedgelines(from, to;
        edgenumber=1,
        edgelines=nothing,
        edgestrokecolors=nothing,
        edgestrokeweights=nothing,
        digraph=false,
        edgecurvature=0.0)

    # decide whether or not to draw this edge

    edgeline = nothing

    if edgelines isa Vector
        # only draw edges that are in the vector
        if edgenumber in edgelines
            edgeline = true
        end
    elseif edgelines isa AbstractRange
        if edgenumber in edgelines
            edgeline = true
        end
    elseif edgelines isa Int
        if edgenumber == edgelines
            edgeline = true
        end
    elseif edgelines == :none

    elseif edgelines isa Function
        # an edgeline function is f(from, to)
            edgeline = edgelines(from, to)
    else
        edgeline = true
    end

    strokecolor = Luxor.get_current_color()
    # set edge stroke color

    if isnothing(edgestrokecolors)
        # default - use current color
    elseif edgestrokecolors isa Array && !isempty(edgestrokecolors)
        if edgestrokecolors[mod1(edgenumber, end)] isa Colorant
            strokecolor = edgestrokecolors[mod1(edgenumber, end)]
        else
            if edgestrokecolors[mod1(edgenumber, end)] == :none
                strokecolor = :none
            end
        end
    elseif edgestrokecolors isa Colorant
        strokecolor = edgestrokecolors
    elseif edgestrokecolors == :none
        strokecolor = :none
    end

    # set the stroke weight
    # default to Luxor default
    linewidth = 2
    if isnothing(edgestrokeweights)
        # by default, do nothing
    elseif edgestrokeweights isa Array
        if !isempty(edgestrokeweights)
            if edgestrokeweights[mod1(edgenumber, end)] != :none
                linewidth = edgestrokeweights[mod1(edgenumber, end)]
            else
                linewidth = 0
            end
        end
    elseif edgestrokeweights isa AbstractRange
        linewidth = edgestrokeweights[mod1(edgenumber, end)]
    elseif edgestrokeweights isa Real
        linewidth = edgestrokeweights
    elseif edgestrokeweights == :none
        # do nothing
    end

    # finally time to draw the edge
    # edgeline = nothing | true | function
    @layer begin
        setline(linewidth)
        sethue(strokecolor)

        # use fontsize as a reasonable basis for the gap
        # between vertex center and arrow tip

        d = distance(from, to)
        f = get_fontsize()
        if edgeline isa Function
            edgeline(from, to)
        elseif edgeline == true
            if digraph == true && abs(edgecurvature) > 0.0
                # digraph and curvey lines
                if abs(edgecurvature) > 0.0
                    arrow(between(from, to, f/d), between(from, to, 1 - f/d), [edgecurvature, edgecurvature], linewidth=linewidth)
                else
                    arrow(between(from, to, f/d), between(from, to, 1 - f/d), [12, 12], linewidth=linewidth)
                end
            elseif digraph == false && abs(edgecurvature) > 0.0
                arrow(between(from, to, f/d), between(from, to, 1 - f/d), [edgecurvature, edgecurvature], linewidth=linewidth)
            elseif digraph == true && isapprox(edgecurvature, 0.0)
                midpt = midpoint(from, to)
                circle(midpt, get_fontsize() / 2, :fill)
                arrow(midpt, between(midpt, to, 1 - f/d), linewidth=linewidth)
                arrow(midpt, between(midpt, from, 1 - f/d), linewidth=linewidth)
            else
                # straight, no digraph
                line(from, to, :stroke)
            end
        else
        end
    end
end

function _drawedgelabels(from, to;
        edgenumber=1,
        digraph=false,
        straight=true,
        edgelabels=nothing,
        edgelabeltextcolors=nothing,
        edgelabelfontsizes=nothing,
        edgelabelfontfaces=nothing)

    # edge labels

    textcolor = Luxor.get_current_color()

    # set edge text color

    if isnothing(edgelabeltextcolors)
        # default - use current color
    elseif edgelabeltextcolors isa Array
        textcolor = edgelabeltextcolors[mod1(edge, end)]
    elseif edgelabeltextcolors isa Colorant
        textcolor = edgelabeltextcolors
    elseif edgelabeltextcolors == :none
        textcolor = :none
    end

    if edgelabels isa Vector && !isempty(edgelabels) || edgelabels isa AbstractRange
        @layer begin
            if edgelabels[mod1(edgenumber, end)] == :none
            else
                str = string(collect(edgelabels)[mod1(edgenumber, end)])
                if textcolor != :none
                    sethue(textcolor)
                    text(str, midpoint(from, to))
                end
            end
        end
    elseif edgelabels == :none
        # edgelabels
    elseif isnothing(edgelabels)
        # default is do nothing
    end

end

function _drawvertexshapes(vertex, coordinates::Array{Point,1};
        vertexshapes=nothing,
        vertexshapesizes=nothing,
        vertexstrokecolors=nothing,
        vertexfillcolors=nothing,
        vertexstrokeweights=nothing)
    # decide whether or not to draw this vertex
    vertexshape = nothing
    if vertexshapes isa Array
        if vertexshapes[mod1(vertex, end)] == :square
            vertexshape = :square
        elseif vertexshapes[mod1(vertex, end)] == :circle
            vertexshape = :circle
        elseif vertex in vertexshapes
            vertexshape = true
        end
    elseif vertexshapes isa Function
        # a vertexshapes function  is f(v, c) ->
        vertexshape = vertexshapes
    elseif vertexshapes isa AbstractRange
        if vertex in vertexshapes
            vertexshape = true
        end
    elseif vertexshapes == :circle
        vertexshape = :circle
    elseif vertexshapes == :square
        vertexshape = :square
    elseif vertexshapes isa Int64
        if vertexshapes == vertex
            vertexshape = true
        end
    end

    if isnothing(vertexshape)
        return
    end

    # so we can draw this vertex
    # vertexshape is one of true, square, circle, or can be function

    # work out fill and stroke colors
    # set the fill color
    # if :none, don't draw it (will override other specs)

    if vertexfillcolors isa Array && !isempty(vertexfillcolors)
        if vertexfillcolors[mod1(vertex, end)] isa Colorant
            fillcolor = vertexfillcolors[mod1(vertex, end)]
        else
            fillcolor = :none
        end
    elseif vertexfillcolors isa Colorant
        fillcolor = vertexfillcolors
    elseif vertexfillcolors == :none
        fillcolor = :none
    else
        # default - use current color
        fillcolor = Luxor.get_current_color()
    end

    # set the stroke color
    strokecolor = :none

    if isnothing(vertexstrokecolors)
        # default - use current color
        strokecolor = Luxor.get_current_color()
    elseif vertexstrokecolors isa Array && !isempty(vertexstrokecolors)
        if vertexstrokecolors[mod1(vertex, end)] isa Colorant
            strokecolor = vertexstrokecolors[mod1(vertex, end)]
        end
    elseif vertexstrokecolors isa Colorant
        strokecolor = vertexstrokecolors
    elseif vertexstrokecolors == :none
        strokecolor = :none
    else
        strokecolor = Luxor.get_current_color()
    end

    # set the stroke weight
    # default to Luxor default
    linewidth = 2

    if isnothing(vertexstrokeweights)
        # by default, do nothing
    elseif vertexstrokeweights isa Array
        if !isempty(vertexstrokeweights)
            if vertexstrokeweights[mod1(vertex, end)] != :none
                linewidth = vertexstrokeweights[mod1(vertex, end)]
            end
        end
    elseif vertexstrokeweights isa AbstractRange
        linewidth = vertexstrokeweights[mod1(vertex, end)]
    elseif vertexstrokeweights == :none
        # do nothing
    end

    # set shape sizes
    # vertexshape size is a radius rather than diameter

    if isnothing(vertexshapesizes)
        vertexshapesize = 6
    elseif vertexshapesizes isa Array
        if !isempty(vertexshapesizes)
            if vertexshapesizes[mod1(vertex, end)] != :none
                vertexshapesize = vertexshapesizes[mod1(vertex, end)]
            end
        end
    elseif vertexshapesizes isa AbstractRange
        vertexshapesize = vertexshapesizes[mod1(vertex, end)]
    elseif vertexshapesizes isa Real
        vertexshapesize = vertexshapesizes
    elseif vertexshapesizes == :none
        # don't draw it
    end

    # finally do some drawing
    # vertexshape is one of true, square, circle, function

    if fillcolor != :none
        @layer begin
            setline(linewidth)
            if vertexshape isa Function
                sethue(fillcolor)
                vertexshape(vertex, coordinates)
            elseif vertexshape == :circle
                sethue(fillcolor)
                circle(coordinates[vertex], vertexshapesize, :fill)
                sethue(strokecolor)
                circle(coordinates[vertex], vertexshapesize, :stroke)
            elseif vertexshape == :square
                sethue(fillcolor)
                box(coordinates[vertex], vertexshapesize, vertexshapesize, :fill)
                sethue(strokecolor)
                box(coordinates[vertex], vertexshapesize, vertexshapesize, :stroke)
            else # default is a circle
                sethue(fillcolor)
                circle(coordinates[vertex], vertexshapesize, :fill)
                sethue(strokecolor)
                circle(coordinates[vertex], vertexshapesize, :stroke)
            end
        end
    end
end

function _drawvertexlabels(vertex, coordinates::Array{Point,1};
        vertexlabels=nothing,
        vertextextcolors=nothing,
        vertexlabelfontsizes=nothing,
        vertexlabelfontfaces=nothing)

    # decide whether to draw this vertex

    vertexlabel = nothing
    if isnothing(vertexlabels)
        # by default, no labels
    elseif vertexlabels isa Array
        if vertexlabels[mod1(vertex, end)] != :none
            vertexlabel = string(vertexlabels[mod1(vertex, end)])
        end
    elseif vertexlabels isa AbstractRange
        vertexlabel = string(vertexlabels[mod1(vertex, end)])
    elseif vertexlabels isa AbstractString
            vertexlabel = vertexlabels
    elseif vertexlabels == :none
        # er
    end

    # set font size
    font_size = 0
    if isnothing(vertexlabelfontsizes)
        # use default fontsize
        font_size = get_fontsize()
    elseif vertexlabelfontsizes isa Array
        if !isempty(vertexlabelfontsizes)
            if vertexlabelfontsizes[mod1(vertex, end)] != :none
                font_size = vertexlabelfontsizes[mod1(vertex, end)]
            end
        end
    elseif vertexlabelfontsizes isa AbstractRange
        font_size = vertexlabelfontsizes[mod1(vertex, end)]
    elseif vertexlabelfontsizes isa Real
        font_size = vertexlabelfontsizes[mod1(vertex, end)]
    elseif vertexlabelfontsizes == :none
    end

    # set font face
    font_face = ""
    if isnothing(vertexlabelfontfaces)
        # use default fontsize
    elseif vertexlabelfontfaces isa Array
        if !isempty(vertexlabelfontfaces)
            if vertexlabelfontfaces[mod1(vertex, end)] != :none
                font_face = vertexlabelfontfaces[mod1(vertex, end)]
            end
        end
    elseif vertexlabelfontfaces isa AbstractRange
        font_face = vertexlabelfontfaces[mod1(vertex, end)]
    elseif vertexlabelfontfaces isa String
        font_face = vertexlabelfontfaces
    elseif vertexlabelfontfaces == :none
    end

    # set the colors for all labels
    textcolor = Luxor.get_current_color()
    if isnothing(vertextextcolors)
        # default - use current color
    elseif vertextextcolors isa Array
        textcolor = vertextextcolors[mod1(vertex, end)]
    elseif vertextextcolors isa Colorant
        textcolor = vertextextcolors
    elseif vertextextcolors == :none
        textcolor = :none
    end

    # draw the label
    if !isnothing(vertexlabel)
        @layer begin
            pt = coordinates[vertex]
            sethue(textcolor)
            fontsize(font_size)
            fontface(font_face)
            label(vertexlabel, slope(O, pt), pt, offset=10)
        end
    end
end

function drawedge(from::Point, to::Point;
        graph::AbstractGraph,
        edgenumber::Int64,
        edgefunction=nothing,
        edgelabels=nothing,
        edgelines=nothing,
        edgecurvature=nothing,
        edgestrokecolors=nothing,
        edgelabeltextcolors=nothing,
        edgelabelfontsizes=nothing,
        edgelabelfontfaces=nothing,
        edgestrokeweights=nothing)

    # is completely specified by function?
    if edgefunction isa Function
        edgefunction(from, to)
    else
        _drawedgelines(from, to;
            edgenumber,
            edgelines,
            edgestrokecolors,
            edgestrokeweights,
            digraph=graph isa DiGraph,
            edgecurvature=edgecurvature)
        _drawedgelabels(from, to;
            edgenumber,
            edgelabels,
            edgelabeltextcolors,
            edgelabelfontsizes,
            edgelabelfontfaces)
    end
end

function drawvertex(vertex, coordinates::Array{Point,1};
        vertexfunction=nothing,
        vertexlabels=nothing,
        vertexshapes=nothing,
        vertexshapesizes=nothing,
        vertexstrokecolors=nothing,
        vertexstrokeweights=nothing,
        vertexfillcolors=nothing,
        vertextextcolors=nothing,
        vertexlabelfontsizes=nothing,
        vertexlabelfontfaces=nothing)

    # is completely specified by function?
    if vertexfunction isa Function
        vertexfunction(vertex, coordinates)
    else
        _drawvertexshapes(vertex, coordinates::Array{Point,1};
            vertexshapes,
            vertexshapesizes,
            vertexstrokecolors,
            vertexstrokeweights,
            vertexfillcolors)
        _drawvertexlabels(vertex, coordinates::Array{Point,1};
            vertexlabels,
            vertextextcolors,
            vertexlabelfontsizes,
            vertexlabelfontfaces
        )
    end
end

"""
Draw a graph `g` using coordinates in `layout` to fit in a
Luxor `boundingbox`.

## Keyword arguments

`g`
- the graph to be drawn

`boundingbox`
- the drawing fits in this BoundingBox

`layout`
- the layout method or coordinates to be used. Examples:
    layout = squaregrid
    layout = shell
    layout = vcat(
        between.(O + (-W/2, H), O + (W/2, H), range(0, 1, length=N)),
        between.(O + (-W/2, -H), O + (W/2, -H), range(0, 1, length=N)))
    layout = stress
    layout = (g) -> spectral(adjacency_matrix(g), dim=2)
    layout = spectrallayout
    layout = shell ∘ adjacency_matrix
    layout = (g) -> sfdp(g, Ptype=Float64, dim=2, tol=0.05, C=0.4, K=2)
    layout = Shell(nlist=[6:10,])

    Refer to the NetworkLayout.jl documentation for more.

`margin = 20`
- a margin added to the graph diagram before fitting to boundingbox

`vertexfunction`
- a function `vertexfunction(vertex, coordinates)` that
  completely specifies the appearance of every vertex. None
  of the other vertex- keyword arguments will be used. Exmple:

    vertexfunction = (v, c) -> ngon(c[v], 30, 6, 0, :fill)

`edgefunction`
- a function `edgefunction(from, to)` that
  completely specifies the appearance of every vertex. None
  of the other edge- keyword arguments are used.

`vertexlabels`
- the text labels for each vertex

`vertexshapes`
- the shape of each vertex; can be :circle :square

`vertexshapesizes`
- the size of each vertex shape for :circle :square...

`vertexstrokecolors`

`vertexstrokeweights`

`vertexfillcolors`

`vertextextcolors`

`vertexlabelfontsizes`

`vertexlabelfontfaces`

`edgelabels`

`edgelines`

`edgecurvature=0.0`

`edgestrokecolors`

`edgestrokeweights`

`edgelabeltextcolors`

"""
function drawgraph(g::AbstractGraph;
        boundingbox::BoundingBox=BoundingBox(),
        layout=nothing,
        margin::Real=20,
        vertexfunction=nothing,
        vertexlabels=nothing,
        vertexshapes=nothing,
        vertexshapesizes=nothing,
        vertexstrokecolors=nothing,
        vertexstrokeweights=nothing,
        vertexfillcolors=nothing,
        vertextextcolors=nothing,
        vertexlabelfontsizes=nothing,
        vertexlabelfontfaces=nothing,
        edgefunction=nothing,
        edgelabels=nothing,
        edgelines=nothing,
        edgecurvature=0.0,
        edgestrokecolors=nothing,
        edgestrokeweights=nothing,
        edgelabeltextcolors=nothing)

    # so, do we need some coordinates for the vertices?
    # do we have a layout function to call?
    if isnothing(layout)
        # no, make some random points up, a circle should do
        coordinates = [polar(min(boxwidth(boundingbox - margin), boxheight(boundingbox - margin)) / 2, θ) for θ in range(0, step=2π / nv(g), length=nv(g))]
    elseif layout isa Array{Point,1}
        coordinates = layout
    else
        # great, let's run layout function
        rawpts = layout(g)
        # convert to Luxor Points and resize to fit boundingbox
        coordinates = _normalize_layout_coordinates(rawpts, boundingbox, margin)
    end
    for (n, edge) in enumerate(edges(g))
        s, d = src(edge), dst(edge)
        drawedge(
            coordinates[s],
            coordinates[d],
            graph=g,
            edgefunction=edgefunction,
            edgelabels=edgelabels,
            edgenumber=n,
            edgelines=edgelines,
            edgecurvature=edgecurvature,
            edgestrokecolors=edgestrokecolors,
            edgestrokeweights=edgestrokeweights,
            edgelabeltextcolors=edgelabeltextcolors,
        )
    end
    for vertex in vertices(g)
        drawvertex(vertex, coordinates,
            vertexfunction=vertexfunction,
            vertexlabels=vertexlabels,
            vertexshapes=vertexshapes,
            vertexshapesizes=vertexshapesizes,
            vertexstrokecolors=vertexstrokecolors,
            vertexstrokeweights=vertexstrokeweights,
            vertexfillcolors=vertexfillcolors,
            vertextextcolors=vertextextcolors,
            vertexlabelfontsizes=vertexlabelfontsizes,
            vertexlabelfontfaces=vertexlabelfontfaces,
        )
    end
end

end
