package.path = GetScriptsDir() .. "/Melee/Melee_Core.lua"
local core = require("Melee_Core")

local last_frame = 0
local last_index = 0
local current = core.getRNG()

function onScriptStart()
    if (GetGameID() ~= "GALE01") then
        CancelScript()
    end

    startRNG = core.inverseRNG(current)

    MsgBox("Script Started.")
end

function onScriptCancel()
    MsgBox("Script Ended.")
    SetScreenText("")
end

function onScriptUpdate()
    local frame = GetFrameCount()
    local index = core.inverseRNG(core.getRNG()) - startRNG
    local advance = index - last_index

    if (last_frame == frame) then return end
    last_frame = frame

    local text = ""
    text = text .. string.format("\n\nFrame: %d (%d)", frame, core.frameOfInput())
    text = text .. string.format("\nGame ID: %s", GetGameID())
    text = text .. "\n===== Position ====="
    text = text .. string.format("\nX: %10.7f\nY: %10.7f", core.getPos().X, core.getPos().Y)
    text = text .. "\n===== Speed ====="
    text = text .. string.format("\nSpeed: %16.7f\nTotal Speed: %10.7f", core.getSpeed())
    text = text .. "\n===== RNG ====="
    text = text .. string.format("\nRNG: %X", core.getRNG())
    text = text .. string.format("\nIndex: %d", index)
    text = text .. string.format("\nAdvance: %d", advance)
    text = text .. "\n===== Inputs ====="
    text = text .. string.format("\nInputs: %s", core.getInput().buttonText)
    text = text .. string.format("\nX: %10.7f | Y: %10.7f", core.getInput().X, core.getInput().Y)
    SetScreenText(text)

    last_index = index
end