# ECS.jl

```julia
add "https://github.com/richardanaya/ECS.jl"
```

An entity component system written for Julia

```julia
using ECS

mutable struct Position <: ECSComponent
  x::Float32
  y::Float32
end

mutable struct Velocity <: ECSComponent
  x::Float32
  y::Float32
end

# Create a world for entities
world = World()

# Register memory storage for components
register!(world,Position)
register!(world,Velocity)

# Create entities
player = createentity!(world)
addcomponent!(world,player,Position(0,0))
addcomponent!(world,player,Velocity(1,2))

# Run systems on entities with specific sets of components
runsystem!(world,[Position,Velocity]) do entity,components
    # Components are given in order they are requested
    pos,vel = components
    # Modify components
    pos.x += vel.x
    pos.y += vel.y
end
```
