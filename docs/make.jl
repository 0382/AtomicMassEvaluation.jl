using Documenter
push!(LOAD_PATH, "../src")
using AtomicMassEvaluation

makedocs(
    modules = [AtomicMassEvaluation],
    sitename = "AtomicMassEvaluation.jl",
    clean = false,
    pages = [
        "Home" => "index.md"
    ]
)

deploydocs(
    repo = "github.com/0382/AtomicMassEvaluation.jl.git",
    target = "build/"
)