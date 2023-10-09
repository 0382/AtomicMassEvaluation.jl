using Documenter
push!(LOAD_PATH, "../src")
using AME

makedocs(
    modules = [AME],
    sitename = "AME.jl",
    clean = false,
    pages = [
        "Home" => "index.md"
    ]
)

deploydocs(
    repo = "github.com/0382/AME.jl.git",
    target = "build/"
)