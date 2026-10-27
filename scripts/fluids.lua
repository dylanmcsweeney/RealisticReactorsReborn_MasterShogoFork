local fluids = {}

function fluids.transferable(source, destination, amount)
    local fluid = source.get_fluid(1)
    if not fluid then return 0 end
    local target = destination.get_fluid(1)
    if target and target.name ~= fluid.name then return 0 end
    return math.max(0, math.min(amount, fluid.amount,
        destination.get_fluid_capacity(1) - (target and target.amount or 0)))
end

-- Keep rejected fluid on the source side, at its original temperature.
function fluids.transfer(source, destination, amount, temperature)
    amount = fluids.transferable(source, destination, amount)
    if amount <= 0 then return 0 end
    local removed = source.remove_fluid(1, amount)
    if not removed then return 0 end
    local accepted = destination.add_fluid(1, {
        name = removed.name, amount = removed.amount, temperature = temperature,
    })
    if accepted < removed.amount then
        source.add_fluid(1, {name = removed.name, amount = removed.amount - accepted,
            temperature = removed.temperature})
    end
    return accepted
end

return fluids
