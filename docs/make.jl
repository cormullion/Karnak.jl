using Documenter, Karnak

makedocs(
    modules = [Karnak],
    sitename = "Karnak",
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true",
        warn_outdated = true,
        collapselevel=1,
        ),
    pages    = [
        "Introduction to Karnak"  =>  "index.md",
        "Basic graphs"            =>  "basics.md",
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