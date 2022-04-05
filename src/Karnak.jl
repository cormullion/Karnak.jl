module Karnak

using Luxor, Graphs, Colors, NetworkLayout

export drawgraph

# notes

# use none for no fill, no stroke ?
# spectral layout must be 2D!
# how to specify default size of grid squares and circles
# font options?

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

function _drawedge(from, to;
        digraph=false,
        straight = true)
    @layer begin
        if digraph && straight
            # digraph and straight
            midpt = midpoint(from, to)
            circle(midpt, 5.5, :fill)
            arrow(midpt, between(midpt, to, 0.9),   )
            arrow(midpt, between(midpt, from, 0.9), )
        elseif digraph && !straight
            # digraph and curvey lines
            arrow(between(from, to, 0.1), between(from, to, 0.9), [10, 10])
        else
            # straight, no digraph
            line(from, to, :stroke)
        end
    end
end

function drawedge(from::Point, to::Point;
    graph::AbstractGraph=nothing,
    edgenumber=1,
    edgefunction=nothing,
    edgelabels=nothing,
    edgeshapes=nothing,
    edgestrokecolors=nothing,
    edgetextcolors=nothing,
    edgestrokeweights=nothing,
    )

    strokecolor = Luxor.get_current_color()
    textcolor = Luxor.get_current_color()

    # set edge text color

    if isnothing(edgetextcolors)
        # default - use current color
    elseif edgetextcolors isa Function
        @layer begin
            edgetextcolors(edge, coordinates)
        end
    elseif edgetextcolors isa Array
        textcolor = edgetextcolors[mod1(edge, end)]
    elseif edgetextcolors isa Colorant
        textcolor = edgetextcolors
    elseif edgetextcolors == :none
        textcolor = :none
    end

    # set edge stroke color

    if isnothing(edgestrokecolors)
        # default - use current color
    elseif edgestrokecolors isa Function
        @layer begin
            if strokecolor != :none
                sethue(strokecolor)
            end
            # function can override colors
            edgestrokecolors(edge, coordinates)
        end
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


    # is completely specified by function?

    if edgefunction isa Function
        if strokecolor != :none
            sethue(strokecolor)
        end
        # function can override
        edgefunction(from, to)
    end

    # edge labels

    if edgelabels isa Function
        @layer begin
            if textcolor != :none
                sethue(textcolor)
            end
            # function can override this color
            edgelabels(edgenumber, from, to)
        end
    elseif edgelabels isa Vector && !isempty(edgelabels) || edgelabels isa AbstractRange
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

    if edgeshapes isa Function
        @layer begin
            if strokecolor != :none
                sethue(strokecolor)
            end
            # function cen override stroke color
            edgeshapes(from, to)
        end
    elseif edgeshapes isa Vector
        @layer begin
            if strokecolor != :none
                sethue(strokecolor)
                edgeshapes(from, to)
            end
        end
    else
        # default, draw some edges
        @layer begin
            if strokecolor != :none
                sethue(strokecolor)
                _drawedge(from, to, digraph=graph isa DiGraph, straight=false)
            end
        end
    end

    # set the stroke weight
    # default to Luxor default

    if isnothing(edgestrokeweights)
        # by default, do nothing
    elseif edgestrokeweights isa Function
        edgestrokeweights(from, to)
    elseif edgestrokeweights isa Array
        if !isempty(edgestrokeweights)
            if edgestrokeweights[mod1(edgenumber, end)] != :none
                setline(edgestrokeweights[mod1(edgenumber, end)])
            end
        end
    elseif edgestrokeweights isa AbstractRange
        setline(edgestrokeweights[mod1(edgenumber, end)])
    elseif edgestrokeweights == :none
        # do nothing
    end


end

"""
"""
function drawvertex(vertex, coordinates;
    vertexfunction=nothing,
    vertexlabels=nothing,
    vertexshapes=nothing,
    vertexshapesizes=nothing,
    vertexstrokecolors=nothing,
    vertexstrokeweights=nothing,
    vertexfillcolors=nothing,
    vertextextcolors=nothing)

    pt = coordinates[vertex]

    strokecolor = Luxor.get_current_color()
    fillcolor = Luxor.get_current_color()
    textcolor = Luxor.get_current_color()

    # set the colors for all labels

    if isnothing(vertextextcolors)
        # default - use current color
    elseif vertextextcolors isa Function
        @layer begin
            vertextextcolors(vertex, coordinates)
        end
    elseif vertextextcolors isa Array
        textcolor = vertextextcolors[mod1(vertex, end)]
    elseif vertextextcolors isa Colorant
        textcolor = vertextextcolors
    elseif vertexttextcolors == :none
        textcolor = :none
    end

    # set the fill color

    if isnothing(vertexfillcolors)
        # default - use current color
    elseif vertexfillcolors isa Function
        @layer begin
            if strokecolor != :none
                sethue(strokecolor)
            end
            if fillcolor != :none
                sethue(fillcolor)
            end
            # this function can override those colors
            vertexfillcolors(vertex, coordinates)
        end
    elseif vertexfillcolors isa Array && !isempty(vertexfillcolors)
        if vertexfillcolors[mod1(vertex, end)] isa Colorant
            fillcolor = vertexfillcolors[mod1(vertex, end)]
        end
    elseif vertexfillcolors isa Colorant
        fillcolor = vertexfillcolors
    elseif vertexfillcolors == :none
        fillcolor = :none
    end

    # set the stroke color

    if isnothing(vertexstrokecolors)
        # default - use current color
    elseif vertexstrokecolors isa Function
        @layer begin
            if strokecolor != :none
                sethue(strokecolor)
            end
            if fillcolor != :none
                sethue(fillcolor)
            end
            vertexstrokecolors(vertex, coordinates)
        end
    elseif vertexstrokecolors isa Array && !isempty(vertexstrokecolors)
        if vertexstrokecolors[mod1(vertex, end)] isa Colorant
            strokecolor = vertexstrokecolors[mod1(vertex, end)]
        end
    elseif vertexstrokecolors isa Colorant
        strokecolor = vertexstrokecolors
    elseif vertexstrokecolors == :none
        strokecolor = :none
    end

    # set the stroke weight
    # default to Luxor default

    if isnothing(vertexstrokeweights)
        # by default, do nothing
    elseif vertexstrokeweights isa Function
        vertexstrokeweights(vertex, coordinates)
    elseif vertexstrokeweights isa Array
            if !isempty(vertexstrokeweights)
                if vertexstrokeweights[mod1(vertex, end)] != :none
                    setline(vertexstrokeweights[mod1(vertex, end)])
                end
            end
    elseif vertexstrokeweights isa AbstractRange
            setline(vertexstrokeweights[mod1(vertex, end)])
    elseif vertexstrokeweights == :none
        # do nothing
    end

    # set shape sizes
    if isnothing(vertexshapesizes)
        # by default, 10 units
        vertexshapesize = 10
    elseif vertexshapesizes isa Function
        vertexshapesizes(vertex, coordinates)
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

    # is completely specified by function?
    if vertexfunction isa Function
        vertexfunction(vertex, coordinates)
        return
    end

    # no, it's specified by individual argument/functions

    # draw the vertex shape

    if vertexshapes isa Function
        @layer begin
            if strokecolor != :none
                sethue(strokecolor)
            end
            if fillcolor != :none
                sethue(fillcolor)
            end
            # of course, this function could override these colors....
            vertexshapes(vertex, coordinates)
        end
    elseif vertexshapes isa Array
        # array of :circle :square
        @layer begin
            if vertexshapes[mod1(vertex, end)] == :square
                if strokecolor != :none
                    sethue(strokecolor)
                    box(pt, vertexshapesize, vertexshapesize, :stroke)
                end
                if fillcolor != :none
                    sethue(fillcolor)
                    box(pt, vertexshapesize, vertexshapesize, :fill)
                end
            elseif vertexshapes[mod1(vertex, end)] == :circle
                if strokecolor != :none
                    sethue(strokecolor)
                    circle(pt, vertexshapesize, :stroke)
                end
                if fillcolor != :none
                    sethue(fillcolor)
                    circle(pt, vertexshapesize, :fill)
                end
            end
        end
    elseif vertexshapes == :circle
        @layer begin
            if strokecolor != :none
                sethue(strokecolor)
                circle(pt, vertexshapesize, :stroke)
            end
            if fillcolor != :none
                sethue(fillcolor)
                circle(pt, vertexshapesize, :fill)
            end
        end
    elseif vertexshapes == :square
        @layer begin
            if strokecolor != :none
                sethue(strokecolor)
                box(pt, vertexshapesize, vertexshapesize, :stroke)
            end
            if fillcolor != :none
                sethue(fillcolor)
                box(pt, vertexshapesize, vertexshapesize, :fill)
            end
        end
    else
        # default vertex shape
        pt = coordinates[vertex]
        @layer begin
            if fillcolor != :none
                sethue(fillcolor)
                circle(pt, vertexshapesize, :fill)
            end
            if strokecolor != :none
                sethue(strokecolor)
                circle(pt, vertexshapesize, :stroke)
            end
        end
    end

    # draw vertex text labels
    if isnothing(vertexlabels)
        # by default, no labels
    elseif vertexlabels isa Function
        if textcolor != :none
            sethue(textcolor)
        end
        # of course, this function can override colors....
        vertexlabels(vertex, coordinates)
    elseif vertexlabels isa Array
        if textcolor != :none
            sethue(textcolor)
            if !isempty(vertexlabels)
                if vertexlabels[mod1(vertex, end)] != :none
                    label(string(vertexlabels[mod1(vertex, end)]), slope(O, pt), pt, offset=10)
                end
            end
        end
    elseif vertexlabels isa AbstractRange
        if textcolor != :none
            sethue(textcolor)
            label(string(vertexlabels[mod1(vertex, end)]), slope(O, pt), pt, offset=10)
        end
    elseif vertexlabels == :none
    end
end

"""
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
    edgefunction=nothing,
    edgelabels=nothing,
    edgeshapes=nothing,
    edgestrokecolors=nothing,
    edgestrokeweights=nothing,
)

    # so, do we need some coordinates for the vertices?
        # do we have a layout function to call?
        if isnothing(layout)
            # no, make some random points up, a circle should do
            coordinates = [polar(min(boxwidth(boundingbox - margin), boxheight(boundingbox - margin)) / 2, θ) for θ in range(0, step=2π / nv(g), length=nv(g))]
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
            edgeshapes=edgeshapes,
            edgestrokecolors=edgestrokecolors,
            edgestrokeweights=edgestrokeweights,
            )
    end
    for vertex in vertices(g)
        drawvertex(
            vertex,
            coordinates,
            vertexfunction=vertexfunction,
            vertexlabels=vertexlabels,
            vertexshapes=vertexshapes,
            vertexshapesizes=vertexshapesizes,
            vertexstrokecolors=vertexstrokecolors,
            vertexstrokeweights=vertexstrokeweights,
            vertexfillcolors=vertexfillcolors,
            vertextextcolors=vertextextcolors,
        )
    end
end

end
