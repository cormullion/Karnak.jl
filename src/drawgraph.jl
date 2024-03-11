# This code is odd; it's mostly `if` statements and `nothing`s...
# Perhaps I should rewrite it, but it did what I needed it to do, so
# that's not a high priority...

const defaultshaperadius = 6

function _normalize_layout_coordinates(rawcoordinates, boundingbox, margin)
    # convert NetworkLayout coordinates to fit inside Luxor BB
    if length(rawcoordinates[1]) == 3
        @warn "3D coordinates returned by layout function"
    end

    # looks like networklayout uses y at top increasing downwards convention
    bb = BoundingBox(map(p -> Point(p[1], -p[2]), rawcoordinates))
    BB = boundingbox - margin
    offset = boxmiddlecenter(BB) - boxmiddlecenter(bb)

    W = boxwidth(BB)
    H = boxheight(BB)
    w = boxwidth(bb)
    h = boxheight(bb)
    if W / w < H / h
        sf = W / w
    else
        sf = H / h
    end
    return [(sf * offset) + (sf * (Point(first(p), -last(p)))) for p in rawcoordinates]
end

# TODO refactor

function _drawedgelines(from, to, edgesrc, edgedest;
    edgenumber = 1,
    edgelines = nothing,
    edgestrokecolors = nothing,
    edgestrokeweights = nothing,
    edgedashpatterns = nothing,
    edgegaps = nothing,
    edgecurvature = 0.0,
    digraph = false)

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
    elseif edgelines isa Integer
        if edgenumber == edgelines
            edgeline = true
        end
    elseif edgelines == :none
        #
    elseif edgelines isa Function
        edgeline = edgelines
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
    elseif edgestrokecolors isa Function
        strokecolor = edgestrokecolors(edgenumber, edgesrc, edgedest, from, to)
        !(strokecolor isa Colorant) && throw(error("edgestrokecolors should return a color"))
    elseif edgestrokecolors == :none
        strokecolor = :none
    end

    # set the stroke weight
   currentdrawing().surfacetype == :png ? linewidth = 2 : linewidth = 1

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
    elseif edgestrokeweights isa Function
        linewidth = edgestrokeweights(edgenumber, edgesrc, edgedest, from, to)
    elseif edgestrokeweights == :none
        # do nothing
    end

    # set the dash pattern

    dashpattern = Float64[]
    if isnothing(edgedashpatterns)
        # by default, do nothing
    elseif all(a -> a isa Vector, edgedashpatterns)
        # choose the appropriate dash pattern
        dashpattern = edgedashpatterns[mod1(edgenumber, end)]
    elseif edgedashpatterns isa Array
        dashpattern = edgedashpatterns
    elseif edgedashpatterns == :none
        # do nothing
    end

    # set the edgegap: gap between arrow tip and vertex center
    # should default to 0 if no arrows/curvature
    # or defaultshaperadius for arrows

    edgegap = :none

    if edgegaps isa Vector
        edgegap = edgegaps[mod1(edgenumber, end)]
    elseif edgegaps isa AbstractRange
        edgegap = edgegaps[mod1(edgenumber, end)]
    elseif edgegaps isa Function 
        edgegap = edgegaps(edgenumber, edgesrc, edgedest, from, to)
    elseif edgegaps isa Real
        edgegap = edgegaps
    end

    # finally time to draw the edge
    # edgeline = nothing | true | function

    if edgeline == false || edgeline == nothing
        return
    end

    @layer begin
        setline(linewidth)
        if strokecolor isa Function
            strokecolor(edgenumber, edgesrc, edgedest, from, to)
        else
            setcolor(strokecolor)
        end

        if !isempty(dashpattern)
            setdash(dashpattern)
        end

        if edgeline isa Function
            edgeline(edgenumber, edgesrc, edgedest, from, to)
        else
            d = distance(from, to)
            if isapprox(from, to)
                # self loop, draw arrow in circle
                @layer begin
                    defaultshaperadius
                    s = slope(O, from)
                    #TODO better default circle size
                    selfloopradius = 5defaultshaperadius
                    loopcenter = from + polar(selfloopradius, s)
                    translate(loopcenter)
                    rotate(π + s)
                    arrow(
                        O,
                        selfloopradius,
                        0,
                        2π - π / 16,
                        linewidth = linewidth,
                        arrowheadlength = rescale(linewidth, 1, 10, 12, 25),
                    )
                    arrow(
                        O,
                        selfloopradius,
                        0,
                        2π - π / 16,
                        linewidth = linewidth,
                        arrowheadlength = rescale(linewidth, 1, 10, 12, 25),
                    )
                end
                # digraph
            elseif digraph == true
                if abs(edgecurvature) > 0.0
                    # digraph _and_ curvey edges
                    # use default shape radius to allow for arrows, unless otherwise specified
                    if edgegap == :none
                        edgegap = defaultshaperadius
                    end
                    normalizedgap = edgegap / d
                    arrow(between(from, to, normalizedgap),
                        linewidth = linewidth,
                        between(from, to, 1 - normalizedgap),
                        [edgecurvature, edgecurvature],
                        startarrow = false,
                        finisharrow = true, :stroke, arrowheadlength = rescale(linewidth, 1, 10, 12, 25))
                else
                    # digraph, straight edges
                    # default gap is at least the radius of default shape
                    # use default shape radius to allow for arrows, unless otherwise specified
                    if edgegap == :none
                        edgegap = defaultshaperadius
                    end
                    normalizedgap = edgegap / d
                    arrow(between(from, to, normalizedgap),
                        between(from, to, 1 - normalizedgap),
                        [0, 0],
                        startarrow = false,
                        finisharrow = true, :stroke, linewidth = linewidth,
                        arrowheadlength = rescale(linewidth, 1, 10, 12, 25))
                end
                # graph
            elseif digraph == false
                if edgegap == :none
                    normalizedgap = 0
                elseif isapprox(edgegap, 0.0)
                    normalizedgap = 0
                else
                    normalizedgap = edgegap / d
                end
                # not digraph
                if abs(edgecurvature) > 0.0
                    arrow(between(from, to, normalizedgap),
                        between(from, to, 1 - normalizedgap),
                        [edgecurvature, edgecurvature],
                        startarrow = true,
                        finisharrow = true, :stroke, linewidth = linewidth,
                        arrowheadlength = arrowheadlength = rescale(linewidth, 1, 10, 12, 25))
                else
                    line(between(from, to, normalizedgap), between(from, to, 1 - normalizedgap), :stroke)
                end
            end
        end
    end
end

function _drawedgelabels(from, to;
    edgenumber = 1,
    edgesrc = 1,
    edgedest = nothing,
    digraph = false,
    straight = true,
    edgelabels = nothing,
    edgelabelcolors = nothing,
    edgelabelrotations = nothing,
    edgelabelfontsizes = nothing,
    edgelabelfontfaces = nothing)

    # edge labels

    textcolor = Luxor.get_current_color()

    # set edge text color

    if isnothing(edgelabelcolors)
        # default - use current color
    elseif edgelabelcolors isa Array
        textcolor = edgelabelcolors[mod1(edgenumber, end)]
    elseif edgelabelcolors isa Colorant
        textcolor = edgelabelcolors
    elseif edgelabelcolors == :none
        textcolor = :none
    end

    # set text rotation

    textrotation = 0

    if isnothing(edgelabelrotations)
        # by default, do nothing
    elseif edgelabelrotations isa Array
        if !isempty(edgelabelrotations)
            if edgelabelrotations[mod1(edgenumber, end)] != :none
                textrotation = edgelabelrotations[mod1(edgenumber, end)]
            end
        end
    elseif edgelabelrotations isa AbstractRange
        textrotation = edgelabelrotations[mod1(edgenumber, end)]
    elseif edgelabelrotations isa Real
        textrotation = edgelabelrotations
    elseif edgelabelrotations isa Function
        textrotation = edgelabelrotations(edgenumber, edgesrc, edgedest, from, to)
    elseif edgelabelrotations == :none
        # do nothing
    end

    # fonts for labels

    # set font size
    font_size = 0
    if isnothing(edgelabelfontsizes)
        # use default fontsize
        font_size = get_fontsize()
    elseif edgelabelfontsizes isa Array
        if !isempty(edgelabelfontsizes)
            if edgelabelfontsizes[mod1(edgenumber, end)] != :none
                font_size = edgelabelfontsizes[mod1(edgenumber, end)]
            end
        end
    elseif edgelabelfontsizes isa AbstractRange
        font_size = edgelabelfontsizes[mod1(edgenumber, end)]
    elseif edgelabelfontsizes isa Real
        font_size = edgelabelfontsizes[mod1(edgenumber, end)]
    elseif edgelabelfontsizes == :none
    end

    # set font face
    font_face = ""
    usedefaultfont = true
    if isnothing(edgelabelfontfaces)
        # use default fontface
    elseif edgelabelfontfaces isa Array
        if !isempty(edgelabelfontfaces)
            if edgelabelfontfaces[mod1(edgenumber, end)] != :none
                font_face = edgelabelfontfaces[mod1(edgenumber, end)]
                usedefaultfont = false
            end
        end
    elseif edgelabelfontfaces isa AbstractRange
        font_face = edgelabelfontfaces[mod1(edgenumber, end)]
        usedefaultfont = false
    elseif edgelabelfontfaces isa AbstractString
        font_face = edgelabelfontfaces
        usedefaultfont = false
    elseif edgelabelfontfaces == :none
    end

    # TODO refactor!!

    # finally draw label text with textcolor and rotations
    if (edgelabels isa Vector && !isempty(edgelabels)) || edgelabels isa AbstractRange
        @layer begin
            if edgelabels[mod1(edgenumber, end)] == :none
            else
                str = string(collect(edgelabels)[mod1(edgenumber, end)])
                if textcolor != :none
                    setcolor(textcolor)
                    if !usedefaultfont
                        font_face != "" && fontface(font_face)
                    end
                    fontsize(font_size)
                    text(str, midpoint(from, to), halign = :center, angle = textrotation)
                end
            end
        end
    elseif edgelabels isa Function
        @layer begin
            if !usedefaultfont
                font_face != "" && fontface(font_face)
            end
            fontsize(font_size)
            edgelabels(edgenumber, edgesrc, edgedest, from, to)
        end
    elseif edgelabels isa Dict
        # edgelabels can be dict with (src, dst) => "labeltext"
        if haskey(edgelabels, (edgesrc, edgedest))
            edgelabel = string(edgelabels[(edgesrc, edgedest)])
            # TODO don't repeat this code!!!
            @layer begin
                if textcolor != :none
                    setcolor(textcolor)
                    if !usedefaultfont
                        font_face != "" && fontface(font_face)
                    end
                    fontsize(font_size)
                    text(edgelabel, midpoint(from, to), halign = :center, angle = textrotation)
                end
            end
        end
    elseif edgelabels == :none

    elseif isnothing(edgelabels)
        # default is do nothing
    end
end

function _drawvertexshapes(vertex, coordinates::Array{Point,1};
    vertexshapes = nothing,
    vertexshapesizes = nothing,
    vertexfillcolors = nothing,
    vertexstrokecolors = nothing,
    vertexstrokeweights = nothing,
    vertexshaperotations = nothing)

    # decide whether or not to draw a shape at this vertex

    # set rotation angle
    vertexshaperotation = 0
    if isnothing(vertexshaperotations)
        # by default, do nothing
    elseif vertexshaperotations isa Array
        if !isempty(vertexshaperotations)
            if vertexshaperotations[mod1(vertex, end)] != :none
                vertexshaperotation = vertexshaperotations[mod1(vertex, end)]
            end
        end
    elseif vertexshaperotations isa AbstractRange
        vertexshaperotation = vertexshaperotations[mod1(vertex, end)]
    elseif vertexshaperotations isa Real
        vertexshaperotation = vertexshaperotations
    elseif vertexshaperotations isa Function
        vertexshaperotation = vertexshaperotations
    elseif vertexshaperotations == :none
        # do nothing
    end

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
        @layer begin
            # a vertexshapes function is vertexshape(vertex) ->
            vertexshape = vertexshapes
        end
    elseif vertexshapes isa AbstractRange
        if vertex in vertexshapes
            vertexshape = true
        end
    elseif vertexshapes == :circle
        vertexshape = :circle
    elseif vertexshapes == :square
        vertexshape = :square
    elseif vertexshapes == :none
        vertexshape = :none
    elseif vertexshapes isa Integer
        if vertexshapes == vertex
            vertexshape = true
        end
    end

    if vertexshape == :none
        return
    end

    # so now we can draw at this vertex

    # vertexshape is hopefully one of true, square, circle, or can be a function

    # work out fill and stroke colors

    previouscolor = Luxor.get_current_color()
    fillcolorfunction = nothing
    strokecolorfunction = nothing

    # set the fill color
    # if :none, don't draw it (will override other specs)

    fillcolor = :none

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
    elseif vertexfillcolors isa Function
        # a vertexfillcolors function is vertexfillcolors(vertex) ->
        fillcolorfunction = vertexfillcolors
    else
        fillcolor = Luxor.get_current_color()
    end

    # set the stroke color
    strokecolor = :none

    if isnothing(vertexstrokecolors)
        # default - get current color
        strokecolor = Luxor.get_current_color()
    elseif vertexstrokecolors isa Array && !isempty(vertexstrokecolors)
        if vertexstrokecolors[mod1(vertex, end)] isa Colorant
            strokecolor = vertexstrokecolors[mod1(vertex, end)]
        end
    elseif vertexstrokecolors isa Colorant
        strokecolor = vertexstrokecolors
    elseif vertexstrokecolors isa Function
        # a vertexstrokecolors function is vertexstrokecolors(vertex) ->
        @layer begin
            strokecolorfunction = vertexstrokecolors
        end
    elseif vertexstrokecolors == :none
        strokecolor = :none
    else
        strokecolor = Luxor.get_current_color()
    end

    # set the stroke weight
   currentdrawing().surfacetype == :png ? linewidth = 2 : linewidth = 1

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
    elseif vertexstrokeweights isa Real
        linewidth = vertexstrokeweights
    elseif vertexstrokeweights isa Function
        linewidth = vertexstrokeweights(vertex)
    elseif vertexstrokeweights == :none
        # do nothing
    end

    # set shape sizes
    # vertexshape size is "radius" rather than "diameter"
    vertexshapesize = 0
    if isnothing(vertexshapesizes)
        # default
        vertexshapesize = defaultshaperadius
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
    elseif vertexshapesizes isa Function
        vertexshapesize = vertexshapesizes
    elseif vertexshapesizes == :none
        vertexshapesize = 0.0
    end

    # finally, do some drawing
    # vertexshape is one of true, square, circle, function

    @layer begin
        if fillcolorfunction isa Function
            # a vertexfillcolors function is f(vertex) ->
            fillcolor = fillcolorfunction(vertex)
        end

        if strokecolorfunction isa Function
            # a vertexstrokecolors function is f(vertex) ->
            strokecolor = strokecolorfunction(vertex)
        end

        translate(coordinates[vertex])
        if vertexshaperotation isa Function
            rotate(vertexshaperotation(vertex))
        else
            rotate(vertexshaperotation)
        end
        setline(linewidth)

        if vertexshapesize isa Function
            s = vertexshapesize(vertex)
        elseif iszero(vertexshapesize)
            s = 0.0
        else
            s = vertexshapesize
        end
        if vertexshape isa Function
            # TODO fill color or stroke color priority?
            @layer begin
                strokecolor isa Colorant && setcolor(strokecolor)
                fillcolor isa Colorant && setcolor(fillcolor)
                vertexshape(vertex)
            end
        elseif vertexshape == :square
            fillcolor isa Colorant && setcolor(fillcolor)
            box(O, 2s, 2s, :fill)
            strokecolor isa Colorant && setcolor(strokecolor)
            box(O, 2s, 2s, :stroke)

        else # default is a circle
            fillcolor isa Colorant && setcolor(fillcolor)
            circle(O, s, :fill)
            strokecolor isa Colorant && setcolor(strokecolor)
            circle(O, s, :stroke)
        end
    end
end

function _drawvertexlabels(vertex, coordinates::Array{Point,1};
    vertexlabels = nothing,
    vertexlabeltextcolors = nothing,
    vertexlabelfontsizes = nothing,
    vertexlabelfontfaces = nothing,
    vertexlabelrotations = nothing,
    vertexlabeloffsetangles = nothing,
    vertexlabeloffsetdistances = nothing)

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
    elseif vertexlabels isa Function
        # function to choose vertex, but
        # should return a string
        @layer begin
            vertexlabel = vertexlabels(vertex)
        end
    elseif vertexlabels == :none
        # er...
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
    elseif vertexlabelfontsizes isa Function
        font_size = vertexlabelfontsizes(vertex, coordinates)
    elseif vertexlabelfontsizes == :none
    end

    # set font face
    font_face = ""
    usedefaultfont = true
    if isnothing(vertexlabelfontfaces)
        # use default fontsize
    elseif vertexlabelfontfaces isa Array
        if !isempty(vertexlabelfontfaces)
            if vertexlabelfontfaces[mod1(vertex, end)] != :none
                font_face = vertexlabelfontfaces[mod1(vertex, end)]
                usedefaultfont = false
            end
        end
    elseif vertexlabelfontfaces isa AbstractRange
        font_face = vertexlabelfontfaces[mod1(vertex, end)]
        usedefaultfont = false
    elseif vertexlabelfontfaces isa AbstractString
        font_face = vertexlabelfontfaces
        usedefaultfont = false
    elseif vertexlabelfontfaces == :none
    end

    # set the colors for all labels
    # default to inverse of current color

    gamma = 2.2
    r, g, b, alpha = getfield.(Luxor.get_current_color(), (:r, :g, :b, :alpha))
    luminance = 0.2126 * r^gamma + 0.7152 * g^gamma + 0.0722 * b^gamma
    (luminance > 0.5^gamma) ? textcolor = colorant"black" : textcolor = colorant"white"

    # textcolor = Luxor.get_current_color()

    if isnothing(vertexlabeltextcolors)
        # default
    elseif vertexlabeltextcolors isa Array
        textcolor = vertexlabeltextcolors[mod1(vertex, end)]
    elseif vertexlabeltextcolors isa Colorant
        textcolor = vertexlabeltextcolors
    elseif vertexlabeltextcolors isa Function
        textcolor = vertexlabeltextcolors(vertex)
    elseif vertexlabeltextcolors == :none
        textcolor = :none
    end

    # set rotation angle

    textrotation = 0
    if isnothing(vertexlabelrotations)
        # by default, do nothing
    elseif vertexlabelrotations isa Array
        if !isempty(vertexlabelrotations)
            if vertexlabelrotations[mod1(vertex, end)] != :none
                textrotation = vertexlabelrotations[mod1(vertex, end)]
            end
        end
    elseif vertexlabelrotations isa AbstractRange
        textrotation = vertexlabelrotations[mod1(vertex, end)]
    elseif vertexlabelrotations isa Real
        textrotation = vertexlabelrotations
    elseif vertexlabelrotations == :none
        # do nothing
    end

    # set label offsets
    # set label offset angles

    textoffsetangle = 0
    if isnothing(vertexlabeloffsetangles)
        # by default, 0 is ok
    elseif vertexlabeloffsetangles isa Array
        if !isempty(vertexlabeloffsetangles)
            if vertexlabeloffsetangles[mod1(vertex, end)] != :none
                textoffsetangle = vertexlabeloffsetangles[mod1(vertex, end)]
            end
        end
    elseif vertexlabeloffsetangles isa AbstractRange
        textoffsetangle = vertexlabeloffsetangles[mod1(vertex, end)]
    elseif vertexlabeloffsetangles isa Real
        textoffsetangle = vertexlabeloffsetangles
    end

    # set label offset distances

    textoffsetdistance = 0
    if isnothing(vertexlabeloffsetdistances)
        # by default, 0 is ok
    elseif vertexlabeloffsetdistances isa Array
        if !isempty(vertexlabeloffsetdistances)
            if vertexlabeloffsetdistances[mod1(vertex, end)] != :none
                textoffsetdistance = vertexlabeloffsetdistances[mod1(vertex, end)]
            end
        end
    elseif vertexlabeloffsetdistances isa AbstractRange
        textoffsetdistance = vertexlabeloffsetdistances[mod1(vertex, end)]
    elseif vertexlabeloffsetdistances isa Real
        textoffsetdistance = vertexlabeloffsetdistances
    end

    # draw the label

    if vertexlabel isa AbstractString # && !isnothing(vertexlabel)
        @layer begin
            pt = coordinates[vertex]
            translate(pt)
            rotate(textrotation)
            setcolor(textcolor)
            fontsize(font_size)
            if !usedefaultfont
                font_face != "" && fontface(font_face)
            end
            text(vertexlabel, halign = :center, valign = :middle, O + polar(textoffsetdistance, textoffsetangle))
        end
    end
end

function drawedge(from::Point, to::Point;
    graph::AbstractGraph,
    edgenumber::Integer,
    edgesrc::Integer,
    edgedest::Integer,
    edgefunction = nothing,
    edgelabels = nothing,
    edgelines = nothing,
    edgedashpatterns = nothing,
    edgegaps = nothing,
    edgecurvature = nothing,
    edgestrokecolors = nothing,
    edgelabelcolors = nothing,
    edgelabelfontsizes = nothing,
    edgelabelfontfaces = nothing,
    edgestrokeweights = nothing,
    edgelabelrotations = nothing)

    # is completely specified by function?
    if edgefunction isa Function
        @layer begin
            edgefunction(edgenumber, edgesrc, edgedest, from, to)
        end
    else
        _drawedgelines(from, to, edgesrc, edgedest;
            edgenumber,
            edgelines,
            edgestrokecolors,
            edgestrokeweights,
            edgedashpatterns,
            edgegaps,
            digraph = is_directed(graph),
            edgecurvature = edgecurvature)
        _drawedgelabels(from, to;
            edgenumber,
            edgesrc,
            edgedest,
            edgelabels,
            edgelabelcolors,
            edgelabelfontsizes,
            edgelabelfontfaces,
            edgelabelrotations)
    end
end

function drawvertex(vertex, coordinates::Array{Point,1};
    vertexfunction = nothing,
    vertexlabels = nothing,
    vertexshapes = nothing,
    vertexshapesizes = nothing,
    vertexshaperotations = nothing,
    vertexstrokecolors = nothing,
    vertexstrokeweights = nothing,
    vertexfillcolors = nothing,
    vertexlabeltextcolors = nothing,
    vertexlabelfontsizes = nothing,
    vertexlabelfontfaces = nothing,
    vertexlabelrotations = nothing,
    vertexlabeloffsetangles = nothing,
    vertexlabeloffsetdistances = nothing)

    # is completely specified by function?
    if vertexfunction isa Function
        @layer begin
            vertexfunction(vertex, coordinates)
        end
    else
        _drawvertexshapes(vertex, coordinates::Array{Point,1};
            vertexshapes,
            vertexshapesizes,
            vertexshaperotations,
            vertexstrokecolors,
            vertexstrokeweights,
            vertexfillcolors)
        _drawvertexlabels(vertex, coordinates::Array{Point,1};
            vertexlabels,
            vertexlabeltextcolors,
            vertexlabelfontsizes,
            vertexlabelfontfaces,
            vertexlabelrotations,
            vertexlabeloffsetangles,
            vertexlabeloffsetdistances,
        )
    end
end
"""
Draw a graph `g` using coordinates in `layout` to fit in a
Luxor `boundingbox` (defaulting to the current drawing's extent).

Returns a vector of Points, the location of the graph vertices as drawn.

## Keyword arguments

```
boundingbox::BoundingBox        graph fits inside this BB
layout                          Point[] or function
margin                          default 30
edgelist                        draw only these edges

vertexfunction(vtx, coords) ->  draw vertices
edgefunction(edgenumber, edgesrc, edgedest, from, to) -> draw edges
```

`layout`

  - the layout method or coordinates to be used. Examples:

```
layout = squaregrid

layout = shell

layout = vcat(
    [between(O + (-W / 2, -H / 2), O + (-W / 2, H / 2), i) for i in range(0, 1, length=N)], # left
    [between(O + (W / 2, H / 2), O + (W / 2, -H / 2), i) for i in range(0, 1, length=N)] # right
    )

layout = stress

layout = (g) -> spectral(adjacency_matrix(g), dim=2)

layout = shell ∘ adjacency_matrix

layout = (g) -> sfdp(g, Ptype=Float64, dim=2, tol=0.05, C=0.4, K=2)

layout = Shell(nlist=[6:10,]) # inner shell for vertices 6 to 10

layout = squaregrid

the_positions = [(pt.x, pt.y) for pt in randompointarray(BoundingBox(), 50)[1:nv(G)]]
the_weights = rand(1:20, nv(G), nv(G))
layout=Stress(initialpos = the_positions,
    iterations = 30,
    weights = the_weights)

layout = Stress(iterations = 100, weights = M) # M is matrix of weights

layout = Spring(iterations = 200, initialtemp = 2.5)
```

Refer to the NetworkLayout.jl documentation for more.

# Extended help

All keywords:

```plain
 boundingbox                 BoundingBox                                              
 margin                      Number                                                   
 layout                      Vector{Point}                                            
                             function from NetworkLayout.jl                           
                             f(g::Graph)                                              
 edgefunction                f(edgenumber::Int, edgesrc::Int, edgedest::Int, from::Point)
 vertexfunction              f(vtx::Int, coordinates::Vector{Point})                  
 edgecurvature               Float64                                                  
 edgedashpatterns            Vector{Vector}[number]                                   
                             Vector{Number}                                           
 edgegaps                    Vector                                                   
                             Range                                                    
                             Real
                             f(edgenumber::Int, edgesrc::Int, edgedest::Int, from::Point)                                                     
 edgelabelcolors             Vector{Colorant}                                         
                             Colorant                                                 
 edgelabelfontfaces          Vector{Strings}[edgenumber]                              
                             String                                                   
                             :none                                                    
 edgelabelfontsizes          Vector{Number}                                           
                             Number                                                   
 edgelabelrotations          Vector{angles}                                           
                             angle::Float64                                           
                             f(edgenumber, edges, edgedest, from, to)                 
 edgelabels                  Vector                                                   
                             range                                                    
                             Dict{Int, Int}                                           
                             f(edgenumber, edgesrc, edgedest, from::Point, to::Point)
                               - this function must draw the required text 
                             :none                                                    
 edgelines                   Vector{Int}                                              
                             range                                                    
                             Int                                                      
                             f(edgenumber, edgesrc, edgedest, from::Point, to::Point) 
 edgelist                    Graphs.EdgeIterator                                      
 edgestrokecolors            Vector{Colorant}[edge::Int]                              
                             Colorant                                                 
                             f(edgenumber, edgesrc, edgedest, from::Point, to::Point) 
 edgestrokeweights           Vector{Number}[vtx]                                      
                             range                                                    
                             Real                                                     
                             f(edgenumber, edgesrc, edgedest, from::Point, to::Point) 
 vertexfillcolors            Vector{Colorant}                                         
                             Colorant                                                 
                             :none                                                    
                             f(vtx::Int)                                              
 vertexlabelfontfaces        Vector{Strings}                                          
                             String                                                   
 vertexlabelfontsizes        Vector                                                   
                             range                                                    
                             Real                                                     
                             :none
                             f(vtx::Int, coord::Point[])
                              - function must return a numeric value for fontsize
 vertexlabeloffsetangles     Vector                                                   
                             Range                                                    
                             Real                                                     
 vertexlabeloffsetdistances  Vector                                                   
                             range                                                    
                             Real                                                     
 vertexlabelrotations        Vector                                                   
                             range                                                    
                             Real                                                     
                             :none                                                    
 vertexlabels                Vector{String}                                           
                             String                                                   
                             range[vtx::Int]                                          
                             :none                                                    
                             f(vtx::Int)
                             - this function must return a string                                              
 vertexlabeltextcolors       Vector{Colorant}                                         
                             Colorant
                             f(vtx::Int)                                                 
                             :none                                                    
 vertexshaperotations        f(vtx::Int)                                              
                             angle::Float64                                           
 vertexshapes                Vector of :circle :square :none                          
                             range[vtx]                                               
                             :circle :square :none                                    
                             f(vtx::Int)                                              
 vertexshapesizes            Vector{Real}                                             
                             range                                                    
                             Real                                                     
                             :none                                                    
                             f(vtx::Int)                                              
 vertexstrokecolors          Vector                                                   
                             Colorant                                                 
                             :none                                                    
                             f(vtx::Int)                                              
 vertexstrokeweights         Vector                                                   
                             range                                                    
                             :none                                                    
                             f(vtx::Int)                                              
```
"""
function drawgraph(g::AbstractGraph;
    boundingbox::BoundingBox = BoundingBox(),
    layout = nothing,
    margin::Real = 30,
    vertexfunction = nothing,
    vertexlabels = nothing,
    vertexshapes = nothing,
    vertexshapesizes = nothing,
    vertexshaperotations = nothing,
    vertexstrokecolors = nothing,
    vertexstrokeweights = nothing,
    vertexfillcolors = nothing,
    vertexlabeltextcolors = nothing,
    vertexlabelfontsizes = nothing,
    vertexlabelfontfaces = nothing,
    vertexlabelrotations = nothing,
    vertexlabeloffsetangles = nothing,
    vertexlabeloffsetdistances = nothing,
    edgelist = nothing,
    edgefunction = nothing,
    edgelabels = nothing,
    edgelines = nothing,
    edgecurvature = 0.0,
    edgestrokecolors = nothing,
    edgelabelcolors = nothing,
    edgelabelfontsizes = nothing,
    edgelabelfontfaces = nothing,
    edgestrokeweights = nothing,
    edgedashpatterns = nothing,
    edgegaps = nothing,
    edgelabelrotations = nothing)

    # so, do we need some coordinates for the vertices?
    # do we have a layout function to call?
    if isnothing(layout)
        # no, make some random points up, a circle should do
        coordinates = [
            polar(min(boxwidth(boundingbox - margin), boxheight(boundingbox - margin)) / 2, θ) for
            θ in range(0, step = 2π / nv(g), length = nv(g))
        ]
    elseif layout isa Array{Point,1}
        coordinates = layout
    else
        # great, let's run layout function
        rawpts = layout(g)
        # convert to Luxor Points and resize to fit boundingbox
        coordinates = _normalize_layout_coordinates(rawpts, boundingbox, margin)
    end

    if !isnothing(edgelist)
        # only some edges to be drawn
        edgestodraw = edgelist
    else
        # potentially all edges of graph
        edgestodraw = Graphs.edges(g)
    end

    for (n, edge) in enumerate(edgestodraw)
        s, d = src(edge), dst(edge)
        @layer begin
            drawedge(
                coordinates[s],
                coordinates[d];
                graph = g,
                edgenumber = n,
                edgesrc = s,
                edgedest = d,
                edgefunction,
                edgelabels,
                edgelines,
                edgedashpatterns,
                edgegaps,
                edgecurvature,
                edgestrokecolors,
                edgelabelcolors,
                edgelabelfontsizes,
                edgelabelfontfaces,
                edgestrokeweights,
                edgelabelrotations,
            )
        end
    end
    for vertex in vertices(g)
        @layer begin
            drawvertex(vertex, coordinates;
                vertexfunction,
                vertexlabels,
                vertexshapes,
                vertexshapesizes,
                vertexshaperotations,
                vertexstrokecolors,
                vertexstrokeweights,
                vertexfillcolors,
                vertexlabeltextcolors,
                vertexlabelfontsizes,
                vertexlabelfontfaces,
                vertexlabelrotations,
                vertexlabeloffsetangles,
                vertexlabeloffsetdistances,
            )
        end
    end

    return coordinates
end
