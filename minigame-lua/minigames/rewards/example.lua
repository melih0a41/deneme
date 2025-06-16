--[[--------------------------------------------
                 Reward Example
--------------------------------------------]]--

local Reward = Minigames.CreateNewReward()

Reward:SetName("Example") --> Required
Reward:SetIcon("minigames/icons/example.png") --> Optional

-- Set a name amount with a string
Reward:SetNameAmount("Example") --> Required

-- Or you can set a name amount with a function
Reward:SetNameAmount(function(item, arg1, arg2, arg3)
    return "The example ID(" .. item .. ") with argument: " .. arg1 .. " and " .. arg2
end)


-- Function Reward
Reward:SetFunctionReward(function(owner, ply, arg1, arg2, arg3)
    RunConsoleCommand("givereward_example", ply:SteamID64(), arg1, arg2, arg3)

    --[[
    Be careful about using functions that can be exploited, like RunConsoleCommand
    you should use ConCommand in order to prevent exploits or giving ranks above the current owner rank
    like this:
    
    owner:ConCommand("ulx adduser '" .. ply:Nick() .. "' user")
    --]]
end) -- Required



-- Arguments
Reward:AddArgument({ -- arg1
    Name = "Argument 1",
    Type = "Text",
    Default = "example",
    Placeholder = "Example ID"
})

Reward:AddArgument({ -- arg2
    Name = "Awesome Slider",
    Type = "Slider",
    Min = 1,
    Max = 5,
    Default = 2,
    Convert = function(v) return v end --> This will be arg1 that will be passed to the SetFunctionReward
})

Reward:AddArgument({ -- arg3
    Name = "Only numeric text",
    Type = "Text",
    Placeholder = "Numeric ID",
    Numeric = true
})

Reward:AddArgument({ -- arg4
    Name = "Incredible List",
    Type = "List",
    Options = {
        ["option1"] = "Display Name 1",
        ["option2"] = "Display Name 2",
        ["option3"] = "Display Name 3"
    },
    Default = "option3",
    Convert = function(v) return v end
})

Reward:AddArgument({ -- arg5
    Name = "An awesome sequencial list",
    Type = "List",
    Options = {
        "option1",
        "option2",
        "option3"
    },
    Default = "option1",
    Convert = function(v) return v end,
    Optional = true -- This means that the argument can be or not as arg4 in the function
})

-- Minigames.RegisterReward(Reward)