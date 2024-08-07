--[[------------------------------------------------------------]]
            --[[------- UI --------]]
--[[------------------------------------------------------------]]

-- workspace folders
if not isfile("uilibrary") then makefolder("uilibrary") end
if not isfile("uilibrary/configs") then makefolder("uilibrary/configs") end

--- services
local players		= cloneref(game:GetService("Players"))
local tweenService	= cloneref(game:GetService("TweenService"))
local _runservice	= cloneref(game:GetService("RunService"))
local CoreGui       = cloneref(game:GetService("CoreGui"))
local _uis			= cloneref(game:GetService("UserInputService"))
local Http          = cloneref(game:GetService("HttpService"))
-- vars
local localplayer   = players.LocalPlayer
local mouse 		= localplayer:GetMouse()
local tweenInfo 	= TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
-- Library
local Utility = {
    Ui_Bind = Enum.KeyCode.RightShift,
    Menu_Visible = true,
    Unload_Bind = Enum.KeyCode.Delete,
    Colors = {
        Window = Color3.fromRGB(20, 19, 24), --
        InnerPlate = Color3.fromRGB(35, 35, 35),
        InnerWindow = Color3.fromRGB(28, 27, 34), --
        BorderColor = Color3.fromRGB(50, 50, 50),
        TabContainer = Color3.fromRGB(17, 17, 17),
        Accent = Color3.fromRGB(100, 83, 170), -- Normal 100, 83, 170
        ContentContainer = Color3.fromRGB(13, 13, 13),
        ImageActive  = Color3.fromRGB(240,240,240),
        ImageInactive  = Color3.fromRGB(85, 85, 89),
        TextActive = Color3.fromRGB(200, 200, 200),
        TextInactive = Color3.fromRGB(100, 100, 100),
        Section = Color3.fromRGB(17, 17, 17),
        ElementText = Color3.fromRGB(125, 125, 125),
        ElementBackground = Color3.fromRGB(10,10,10),
        ElementTopGradient= Color3.fromRGB(33, 32, 37),
        ElementBottomGradient= Color3.fromRGB(47, 46, 51),
        ElementBorder = Color3.fromRGB(31, 31, 36)
    },
    ButtonMap = {
        [Enum.UserInputType.MouseButton1] = "Enum.UserInputType.MB1",
        [Enum.UserInputType.MouseButton2] = "Enum.UserInputType.MB2",
        [Enum.UserInputType.MouseButton3] = "Enum.UserInputType.MB3",
    },
    Flags = {},
    Connections = {},
    Instances = {},
    Fonts = {},
}
getgenv().Flags = Utility.Flags
local Colors = Utility.Colors
--[ [Fonts] ]--
function GetFont(name) getgenv().FONTNAME = name
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Neural0/base64fonts/main/FontAPI.lua",true))()
end
Utility.Font = GetFont("manrope")
--[ [Functions] ]--
function Utility:Create(Class: Instance, Properties: PhysicalProperties)
    local _Instance = type(Class) == 'string' and Instance.new(Class) or Class
    for Property, Value in next, Properties do
        _Instance[Property] = Value
    end
    table.insert(self.Instances, _Instance)
    return _Instance
end
function Utility:Unload()
    for _,v in next, self.Instances do v:Destroy() end
    for _,v in next, self.Connections do v:Disconnect() end
end
function Utility.Validate(defaults, options)
	for i,v in pairs(defaults) do
		if options[i] == nil then
			options[i] = v
		end
	end
    return options
end
function Utility.Tween(object, goal, callback)
	local tween = tweenService:Create(object, tweenInfo, goal)
	tween.Completed:Connect(callback or function() end)
	tween:Play()
end
--[ [Connections] ]--
function Utility:Connection(signal: RBXScriptSignal, callback, tbl: table)
    local connection = signal:Connect(callback)
    table.insert(self.Connections, connection)
    if tbl then table.insert(tbl, connection) end
    return connection
end
function Utility:MouseEvents(GUIOBJECT: Instance, onEnter, onLeave, onClick)
    self:Connection(GUIOBJECT.MouseEnter, function()
        if onEnter then onEnter() end
        local input = Utility:Connection(_uis.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if onClick and Utility.Menu_Visible then onClick() end
            end
        end)
        local leave
        leave = self:Connection(GUIOBJECT.MouseLeave, function()
            input:Disconnect()
            leave:Disconnect()
            if onLeave then onLeave() end
        end)
    end)
end

--[ [Configs] ]--
function creafeconfig(cfgname)
    local results = {}
    for key, item in pairs(getgenv().Flags) do
        local function tableToList(t)
            local list = {}
            for _, v in pairs(t) do table.insert(list, v) end
            return list
        end
        if type(item.value) == "table" then
            local list = tableToList(item.value)
            results[key] = {value = list}
        else
            results[key] = {value = item.value}
        end
    end
    local converted = Http:JSONEncode(results)
    writefile("uilibrary/configs/"..cfgname..".cfg", converted)
end
function deleteconfig(cfgname)
    delfile("uilibrary/configs/"..cfgname)
end
function saveconfig(cfgname)
    if not cfgname then return end
    local results = {}
    for key, item in pairs(getgenv().Flags) do
        if type(item.value) == "table" then
            results[key] = {value = item.value}
        else
            results[key] = {value = item.value}
        end
    end
    local converted = Http:JSONEncode(results)
    writefile("uilibrary/configs/"..cfgname, converted)
end
function loadconfig(cfgname)
    if not cfgname then return end
    local decoded = Http:JSONDecode(readfile("uilibrary/configs/"..cfgname))
    for key, item in pairs(decoded) do
        if not getgenv().Flags[key] then print("no corresponding flag to set", item) continue end
        if type(item.value) == "string" and string.find(item.value, "{") then
            local conv = Http:JSONDecode(item.value)
            local r, g, b = math.floor(conv.R * 255) , math.floor(conv.G * 255), math.floor(conv.B * 255)
            local color = Color3.fromRGB(r, g, b)
            getgenv().Flags[key].set(color)
        else
            getgenv().Flags[key].set(item.value)
        end
    end
end
--[ [Shortcuts] ]--
function addstroke(GUIOBJECT: Instance, Inner: boolean, Padding: number, Element: boolean, Thickness: number, _ZIndex: number)
    if not Thickness then Thickness = 1 end
    if not _ZIndex then _ZIndex = 1 end
    local stroke, Color, Mode
    if Element then Color = Colors.ElementBorder Mode = Enum.LineJoinMode.Round else Color = Colors.BorderColor Mode = Enum.LineJoinMode.Miter end
    if Inner and Padding then
        local strokeholder = Utility:Create("Frame", {
            Parent = GUIOBJECT,
            BackgroundTransparency = 1,
            Size = UDim2.new(1,-Padding,1,-Padding),
            AnchorPoint = Vector2.new(0.5,0.5),
            Position = UDim2.new(0.5,0,0.5,0),
            ZIndex = _ZIndex
        })
        stroke = Utility:Create("UIStroke", {
            Parent = strokeholder,
            Color = Color,
            Thickness = Thickness,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            LineJoinMode = Mode
        })
    else
        stroke = Utility:Create("UIStroke", {
            Parent = GUIOBJECT,
            Color = Color,
            Thickness = Thickness,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            LineJoinMode = Mode
        })
    end
    return stroke
end
function relight(color3: Color3, intensity: number)
    if not intensity then intensity = 0.5 end
    return Color3.fromRGB(math.clamp(color3.r * 255 * intensity, 0, 255), math.clamp(color3.g * 255 * intensity, 0, 255), math.clamp(color3.b * 255 * intensity, 0, 255))
end
function draggable(object: Instance, ignored: Instance)
    local container = {Hover = false}
    if ignored then
        Utility:Connection(ignored.MouseEnter, function() container.Hover = true end)
        Utility:Connection(ignored.MouseLeave, function() container.Hover = false end)
    end

    local dragStart, startPos, dragging
    Utility:Connection(object.InputBegan, function(input)
        if getgenv().slideractive then return end
        if ignored and container.Hover ~= true then
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = object.Position
            end
        else
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = object.Position
            end
        end
    end)
    Utility:Connection(_uis.InputChanged, function(input)
        if container.Hover ~= true then
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                local newX = startPos.X.Offset + delta.X
                local newY = startPos.Y.Offset + delta.Y

                object.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
            end
        end
    end)
    Utility:Connection(_uis.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end
local SCREENGUI = Utility:Create("ScreenGui", {
    Parent = CoreGui,
    ZIndexBehavior = Enum.ZIndexBehavior.Global,
    Name = "0000000000000000000000000000000000000000000000"
})
local dropdownindex = 50
local blur
function AddWindow(options)
    options = Utility.Validate({
        name = "imgui menu",
    }, options or {})
    local menu = {CurrentTab = nil}

    blur = Utility:Create("BlurEffect", {Parent = game.Lighting, Size = 20 })

    local WINDOW = Utility:Create("Frame", {
        Parent = SCREENGUI,
        Size = UDim2.new(0,680,0,480),
        AnchorPoint = Vector2.new("0.5","0.5"),
        Position = UDim2.new(0.5, -20, 0.5, 0),
        BackgroundColor3 = Colors.Window,
        BackgroundTransparency = 0.1,
        Visible = true,
        BorderSizePixel = 0,
    }) Utility:Create("UICorner", { Parent = WINDOW, CornerRadius = UDim.new(0,8) })

    local TITLECONTAINER = Utility:Create("Frame", {
        Parent = WINDOW,
        Size = UDim2.new(0,200,0,50),
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    })

    Utility:Create("TextLabel", {
        Parent = TITLECONTAINER,
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0.5,0,0.5,0),
        BackgroundTransparency = 1,
        TextColor3 = Colors.TextActive,
        TextXAlignment = Enum.TextXAlignment.Center,
        RichText = true,
        FontFace = Utility.Font,
        TextSize = 26,
        Text = options.name,
    })

    local TABCONTAINER = Utility:Create("Frame", {
        Parent = WINDOW,
        Size = UDim2.new(0,200,1,-50),
        Position = UDim2.new(0,0,0,50),
        BackgroundTransparency = 1
    })

    Utility:Create("UIListLayout", {
        Parent = TABCONTAINER,
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = Enum.FillDirection.Vertical,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        Padding = UDim.new(0, 4),
    })
    local xoffset= TABCONTAINER.Size.X.Offset
    local INNERCONTAINER = Utility:Create("Frame", {
        Parent = WINDOW,
        Size = UDim2.new(1,-xoffset,1,0),
        Position = UDim2.new(0,xoffset,0,0),
        BackgroundColor3 = Colors.InnerWindow,
        BorderSizePixel = 0,
    }) Utility:Create("UICorner", { Parent = INNERCONTAINER, CornerRadius = UDim.new(0,8) })
    Utility:Create("Frame", {
        Parent = INNERCONTAINER,
        Position = UDim2.new(0,1,0,0),
        Size = UDim2.new(0,8,1,0),
        BackgroundColor3 = Colors.InnerWindow,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0
    })
    Utility:Create("Frame", {
        Parent = INNERCONTAINER,
        Size = UDim2.new(0,1,1,0),
        BackgroundColor3 = Colors.BorderColor,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0
    })
    local TABFADE = Utility:Create("Frame", {
        Parent = INNERCONTAINER,
        Size = UDim2.new(1,-1, 1, 0),
        Position = UDim2.new(0.5, 1, 0.5, 0),
        AnchorPoint = Vector2.new(0.5,0.5),
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Name = "TabFade",
        ZIndex = 99,
    })
    local function deactivate(tab)
        for _, content in ipairs(INNERCONTAINER:GetChildren()) do
            if content.Name == tab.Name then
                Utility.Tween(TABFADE, {BackgroundTransparency = 0.6})
                repeat task.wait() until TABFADE.BackgroundTransparency <= 0.61
                content.Visible = false
            end
        end

        Utility.Tween(tab.TabText, {TextColor3 = Utility.Colors.TextInactive})
        Utility.Tween(tab.TabText, {Position = UDim2.new(0,48,0.5,0)})
        Utility.Tween(tab.TabIcon, {Position = UDim2.new(0,24,0.5,-1)})

        Utility.Tween(tab.TabBar, {BackgroundTransparency = 1})
        Utility.Tween(tab.GradientHolder, {BackgroundTransparency = 1})
    end

    function menu:AddTab(options)
        options = Utility.Validate({
            name = "example",
            image = "18748264029",
            separator = false
        }, options or {})
        local funcs = {}
        local TAB = Utility:Create("Frame", {
            Parent = TABCONTAINER,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1,0,0,20),
            Name = options.name
        })
        if options.separator then
            TAB.Size = UDim2.new(1,0,0,30) TAB.Name = "separator"

            Utility:Create("TextLabel", {
                Parent = TAB,
                AnchorPoint = Vector2.new(0,0.5),
                Position = UDim2.new(0, 14, 0.5, 0),
                Size = UDim2.new(0.5,0,0.5,0),
                BackgroundTransparency = 1,
                TextColor3 = Colors.TextInactive,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                RichText = true,
                FontFace = Utility.Font,
                TextSize = 14,
                Text = options.name,
            })
            return
        end

        local TABBAR = Utility:Create("Frame", {
            Parent = TAB,
            Position = UDim2.new(0,15,0,0),
            Size = UDim2.new(0,-1,1,0),
            BackgroundColor3 = relight(Colors.Accent, 1.2),
            BackgroundTransparency = 1,
            ZIndex = 2,
            Name = "TabBar"
        })

        local GRADIENTHOLDER = Utility:Create("Frame", {
            Parent = TAB,
            Position = UDim2.new(0,13,0,0),
            Size = UDim2.new(0,10,1,0),
            BackgroundColor3 = Colors.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Name = "GradientHolder"
        })
        Utility:Create("UIGradient", {
            Parent = GRADIENTHOLDER,
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(0.83, 0.82),
                NumberSequenceKeypoint.new(1, 1),
            }),
        })
        local TABICON = Utility:Create("ImageLabel", {
            Parent = TAB,
            AnchorPoint = Vector2.new(0,0.5),
            Position = UDim2.new(0,24,0.5,-1),
            Size = UDim2.new(0,14,0,14),
            BackgroundTransparency = 1,
            Image = "rbxassetid://"..options.image,
            ImageColor3 = Colors.ImageActive,
            Name = "TabIcon"
        })

        local TABTEXT = Utility:Create("TextLabel", {
            Parent = TAB,
            AnchorPoint = Vector2.new(0,0.5),
            Position = UDim2.new(0,48,0.5,0),
            Size = UDim2.new(0.5,0,0.5,0),
            BackgroundTransparency = 1,
            TextColor3 = Colors.TextInactive,
            TextTransparency = 0.5,
            TextXAlignment = Enum.TextXAlignment.Left,
            RichText = true,
            FontFace = Utility.Font,
            TextSize = 15,
            Text = options.name,
            Name = "TabText"
        })

        -----------------------------
            --- Tab Content -----
        -----------------------------

        local CONTENTCONTAINER = Utility:Create("Frame", {
            Parent = INNERCONTAINER,
            Size = UDim2.new(1,0, 1,0),
            Visible = false,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Name = options.name
        })

        local LEFTCONTAINER = Utility:Create("Frame", {
            Parent = CONTENTCONTAINER,
            Position = UDim2.new(0,10,0.5,0),
            AnchorPoint = Vector2.new(0,0.5),
            Size = UDim2.new(0.5,-18,1,-25),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Name = "LeftContainer"
        })

        local RIGHTCONTAINER = Utility:Create("Frame", {
            Parent = CONTENTCONTAINER,
            Position = UDim2.new(1,-10,0.5,0),
            AnchorPoint = Vector2.new(1,0.5),
            Size = UDim2.new(0.5,-18,1,-25),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Name = "RightContainer"
        })

        do -- Functionality
            local function Activate()
                CONTENTCONTAINER.Visible = true

                Utility.Tween(TABFADE, {BackgroundTransparency = 1})
                Utility.Tween(TABTEXT, {TextColor3 = Colors.TextActive})
                Utility.Tween(TABTEXT, {Position = UDim2.new(0,56,0.5,0)})
                Utility.Tween(TABICON, {Position = UDim2.new(0,32,0.5,-1)})
                Utility.Tween(TABBAR, {BackgroundTransparency = 0})
                Utility.Tween(GRADIENTHOLDER, {BackgroundTransparency = 0})
                self.CurrentTab = TAB
            end
            local function switchTab(tab)
                for _, content in pairs(TABCONTAINER:GetChildren()) do
                    if content.Name == "UIListLayout" then continue end
                    if content.Name ~= "separator" and content.Name ~= tab.Name then
                        deactivate(content)
                    end
                end
                Activate()
            end
            Utility:MouseEvents(TAB,
                function()
                    if self.CurrentTab ~= TAB then
                        Utility.Tween(TABTEXT, {TextColor3 = Colors.TextActive})
                        Utility.Tween(TABBAR, {BackgroundTransparency = 0})
                        Utility.Tween(GRADIENTHOLDER, {BackgroundTransparency = 0})
                    end
                end, -- enter
                function()
                    if self.CurrentTab ~= TAB then 
                        Utility.Tween(TABTEXT, {TextColor3 = Colors.TextInactive})
                        Utility.Tween(TABBAR, {BackgroundTransparency = 1})
                        Utility.Tween(GRADIENTHOLDER, {BackgroundTransparency = 1})
                    end
                end, -- leave
                function() switchTab(TAB) end -- press
            )

            if self.CurrentTab == nil then switchTab(TAB) end
        end

        local LeftHeight = {0}
        local RightHeight = {0}

        function funcs.AddSection(options)
            options = Utility.Validate({
                name = "ONE CHILD",
                side = "Left",
                height = "1/1"
            }, options or {})
            local funcs = {}

            local NewPos, padding = nil, 10
            do -- Calculate Section Position
                local currentHeightTable = options.side == "Left" and LeftHeight or RightHeight
                local lastHeight = currentHeightTable[#currentHeightTable]
                NewPos = lastHeight + padding
                if lastHeight ~= 0 then
                    NewPos = lastHeight + padding
                else NewPos = lastHeight end
            end
        
            local SECTION = Utility:Create("Frame", {
                Size = UDim2.new(1, 0, 0, options.height),
                AnchorPoint = Vector2.new(0, 0),
                BackgroundColor3 = Colors.Section,
                Position = UDim2.new(0, 0, 0, NewPos),
                BorderSizePixel = 0,
                Name = options.name
            }) Utility:Create("UICorner", { Parent = SECTION, CornerRadius = UDim.new(0,8) })
            do -- handle sizing
                if typeof(options.height) == "string" then
                    local numerator, denominator = options.height:match("(%d+)/(%d+)")
                    if numerator and denominator then
                        numerator, denominator = tonumber(numerator), tonumber(denominator)
                        if numerator and denominator and denominator ~= 0 then
                            local fraction = numerator / denominator
                            SECTION.Size = UDim2.new(1, 0, fraction, -padding)
                        end
                    end
                end
            end
            do -- handle side picking
                if options.side == "Right" then
                    SECTION.Parent = RIGHTCONTAINER
                    table.insert(RightHeight, NewPos + SECTION.AbsoluteSize.Y)
                else
                    SECTION.Parent = LEFTCONTAINER
                    table.insert(LeftHeight, NewPos + SECTION.AbsoluteSize.Y)
                end
            end

            local TOPLINE = Utility:Create("Frame", {
                Parent = SECTION,
                Size = UDim2.new(1,0,0,1),
                BackgroundColor3 = Colors.Accent,
                BorderSizePixel = 0,
            })
            Utility:Create("UIGradient", {
                Parent = TOPLINE,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(0.5, 0),
                    NumberSequenceKeypoint.new(1, 1),
                }),
            })
            Utility:Create("TextLabel", {
                Parent = SECTION,
                Size = UDim2.new(1,0,0,10),
                Position = UDim2.new(0,5,0,4),
                BackgroundTransparency = 1,
                TextColor3 = Colors.TextInactive,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center,
                FontFace = Utility.Font,
                TextSize = 12,
                Text = options.name,
            })
            local BOTTOMLINE = Utility:Create("Frame", {
                Parent = SECTION,
                Position = UDim2.new(0,0,1,0),
                AnchorPoint = Vector2.new(0,1),
                Size = UDim2.new(1,0,0,1),
                BackgroundColor3 = Colors.Accent,
                BorderSizePixel = 0,
            })
            Utility:Create("UIGradient", {
                Parent = BOTTOMLINE,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(0.5, 0),
                    NumberSequenceKeypoint.new(1, 1),
                }),
            })

            -------------------------------
                --- Section Content ---
            -------------------------------

            local ELEMENTCONTAINER = Utility:Create("Frame", {
                Parent = SECTION,
                Size = UDim2.new(1, 0, 1, -15),
                Position = UDim2.new(0,0,0,15),
                BackgroundTransparency = 1,
            })

            Utility:Create("UIPadding", {
                Parent = ELEMENTCONTAINER,
                PaddingTop = UDim.new(0, 10),
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 10)
            })

            Utility:Create("UIListLayout", {
                Parent = ELEMENTCONTAINER,
                FillDirection = Enum.FillDirection.Vertical,
                VerticalAlignment = Enum.VerticalAlignment.Top,
                Padding = UDim.new(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder,
            })

            ------------------------
                --- Elements ---
            ------------------------

            function funcs.AddButton(options)
                options = Utility.Validate({
                    name = "button",
                    callback = function() end,
                }, options or {})

                local BUTTONCONTAINER = Utility:Create("Frame", {
                    Parent = ELEMENTCONTAINER,
                    Size = UDim2.new(1, 0, 0, 25),
                    BackgroundTransparency = 1,
                    Name = "ButtonContainer"
                })

                local BUTTON = Utility:Create("Frame", {
                    Parent = BUTTONCONTAINER,
                    Size = UDim2.new(1, 0, 1, 0),
                    BorderSizePixel = 0,
                    Name = "Button",
                }) addstroke(BUTTON, false, 2, true) Utility:Create("UICorner", { Parent = BUTTON, CornerRadius = UDim.new(0,4) })
                Utility:Create("UIGradient", {
                    Parent = BUTTON,
                    Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Colors.ElementBottomGradient),
                        ColorSequenceKeypoint.new(1, Colors.ElementTopGradient)
                    },
                    Rotation = 90,
                })

                local BUTTONTITLE = Utility:Create("TextLabel", {
                    Parent = BUTTON,
                    AnchorPoint = Vector2.new(0.5,0.5),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Size = UDim2.new(0.5,0,0.5,0),
                    BackgroundTransparency = 1,
                    TextColor3 = Colors.TextInactive,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    RichText = true,
                    FontFace = Utility.Font,
                    TextSize = 14,
                    Text = options.name,
                })

                do -- Functionality
                    Utility:MouseEvents(BUTTON,
                        function() Utility.Tween(BUTTONTITLE, {TextColor3 = Colors.TextActive}) end,
                        function() Utility.Tween(BUTTONTITLE, {TextColor3 = Colors.TextInactive}) end,
                        function() options.callback() end)
                end

                return
            end
            function funcs.AddTextbox(options)
				options = Utility.Validate({
					name = "example textbox",
                    flag = nil,
                    default = "",
                    callback = function() end,
				}, options or {})
                if not options.flag then error("exception: FLAG on: " .. options.name) end
                Utility.Flags[options.flag] = {value = options.default}
                local TEXTBOXCONTAINER = Utility:Create("Frame", {
                    Parent = ELEMENTCONTAINER,
                    Size = UDim2.new(1, 0, 0, 42),
                    BackgroundTransparency = 1,
                    Name = "TextboxContainer"
                })

                Utility:Create("TextLabel", {
                    Parent = TEXTBOXCONTAINER,
                    Position = UDim2.new(0, 1, 0, 2),
                    Size = UDim2.new(1,0,0,10),
                    BackgroundTransparency = 1,
                    TextColor3 = Colors.TextInactive,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    RichText = true,
                    FontFace = Utility.Font,
                    TextSize = 14,
                    Text = options.name,
                })

                local BACKGROUND = Utility:Create("Frame", {
                    Parent = TEXTBOXCONTAINER,
                    AnchorPoint = Vector2.new(0,1),
                    Position = UDim2.new(0,0,1,0),
                    Size = UDim2.new(1, 0, 0, 25),
                    BorderSizePixel = 0
                }) addstroke(BACKGROUND, false, 2, true) Utility:Create("UICorner", { Parent = BACKGROUND, CornerRadius = UDim.new(0,4) })
                Utility:Create("UIGradient", {
                    Parent = BACKGROUND,
                    Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Colors.ElementBottomGradient),
                        ColorSequenceKeypoint.new(1, Colors.ElementTopGradient)
                    },
                    Rotation = 90,
                })
                local TEXTBOX = Utility:Create("TextBox", {
                    Parent = BACKGROUND,
                    BackgroundTransparency = 1,
                    Selectable = false,
                    Size = UDim2.new(1, 0, 1, 0),
                    FontFace = Utility.Font,
                    Text = options.default or "",
                    TextColor3 = Colors.TextInactive,
                    TextSize = 14,
                    TextStrokeTransparency = 0,
                    TextXAlignment = Enum.TextXAlignment.Center,
                })
                do -- Functionality
                    Utility.Flags[options.flag].set = function(text)
                        TEXTBOX.Text = text
                        options.callback(TEXTBOX.text)
                        Utility.Flags[options.flag].value = text
                    end
                    Utility:MouseEvents(TEXTBOX,
                        function() Utility.Tween(TEXTBOX, {TextColor3 = Colors.TextActive}) end,
                        function() Utility.Tween(TEXTBOX, {TextColor3 = Colors.TextInactive}) end)

                    Utility:Connection(TEXTBOX:GetPropertyChangedSignal("Text"), function()
                        options.name = TEXTBOX.Text
                    end)
                    
                    Utility:Connection(TEXTBOX.FocusLost, function(enterPressed)
                        local text = TEXTBOX.Text
                        local callback_text = text ~= "" and text or options.default
                        
                        if enterPressed and options.callback then
                            options.callback(callback_text)
                            Utility.Flags[options.flag].value = callback_text
                        end
                    end)
                end
                return
            end
            function funcs.AddToggle(options)
                options = Utility.Validate({
					name = "example toggle",
                    flag = nil,
                    default = false,
                    callback = function() end,
				}, options or {})
                if not options.flag then error("exception: FLAG on: " .. options.name) end
                Utility.Flags[options.flag] = {value = options.default} options.callback(options.default)

                local funcs = {state = options.default}

                local TOGGLECONTAINER = Utility:Create("Frame", {
                    Parent = ELEMENTCONTAINER,
                    Size = UDim2.new(1,0,0,25),
                    BackgroundTransparency = 1,
                    Name = "ToggleContainer",
                })

                local TOGGLE = Utility:Create("Frame", {
                    Parent = TOGGLECONTAINER,
                    Size = UDim2.new(0,20,0,20),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = UDim2.new(0, 0, 0.5, 0),
                    BorderSizePixel = 0,
                    Name = "Toggle",
                }) Utility:Create("UICorner", { Parent = TOGGLE, CornerRadius = UDim.new(0,4) })
                Utility:Create("UIGradient", {
                    Parent = TOGGLE,
                    Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Colors.ElementBottomGradient),
                        ColorSequenceKeypoint.new(1, Colors.ElementTopGradient)
                    },
                    Rotation = 90,
                })

                local TOGGLEACTIVE = Utility:Create("Frame", {
                    Parent = TOGGLE,
                    AnchorPoint = Vector2.new(0.5, .5),
                    Position = UDim2.new(0.5, 0, .5, 0),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1,0,1,0),
                }) Utility:Create("UICorner", { Parent = TOGGLEACTIVE, CornerRadius = UDim.new(0,4) })
                Utility:Create("UIGradient", {
                    Parent = TOGGLEACTIVE,
                    Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, relight(Colors.Accent, 0.4)),
                        ColorSequenceKeypoint.new(1, relight(Colors.Accent, 1.2))
                    },
                    Rotation = -45,
                })
                local IMAGEACTIVE = Utility:Create("ImageLabel", {
                    Parent = TOGGLEACTIVE,
                    AnchorPoint = Vector2.new(0.5, .5),
                    Position = UDim2.new(0.5, 0, .5, 0),
                    Size = UDim2.new(1,-10,1,-10),
                    BackgroundTransparency = 1,
                    ImageTransparency = 1,
                    Image = "rbxassetid://18760472741",
                    Name = "TabIcon"
                })

                local TOGGLETITLE = Utility:Create("TextLabel", {
                    Parent = TOGGLECONTAINER,
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = UDim2.new(0, 25, 0.5, -1),
                    BackgroundTransparency = 1,
                    TextSize = 14,
                    TextColor3 = Colors.TextInactive,
                    Text = options.name,
                    FontFace = Utility.Font,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })

                local SUBELEMENTHOLDER = Utility:Create("Frame", {
                    Parent = TOGGLECONTAINER,
                    Size = UDim2.new(1,0,1,0),
                    Position = UDim2.new(0,0,0,0),
                    BackgroundTransparency = 1,
                    Name = "elementholder",
                })

                Utility:Create("UIListLayout", {
                    Parent = SUBELEMENTHOLDER,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Right,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    Padding = UDim.new(0, 4),
                    Name = "elementlayout",
                })
                do -- functionality
                    local state = funcs.state
                    local function HandleActivation(flag, flagstate)
                        if not flag then state = not state
                        else state = flagstate end
                        Utility.Flags[options.flag].value = state
                        options.callback(state)
                        Utility.Tween(TOGGLEACTIVE, {BackgroundTransparency = state and 0 or 1})
                        Utility.Tween(IMAGEACTIVE, {ImageTransparency = state and 0 or 1})
                        Utility.Tween(TOGGLEACTIVE, {Size = state and UDim2.new(1,0,1,0) or UDim2.new(0,0,0,0)})
                        Utility.Tween(TOGGLETITLE, {TextColor3 = state and Colors.TextActive or Colors.TextInactive})
                    end
                    

                    Utility:MouseEvents(TOGGLE,
                    function()
                        if state then return end
                        Utility.Tween(TOGGLEACTIVE, {BackgroundTransparency = 0, Size = UDim2.new(1,0,1,0)})
                        Utility.Tween(TOGGLETITLE, {TextColor3 = Colors.TextActive})
                    end,
                    function()
                        if state then return end
                        Utility.Tween(TOGGLEACTIVE, {BackgroundTransparency = 1, Size = UDim2.new(0,0,0,0)})
                        Utility.Tween(TOGGLETITLE, {TextColor3 = Colors.TextInactive})
                    end,
                    HandleActivation)
                    Utility.Flags[options.flag].set = function(state) HandleActivation(true, state) end
                end
                ---- Keybinds ----
                function funcs.AddKeybind(options)
                    options = Utility.Validate({
                        default = "...",
                        flag = nil,
                        getkey = function() end,
                    }, options or {})
                    
                    if not options.flag then error("exception: FLAG on: " .. "keybind-" .. TOGGLETITLE.Text) end
                    
                    Utility.Flags[options.flag] = {value = options.default}
                    options.getkey(options.default)
                
                    local KEYBIND = Utility:Create("Frame", {
                        Parent = SUBELEMENTHOLDER,
                        Size = UDim2.new(0, 30, 0, 12),
                        BorderSizePixel = 0,
                        Name = "Keybind",
                    }) 
                    addstroke(KEYBIND, true, 2, true)
                    
                    Utility:Create("UIGradient", {
                        Parent = KEYBIND,
                        Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, Colors.ElementBottomGradient),
                            ColorSequenceKeypoint.new(1, Colors.ElementTopGradient)
                        },
                        Rotation = 90,
                    })
                
                    local KEYBINDTEXT = Utility:Create("TextLabel", {
                        Parent = KEYBIND,
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        TextColor3 = Colors.TextActive,
                        TextSize = 10,
                        Text = string.lower(options.default),
                        FontFace = Utility.Font,
                        TextXAlignment = Enum.TextXAlignment.Center,
                        Name = "KeybindText",
                    })
                    
                    local function applykey(key)
                        if key == "..." then return end
                        if typeof(key) == "string" and string.find(key, "UserInputType") then
                            key = Enum.UserInputType[string.match(key, "[^.]+$")]
                        end
                        key = Utility.ButtonMap[key] or key
                        
                        local str = tostring(key):match("[^.]+$")
                        local formattedkey = str:gsub("Left", "L"):gsub("Right", "R")
                        
                        KEYBINDTEXT.Text = string.lower(formattedkey)
                        Utility.Tween(KEYBINDTEXT, {TextColor3 = Colors.TextActive})
                        KEYBIND.Size = UDim2.new(0, KEYBINDTEXT.TextBounds.X + 12, 0, 12)
                    end
                
                    Utility.Flags[options.flag].set = function(key)
                        options.getkey(key)
                        Utility.Flags[options.flag].value = key
                        applykey(key)
                    end
                
                    local function _wait_for_input()
                        local getkey
                        getkey = Utility:Connection(_uis.InputBegan, function(input)
                            local keyPressed = input.KeyCode == Enum.KeyCode.Unknown and input.UserInputType or input.KeyCode
                            
                            if keyPressed == Enum.KeyCode.Backspace then -- remove keybind
                                KEYBINDTEXT.Text = "..."
                                Utility.Tween(KEYBINDTEXT, {TextColor3 = Colors.Accent})
                                getkey:Disconnect()
                                return
                            end
                
                            local disallowedKeys = {Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.UserInputType.MouseMovement}
                            for _, key in ipairs(disallowedKeys) do
                                if keyPressed == key then getkey:Disconnect() return end
                            end
                            
                            options.getkey(keyPressed)
                            Utility.Flags[options.flag].value = tostring(keyPressed)
                            applykey(keyPressed)
                            getkey:Disconnect()
                        end)
                    end
                
                    Utility:MouseEvents(KEYBIND,
                        function() Utility.Tween(KEYBINDTEXT, {TextColor3 = Colors.Accent}) end,
                        function() Utility.Tween(KEYBINDTEXT, {TextColor3 = Colors.TextActive}) end,
                        function()
                            KEYBINDTEXT.Text = "..."
                            KEYBIND.Size = UDim2.new(0, KEYBINDTEXT.TextBounds.X + 20, 0, 16)
                            _wait_for_input()
                    end)
                end
                ---- Color Pickers ----
                function funcs.AddColorpicker(options)
                    options = Utility.Validate({
                        default = Color3.fromRGB(255,255,255),
                        colorflag = nil,
                        transflag = nil,
                        getcolor = function() end,
                        gettransparency = function() end
                    }, options or {})
                    if not options.colorflag then error("exception: COLORFLAG on: " .. options.name) end
                    if not options.transflag then error("exception: TRANSFLAG on: " .. options.name) end
                    Utility.Flags[options.colorflag] = {value = options.default}
                    Utility.Flags[options.transflag] = {value = options.default}

                    local ELEMENT = Utility:Create("Frame", {
                        Name = "element",
                        Parent = SUBELEMENTHOLDER,
                        Size = UDim2.new(0, 15, 0, 15),
                        BorderColor3 = Colors.BorderColor,
                        BorderSizePixel = 1,
                    }) Utility:Create("UICorner", { Parent = ELEMENT, CornerRadius = UDim.new(0,4) })

                    Utility:Create("UIGradient", {
                        Parent = ELEMENT,
                        Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(70,70,70)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
                        },
                        Rotation = -45,
                    })

                    local COLORPICKER = Utility:Create("Frame", {
                        Parent = TOGGLECONTAINER,
                        Name = "colorpicker",
                        Size = UDim2.new(0, 200, 0, 205),
                        Visible = false,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 2,
                        BackgroundColor3 = Colors.Window,
                    }) Utility:Create("UICorner", { Parent = COLORPICKER })

                    if COLORPICKER.Parent.Parent.Parent.Parent.Name == "LeftContainer" then COLORPICKER.Position = UDim2.new(0, -423, 0, -20)
                    else COLORPICKER.Position = UDim2.new(0, 225, 0, -20) end

                    local BRIGHTNESS = Utility:Create("Frame", {
                        Parent = COLORPICKER,
                        AnchorPoint = Vector2.new(0.5, 0),
                        Position = UDim2.new(0.5, 0, 0, 0),
                        Size = UDim2.new(0, 160, 0, 150),
                        BorderSizePixel = 0,
                    }) Utility:Create("UICorner", { Parent = BRIGHTNESS, CornerRadius = UDim.new(0,6) })
                    
                    local image1 = Utility:Create("ImageLabel", {
                        Name = "ImageLabel",
                        Parent = BRIGHTNESS,
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Image = "rbxassetid://2615689005"
                    }) Utility:Create("UICorner", { Parent = image1, CornerRadius = UDim.new(0,4) })
                    
                    local PICKER_BRIGHTNESS = Utility:Create("ImageLabel", {
                        Parent = BRIGHTNESS,
                        Size = UDim2.new(0, 10, 0, 10),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 2,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Image = "rbxassetid://18268646065"
                    })

                    Utility:Create("UIPadding", {
                        Name = "UIPadding",
                        Parent = COLORPICKER,
                        PaddingBottom = UDim.new(0, 10),
                        PaddingTop = UDim.new(0, 10),
                        PaddingLeft = UDim.new(0, 10),
                        PaddingRight = UDim.new(0, 10)
                    })
                    
                    local HUE = Utility:Create("Frame", {
                        Parent = COLORPICKER,
                        AnchorPoint = Vector2.new(0.5, 1),
                        Size = UDim2.new(0, 160, 0, 6),
                        Position = UDim2.new(0.5, 0, 1, -18),
                        BorderSizePixel = 0,
                    }) Utility:Create("UICorner", { Parent = HUE, CornerRadius = UDim.new(0,6) })

                    local thisa1 = Utility:Create("ImageLabel", {
                        Parent = HUE,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(0.5, 1, 0.5, 1),
                        Size = UDim2.new(0, 6, 0, 160),
                        Rotation = 90,
                        BorderSizePixel = 0,
                        Image = "rbxassetid://2615692420"
                    }) Utility:Create("UICorner", { Parent = thisa1, CornerRadius = UDim.new(0,6) })
                    
                    local PICKER_HUE = Utility:Create("Frame", {
                        Parent = HUE,
                        Size = UDim2.new(0, 8, 0, 8),
                        Position = UDim2.new(0, 50, 0.5, 0),
                        AnchorPoint = Vector2.new(0, 0.5),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    }) Utility:Create("UICorner", { Parent = PICKER_HUE, CornerRadius = UDim.new(0,100) })

                    Utility:Create("UIStroke", {
                        Parent = PICKER_HUE,
                        Color = Color3.fromRGB(255, 255, 255),
                        Thickness = 1.8,
                    })
                    local TRANSPARENCY = Utility:Create("Frame", {
                        Parent = COLORPICKER,
                        AnchorPoint = Vector2.new(0.5, 1),
                        Size = UDim2.new(0, 160, 0, 6),
                        Position = UDim2.new(0.5, 0, 1, -5),
                        BorderSizePixel = 0,
                    }) Utility:Create("UICorner", { Parent = TRANSPARENCY, CornerRadius = UDim.new(0,4) })

                    local iamge1 = Utility:Create("ImageLabel", {
                        Parent = TRANSPARENCY,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Image = "rbxassetid://18779628496",
                    }) Utility:Create("UICorner", { Parent = iamge1, CornerRadius = UDim.new(0,2) })
                    
                    local PICKER_TRANSPARENCY = Utility:Create("Frame", {
                        Parent = TRANSPARENCY,
                        Size = UDim2.new(0, 8, 0, 8),
                        Position = UDim2.new(0, 50, 0.5, 0),
                        AnchorPoint = Vector2.new(0, 0.5),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    }) Utility:Create("UICorner", { Parent = PICKER_TRANSPARENCY, CornerRadius = UDim.new(0,100) })

                    Utility:Create("UIStroke", {
                        Parent = PICKER_TRANSPARENCY,
                        Color = Color3.fromRGB(255, 255, 255),
                        Thickness = 1.8,
                    })
                    -- functionality

                    local elhovered = false
                    Utility:MouseEvents(ELEMENT, function()
                        Utility.Tween(ELEMENT, {BorderColor3 = Colors.Accent})
                        elhovered = true
                    end,
                    function()
                        Utility.Tween(ELEMENT, {BorderColor3 = Color3.fromRGB(0,0,0)})
                        elhovered = false
                    end,
                    nil)
                    Utility:Connection(ELEMENT.MouseLeave, function()
                        Utility.Tween(ELEMENT, {BorderColor3 = Color3.fromRGB(0,0,0)})
                    end)
                    Utility:Connection(_uis.InputBegan, function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 and elhovered then
                            for i,v in pairs(SCREENGUI:GetDescendants()) do
                                if v.Name == "colorpicker" and v.Visible == true and ELEMENT.Parent.Parent.Parent.Parent:FindFirstChild("colorpicker") and button2.Parent.Parent.Parent.Parent:FindFirstChild("colorpicker") ~= v then 
                                    v.Visible = false
                                end
                            end
                            COLORPICKER.Visible = not COLORPICKER.Visible
                            ELEMENT.BorderColor3 = Colors.BorderColor
                        end
                    end)
                    local absvalue
                    local function updateValue(value, fakevalue)
                        if typeof(value) == "table" then value = fakevalue end
                        if not value then return end
                    
                        local r, g, b = value.R, value.G, value.B
                    
                        options.default = value
                        ELEMENT.BackgroundColor3 = value
                        TRANSPARENCY.BackgroundColor3 = value
                        absvalue = tostring(math.round(r * 255)) .. "," .. tostring(math.round(g * 255)) .. "," .. tostring(math.round(b * 255))
                        options.getcolor(value)
                        Utility.Flags[options.colorflag].value = string.format('{"R":%.8f,"G":%.8f,"B":%.8f}', r, g, b)
                    end
                    
                    local white, black = Color3.new(1,1,1), Color3.new(0,0,0)
                    local colors = {Color3.new(1,0,0),Color3.new(1,1,0),Color3.new(0,1,0),Color3.new(0,1,1),Color3.new(0,0,1),Color3.new(1,0,1),Color3.new(1,0,0)}
                    local heartbeat = _runservice.Heartbeat
                    local brightnessX,brightnessY,hueX = 0,0,0
                    local oldpercentX,oldpercentY = 0,0

                    function lerp(startValue, endValue, duration, callback)
                        local startTime = tick()  -- Get the current time
                        local completed = false
                        task.spawn(function()
                            while true do
                                local currentTime = tick() - startTime
                                if currentTime >= duration then
                                    callback(endValue)
                                    completed = true
                                    break
                                end
                    
                                local progress = currentTime / duration
                                local lerped = startValue + (endValue - startValue) * (1 - (1 - progress) * (1 - progress))
                    
                                callback(lerped)
                                task.wait()
                            end
                        end)
                        while not completed do
                            task.wait()
                        end
                    end

                    Utility:Connection(HUE.MouseEnter, function()
                        local input = Utility:Connection(HUE.InputBegan, function(key)
                            if key.UserInputType == Enum.UserInputType.MouseButton1 then
                                while heartbeat:wait() and _uis:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                                    local percent = (hueX - HUE.AbsolutePosition.X - 36) / HUE.AbsoluteSize.X
                                    local num = math.max(1, math.min(7, math.floor(((percent * 7 + 0.5) * 100)) / 100))
                                    local startC = colors[math.floor(num)]
                                    local endC = colors[math.ceil(num)]
                                    local color = white:lerp(BRIGHTNESS.BackgroundColor3, oldpercentX):lerp(black, oldpercentY)
                                    BRIGHTNESS.BackgroundColor3 = startC:lerp(endC, num - math.floor(num)) or Color3.new(0, 0, 0)
                                    updateValue(color)
                                    
                                    lerp(PICKER_HUE.Position.X.Offset,  mouse.X - HUE.AbsolutePosition.X, 0.1, function(value)
                                        PICKER_HUE.Position = UDim2.new(0, value, 0.5, 0)
                                    end)
                                end
                            end
                        end)
                        
                        local leave
                        leave = Utility:Connection(HUE.MouseLeave, function()
                            input:disconnect()
                            leave:disconnect()
                        end)
                    end)
                    

                    Utility:Connection(TRANSPARENCY.MouseEnter, function()
                        local input = Utility:Connection(_uis.InputBegan, function(key)
                            if key.UserInputType == Enum.UserInputType.MouseButton1 then
                                    while heartbeat:wait() and _uis:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                                        if mouse.X >= TRANSPARENCY.AbsolutePosition.X and mouse.X <= TRANSPARENCY.AbsolutePosition.X + TRANSPARENCY.AbsoluteSize.X then -- check if mouse is between transparency 
                                            local output = (mouse.X - TRANSPARENCY.AbsolutePosition.X) / TRANSPARENCY.AbsoluteSize.X
                                            local value = math.clamp(output * (1 - 0) + 0, 0, 1)
    
                                            options.gettransparency(value)
                                            Utility.Flags[options.transflag].value = value
                                            lerp(PICKER_TRANSPARENCY.Position.X.Offset, mouse.X - TRANSPARENCY.AbsolutePosition.X, 0.1, function(value)
                                                PICKER_TRANSPARENCY.Position = UDim2.new(0,value,0.5,0)
                                            end)
                                        end
                                    end
                                end
                            end)
                                local leave
                                leave = Utility:Connection(TRANSPARENCY.MouseLeave, function()
                                input:disconnect()
                                leave:disconnect()
                        end)
                    end)

                    Utility.Flags[options.transflag].set = function(value)
                        options.gettransparency(value)
                        Utility.Flags[options.transflag].value = value
                    end

                    local isDragging = false
                    Utility:Connection(_uis.InputBegan, function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = true end
                    end)
                    Utility:Connection(_uis.InputEnded, function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end
                    end)
                    local brightnessEnter
                    Utility:Connection(BRIGHTNESS.MouseEnter, function()
                        brightnessEnter = true
                        local input = Utility:Connection(BRIGHTNESS.InputBegan, function(key)
                            if key.UserInputType == Enum.UserInputType.MouseButton1 then
                                while heartbeat:wait() and _uis:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                                    local xPercent = (brightnessX - BRIGHTNESS.AbsolutePosition.X) / BRIGHTNESS.AbsoluteSize.X
                                    local yPercent = (brightnessY - BRIGHTNESS.AbsolutePosition.Y - 36) / BRIGHTNESS.AbsoluteSize.Y
                                    local color = white:lerp(BRIGHTNESS.BackgroundColor3, xPercent):lerp(black, yPercent)
                                    updateValue(color)
                                    oldpercentX, oldpercentY = xPercent, yPercent

                                    local offsetX = brightnessX - BRIGHTNESS.AbsolutePosition.X
                                    local offsetY = brightnessY - BRIGHTNESS.AbsolutePosition.Y - 35
                                    PICKER_BRIGHTNESS.Position = UDim2.new(0, offsetX, 0, offsetY)
                                end
                            end
                        end)
                        local leave
                        leave = Utility:Connection(BRIGHTNESS.MouseLeave, function()
                            input:Disconnect()
                            leave:Disconnect()
                        end)
                    end)

                    Utility:Connection(BRIGHTNESS.MouseLeave, function()
                        brightnessEnter = false
                    end)

                    Utility:Connection(HUE.MouseMoved, function(x, _) hueX = x end)
                    Utility:Connection(HUE.MouseMoved, function(x, _) hueX = x end)

                    Utility:Connection(BRIGHTNESS.MouseMoved, function(x, y) if brightnessEnter then brightnessX,brightnessY = x,y end end)

                    options.default = options.default
                    updateValue(options.default or Color3.new(1,1,1))
                    Utility.Flags[options.colorflag].set = updateValue
                end
                return funcs
            end
            function funcs.AddDropdown(options)
                options = Utility.Validate({
                    name = "example dropdown",
                    flag = nil,
                    list = {"example 1", "example 2", "example 3", "example 4"},
                    min = 1,
                    max = 1,
                    default = 1,
                    callback = function(active) end
                }, options or {})
                options.default = options.default or 1
                dropdownindex = dropdownindex - 1
                
                if not options.flag then error("exception: FLAG on: " .. options.name) end
                Utility.Flags[options.flag] = {value = {}}

                local dropdown = {
                    Hover = false,
                    active = {},
                    state = false
                }

                local DROPDOWNCONTAINER = Utility:Create("Frame", {
                    Parent = ELEMENTCONTAINER,
                    Size = UDim2.new(1, 0, 0, 42),
                    BackgroundTransparency = 1,
                    Name = "DropdownContainer"
                })

                Utility:Create("TextLabel", {
                    Parent = DROPDOWNCONTAINER,
                    Position = UDim2.new(0, 1, 0, 2),
                    Size = UDim2.new(1,0,0,10),
                    BackgroundTransparency = 1,
                    TextColor3 = Colors.TextInactive,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    RichText = true,
                    FontFace = Utility.Font,
                    TextSize = 14,
                    Text = options.name,
                })

                local ACTIVECHOICE = Utility:Create("Frame", {
                    Parent = DROPDOWNCONTAINER,
                    AnchorPoint = Vector2.new(0,1),
                    Position = UDim2.new(0,0,1,0),
                    Size = UDim2.new(1, 0, 0, 25),
                    BorderSizePixel = 0
                }) addstroke(ACTIVECHOICE, false, 2, true) Utility:Create("UICorner", { Parent = ACTIVECHOICE, CornerRadius = UDim.new(0,4) })
                Utility:Create("UIGradient", {
                    Parent = ACTIVECHOICE,
                    Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Colors.ElementBottomGradient),
                        ColorSequenceKeypoint.new(1, Colors.ElementTopGradient)
                    },
                    Rotation = 90,
                })

                local ACTIVETEXT = Utility:Create("TextLabel", {
                    Parent = ACTIVECHOICE,
                    Size = UDim2.new(1,0,1,0),
                    Position = UDim2.new(0.5, 5, 0.5, -1),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    FontFace = Utility.Font,
                    TextColor3 = Colors.TextInactive,
                    TextSize = 14,
                    ZIndex = dropdownindex + 5,
                })

                local HOLDERBACKGROUND = Utility:Create('Frame', {
                    Parent = DROPDOWNCONTAINER,
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 0, DROPDOWNCONTAINER.AbsoluteSize.Y + 4),
                    Visible = false,
                    BorderSizePixel = 0,
                    ZIndex = dropdownindex + 5,
                }) addstroke(HOLDERBACKGROUND, false, 2, true) Utility:Create("UICorner", { Parent = HOLDERBACKGROUND, CornerRadius = UDim.new(0,4) })

                Utility:Create("UIGradient", {
                    Parent = HOLDERBACKGROUND,
                    Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Colors.ElementBottomGradient),
                        ColorSequenceKeypoint.new(1, Colors.ElementTopGradient)
                    },
                    Rotation = 90,
                })

                local CHOICEHOLDER = Utility:Create("ScrollingFrame", {
                    Parent = HOLDERBACKGROUND,
                    Size = UDim2.new(1,0,1,0),
                    BackgroundTransparency = 1,
                    ScrollBarThickness = 0,
                    ZIndex = dropdownindex + 5,
                })

                Utility:Create("UIListLayout", {
                    Parent = CHOICEHOLDER,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    FillDirection = Enum.FillDirection.Vertical,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    Padding = UDim.new(0, 4),
                    Name = "ChoiceLayout",
                })

                Utility:Create("UIPadding", {
                    Parent = CHOICEHOLDER,
                    PaddingTop = UDim.new(0, 2),
                    PaddingLeft = UDim.new(0, 2),
                    PaddingRight = UDim.new(0, 2),
                    PaddingBottom = UDim.new(0, 2)
                })

                local holderSize, visstate = 0
                do -- dropdown vis/invis
                    Utility:MouseEvents(ACTIVECHOICE,
                    function() Utility.Tween(ACTIVETEXT, {TextColor3 = Colors.TextActive}) end,
                    function() Utility.Tween(ACTIVETEXT, {TextColor3 = Colors.TextInactive}) end,
                    function()
                        visstate = not HOLDERBACKGROUND.Visible
                        if visstate then HOLDERBACKGROUND.Visible = true end
                        Utility.Tween(HOLDERBACKGROUND, {Size = visstate and UDim2.new(1,0,0,holderSize) or UDim2.new(1,0,0,0)} ,function()
                            HOLDERBACKGROUND.Visible = visstate
                        end)
                    end)
                end

                local orderMap = {}
                for index, item in ipairs(options.list) do orderMap[item] = index end
                
                local lastchoice

                local function HandleState(isActive, object, hover)
                    local textColor = isActive and Colors.TextActive or Colors.TextInactive
                    local textPosition = isActive and UDim2.new(0.5, 20, 0, -1) or UDim2.new(0.5, 5, 0, -1)
                    local circleTransparency = isActive and 0 or 1
                
                    Utility.Tween(object.ChoiceText, {TextColor3 = textColor})
                    Utility.Tween(object.ChoiceText, {Position = textPosition})
                    Utility.Tween(object.ActiveCircle, {BackgroundTransparency = circleTransparency})
                
                    if hover then return end
                
                    if isActive then
                        if not table.find(dropdown.active, object.Name) then
                            table.insert(dropdown.active, object.Name)
                        end
                        if not table.find(Utility.Flags[options.flag].value, object.Name) then
                            table.insert(Utility.Flags[options.flag].value, object.Name)
                        end
                        lastchoice = object.Name
                    else
                        local activeIndex = table.find(dropdown.active, object.Name)
                        if activeIndex then
                            table.remove(dropdown.active, activeIndex)
                        end
                        local flagIndex = table.find(Utility.Flags[options.flag].value, object.Name)
                        if flagIndex then
                            table.remove(Utility.Flags[options.flag].value, flagIndex)
                        end
                    end
                
                    object:SetAttribute("state", isActive)
                
                    table.sort(dropdown.active, function(a, b)
                        return orderMap[a] < orderMap[b]
                    end)
                
                    ACTIVETEXT.Text = table.concat(dropdown.active, ", ")
                
                    options.callback(ACTIVETEXT.Text)
                
                    while ACTIVETEXT.TextBounds.X > ACTIVECHOICE.AbsoluteSize.X do
                        local clonedtable = table.clone(dropdown.active)
                        table.remove(clonedtable, #clonedtable)
                        ACTIVETEXT.Text = table.concat(clonedtable, ", ") .. ".."
                    end
                end

                function dropdown.AddChoice(name)
                    local CHOICE = Utility:Create("Frame", {
                        Parent = CHOICEHOLDER,
                        Size = UDim2.new(1,0,0,20),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        ZIndex = dropdownindex + 5,
                        Name = name
                    }) CHOICE:SetAttribute("state", false)

                    local ACTIVECIRCLE = Utility:Create("Frame", {
                        Parent = CHOICE,
                        Position = UDim2.new(0,5,0.5,0),
                        AnchorPoint = Vector2.new(0,0.5),
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0,10,0,10),
                        BorderSizePixel = 0,
                        ZIndex = dropdownindex + 5,
                        Name = "ActiveCircle"
                    }) Utility:Create("UICorner", { Parent = ACTIVECIRCLE, CornerRadius = UDim.new(0,100) })
                
                    Utility:Create("UIGradient", {
                        Parent = ACTIVECIRCLE,
                        Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0.0, relight(Colors.Accent, 2)),
                            ColorSequenceKeypoint.new(1.0, Colors.Accent)
                        },
                        Rotation = 90
                    })

                    Utility:Create("TextLabel", {
                        Parent = CHOICE,
                        Size = UDim2.new(1,-5,1,0),
                        AnchorPoint = Vector2.new(0.5,0),
                        Position = UDim2.new(0.5, 5, 0, -1),
                        BackgroundTransparency = 1,
                        FontFace = Utility.Font,
                        Text = name,
                        TextColor3 = Colors.TextInactive,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextSize = 14,
                        Name = "ChoiceText",
                        ZIndex = dropdownindex + 5,
                    })
                    
                    if name == options.list[options.default] then
                        HandleState(true, CHOICE)
                    end

                    do -- Functionality for MouseEvents
                        Utility:MouseEvents(CHOICE,
                            function() if not CHOICE:GetAttribute("state") then HandleState(true, CHOICE, true) end end,
                            function() if not CHOICE:GetAttribute("state") then HandleState(false, CHOICE, true) end end,
                            function()
                                local count = #dropdown.active
                    
                                if not CHOICE:GetAttribute("state") then -- select
                                    if count < options.max then HandleState(true, CHOICE, false)
                                    elseif count == options.max then -- switch from last state
                                        for _, choice in pairs(CHOICEHOLDER:GetChildren()) do
                                            if choice.Name == lastchoice then
                                                HandleState(false, choice, false)
                                                break
                                            end
                                        end
                                        HandleState(true, CHOICE, false)
                                    end
                                else -- deselect
                                    if count > options.min then HandleState(false, CHOICE, false) end
                                end
                            end
                        )
                    end

                    holderSize = holderSize + CHOICE.AbsoluteSize.Y + 6
                end
                for _,v in pairs(options.list) do dropdown.AddChoice(v) end

                Utility.Flags[options.flag].set = function(active)
                    dropdown.active = {}
                    Utility.Flags[options.flag].value = {}
                
                    for _, value in ipairs(active) do
                        if not table.find(dropdown.active, value) then
                            table.insert(dropdown.active, value)
                        end
                        if not table.find(Utility.Flags[options.flag].value, value) then
                            table.insert(Utility.Flags[options.flag].value, value)
                        end
                    end
                
                    for _, choice in pairs(CHOICEHOLDER:GetChildren()) do
                        if choice:IsA("UIListLayout") or choice:IsA("UIPadding") then continue end
                        if table.find(active, choice.Name) then
                            HandleState(true, choice, false)
                        else
                            HandleState(false, choice, false)
                        end
                    end
                end

                return
            end
            function funcs.AddSlider(options)
                options = Utility.Validate({
                    name = "example slider",
                    flag = nil,
                    default = 50,
                    suffix = "",
                    min = 0,
                    max = 100,
                    callback = function() end
                }, options or {})
                if not options.flag then error("exception: FLAG on: " .. options.name) end
                Utility.Flags[options.flag] = {value = options.default}

                local slider = { MouseDown = false, Hover = false, Connection = nil }
                options.value = 0
                if options.min then if options.default < options.min then options.default = options.min end end
            
                local SLIDERCONTAINER = Utility:Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 30),
                    Parent = ELEMENTCONTAINER,
                    BackgroundTransparency = 1,
                    Name = "SliderContainer"
                })
            
                Utility:Create("TextLabel", {
                    Parent = SLIDERCONTAINER,
                    Position = UDim2.new(0, 1, 0, 2),
                    Size = UDim2.new(1,0,0,10),
                    BackgroundTransparency = 1,
                    TextColor3 = Colors.TextInactive,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    RichText = true,
                    FontFace = Utility.Font,
                    TextSize = 14,
                    Text = options.name,
                })
            
                local SLIDERVALUE = Utility:Create("TextBox", {
                    Parent = SLIDERCONTAINER,
                    Size = UDim2.new(1,0,0,10),
                    AnchorPoint = Vector2.new(1,0),
                    Position = UDim2.new(1, -1, 0, 2),
                    BackgroundTransparency = 1,
                    Selectable = false,
                    TextColor3 = Colors.TextInactive,
                    FontFace = Utility.Font,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Text = tostring(options.default) .. options.suffix,
                    TextSize = 14,
                    Name = options.name
                })
            
                local SLIDERBACK = Utility:Create("Frame", {
                    Parent = SLIDERCONTAINER,
                    AnchorPoint = Vector2.new(0,.5),
                    Position = UDim2.new(0,0,.5,8),
                    BackgroundColor3 = Color3.fromRGB(10,10,10),
                    Size = UDim2.new(1, 0, 0, 6),
                    BorderSizePixel = 0
                }) Utility:Create("UICorner", { Parent = SLIDERBACK, CornerRadius = UDim.new(0,12) })
            
                local SLIDER = Utility:Create("Frame", {
                    Parent = SLIDERBACK,
                    Size = UDim2.new((options.default - options.min) / (options.max - options.min), 1),
                    Name = "Slider",
                    ZIndex = 2,
                    BorderSizePixel = 0
                }) Utility:Create("UICorner", { Parent = SLIDER, CornerRadius = UDim.new(0,12) })
            
                Utility:Create("UIGradient", {
                    Parent = SLIDER,
                    Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0.0, relight(Colors.Accent, 1.8)),
                        ColorSequenceKeypoint.new(0.6, relight(Colors.Accent, 1.8)),
                        ColorSequenceKeypoint.new(1.0, Color3.fromRGB(0,0,0))
                    },
                })
            
                local DRAGBAR = Utility:Create("Frame", {
                    Parent = SLIDER,
                    Position = UDim2.new(1,0,0.5,0),
                    AnchorPoint = Vector2.new(1,0.5),
                    Size = UDim2.new(0,15,0,15),
                    BorderSizePixel = 0,
                    ZIndex = 2,
                }) Utility:Create("UICorner", { Parent = DRAGBAR, CornerRadius = UDim.new(0,100) })
            
                Utility:Create("UIGradient", {
                    Parent = DRAGBAR,
                    Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0.0, relight(Colors.ElementTopGradient, 2)),
                        ColorSequenceKeypoint.new(1.0, Colors.ElementBottomGradient)
                    },
                    Rotation = 90
                })
            
                local numberValue = Instance.new("NumberValue")
                function slider:SetValue(v: number)
                    local targetValue
                    if v == nil then
                        local output = (mouse.X - SLIDERBACK.AbsolutePosition.X) / SLIDERBACK.AbsoluteSize.X
                        targetValue = math.clamp(math.round(output * (options.max - options.min) + options.min), options.min, options.max)
                    else targetValue = v
                    end

                    numberValue.Value = tonumber(SLIDERVALUE.Text)
                    local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
                    local tweenGoal = { Value = targetValue }

                    local tween = tweenService:Create(numberValue, tweenInfo, tweenGoal)
                    tween:Play()

                    numberValue:GetPropertyChangedSignal("Value"):Connect(function()
                        SLIDERVALUE.Text = string.format("%.1f", numberValue.Value) .. options.suffix
                        Utility.Flags[options.flag].value = slider:GetValue()
                        options.callback(slider:GetValue())
                    end)
                    SLIDER:TweenSize(UDim2.fromScale((targetValue - options.min) / (options.max - options.min), 1), Enum.EasingDirection.In, Enum.EasingStyle.Linear, 0.1, true)
                    Utility.Flags[options.flag].value = slider:GetValue()
                    options.callback(slider:GetValue())
                end
            
                function slider:GetValue()
                    local value = tonumber(numberValue.Value)
                    if options.suffix then
                        local suffixLength = string.len(options.suffix)
                        return tonumber(string.sub(SLIDERVALUE.Text, 1, -suffixLength - 1))
                    else
                        return value
                    end
                end
                Utility:Connection(SLIDERVALUE.FocusLost, function(enterPressed)
                    local text = tonumber(SLIDERVALUE.Text)
                    if text >= options.min and text <= options.max then
                        if enterPressed then
                            slider:SetValue(text)
                        end
                    end
                    
                end)
                do -- Functionality
                    Utility:MouseEvents(SLIDERBACK,
                        function() slider.Hover = true getgenv().slideractive = true end,
                        function() slider.Hover = false getgenv().slideractive = false end,
                        function()
                            Utility.Tween(SLIDERVALUE, {TextColor3 = Colors.TextActive})
                            if not slider.Connection then
                                slider.Connection = Utility:Connection(_runservice.RenderStepped, function()
                                    slider:SetValue()
                                    if not slider.Hover then Utility.Tween(SLIDERVALUE, {TextColor3 = Colors.TextInactive}) end
                                end)
                            end
                        end
                    )
            
                    Utility:Connection(_uis.InputEnded, function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            slider.Hover = false
                            Utility.Tween(SLIDERVALUE, {TextColor3 = Colors.ElementText})
                            if slider.Connection then slider.Connection:Disconnect() end
                            slider.Connection = nil
                        end
                    end)

                    slider:SetValue(options.default)
                    options.callback(slider:GetValue())
                    Utility.Flags[options.flag].set = function(v) slider:SetValue(v) end
                end

                return
            end
            function funcs.AddConfigList(options)
                options = Utility.Validate({
                    callback = function(active) end
                }, options or {})
                local List = { CurrentChoice = nil }

                local LISTCONTAINER = Utility:Create("Frame", {
                    Parent = ELEMENTCONTAINER,
                    Size = UDim2.new(1, 0, 0, 100),
                    Name = options.name,
                }) addstroke(LISTCONTAINER, false, 2, true) Utility:Create("UICorner", { Parent = LISTCONTAINER, CornerRadius = UDim.new(0,4) })

                Utility:Create("UIGradient", {
                    Parent = LISTCONTAINER,
                    Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Colors.ElementBottomGradient),
                        ColorSequenceKeypoint.new(1, Colors.ElementTopGradient)
                    },
                    Rotation = 90,
                })

                local CHOICEHOLDER = Utility:Create("ScrollingFrame", {
                    Parent = LISTCONTAINER,
                    Size = UDim2.new(1,0,1,0),
                    BackgroundTransparency = 1,
                    ScrollBarThickness = 0,
                })

                Utility:Create("UIListLayout", {
                    Parent = CHOICEHOLDER,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    FillDirection = Enum.FillDirection.Vertical,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    Padding = UDim.new(0, 4),
                    Name = "ChoiceLayout",
                })

                Utility:Create("UIPadding", {
                    Parent = CHOICEHOLDER,
                    PaddingTop = UDim.new(0, 2),
                    PaddingLeft = UDim.new(0, 2),
                    PaddingRight = UDim.new(0, 2),
                    PaddingBottom = UDim.new(0, 2)
                })

                local function HandleState(isActive, object, hover)
                    local textColor = isActive and Colors.TextActive or Colors.TextInactive
                    local textPosition = isActive and UDim2.new(0.5, 20, 0, -1) or UDim2.new(0.5, 5, 0, -1)
                    local circleTransparency = isActive and 0 or 1
                
                    Utility.Tween(object.ChoiceText, {TextColor3 = textColor})
                    Utility.Tween(object.ChoiceText, {Position = textPosition})
                    Utility.Tween(object.ActiveCircle, {BackgroundTransparency = circleTransparency})
                    if hover then return end

                    object:SetAttribute("state", isActive)
                    if isActive then options.callback(object.Name) end
                end
                function List.AddChoice(name)
                    local CHOICE = Utility:Create("Frame", {
                        Parent = CHOICEHOLDER,
                        Size = UDim2.new(1,0,0,20),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        ZIndex = dropdownindex + 5,
                        Name = name
                    }) CHOICE:SetAttribute("state", false)

                    local ACTIVECIRCLE = Utility:Create("Frame", {
                        Parent = CHOICE,
                        Position = UDim2.new(0,5,0.5,0),
                        AnchorPoint = Vector2.new(0,0.5),
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0,10,0,10),
                        BorderSizePixel = 0,
                        ZIndex = dropdownindex + 5,
                        Name = "ActiveCircle"
                    }) Utility:Create("UICorner", { Parent = ACTIVECIRCLE, CornerRadius = UDim.new(0,100) })
                
                    Utility:Create("UIGradient", {
                        Parent = ACTIVECIRCLE,
                        Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0.0, relight(Colors.Accent, 2)),
                            ColorSequenceKeypoint.new(1.0, Colors.Accent)
                        },
                        Rotation = 90
                    })

                    Utility:Create("TextLabel", {
                        Parent = CHOICE,
                        Size = UDim2.new(1,-5,1,0),
                        AnchorPoint = Vector2.new(0.5,0),
                        Position = UDim2.new(0.5, 5, 0, -1),
                        BackgroundTransparency = 1,
                        FontFace = Utility.Font,
                        Text = name,
                        TextColor3 = Colors.TextInactive,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextSize = 14,
                        Name = "ChoiceText",
                        ZIndex = dropdownindex + 5,
                    })

                    Utility:MouseEvents(CHOICE,
                    function()
                        if not CHOICE:GetAttribute("state") then HandleState(true, CHOICE, true) end
                    end,
                    function()
                        if not CHOICE:GetAttribute("state") then HandleState(false, CHOICE, true) end
                    end,
                    function()
                        HandleState(true, CHOICE, false)
                        for _,v in pairs(CHOICEHOLDER:GetChildren()) do
                            if v:IsA("UIListLayout") or v:IsA("UIPadding") then continue end
                            if v.Name ~= CHOICE.Name then HandleState(false, v, false) end
                        end
                    end)

                end

                function List:Refresh()
                    for _,v in pairs(CHOICEHOLDER:GetDescendants()) do
                        if v:IsA("UIListLayout") then continue end
                        v:Destroy()
                    end
                    local conflist = listfiles("uilibrary/configs/")
                    for _,v in pairs(conflist) do
                        local firstSlash = v:find("/", 1, true)
                        local secondSlash = v:find("/", firstSlash + 1, true)
                        local result = v:sub(secondSlash + 1)
                        List.AddChoice(result)
                    end
                end List:Refresh()

                return List
            end
            return funcs
        end
        return funcs
    end
    draggable(WINDOW, INNERCONTAINER)
    return menu
end

do -- Keys
    -- Open / Close
    _uis.MouseIconEnabled = false
    Utility:Connection(_uis.InputBegan, function(input)
        if input.KeyCode == Utility.Ui_Bind then
            SCREENGUI.Enabled = not SCREENGUI.Enabled
            _uis.MouseIconEnabled = not SCREENGUI.Enabled
            Utility.Menu_Visible = SCREENGUI.Enabled
            if SCREENGUI.Enabled then
                blur.Enabled = true
                Utility.Tween(blur, {Size = 20})
            else
                Utility.Tween(blur, {Size = 0}, function()
                    blur.Enabled = false
                end)
            end
        end
    end)
    -- Destroy
    Utility:Connection(_uis.InputBegan, function(input)
        if input.KeyCode == Utility.Unload_Bind then
            Utility:Unload()
        end
    end)
end
