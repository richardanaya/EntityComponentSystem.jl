push!(LOAD_PATH,"../src/")
using Documenter,ECS
makedocs(
modules = [ECS],
sitename="ECS.js")
