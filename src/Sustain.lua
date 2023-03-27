local Sustain = {}

local VIM = game:GetService("VirtualInputManager")
local VK_SPACE = Enum.KeyCode.Space
Sustain.toggle = false

function Sustain.Press()
    if not Sustain.toggle then
    --VIM:SendKeyEvent(false,VK_SPACE,false,game)
    VIM:SendKeyEvent(true,VK_SPACE,false,game)
    end
    Sustain.toggle = true
end


function Sustain.Release()
    if Sustain.toggle then
    VIM:SendKeyEvent(false,VK_SPACE,false,game)
    end
    Sustain.toggle = false
end

return Sustain
