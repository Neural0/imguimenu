-- loadstring here

local window = AddWindow()
window:AddTab({name = "RAGEBOT", separator =  true})

local tab = window:AddTab({name = "General"})
local section = tab.AddSection({height = "1/1"})
local togggle = section.AddToggle({flag = "Toggle1"})
togggle.AddKeybind({flag = "aoksdho"})
togggle.AddColorpicker({colorflag = "asdfad", transflag = "asodih01"})
section.AddSlider({flag = "asfgd2345"})
section.AddDropdown({flag = "aopishjd0"})
section.AddDropdown({min = 2, max = 3, flag = "aouisfh012"})
section.AddButton()
section.AddTextbox({flag = "TextboxFlag1"})
local section2 = tab.AddSection({side = "Right"})
local togggle2 = section2.AddToggle({flag = "Toggle2"})
section2.AddSlider({flag = "aoipsfdh0"})
togggle2.AddKeybind({flag = "asdf123asdf"})
togggle2.AddColorpicker({colorflag = "asdga1q23", transflag = "asg24621"})
section2.AddConfigList()

local configtab = window:AddTab({name = "Anti-Aim"})

do -- CPONFINGS
    local config_section = configtab:AddSection()
    
    local selectedconf = nil
    local configlist = config_section.AddConfigList({callback = function(active) selectedconf = active end})
    config_section.AddTextbox({name = "create", callback = function(text)
        creafeconfig(text) configlist:Refresh()
    end, flag = "uwuuwuu"})
    config_section.AddButton({name = "delete", callback = function()
        deleteconfig(selectedconf) configlist:Refresh()
    end})
    config_section.AddButton({name = "save", callback = function()
        saveconfig(selectedconf) configlist:Refresh()
    end})
    config_section.AddButton({name = "load", callback = function()
        loadconfig(selectedconf) configlist:Refresh()
    end})
end

window:AddTab({name = "LEGITBOT", separator =  true})

window:AddTab({name = "Generall"})
window:AddTab({name = "Triggerbot"})
window:AddTab({name = "More"})

window:AddTab({name = "VISUALS", separator =  true})

window:AddTab({name = "Players"})
window:AddTab({name = "World"})
window:AddTab({name = "More"})

window:AddTab({name = "OTHER", separator =  true})

window:AddTab({name = "Misc"})
window:AddTab({name = "Skins"})
window:AddTab({name = "Configs"})
