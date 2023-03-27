-- Input
-- 0866
-- November 03, 2020



local Input = {}

local VIM = game:GetService("VirtualInputManager")

local VK_LSHIFT = Enum.KeyCode.LeftShift
local VK_LCONTROL = Enum.KeyCode.LeftControl
local VK_LALT = Enum.KeyCode.LeftAlt

local NOTE_MAP = "1!2@34$5%6^78*9(0qQwWeErtTyYuiIoOpPasSdDfgGhHjJklLzZxcCvVbBnm"
local VELOCITY_MAP = "1234567890qwertyuiopasdfghjklzxc"
local UPPER_MAP = "!@ $%^ *( QWE TY IOP SD GHJ LZ CVB"
local LOWER_MAP = "1234567890qwertyuiopasdfghjklzxcvbnm"

local LOW_64_MAP = "1234567890qwert"
local HIGH_64_MAP = "yuiopasdfghj"

local WORDS ={
    ["Zero"]="0",
    ["One"]="1",
    ["Two"]="2",
    ["Three"]="3",
    ["Four"]="4",
    ["Five"]="5",
    ["Six"]="6",
    ["Seven"]="7",
    ["Eight"]="8",
    ["Nine"]="9",
}

local BLOCKED = {
    4,16,28,40,52,64,76,88,100,112,124,
    11,23,35,47,59,71,83,95,107,119
}

local Thread = require(script.Parent.Util.Thread)
local Maid = require(script.Parent.Util.Maid)

local inputMaid = Maid.new()

local function CheckValue(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

local function CharacterToWord(char)
    local wordfound
    for word, v in pairs(WORDS) do
        if v == char then
            wordfound = word
        end
    end
    return wordfound or char:upper()
end

local function GetKey(pitch)
    local idx = (pitch + 1 - 36)
    if (idx > #NOTE_MAP) then
        idx = idx - 61
        local key = HIGH_64_MAP:sub(idx, idx)
        return key, nil, true
    elseif (idx < 1) then
        idx = idx + 15
        local key = LOW_64_MAP:sub(idx, idx)
        return key, nil, true
    else
        local key = NOTE_MAP:sub(idx, idx)
        return key, UPPER_MAP:find(key, 1, true), false
    end
end


function Input.IsUpper(pitch)
    local key, upperMapIdx = GetKey(pitch)
    if (not key) then return end
    return upperMapIdx
end

function Input.SetVelocity(velocity)
    local idx = math.ceil(32 / 127 * velocity)
    local velocityKey = VELOCITY_MAP:sub(idx, idx)
    VIM:SendKeyEvent(true, VK_LALT, false, game)
    VIM:SendKeyEvent(true, CharacterToWord(velocityKey), false, game)
    VIM:SendKeyEvent(false, CharacterToWord(velocityKey), false, game)
    VIM:SendKeyEvent(false, VK_LALT, false, game)
end

function Input.Press(pitch, velocity)
    local key, upperMapIdx, over64 = GetKey(pitch)
    if (not key) then return end
    Input.SetVelocity(velocity)
    
    if (upperMapIdx) then
        local keyToPress = LOWER_MAP:sub(upperMapIdx, upperMapIdx)
        VIM:SendKeyEvent(true, VK_LSHIFT, false,game)
        VIM:SendKeyEvent(true ,CharacterToWord(keyToPress), false, game)
        VIM:SendKeyEvent(false, VK_LSHIFT, false, game)
    else
        if (over64) then
            VIM:SendKeyEvent(true, VK_LCONTROL, false, game)
            VIM:SendKeyEvent(true, CharacterToWord(key), false, game)
            VIM:SendKeyEvent(false, VK_LCONTROL, false, game)
        else
            VIM:SendKeyEvent(true, CharacterToWord(key),false,game)
        end
    end
end


function Input.Release(pitch)
    local key, upperMapIdx, over64 = GetKey(pitch)
    if (not key) then return end

    if (upperMapIdx) then
        local keyToPress = LOWER_MAP:sub(upperMapIdx, upperMapIdx)
        VIM:SendKeyEvent(false, CharacterToWord(keyToPress), false, game)
        inputMaid[pitch - 1] = nil
    else
        if (not over64) then 
            if CheckValue(BLOCKED, pitch) then
                VIM:SendKeyEvent(false, CharacterToWord(key), false, game)
            else
                VIM:SendKeyEvent(false, CharacterToWord(key), false, game)
                inputMaid[pitch + 1] = nil
            end
        else
            VIM:SendKeyEvent(false, CharacterToWord(key), false, game)
        end
    end
end


function Input.Hold(pitch, duration, velocity)
    if (getgenv().leftNotePitches[pitch] and not getgenv().LeftHand) then return end
    if (getgenv().rightNotePitches[pitch] and not getgenv().RightHand) then return end
    if inputMaid[pitch] then
        inputMaid[pitch] = nil
    end
    Input.Release(pitch)
    Input.Press(pitch, velocity)
    inputMaid[pitch] = Thread.Delay(duration, Input.Release, pitch)
end


return Input
