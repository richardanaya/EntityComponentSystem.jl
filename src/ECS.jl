module ECS

"""
    ECSComponent
    
A representation of an entity component system component.
"""
abstract type ECSComponent end

"""
    World

A collection of entities and their components.
"""
mutable struct World
    entity_generation::Array{Union{Int64,Nothing}}
    max_entity::Int64
    free_entities::Array{Int64,1}
    components::Dict{DataType,Any}
end

struct EntityKey
    index::Int64
    generation::Int64
end

function World()
    World(Array{Union{Int64,Nothing}}(undef,100),0,[],Dict())
end

"""
    getentity(world::World,key::EntityKey)

Returns double the number `x` plus `1`.
"""
function getentity(world::World,key::EntityKey)
    current_generation = world.entity_generation[key.index]
    if current_generation == nothing || current_generation != key.generation
        return nothing
    end
    key.index
end

function register!(world::World,::Type{C}) where C <: ECSComponent
    world.components[C] = Array{Union{C,Nothing}}(undef,1000)
    nothing
end

function destroyentity!(world::World,entity::EntityKey)
    if getentity(world,entity) == nothing
        println("tried to destroy non existant entity")
        return
    end
    for x in keys(world.components)
        world.components[x][entity.index] = nothing
    end
    push!(world.free_entities,entity.index)
    # makes sure entity cant be retrieved again
    world.entity_generation[entity.index] += 1
    nothing
end

function createentity!(world::World)
    i = if length(world.free_entities) > 0
        # If there's a free entity, use it
        pop!(world.free_entities)
    else
        # Otherwise add a new one
        world.max_entity += 1
    end

    current_generation = world.entity_generation[i]
    if current_generation == nothing
        current_generation = 1
    else
        current_generation += 1
    end
    world.entity_generation[i] = current_generation
    # clear out components for the new entity
    for x in keys(world.components)
        componentList = world.components[x]
        if i > length(componentList)
            resize!(componentList,2*length(componentList))
        end
        componentList[i] = nothing
    end
    EntityKey(i,current_generation)
end

function addcomponent!(world::World,entity::EntityKey,component::C) where C <: ECSComponent
    if getentity(world,entity) == nothing
        println("tried to add component to non existant entity")
        return
    end
    world.components[C][entity.index] = component
    nothing
end

function removecomponent!(world::World,entity::EntityKey,::Type{C}) where C <: ECSComponent
    if getentity(world,entity) == nothing
        println("tried to remove component to non existant entity")
        return
    end
    world.components[C][entity.index] = nothing
    nothing
end

function getcomponent(world::World,entity::EntityKey,::Type{C}) where C <: ECSComponent
    if getentity(world,entity) == nothing
        println("tried to remove component to non existant entity")
        return
    end
    world.components[C][entity.index]
end

function runsystem!(f,world::World,types::Array{DataType,1})
    num_types = length(types)
    for e = 1:world.max_entity
        components = []
        for t in types
            component_list = world.components[t]
            if e<=length(component_list) && component_list[e] != nothing
                # if we found a component, store it
                push!(components,component_list[e])
            else
                # if we find nothing we can stop right now
                break
            end
        end
        # if entity has all components call function
        if length(components) == num_types
            f(EntityKey(e,world.entity_generation[e]),components)
        end
    end
    nothing
end

export ECSComponent,World,EntityKey,getentity,createentity!,register!,destroyentity!,
runsystem!,addcomponent!,removecomponent!,getcomponent
end
