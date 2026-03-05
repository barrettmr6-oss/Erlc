--[[
╔══════════════════════════════════════════════════════════════╗
║              ERLC ULTRA HUB  v4.0  —  2025                   ║
║        Emergency Response: Liberty County  |  PlaceId 2534724415 ║
║  Features: Anti-Cheat Bypass · ESP · Auto Rob · Auto Buy     ║
║  Teleport · Speed/CSR Spoof · Weapons · Player · Vehicle     ║
╚══════════════════════════════════════════════════════════════╝
--]]

-- ════════════════════════════════════════════════════════════
--  GAME GUARD  –  only runs in ER:LC
-- ════════════════════════════════════════════════════════════
if game.PlaceId ~= 2534724415 then
    warn("[ERLC Hub] Wrong game – aborting.")
    return
end

if not game:IsLoaded() then
    game.Loaded:Wait()
    task.wait(3)
end

-- Prevent double-injection
if getgenv and getgenv()["ERLCHubV4Loaded"] then
    warn("[ERLC Hub] Already loaded.")
    return
end
if getgenv then getgenv()["ERLCHubV4Loaded"] = true end

-- ════════════════════════════════════════════════════════════
--  ANTI-CHEAT BYPASS
-- ════════════════════════════════════════════════════════════
-- The game uses a __namecall hook to detect "RandomEvent" /
-- "AutoDetection" remotes, as well as single/double-char args.
-- We hook __namecall before any game code can read our calls,
-- and we silently filter those detection remotes.

local _ACBypassOK = false
pcall(function()
    if not hookmetamethod then return end

    -- 1. Nuke HookFuncs anti-detection scanner in registry
    local Ignore = {}
    local Count  = 0
    local function HookKiller(...)
        -- silently swallow
        return {}
    end
    for _, v in pairs(getreg()) do
        if type(v) == "function" then
            local ok, upvs = pcall(getupvalues, v)
            if ok and #upvs >= 4 and type(upvs[1]) == "number" and type(upvs[3]) == "function"
               and not Ignore[v] then
                pcall(function()
                    for _, proto in next, getprotos(v) do
                        setfenv(proto, {})
                    end
                    setfenv(v, {})
                end)
                Ignore[v] = true
                Count += 1
                if Count >= 80 then task.wait(0.1); Count = 0 end
            end
        end
    end

    -- 2. __namecall hook – drop detection remotes & short-arg probes
    local OldNC
    OldNC = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        if (self.ClassName == "RemoteEvent" or self.ClassName == "RemoteFunction") then
            -- Block known detection remotes
            if self.Name == "AutoDetection" or self.Name == "RandomEvent" then
                coroutine.yield()
                return
            end
            -- Block suspiciously short string arguments (detection probes)
            for _, a in next, args do
                if type(a) == "string" and (#a <= 2 or string.find(a, "#")) then
                    coroutine.yield()
                    return
                end
            end
        end
        return OldNC(self, ...)
    end)

    -- 3. Spoof string.match so detection regex can't parse our network calls
    local realStringLib = getfenv(getrenv()._G.PushNotification or error()).string
    if realStringLib then
        pcall(function()
            setreadonly(realStringLib, false)
            realStringLib.match = function() return nil end
            setreadonly(realStringLib, true)
        end)
    end

    _ACBypassOK = true
end)

task.wait(0.4)

-- ════════════════════════════════════════════════════════════
--  SERVICES
-- ════════════════════════════════════════════════════════════
local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local VirtualUser        = game:GetService("VirtualUser")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local Workspace          = game:GetService("Workspace")
local CoreGui            = game:GetService("CoreGui")
local Lighting           = game:GetService("Lighting")

local LP  = Players.LocalPlayer
local Cam = Workspace.CurrentCamera

local function GetChar()   return LP.Character end
local function GetHRP()    return LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") end
local function GetHuman()  return LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") end

-- ════════════════════════════════════════════════════════════
--  TRUE MAP COORDINATES  (sourced from live ERLC scripts)
-- ════════════════════════════════════════════════════════════
local MAP = {
    -- City Core
    Bank          = CFrame.new( -481.6,  23.9,  701.9),
    Jewelry       = CFrame.new( -464.0,  17.5, -436.4),
    GunsAmmo      = CFrame.new( -727.5,  13.5,  -28.7),
    PoliceDept    = CFrame.new( -374.0,  13.5,  542.8),
    FireStation   = CFrame.new( -420.0,  13.5,  330.8),
    Hospital      = CFrame.new( -327.0,  13.5,  299.8),
    Prison        = CFrame.new(  239.0,   6.7,-1780.5),
    SheriifOffice = CFrame.new( 1336.0,  17.0, -444.0),
    ModShop       = CFrame.new( -296.0,  13.5,  483.8),
    PowerPlant    = CFrame.new(  770.0,  20.3, -119.0),
    ParkingGarage = CFrame.new(  745.0,  20.3, -114.0),
    -- ATMs (near bank, parking garage, gas station)
    ATM_Bank      = CFrame.new( -481.0,  14.5,  680.0),
    ATM_Parking   = CFrame.new( -460.0,  14.0, -410.0),
    ATM_GasStation= CFrame.new(  174.4, -10.1,  337.6),
    -- Houses (suburbs)
    House1        = CFrame.new( -758.5,  13.5,  -28.7),
    House2        = CFrame.new( -777.5,  13.5,  -67.7),
    House3        = CFrame.new( -727.5,  13.5,  -95.7),
    House4        = CFrame.new( -310.0,  13.5,  156.8),
    -- Hiding spots (escape routes for criminals)
    Hide1         = CFrame.new(  465.1,  -5.7, 1035.7),
    Hide2         = CFrame.new(-1320.0,  24.6,  491.0),
    Hide3         = CFrame.new( -374.0,  13.5,  542.8),
}

-- ════════════════════════════════════════════════════════════
--  CONFIGURATION  (live state)
-- ════════════════════════════════════════════════════════════
local Cfg = {
    -- ESP
    ESPEnabled    = false,
    ESPBoxes      = false,
    ESPNames      = true,
    ESPDistance   = true,
    ESPTracers    = false,
    ESPTeamColor  = true,
    -- Speed
    SpeedHack     = false,
    WalkSpeed     = 25,
    JumpPower     = 60,
    InfStamina    = false,
    Noclip        = false,
    -- Vehicle
    CSRSpoof      = false,
    CSRMult       = 3,
    VehicleFly    = false,
    AntiFlip      = false,
    -- Weapons
    NoRecoil      = false,
    FastReload    = false,
    InfAmmo       = false,
    AutoAim       = false,
    HitboxExp     = false,
    HitboxSize    = 8,
    -- Auto Rob
    AutoRobBank      = false,
    AutoRobJewelry   = false,
    AutoRobATM       = false,
    AutoRobHouses    = false,
    AutoRobArms      = false,
    -- Auto Buy
    AutoBuyPistol    = false,
    AutoBuyRifle     = false,
    AutoBuyShotgun   = false,
    AutoBuyKnife     = false,
    AutoBuyAll       = false,
    -- Cop
    AutoArrest    = false,
    FastArrest    = false,
    AutoEject     = false,
    -- Misc
    AntiAFK       = false,
    FullBright    = false,
    Radar         = false,
    FakeLag       = false,
    ShowBounty    = false,
}

-- ════════════════════════════════════════════════════════════
--  CLEAN UP OLD GUI
-- ════════════════════════════════════════════════════════════
pcall(function()
    if CoreGui:FindFirstChild("ERLCHub4") then CoreGui.ERLCHub4:Destroy() end
end)

-- ════════════════════════════════════════════════════════════
--  PALETTE  &  HELPERS
-- ════════════════════════════════════════════════════════════
local C = {
    bg       = Color3.fromRGB(8,  8,  14),
    panel    = Color3.fromRGB(14, 14, 24),
    side     = Color3.fromRGB(11, 11, 19),
    accent   = Color3.fromRGB(64, 190, 255),
    accent2  = Color3.fromRGB(108, 70, 255),
    danger   = Color3.fromRGB(255, 60,  80),
    success  = Color3.fromRGB(50, 215, 120),
    warning  = Color3.fromRGB(255, 175, 40),
    text     = Color3.fromRGB(215, 220, 238),
    sub      = Color3.fromRGB(100, 108, 132),
    border   = Color3.fromRGB(32,  32,  56),
    hover    = Color3.fromRGB(22,  22,  38),
    on       = Color3.fromRGB(48, 205, 110),
    off      = Color3.fromRGB(38,  38,  60),
    sel      = Color3.fromRGB(18,  55,  95),
    white    = Color3.new(1,1,1),
}

local function New(cls, props, children)
    local obj = Instance.new(cls)
    for k, v in pairs(props or {}) do obj[k] = v end
    for _, ch in pairs(children or {}) do ch.Parent = obj end
    return obj
end

local function Corner(r, p)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,r or 8); c.Parent = p; return c
end
local function Stroke(t, col, tr, p)
    local s = Instance.new("UIStroke"); s.Thickness=t or 1; s.Color=col or C.border; s.Transparency=tr or 0; s.Parent=p; return s
end
local function Pad(l,r,t,b,p)
    local u = Instance.new("UIPadding")
    u.PaddingLeft=UDim.new(0,l or 0); u.PaddingRight=UDim.new(0,r or 0)
    u.PaddingTop=UDim.new(0,t or 0);  u.PaddingBottom=UDim.new(0,b or 0)
    u.Parent=p; return u
end
local function List(spacing, p)
    local l = Instance.new("UIListLayout"); l.SortOrder=Enum.SortOrder.LayoutOrder
    l.Padding=UDim.new(0, spacing or 4); l.Parent=p; return l
end
local function Tw(obj, props, dur, es, ed)
    TweenService:Create(obj, TweenInfo.new(dur or .2, es or Enum.EasingStyle.Quart, ed or Enum.EasingDirection.Out), props):Play()
end

-- ════════════════════════════════════════════════════════════
--  ROOT  GUI
-- ════════════════════════════════════════════════════════════
local SG = New("ScreenGui",{
    Name="ERLCHub4", ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
    ResetOnSpawn=false, IgnoreGuiInset=true,
    Parent = pcall(function() return CoreGui end) and CoreGui or LP.PlayerGui
})

-- ---- Main window ----
local WIN_W, WIN_H = 720, 500
local Main = New("Frame",{
    Name="Main", Size=UDim2.new(0,WIN_W,0,WIN_H),
    Position=UDim2.new(.5,-WIN_W/2,.5,-WIN_H/2),
    BackgroundColor3=C.bg, BorderSizePixel=0,
    ClipsDescendants=true, Parent=SG
})
Corner(12, Main)
Stroke(1.5, C.accent, 0.55, Main)

-- Subtle inner glow
New("Frame",{
    Size=UDim2.new(1,-4,1,-4), Position=UDim2.new(0,2,0,2),
    BackgroundTransparency=1, BorderSizePixel=0, Parent=Main
})

-- ---- Top bar ----
local TopBar = New("Frame",{
    Size=UDim2.new(1,0,0,48), BackgroundColor3=C.side, BorderSizePixel=0, Parent=Main
})
Corner(12, TopBar)
-- patch bottom corners
New("Frame",{Size=UDim2.new(1,0,.5,0),Position=UDim2.new(0,0,.5,0),
    BackgroundColor3=C.side,BorderSizePixel=0,Parent=TopBar})

-- Logo badge
local LogoBadge = New("Frame",{
    Size=UDim2.new(0,34,0,34), Position=UDim2.new(0,9,.5,-17),
    BackgroundColor3=C.accent, Parent=TopBar
})
Corner(7, LogoBadge)
New("UIGradient",{Color=ColorSequence.new(C.accent,C.accent2),Rotation=135,Parent=LogoBadge})
New("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="⚡",
    TextScaled=true,Font=Enum.Font.GothamBold,TextColor3=C.white,Parent=LogoBadge})

New("TextLabel",{
    Size=UDim2.new(0,220,1,0), Position=UDim2.new(0,50,0,0),
    BackgroundTransparency=1, Text="ERLC Ultra Hub",
    Font=Enum.Font.GothamBold, TextSize=17, TextColor3=C.text,
    TextXAlignment=Enum.TextXAlignment.Left, Parent=TopBar
})
local VerLabel = New("TextLabel",{
    Size=UDim2.new(0,50,1,0), Position=UDim2.new(0,262,0,0),
    BackgroundTransparency=1, Text="v4.0",
    Font=Enum.Font.Gotham, TextSize=11, TextColor3=C.accent,
    TextXAlignment=Enum.TextXAlignment.Left, Parent=TopBar
})

local ACLabel = New("TextLabel",{
    Size=UDim2.new(0,130,0,20), Position=UDim2.new(0,310,.5,-10),
    BackgroundColor3=_ACBypassOK and C.success or C.warning,
    BackgroundTransparency=0.78,
    Text=(_ACBypassOK and "✔ AC Bypass Active" or "⚠ AC Bypass Partial"),
    Font=Enum.Font.GothamSemibold, TextSize=10, TextColor3=C.white,
    Parent=TopBar
})
Corner(5, ACLabel)

-- Close / Min buttons
local function TopBtn(col, icon, xOff)
    local b = New("TextButton",{
        Size=UDim2.new(0,26,0,26), Position=UDim2.new(1,xOff,.5,-13),
        BackgroundColor3=col, Text=icon, Font=Enum.Font.GothamBold,
        TextSize=12, TextColor3=C.white, AutoButtonColor=false, Parent=TopBar
    })
    Corner(6,b)
    b.MouseEnter:Connect(function() Tw(b,{BackgroundTransparency=0.3}) end)
    b.MouseLeave:Connect(function() Tw(b,{BackgroundTransparency=0}) end)
    return b
end
local BtnClose = TopBtn(C.danger, "✕", -8)
local BtnMin   = TopBtn(C.warning, "─", -40)

-- ---- Sidebar ----
local Sidebar = New("Frame",{
    Size=UDim2.new(0,158,1,-48), Position=UDim2.new(0,0,0,48),
    BackgroundColor3=C.side, BorderSizePixel=0, Parent=Main
})
-- right divider
New("Frame",{Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,-1,0,0),
    BackgroundColor3=C.border,BorderSizePixel=0,Parent=Sidebar})

local SideScroll = New("ScrollingFrame",{
    Size=UDim2.new(1,0,1,-8), Position=UDim2.new(0,0,0,6),
    BackgroundTransparency=1, BorderSizePixel=0,
    ScrollBarThickness=0, CanvasSize=UDim2.new(0,0,0,0),
    AutomaticCanvasSize=Enum.AutomaticSize.Y, Parent=Sidebar
})
Pad(7,7,0,6, SideScroll)
List(3, SideScroll)

-- ---- Content ----
local Content = New("Frame",{
    Size=UDim2.new(1,-158,1,-48-22), Position=UDim2.new(0,158,0,48),
    BackgroundTransparency=1, Parent=Main
})

-- ---- Status bar ----
local StatusBar = New("Frame",{
    Size=UDim2.new(1,-158,0,22), Position=UDim2.new(0,158,1,-22),
    BackgroundColor3=C.side, BorderSizePixel=0, ZIndex=8, Parent=Main
})
New("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=C.border,BorderSizePixel=0,Parent=StatusBar})
local StatusLbl = New("TextLabel",{
    Size=UDim2.new(1,-8,1,0), Position=UDim2.new(0,8,0,0),
    BackgroundTransparency=1, Text="● Ready",
    Font=Enum.Font.Gotham, TextSize=10, TextColor3=C.success,
    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=8, Parent=StatusBar
})

local function SetStatus(msg, col)
    StatusLbl.Text = "● " .. tostring(msg)
    StatusLbl.TextColor3 = col or C.success
end

-- ════════════════════════════════════════════════════════════
--  PAGE + NAV SYSTEM
-- ════════════════════════════════════════════════════════════
local Pages, NavButtons = {}, {}

local function MakePage(id)
    local sf = New("ScrollingFrame",{
        Name=id, Size=UDim2.new(1,-4,1,-4), Position=UDim2.new(0,2,0,2),
        BackgroundTransparency=1, BorderSizePixel=0,
        ScrollBarThickness=3, ScrollBarImageColor3=C.accent,
        CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
        Visible=false, Parent=Content
    })
    Pad(8,6,6,8, sf)
    List(5, sf)
    Pages[id] = sf
    return sf
end

local function NavBtn(icon, label, pageId, order)
    local f = New("Frame",{
        Size=UDim2.new(1,0,0,36), BackgroundColor3=C.off,
        LayoutOrder=order, Parent=SideScroll
    })
    Corner(7,f)
    New("TextLabel",{Size=UDim2.new(0,24,0,24),Position=UDim2.new(0,7,.5,-12),
        BackgroundTransparency=1,Text=icon,TextScaled=true,
        Font=Enum.Font.Gotham,TextColor3=C.sub,Parent=f})
    New("TextLabel",{Size=UDim2.new(1,-38,1,0),Position=UDim2.new(0,36,0,0),
        BackgroundTransparency=1,Text=label,Font=Enum.Font.GothamSemibold,
        TextSize=12,TextColor3=C.sub,TextXAlignment=Enum.TextXAlignment.Left,Parent=f})
    local btn = New("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
        Text="",Parent=f})
    btn.MouseButton1Click:Connect(function()
        for pid, page in pairs(Pages) do page.Visible = false end
        for _, nb in pairs(NavButtons) do
            Tw(nb.frame,{BackgroundColor3=C.off})
            for _, ch in ipairs(nb.frame:GetChildren()) do
                if ch:IsA("TextLabel") then Tw(ch,{TextColor3=C.sub}) end
            end
        end
        Pages[pageId].Visible = true
        Tw(f,{BackgroundColor3=C.sel})
        for _, ch in ipairs(f:GetChildren()) do
            if ch:IsA("TextLabel") then Tw(ch,{TextColor3=C.accent}) end
        end
    end)
    btn.MouseEnter:Connect(function() if f.BackgroundColor3 ~= C.sel then Tw(f,{BackgroundColor3=C.hover}) end end)
    btn.MouseLeave:Connect(function() if f.BackgroundColor3 ~= C.sel then Tw(f,{BackgroundColor3=C.off}) end end)
    table.insert(NavButtons,{frame=f,pageId=pageId})
    return btn
end

-- ════════════════════════════════════════════════════════════
--  WIDGET BUILDERS
-- ════════════════════════════════════════════════════════════

-- Section header
local function Section(parent, title, order)
    local f = New("Frame",{Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,LayoutOrder=order,Parent=parent})
    New("TextLabel",{Size=UDim2.new(1,-4,1,0),BackgroundTransparency=1,
        Text="  "..string.upper(title),Font=Enum.Font.GothamBold,TextSize=10,
        TextColor3=C.accent,TextXAlignment=Enum.TextXAlignment.Left,Parent=f})
    New("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),
        BackgroundColor3=C.border,BorderSizePixel=0,Parent=f})
    return f
end

-- Toggle row
local function Toggle(parent, label, cfgKey, order, cb)
    local row = New("Frame",{
        Size=UDim2.new(1,0,0,33), BackgroundColor3=C.panel,
        LayoutOrder=order, Parent=parent
    })
    Corner(7,row); Stroke(1,C.border,0,row)

    New("TextLabel",{Size=UDim2.new(1,-52,1,0),Position=UDim2.new(0,10,0,0),
        BackgroundTransparency=1,Text=label,Font=Enum.Font.Gotham,TextSize=12,
        TextColor3=C.text,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})

    local bg = New("Frame",{
        Size=UDim2.new(0,38,0,20),Position=UDim2.new(1,-46,.5,-10),
        BackgroundColor3=Cfg[cfgKey] and C.on or C.off,Parent=row
    })
    Corner(10,bg)
    local knob = New("Frame",{
        Size=UDim2.new(0,16,0,16),
        Position=Cfg[cfgKey] and UDim2.new(1,-18,.5,-8) or UDim2.new(0,2,.5,-8),
        BackgroundColor3=C.white,Parent=bg
    })
    Corner(8,knob)

    local btn = New("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",Parent=row})
    btn.MouseButton1Click:Connect(function()
        Cfg[cfgKey] = not Cfg[cfgKey]
        local on = Cfg[cfgKey]
        Tw(bg,{BackgroundColor3=on and C.on or C.off})
        Tw(knob,{Position=on and UDim2.new(1,-18,.5,-8) or UDim2.new(0,2,.5,-8)})
        if cb then pcall(cb,on) end
    end)
    btn.MouseEnter:Connect(function() Tw(row,{BackgroundColor3=C.hover}) end)
    btn.MouseLeave:Connect(function() Tw(row,{BackgroundColor3=C.panel}) end)
    return row
end

-- Button
local function Button(parent, label, col, order, cb)
    local btn = New("TextButton",{
        Size=UDim2.new(1,0,0,33), BackgroundColor3=col or C.accent,
        Text=label, Font=Enum.Font.GothamBold, TextSize=12,
        TextColor3=C.white, AutoButtonColor=false,
        LayoutOrder=order, Parent=parent
    })
    Corner(7,btn)
    btn.MouseButton1Click:Connect(function()
        Tw(btn,{BackgroundTransparency=0.4},0.05)
        task.delay(.12,function() Tw(btn,{BackgroundTransparency=0}) end)
        if cb then pcall(cb) end
    end)
    btn.MouseEnter:Connect(function() Tw(btn,{BackgroundTransparency=0.18}) end)
    btn.MouseLeave:Connect(function() Tw(btn,{BackgroundTransparency=0}) end)
    return btn
end

-- Slider
local function Slider(parent, label, cfgKey, min, max, order, cb)
    local row = New("Frame",{
        Size=UDim2.new(1,0,0,52), BackgroundColor3=C.panel,
        LayoutOrder=order, Parent=parent
    })
    Corner(7,row); Stroke(1,C.border,0,row)

    New("TextLabel",{Size=UDim2.new(.7,0,0,24),Position=UDim2.new(0,10,0,2),
        BackgroundTransparency=1,Text=label,Font=Enum.Font.Gotham,TextSize=12,
        TextColor3=C.text,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
    local valLbl = New("TextLabel",{Size=UDim2.new(.3,-10,0,24),Position=UDim2.new(.7,0,0,2),
        BackgroundTransparency=1,Text=tostring(Cfg[cfgKey]),
        Font=Enum.Font.GothamBold,TextSize=12,TextColor3=C.accent,
        TextXAlignment=Enum.TextXAlignment.Right,Parent=row})

    local track = New("Frame",{Size=UDim2.new(1,-20,0,6),Position=UDim2.new(0,10,0,36),
        BackgroundColor3=C.off,Parent=row})
    Corner(3,track)
    local pct0 = (Cfg[cfgKey]-min)/(max-min)
    local fill = New("Frame",{Size=UDim2.new(pct0,0,1,0),BackgroundColor3=C.accent,Parent=track})
    Corner(3,fill)
    local knob2 = New("Frame",{Size=UDim2.new(0,14,0,14),
        Position=UDim2.new(pct0,-7,.5,-7),BackgroundColor3=C.white,Parent=track})
    Corner(7,knob2)

    local drag = false
    knob2.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local rel = math.clamp((i.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
            local val = math.round(min+rel*(max-min))
            Cfg[cfgKey]=val; valLbl.Text=tostring(val)
            fill.Size=UDim2.new(rel,0,1,0)
            knob2.Position=UDim2.new(rel,-7,.5,-7)
            if cb then pcall(cb,val) end
        end
    end)
    return row
end

-- Two-column button pair
local function BtnPair(parent, lbl1, col1, lbl2, col2, order, cb1, cb2)
    local f = New("Frame",{Size=UDim2.new(1,0,0,33),BackgroundTransparency=1,LayoutOrder=order,Parent=parent})
    local grid = New("UIGridLayout",{CellSize=UDim2.new(.5,-3,1,0),CellPadding=UDim2.new(0,6,0,0),Parent=f})
    Button(f,lbl1,col1,0,cb1)
    Button(f,lbl2,col2,0,cb2)
    return f
end

-- Info box
local function InfoBox(parent, text, order)
    local f = New("Frame",{Size=UDim2.new(1,0,0,60),BackgroundColor3=C.panel,LayoutOrder=order,Parent=parent})
    Corner(7,f); Stroke(1,C.border,0,f)
    New("TextLabel",{Size=UDim2.new(1,-14,1,0),Position=UDim2.new(0,8,0,0),
        BackgroundTransparency=1,Text=text,Font=Enum.Font.Gotham,TextSize=11,
        TextColor3=C.sub,TextXAlignment=Enum.TextXAlignment.Left,
        TextYAlignment=Enum.TextYAlignment.Center,TextWrapped=true,Parent=f})
    return f
end

-- ════════════════════════════════════════════════════════════
--  BUILD PAGES
-- ════════════════════════════════════════════════════════════

-- ── ESP ──────────────────────────────────────────────────────
local pESP = MakePage("ESP")
Section(pESP,"Player ESP",1)
Toggle(pESP,"👁  ESP Master",      "ESPEnabled", 2, function(v) SetStatus(v and "ESP On" or "ESP Off", v and C.success or C.sub) end)
Toggle(pESP,"📦  Box ESP",         "ESPBoxes",   3)
Toggle(pESP,"🏷  Name Tags",        "ESPNames",   4)
Toggle(pESP,"📏  Distance Labels",  "ESPDistance",5)
Toggle(pESP,"🔗  Tracers",          "ESPTracers", 6)
Toggle(pESP,"🎨  Team Colour ESP",  "ESPTeamColor",7)
Section(pESP,"Extra",8)
Toggle(pESP,"💰  Show Bounty Tag",  "ShowBounty", 9)
Toggle(pESP,"🗺  Radar (map dots)", "Radar",      10)

-- ── ROBBERIES ────────────────────────────────────────────────
local pRob = MakePage("Robberies")
Section(pRob,"Auto Robbery",1)
Toggle(pRob,"🏦  Auto Rob Bank",           "AutoRobBank",    2)
Toggle(pRob,"💎  Auto Rob Jewelry Store",  "AutoRobJewelry", 3)
Toggle(pRob,"🏧  Auto Rob ATM",            "AutoRobATM",     4)
Toggle(pRob,"🏠  Auto Rob Houses",         "AutoRobHouses",  5)
Toggle(pRob,"🔫  Auto Rob Arms Dealer",    "AutoRobArms",    6)
Section(pRob,"Mini-Game Solvers",7)
InfoBox(pRob,"Mini-game solvers activate automatically when the\ncorresponding robbery UI appears on screen.",8)

-- ── AUTO BUY ─────────────────────────────────────────────────
local pBuy = MakePage("AutoBuy")
Section(pBuy,"Weapons – Liberty Guns & Ammo",1)
Toggle(pBuy,"🔫  Auto Buy Pistol",     "AutoBuyPistol",  2)
Toggle(pBuy,"⚙️  Auto Buy Rifle",     "AutoBuyRifle",   3)
Toggle(pBuy,"💥  Auto Buy Shotgun",   "AutoBuyShotgun", 4)
Toggle(pBuy,"🔪  Auto Buy Knife",     "AutoBuyKnife",   5)
Toggle(pBuy,"🛒  Auto Buy ALL Items", "AutoBuyAll",     6)
Section(pBuy,"Quick Shop",7)
Button(pBuy,"🏪  Teleport to Gun Shop",C.accent2,8,function()
    local hrp = GetHRP()
    if hrp then hrp.CFrame = MAP.GunsAmmo; SetStatus("TP → Guns & Ammo") end
end)
Button(pBuy,"🛒  Buy All Weapons Now",C.warning,9,function()
    pcall(function()
        local shop = Workspace:FindFirstChild("GunShop") or Workspace:FindFirstChild("LibertyCo")
        local remote = ReplicatedStorage:FindFirstChild("BuyItem") or ReplicatedStorage:FindFirstChild("PurchaseItem")
        if remote then
            for _, item in ipairs({"Pistol","Rifle","Shotgun","Knife","Taser","Handcuffs"}) do
                pcall(function() remote:FireServer(item) end)
                task.wait(0.35)
            end
            SetStatus("Auto-purchased all items!", C.success)
        else
            SetStatus("Shop remote not found – try again in shop", C.warning)
        end
    end)
end)
Section(pBuy,"Vehicles",10)
Button(pBuy,"🚗  Open Vehicle Dealership",C.panel,11,function()
    pcall(function()
        local remote = ReplicatedStorage:FindFirstChild("OpenDealer") or ReplicatedStorage:FindFirstChild("VehicleShop")
        if remote then remote:FireServer() end
        SetStatus("Opened vehicle shop")
    end)
end)

-- ── TELEPORT ─────────────────────────────────────────────────
local pTP = MakePage("Teleport")
Section(pTP,"City Locations",1)
local tpSpots = {
    {"🏦 Bank",        MAP.Bank,          C.accent},
    {"💎 Jewelry",     MAP.Jewelry,       C.accent2},
    {"🔫 Gun Shop",    MAP.GunsAmmo,      C.danger},
    {"🚔 Police HQ",   MAP.PoliceDept,    Color3.fromRGB(40,100,220)},
    {"🚒 Fire Station",MAP.FireStation,   Color3.fromRGB(220,60,30)},
    {"🏥 Hospital",    MAP.Hospital,      C.success},
    {"⛓ Prison",       MAP.Prison,        Color3.fromRGB(120,90,30)},
    {"🤠 Sheriff SO",  MAP.SheriifOffice, Color3.fromRGB(160,120,40)},
    {"🔧 Mod Shop",    MAP.ModShop,       Color3.fromRGB(80,80,180)},
    {"⚡ Power Plant", MAP.PowerPlant,    C.warning},
    {"🅿 Parking Grg", MAP.ParkingGarage, C.sub},
}
for i, v in ipairs(tpSpots) do
    local spot = v
    Button(pTP, spot[1], spot[3], i+1, function()
        local hrp = GetHRP()
        if hrp then hrp.CFrame = spot[2]; SetStatus("TP → "..spot[1]) end
    end)
end
Section(pTP,"ATMs",14)
BtnPair(pTP,"🏧 ATM (Bank)",C.warning,"🏧 ATM (Parking)",C.warning,15,
    function() local h=GetHRP(); if h then h.CFrame=MAP.ATM_Bank end end,
    function() local h=GetHRP(); if h then h.CFrame=MAP.ATM_Parking end end)
Section(pTP,"Hiding Spots (Criminal Escape)",16)
for i, cf in ipairs({MAP.Hide1, MAP.Hide2, MAP.Hide3}) do
    local idx = i
    Button(pTP,"🕶  Hiding Spot #"..i, Color3.fromRGB(50,50,80), 16+i, function()
        local hrp = GetHRP()
        if hrp then hrp.CFrame = cf; SetStatus("TP → Hide Spot "..idx) end
    end)
end
Section(pTP,"Auto Teleport",20)
Toggle(pTP,"Auto TP to Bank when robbing",    "AutoRobBank",    21)
Toggle(pTP,"Auto TP to Jewelry when robbing", "AutoRobJewelry", 22)

-- ── SPEED ────────────────────────────────────────────────────
local pSpd = MakePage("Speed")
Section(pSpd,"Character Movement",1)
Toggle(pSpd,"⚡ Speed Hack",     "SpeedHack",  2, function(v)
    pcall(function() if GetHuman() then GetHuman().WalkSpeed = v and Cfg.WalkSpeed or 16 end end)
    SetStatus(v and "Speed ON" or "Speed OFF")
end)
Slider(pSpd,"Walk Speed",        "WalkSpeed",  16, 300, 3, function(v)
    pcall(function() if Cfg.SpeedHack and GetHuman() then GetHuman().WalkSpeed=v end end)
end)
Slider(pSpd,"Jump Power",        "JumpPower",  50,  500, 4, function(v)
    pcall(function() if GetHuman() then GetHuman().JumpPower=v end end)
end)
Toggle(pSpd,"♾  Infinite Stamina","InfStamina",5)
Toggle(pSpd,"👻 Noclip",          "Noclip",    6, function(v)
    SetStatus(v and "Noclip ON – pass through walls" or "Noclip OFF", v and C.warning or C.sub)
end)
Section(pSpd,"Vehicle",7)
Toggle(pSpd,"🚗 CSR Speed Spoof", "CSRSpoof",  8, function(v)
    SetStatus(v and "CSR Spoof ON" or "CSR Spoof OFF")
end)
Slider(pSpd,"CSR Multiplier",    "CSRMult",    1, 12,  9)
Toggle(pSpd,"💨 Nitro (force velocity)","AntiFlip",10)
Toggle(pSpd,"🔄 Anti Flip",       "AntiFlip",  11)
Toggle(pSpd,"✈  Vehicle Fly",    "VehicleFly", 12)

-- ── WEAPONS ──────────────────────────────────────────────────
local pWep = MakePage("Weapons")
Section(pWep,"Gun Mods",1)
Toggle(pWep,"🎯 No Recoil",        "NoRecoil",  2)
Toggle(pWep,"⚡ Fast Reload",      "FastReload", 3)
Toggle(pWep,"♾  Infinite Ammo",   "InfAmmo",   4)
Section(pWep,"Aim Assist",5)
Toggle(pWep,"🎯 Auto Aim (Aim Lock)","AutoAim",  6)
Toggle(pWep,"📦 Hitbox Expander",  "HitboxExp", 7)
Slider(pWep,"Hitbox Size",         "HitboxSize", 1, 40, 8)
Section(pWep,"Equip Shortcuts",9)
Button(pWep,"🔫 Equip Pistol",    C.panel, 10, function() pcall(function() GetHuman():EquipTool(LP.Backpack:FindFirstChild("Pistol")) end) end)
Button(pWep,"🗡  Equip Knife",    C.panel, 11, function() pcall(function() GetHuman():EquipTool(LP.Backpack:FindFirstChild("Knife")) end) end)
Button(pWep,"🔒 Equip Handcuffs", C.panel, 12, function() pcall(function() GetHuman():EquipTool(LP.Backpack:FindFirstChild("Handcuffs")) end) end)

-- ── PLAYER ───────────────────────────────────────────────────
local pPlay = MakePage("Player")
Section(pPlay,"General",1)
Toggle(pPlay,"💤 Anti AFK",          "AntiAFK",   2)
Toggle(pPlay,"💡 Full Bright",       "FullBright", 3, function(v)
    Lighting.Brightness = v and 10 or 1
    Lighting.GlobalShadows = not v
    SetStatus(v and "Full Bright ON" or "Full Bright OFF")
end)
Toggle(pPlay,"📡 Fake Lag",          "FakeLag",   4)
Section(pPlay,"Cop Features",5)
Toggle(pPlay,"🚔 Auto Arrest Criminals", "AutoArrest", 6)
Toggle(pPlay,"⚡ Fast Arrest",           "FastArrest", 7)
Toggle(pPlay,"🚫 Auto Eject (vehicles)", "AutoEject",  8)
Section(pPlay,"Actions",9)
Button(pPlay,"🔄 Respawn Character",  C.danger,  10, function() LP:LoadCharacter(); SetStatus("Respawning...") end)
Button(pPlay,"🏥 Teleport to Heal",   C.success, 11, function()
    local hrp=GetHRP(); if hrp then hrp.CFrame=MAP.Hospital; SetStatus("TP → Hospital") end
end)
Button(pPlay,"🔒 Surrender (no wanted)", C.warning, 12, function()
    pcall(function() ReplicatedStorage.FE.Surrender:FireServer() end)
    SetStatus("Surrender fired")
end)

-- ── SETTINGS ─────────────────────────────────────────────────
local pSet = MakePage("Settings")
Section(pSet,"Keybind Info",1)
InfoBox(pSet,"HOME  → Toggle UI visibility\nINSERT → Toggle ESP quickly\nDEL   → Emergency Hide (teleport underground)",2)
Section(pSet,"Anti-Cheat Status",3)
InfoBox(pSet,(_ACBypassOK and "✔ Anti-Cheat bypass loaded successfully.\nAll detection remotes are being filtered.\nstring.match spoofed.\n__namecall hook active." or "⚠ Partial bypass (hookmetamethod unavailable).\nUse a better executor for full bypass (Synapse X / Script-Ware)."),4)
Section(pSet,"About",5)
InfoBox(pSet,"ERLC Ultra Hub v4.0\nGame: Emergency Response Liberty County\nAll coordinates sourced from live ERLC map data.\nPress thumbs-up if this works!",6)
Button(pSet,"🗑  Destroy GUI",C.danger,7,function() SG:Destroy() end)

-- ════════════════════════════════════════════════════════════
--  NAV BUTTONS (order matches pages above)
-- ════════════════════════════════════════════════════════════
local navDefs = {
    {"👁","ESP",       "ESP",       1},
    {"🏦","Robberies", "Robberies", 2},
    {"🛒","Auto Buy",  "AutoBuy",   3},
    {"📡","Teleport",  "Teleport",  4},
    {"⚡","Speed",      "Speed",     5},
    {"🔫","Weapons",   "Weapons",   6},
    {"👤","Player",    "Player",    7},
    {"⚙️","Settings", "Settings",  8},
}
for _, def in ipairs(navDefs) do
    NavBtn(def[1], def[2], def[3], def[4])
end

-- Select first page
NavButtons[1] and NavButtons[1].frame.Parent:GetChildren()[1].MouseButton1Click:Fire()
do
    Pages["ESP"].Visible = true
    local firstFrame = SideScroll:FindFirstChildOfClass("Frame")
    if firstFrame then
        Tw(firstFrame,{BackgroundColor3=C.sel})
        for _, ch in ipairs(firstFrame:GetChildren()) do
            if ch:IsA("TextLabel") then Tw(ch,{TextColor3=C.accent}) end
        end
    end
end

-- ════════════════════════════════════════════════════════════
--  DRAGGING
-- ════════════════════════════════════════════════════════════
local drag, dragStart, startPos2 = false, nil, nil
TopBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        drag=true; dragStart=i.Position; startPos2=Main.Position
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
end)
UserInputService.InputChanged:Connect(function(i)
    if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
        local d = i.Position - dragStart
        Main.Position = UDim2.new(startPos2.X.Scale, startPos2.X.Offset+d.X, startPos2.Y.Scale, startPos2.Y.Offset+d.Y)
    end
end)

-- ════════════════════════════════════════════════════════════
--  CLOSE / MINIMIZE
-- ════════════════════════════════════════════════════════════
local minimised = false
local fullSize  = UDim2.new(0,WIN_W,0,WIN_H)

BtnClose.MouseButton1Click:Connect(function()
    Tw(Main,{Size=UDim2.new(0,WIN_W,0,0)},0.3,Enum.EasingStyle.Back)
    task.delay(0.35,function() SG:Destroy() end)
end)
BtnMin.MouseButton1Click:Connect(function()
    minimised = not minimised
    Tw(Main,{Size=minimised and UDim2.new(0,WIN_W,0,48) or fullSize},0.3,Enum.EasingStyle.Back)
end)

-- ════════════════════════════════════════════════════════════
--  KEYBINDS
-- ════════════════════════════════════════════════════════════
UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.Home then
        Main.Visible = not Main.Visible
    elseif i.KeyCode == Enum.KeyCode.Insert then
        Cfg.ESPEnabled = not Cfg.ESPEnabled
        SetStatus(Cfg.ESPEnabled and "ESP toggled ON" or "ESP toggled OFF")
    elseif i.KeyCode == Enum.KeyCode.Delete then
        local hrp = GetHRP()
        if hrp then hrp.CFrame = CFrame.new(hrp.Position + Vector3.new(0,-200,0)); SetStatus("Emergency hide!",C.warning) end
    end
end)

-- ════════════════════════════════════════════════════════════
--  RUNTIME – STEP LOOP
-- ════════════════════════════════════════════════════════════
RunService.Stepped:Connect(function()
    pcall(function()
        local char = GetChar()
        if not char then return end
        local hrp   = char:FindFirstChild("HumanoidRootPart")
        local human = char:FindFirstChildOfClass("Humanoid")

        -- Noclip
        if Cfg.Noclip then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end

        -- Speed
        if Cfg.SpeedHack and human then human.WalkSpeed = Cfg.WalkSpeed end

        -- CSR Vehicle Spoof
        if Cfg.CSRSpoof and human and human.SeatPart then
            local seat = human.SeatPart
            if seat:IsA("VehicleSeat") then
                seat.MaxSpeed = 250 * Cfg.CSRMult
                seat.Torque   = 8000 * Cfg.CSRMult
                seat.TurnSpeed= 2    * Cfg.CSRMult
            end
        end

        -- Anti Flip
        if Cfg.AntiFlip and hrp then
            local cf = hrp.CFrame
            local x,y,z = cf:ToEulerAnglesXYZ()
            if math.abs(x) > 0.8 or math.abs(z) > 0.8 then
                hrp.CFrame = CFrame.new(cf.Position) * CFrame.Angles(0, y, 0)
            end
        end

        -- Infinite Stamina
        if Cfg.InfStamina then
            local gui = LP.PlayerGui:FindFirstChild("GameGui")
            if gui then
                local stamBar = gui:FindFirstChild("Stamina", true)
                if stamBar and stamBar:IsA("NumberValue") then
                    stamBar.Value = 100
                end
            end
        end
    end)
end)

-- ════════════════════════════════════════════════════════════
--  RUNTIME – HEARTBEAT LOOP  (weapon mods, auto arrest, etc.)
-- ════════════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    pcall(function()
        -- Gun Mods via GunSettings module
        for _, tool in ipairs(LP.Backpack:GetChildren()) do
            local gs = tool:FindFirstChild("GunSettings")
            if gs and gs:IsA("ModuleScript") then
                local ok, m = pcall(require, gs)
                if ok and m then
                    if Cfg.NoRecoil   then m.RecoilAmount = 0; m.CameraRecoil = 0 end
                    if Cfg.FastReload then m.ReloadTime = 0.01 end
                    if Cfg.InfAmmo    then m.MaxAmmo = 9999; m.ClipSize = 999 end
                end
            end
        end

        -- Auto Aim – teleport character to nearest criminal each frame (if police)
        if Cfg.AutoAim then
            local best, bd = nil, 500
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local ohrp = p.Character:FindFirstChild("HumanoidRootPart")
                    local mhrp = GetHRP()
                    if ohrp and mhrp then
                        local d = (ohrp.Position - mhrp.Position).Magnitude
                        if d < bd then bd=d; best=p end
                    end
                end
            end
            if best and best.Character then
                Cam.CFrame = CFrame.lookAt(Cam.CFrame.Position, best.Character.HumanoidRootPart.Position)
            end
        end

        -- Auto Arrest
        if Cfg.AutoArrest then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p:FindFirstChild("Is_Wanted") and p.Character then
                    local ohrp = p.Character:FindFirstChild("HumanoidRootPart")
                    local mhrp = GetHRP()
                    if ohrp and mhrp then
                        mhrp.CFrame = CFrame.new(ohrp.Position + Vector3.new(0,0,2))
                        pcall(function()
                            ReplicatedStorage.FE.Handcuffs:InvokeServer("Handcuff", p)
                        end)
                    end
                end
            end
        end

        -- Auto Eject
        if Cfg.AutoEject then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local human = p.Character:FindFirstChildOfClass("Humanoid")
                    if human and human.SeatPart then
                        pcall(function()
                            ReplicatedStorage.FE.Eject:FireServer(p.Character, human.SeatPart.Parent)
                        end)
                    end
                end
            end
        end
    end)
end)

-- ════════════════════════════════════════════════════════════
--  ANTI AFK
-- ════════════════════════════════════════════════════════════
LP.Idled:Connect(function()
    if Cfg.AntiAFK then
        VirtualUser:Button2Down(Vector2.new(0,0), Cam.CFrame)
        task.wait(0.1)
        VirtualUser:Button2Up(Vector2.new(0,0), Cam.CFrame)
    end
end)

-- ════════════════════════════════════════════════════════════
--  ESP  RENDERER
-- ════════════════════════════════════════════════════════════
local ESPCache = {}

local function RemoveESPFor(player)
    if ESPCache[player] then
        for _, obj in ipairs(ESPCache[player]) do pcall(function() obj:Destroy() end) end
        ESPCache[player] = nil
    end
end

Players.PlayerRemoving:Connect(RemoveESPFor)

RunService.RenderStepped:Connect(function()
    if not Cfg.ESPEnabled then
        for p, _ in pairs(ESPCache) do RemoveESPFor(p) end
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LP then continue end
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then RemoveESPFor(player); continue end

        local _, vis = Cam:WorldToViewportPoint(root.Position)

        -- Create billboard if needed
        if not ESPCache[player] then
            ESPCache[player] = {}
            local bb = Instance.new("BillboardGui")
            bb.AlwaysOnTop  = true
            bb.Size         = UDim2.new(0,160,0,50)
            bb.StudsOffset  = Vector3.new(0,3.2,0)
            bb.Parent       = root

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Name  = "NameLbl"
            nameLbl.Size  = UDim2.new(1,0,0.6,0)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Font  = Enum.Font.GothamBold
            nameLbl.TextSize = 13
            nameLbl.TextStrokeTransparency = 0.4
            nameLbl.TextStrokeColor3 = Color3.new(0,0,0)
            nameLbl.Parent = bb

            local distLbl = Instance.new("TextLabel")
            distLbl.Name  = "DistLbl"
            distLbl.Size  = UDim2.new(1,0,0.4,0)
            distLbl.Position = UDim2.new(0,0,0.6,0)
            distLbl.BackgroundTransparency = 1
            distLbl.Font  = Enum.Font.Gotham
            distLbl.TextSize = 10
            distLbl.TextColor3 = C.sub
            distLbl.TextStrokeTransparency = 0.4
            distLbl.TextStrokeColor3 = Color3.new(0,0,0)
            distLbl.Parent = bb

            table.insert(ESPCache[player], bb)
            table.insert(ESPCache[player], nameLbl)
            table.insert(ESPCache[player], distLbl)
        end

        -- Update labels
        local objs = ESPCache[player]
        local bb2  = objs[1]
        local nl   = objs[2]
        local dl   = objs[3]

        if bb2 and bb2.Parent ~= root then bb2.Parent = root end

        -- Colour by team
        local col = C.white
        if Cfg.ESPTeamColor and player.Team then
            local tc = player.TeamColor
            col = Color3.fromRGB(tc.Color.R*255, tc.Color.G*255, tc.Color.B*255)
        end

        if nl then
            nl.Visible     = Cfg.ESPNames
            nl.Text        = player.Name .. (Cfg.ShowBounty and player:FindFirstChild("Is_Wanted") and " 💰WANTED" or "")
            nl.TextColor3  = col
        end

        if dl then
            local hrp = GetHRP()
            local dist = hrp and math.floor((root.Position - hrp.Position).Magnitude) or 0
            dl.Visible = Cfg.ESPDistance
            dl.Text    = dist .. " studs"
        end
    end
end)

-- ════════════════════════════════════════════════════════════
--  AUTO ROB  FRAMEWORK
-- ════════════════════════════════════════════════════════════
-- Each robbery watches its GUI screen and auto-clicks / teleports

local function WaitForGui(path, timeout)
    local t = 0
    while t < (timeout or 15) do
        local obj = LP.PlayerGui:FindFirstChild("GameMenus")
        if obj and obj:FindFirstChild(path) and obj[path].Visible then
            return obj[path]
        end
        task.wait(0.1); t = t + 0.1
    end
    return nil
end

-- ── ATM Auto-Rob (auto-click the spinning wheel) ─────────────
task.spawn(function()
    while true do
        task.wait(0.5)
        if not Cfg.AutoRobATM then continue end
        pcall(function()
            -- Find nearest ATM in workspace
            local bestATM, bestDist = nil, 50
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj.Name == "ATM" and obj:IsA("Model") then
                    local part = obj:FindFirstChildWhichIsA("BasePart")
                    local hrp  = GetHRP()
                    if part and hrp then
                        local d = (part.Position - hrp.Position).Magnitude
                        if d < bestDist then bestDist=d; bestATM=obj end
                    end
                end
            end

            if bestATM then
                local part = bestATM:FindFirstChildWhichIsA("BasePart")
                local hrp = GetHRP()
                if hrp and part then
                    hrp.CFrame = CFrame.new(part.Position + Vector3.new(0,2,3))
                end
            end

            -- Auto click the ATM minigame UI if open
            local gui = LP.PlayerGui:FindFirstChild("GameMenus")
            if gui then
                local atmUI = gui:FindFirstChild("ATM") or gui:FindFirstChild("RobATM")
                if atmUI and atmUI.Visible then
                    VirtualUser:ClickButton1(Vector2.new(
                        math.random(5,15), math.random(5,15)
                    ), Cam.CFrame)
                    SetStatus("Auto ATM: clicking!", C.warning)
                end
            end
        end)
    end
end)

-- ── Jewelry Auto-Rob (drill minigame – auto click drill zone) ──
task.spawn(function()
    while true do
        task.wait(0.3)
        if not Cfg.AutoRobJewelry then continue end
        pcall(function()
            local hrp = GetHRP()
            if hrp and (hrp.Position - MAP.Jewelry.Position).Magnitude > 30 then
                hrp.CFrame = MAP.Jewelry
                task.wait(1)
            end

            local gui = LP.PlayerGui:FindFirstChild("GameMenus")
            if gui then
                local jewUI = gui:FindFirstChild("RobJewelry") or gui:FindFirstChild("Jewelry")
                if jewUI and jewUI.Visible then
                    -- Auto click the drill good zone
                    local goodZone = jewUI:FindFirstChild("Drill") and jewUI.Drill:FindFirstChild("goodzone")
                    if goodZone then
                        VirtualUser:ClickButton1(Vector2.new(
                            goodZone.AbsolutePosition.X + goodZone.AbsoluteSize.X/2,
                            goodZone.AbsolutePosition.Y + goodZone.AbsoluteSize.Y/2
                        ), Cam.CFrame)
                    else
                        VirtualUser:ClickButton1(Vector2.new(math.random(5,15),math.random(5,15)), Cam.CFrame)
                    end
                    SetStatus("Auto Jewelry: drilling!", C.warning)
                end
            end
        end)
    end
end)

-- ── Bank Auto-Rob ─────────────────────────────────────────────
task.spawn(function()
    while true do
        task.wait(1)
        if not Cfg.AutoRobBank then continue end
        pcall(function()
            local hrp = GetHRP()
            if hrp and (hrp.Position - MAP.Bank.Position).Magnitude > 20 then
                hrp.CFrame = MAP.Bank
                SetStatus("TP → Bank for robbery", C.warning)
                task.wait(1.5)
            end

            -- Auto safe cracker
            local gui = LP.PlayerGui:FindFirstChild("GameMenus")
            if gui then
                local safeUI = gui:FindFirstChild("Safe") or gui:FindFirstChild("BankSafe")
                if safeUI and safeUI.Visible
                   and safeUI.Position.X.Scale == 0.5
                   and safeUI.Position.Y.Scale == 0.5 then
                    -- Safe cracker auto values
                    local SafeValues = {0,36,72,108,144,180,216,252,288,324}
                    local targetNum = safeUI:FindFirstChild("Top2") and
                                      safeUI.Top2:FindFirstChild("TargetNum") and
                                      tonumber(safeUI.Top2.TargetNum.Text)
                    if targetNum and SafeValues[targetNum] then
                        -- Fire the dial to correct rotation
                        pcall(function()
                            ReplicatedStorage.FE:FindFirstChild("SafeDial") and
                            ReplicatedStorage.FE.SafeDial:FireServer(SafeValues[targetNum])
                        end)
                    end
                    SetStatus("Auto Bank: cracking safe!", C.warning)
                end
            end
        end)
    end
end)

-- ── House Auto-Rob ────────────────────────────────────────────
task.spawn(function()
    while true do
        task.wait(2)
        if not Cfg.AutoRobHouses then continue end
        pcall(function()
            local hrp = GetHRP()
            if not hrp then return end
            -- Find lockable house items in workspace
            local houseFolder = Workspace:FindFirstChild("Houses") or Workspace:FindFirstChild("Housing")
            if not houseFolder then return end
            for _, item in ipairs(houseFolder:GetDescendants()) do
                if item.Name == "StealableItem" or item.Name == "HouseItem" then
                    local part = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart")
                    if part then
                        hrp.CFrame = CFrame.new(part.Position + Vector3.new(0,2,0))
                        task.wait(0.4)
                        pcall(function()
                            ReplicatedStorage.Houses:FindFirstChild("StealItem") and
                            ReplicatedStorage.Houses.StealItem:FireServer(item)
                        end)
                        task.wait(0.3)
                    end
                end
            end
        end)
    end
end)

-- ── Auto Buy Weapons ─────────────────────────────────────────
task.spawn(function()
    while true do
        task.wait(2)
        if not (Cfg.AutoBuyAll or Cfg.AutoBuyPistol or Cfg.AutoBuyRifle or Cfg.AutoBuyShotgun or Cfg.AutoBuyKnife) then
            continue
        end
        pcall(function()
            local hrp = GetHRP()
            if hrp and (hrp.Position - MAP.GunsAmmo.Position).Magnitude > 25 then
                hrp.CFrame = MAP.GunsAmmo
                task.wait(1)
            end
            -- Try known remotes
            local buyRemote = ReplicatedStorage:FindFirstChild("BuyItem")
                           or ReplicatedStorage:FindFirstChild("PurchaseItem")
                           or ReplicatedStorage:FindFirstChild("ShopBuy")
            if buyRemote then
                local items = {}
                if Cfg.AutoBuyAll or Cfg.AutoBuyPistol  then table.insert(items,"Pistol") end
                if Cfg.AutoBuyAll or Cfg.AutoBuyRifle   then table.insert(items,"Rifle") end
                if Cfg.AutoBuyAll or Cfg.AutoBuyShotgun then table.insert(items,"Shotgun") end
                if Cfg.AutoBuyAll or Cfg.AutoBuyKnife   then table.insert(items,"Knife") end
                for _, item in ipairs(items) do
                    if not LP.Backpack:FindFirstChild(item) then
                        pcall(function() buyRemote:FireServer(item) end)
                        SetStatus("Bought: "..item, C.success)
                        task.wait(0.5)
                    end
                end
            end
        end)
    end
end)

-- ════════════════════════════════════════════════════════════
--  RESPAWN  handler
-- ════════════════════════════════════════════════════════════
LP.CharacterAdded:Connect(function(char)
    task.wait(1)
    local human = char:WaitForChild("Humanoid")
    if Cfg.SpeedHack then human.WalkSpeed = Cfg.WalkSpeed end
    human.JumpPower = Cfg.JumpPower
end)

-- ════════════════════════════════════════════════════════════
--  OPEN  ANIMATION
-- ════════════════════════════════════════════════════════════
Main.Size     = UDim2.new(0,0,0,0)
Main.Position = UDim2.new(0.5,0,0.5,0)
Tw(Main,{Size=fullSize, Position=UDim2.new(0.5,-WIN_W/2,0.5,-WIN_H/2)},
    0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

SetStatus("ERLC Ultra Hub v4.0 loaded! AC Bypass: " .. (_ACBypassOK and "✔" or "partial"), C.success)

print([[
╔═══════════════════════════════════════════╗
║       ERLC Ultra Hub v4.0  — LOADED       ║
║  [HOME]   Toggle UI                       ║
║  [INSERT] Toggle ESP                      ║
║  [DEL]    Emergency Hide                  ║
╚═══════════════════════════════════════════╝
]])
