using Documenter, Karnak

makedocs(
    # debug=true,
    modules = [Karnak],
    sitename = "Karnak",
    warnonly = true,
    format = Documenter.HTML(
        size_threshold = nothing,   
        prettyurls = get(ENV, "CI", nothing) == "true",
        assets = ["assets/karnak-docs.css"],
        collapselevel=3,
        ),
    pages    = [
        "Introduction to Karnak"  =>  "index.md",
        "Basic graphs"            =>  "basics.md",
        "Syntax"                  =>  "syntax.md",
        "Examples"                =>  "examples.md",
        "Reference" => [
            "Alphabetical function list"   =>  "reference/functionindex.md"
            "Function reference"           =>  "reference/api.md"
            ],
        ]
    )

deploydocs(
    repo = "github.com/cormullion/Karnak.jl.git",
    target = "build",
    forcepush = true
)
