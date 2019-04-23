# ECS.jl

An entity component system written for Julia

```julia
mutable struct Position <: ECS.Component
  x::Float32
  y::Float32
end

mutable struct Velocity <: ECS.Component
  x::Float32
  y::Float32
end

# Create a world for entities
world = ECS.create()

# Register memory storage for components
ECS.register(world,Position)
ECS.register(world,Velocity)

# Create entities
player = ECS.createentity!(world)
ECS.addcomponent!(world,player,Position(0,0))
ECS.addcomponent!(world,player,Velocity(1,2))

# Run systems on entities with specific sets of components
ECS.runsystem!(world,[Position,Velocity]) do entity,components 
    # Components are given in order they are requested
    pos,vel = components
    # Modify components
    pos.x += vel.x
    pos.y += vel.y
end
```
