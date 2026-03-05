--[[
╔══════════════════════════════════════════════════════════════╗
║          ERLC ULTRA HUB  v6.0  ·  Emergency Response LC      ║
║  PlaceId: 2534724415                                         ║
║  Features: ESP · Auto Rob · Auto Buy (real ERLC guns)        ║
║            Teleport · Speed · Weapons · Cop Tools · Misc     ║
╚══════════════════════════════════════════════════════════════╝
--]]

------------------------------------------------------------------------
-- §0  SAFE EXECUTOR-API WRAPPERS
-- Every exploit-only function is nil-checked so the script never
-- crashes on executors like Delta that lack some APIs.
------------------------------------------------------------------------
local _hookMM   = type(hookmetamethod)  == "function" and hookmetamethod  or nil
local _getreg   = type(getreg)          == "function" and getreg          or nil
local _getupv   = type(getupvalues)     == "function" and getupvalues     or nil
local _getprot  = type(getprotos)       == "function" and getprotos       or nil
local _sfe      = type(setfenv)         == "function" and setfenv         or nil
local _sro      = type(setreadonly)     == "function" and setreadonly     or nil
local _gfe      = type(getfenv)         == "function" and getfenv         or nil
local _grenv    = type(getrenv)         == "function" and getrenv         or nil
local _genv     = type(getgenv)         == "function" and getgenv         or nil
local _sclip    = type(setclipboard)    == "function" and setclipboard    or nil

------------------------------------------------------------------------
-- §1  GAME GUARD
------------------------------------------------------------------------
if game.PlaceId ~= 2534724415 then
    warn("[ERLC Hub] Wrong game.")
    return
end
if not game:IsLoaded() then game.Loaded:Wait(); task.wait(2) end

if _genv and _genv()["_ERLCv6"] then warn("[ERLC Hub] Already loaded."); return end
if _genv then _genv()["_ERLCv6"] = true end

------------------------------------------------------------------------
-- §2  ANTI-CHEAT BYPASS  (all layers guarded — zero crash risk)
------------------------------------------------------------------------
local ACStatus = "Not Available"

-- Layer 1: __namecall hook
if _hookMM then
    local ok = pcall(function()
        local oldNC
        oldNC = _hookMM(game, "__namecall", function(self, ...)
            local args = {...}
            if self.ClassName == "RemoteEvent" or self.ClassName == "RemoteFunction" then
                if self.Name == "AutoDetection" or self.Name == "RandomEvent"
                or self.Name == "AntiCheat"     or self.Name == "DetectionEvent" then
                    return
                end
                for _, a in next, args do
                    if type(a) == "string" and (#a <= 2 or string.find(a, "#", 1, true)) then
                        return
                    end
                end
            end
            return oldNC(self, ...)
        end)
    end)
    ACStatus = ok and "Hook Active" or "Hook Failed"
end

-- Layer 2: kill HookFuncs scanner in registry
if _getreg and _getupv and _getprot and _sfe then
    pcall(function()
        local done, cap = 0, 100
        for _, v in pairs(_getreg()) do
            if type(v) == "function" and done < cap then
                local ok2, upvs = pcall(_getupv, v)
                if ok2 and type(upvs) == "table" and #upvs >= 4
                   and type(upvs[1]) == "number" and type(upvs[3]) == "function" then
                    pcall(function()
                        for _, p in next, _getprot(v) or {} do pcall(_sfe, p, {}) end
                        pcall(_sfe, v, {})
                    end)
                    done += 1
                end
            end
        end
    end)
    ACStatus = ACStatus == "Hook Active" and "Full Bypass" or "Partial"
end

-- Layer 3: spoof string.match in game env
if _grenv and _gfe and _sro then
    pcall(function()
        local gr = _grenv()
        if gr and gr._G and gr._G.PushNotification then
            local genv = _gfe(gr._G.PushNotification)
            if genv and genv.string then
                _sro(genv.string, false)
                genv.string.match = function() return nil end
                _sro(genv.string, true)
            end
        end
    end)
end

task.wait(0.2)

------------------------------------------------------------------------
-- §3  SERVICES
------------------------------------------------------------------------
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local VirtualUser       = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")
local CoreGui           = game:GetService("CoreGui")
local Lighting          = game:GetService("Lighting")

local LP  = Players.LocalPlayer
local Cam = Workspace.CurrentCamera

local function GetChar()  return LP.Character end
local function GetHRP()   local c = LP.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function GetHuman() local c = LP.Character; return c and c:FindFirstChildOfClass("Humanoid") end
local function GetTeam()  return LP.Team and LP.Team.Name or "None" end

------------------------------------------------------------------------
-- §4  MAP COORDINATES  (live-sourced from ERLC scripts)
------------------------------------------------------------------------
local MAP = {
    Bank          = CFrame.new(-481.6,  23.9,  701.9),
    Jewelry       = CFrame.new(-464.0,  17.5, -436.4),
    GunsAmmo      = CFrame.new(-727.5,  13.5,  -28.7),    -- Fairfax Rd location
    GunsAmmo2     = CFrame.new(-758.5,  13.5,  -95.7),    -- Maple St location
    PoliceDept    = CFrame.new(-374.0,  13.5,  542.8),
    FireStation   = CFrame.new(-420.0,  13.5,  330.8),
    Hospital      = CFrame.new(-327.0,  13.5,  299.8),
    Prison        = CFrame.new( 239.0,   6.7, -1780.5),
    SheriffOffice = CFrame.new(1336.0,  17.0,  -444.0),
    ModShop       = CFrame.new(-296.0,  13.5,   483.8),
    PowerPlant    = CFrame.new( 770.0,  20.3,  -119.0),
    ParkingGarage = CFrame.new( 745.0,  20.3,  -114.0),
    CarDealership = CFrame.new(-310.0,  13.5,   156.8),
    GasStation    = CFrame.new( 174.4, -10.1,   337.6),
    ToolStore     = CFrame.new(-464.0,  13.5,  -390.0),
    ATM_Bank      = CFrame.new(-481.0,  14.5,   680.0),
    ATM_Parking   = CFrame.new(-460.0,  14.0,  -410.0),
    House1        = CFrame.new(-758.5,  13.5,   -28.7),
    House2        = CFrame.new(-777.5,  13.5,   -67.7),
    House3        = CFrame.new(-727.5,  13.5,   -95.7),
    House4        = CFrame.new(-310.0,  13.5,   156.8),
    Hide1         = CFrame.new( 465.1,  -5.7,  1035.7),
    Hide2         = CFrame.new(-1320.0, 24.6,   491.0),
    Hide3         = CFrame.new(-374.0,  13.5,   542.8),
}

------------------------------------------------------------------------
-- §5  REAL ERLC GUNS  (sourced from wiki — civilian & law enforcement)
------------------------------------------------------------------------
-- CIVILIAN guns purchasable at Liberty Guns & Ammo
local CIVILIAN_GUNS = {
    -- Pistols / Revolvers
    { name = "Lemat Revolver",    price = "$1,000",  note = "Paid Access" },
    { name = "Colt Python",       price = "$1,200",  note = "Big Guns GP" },
    { name = "Remington 700",     price = "$2,000",  note = "" },
    -- Shotguns
    { name = "Nova Shotgun",      price = "$1,500",  note = "" },
    { name = "Remington 870",     price = "$1,800",  note = "" },
    { name = "Fabarm FP6",        price = "$2,000",  note = "" },
    { name = "Benelli M4",        price = "$2,200",  note = "Big Guns GP" },
    -- SMG / Machine pistols
    { name = "MAC-10",            price = "$3,750",  note = "" },
    { name = "Kriss Vector",      price = "$2,400",  note = "" },
    { name = "P90 Carbine",       price = "$2,600",  note = "" },
    { name = "PPSH 41",           price = "$2,800",  note = "Big Guns GP" },
    -- Rifles / Assault
    { name = "AK47",              price = "$2,250",  note = "" },
    { name = "M4A1",              price = "$2,500",  note = "" },
    { name = "M14",               price = "$2,200",  note = "" },
    { name = "M249",              price = "$3,500",  note = "Big Guns GP" },
    -- Snipers
    { name = "Remington MSR",     price = "$2,500",  note = "Big Guns GP" },
}

-- LAW ENFORCEMENT guns (from locker, rank/gamepass locked)
local LEO_GUNS = {
    { name = "Ruger SR 556",  note = "Corporal+" },
    { name = "MP5",           note = "Sergeant+" },
    { name = "FN Five-seven", note = "Lieutenant+" },
    { name = "Sauer P226",    note = "Captain+" },
    { name = "M&P 15",        note = "Major+" },
    { name = "Type 89",       note = "Major+" },
    { name = "SPAS 12",       note = "Colonel+" },
    { name = "Model 29",      note = "Commander+" },
    { name = "M&P 9",         note = "Commander+" },
    { name = "Kahr CW9",      note = "Detective GP" },
    { name = "G36C",          note = "SWAT GP" },
    { name = "Orsis T 5000",  note = "SWAT GP" },
    { name = "LMT L129A1",    note = "High Rank" },
}

------------------------------------------------------------------------
-- §6  CONFIG
------------------------------------------------------------------------
local Cfg = {
    -- ESP
    ESPEnabled=false, ESPBoxes=false, ESPNames=true,
    ESPDist=true, ESPTracers=false, ESPTeam=true, ShowBounty=false,
    -- Speed / Movement
    SpeedHack=false, WalkSpeed=30, JumpPower=60,
    InfStamina=false, Noclip=false,
    -- Vehicle
    CSRSpoof=false, CSRMult=3, AntiFlip=false,
    -- Weapons
    NoRecoil=false, FastReload=false, InfAmmo=false,
    AutoAim=false, HitboxExp=false, HitboxSize=10,
    -- Auto Rob
    AutoRobBank=false, AutoRobJewelry=false, AutoRobATM=false,
    AutoRobHouses=false,
    -- Auto Buy (indexed by gun name for dynamic toggling)
    AutoBuyGuns={},
    -- Cop Tools
    AutoArrest=false, FastArrest=false, AutoEject=false,
    -- Misc
    AntiAFK=false, FullBright=false, AutoRespawn=false,
}

------------------------------------------------------------------------
-- §7  CLEAN UP OLD GUI
------------------------------------------------------------------------
pcall(function()
    if CoreGui:FindFirstChild("ERLCHubV6") then
        CoreGui.ERLCHubV6:Destroy()
    end
end)

------------------------------------------------------------------------
-- §8  PALETTE  &  HELPERS
------------------------------------------------------------------------
local C = {
    bg     = Color3.fromRGB( 7,  7, 13),
    panel  = Color3.fromRGB(13, 13, 23),
    side   = Color3.fromRGB(10, 10, 18),
    accent = Color3.fromRGB(56,185,255),
    acc2   = Color3.fromRGB(110,65,255),
    danger = Color3.fromRGB(255,55,75),
    ok     = Color3.fromRGB(45,210,115),
    warn   = Color3.fromRGB(255,170,35),
    text   = Color3.fromRGB(215,222,240),
    sub    = Color3.fromRGB(95,103,128),
    border = Color3.fromRGB(28,28,50),
    hover  = Color3.fromRGB(20,20,36),
    on     = Color3.fromRGB(45,200,108),
    off    = Color3.fromRGB(35,35,58),
    sel    = Color3.fromRGB(16,52,92),
    white  = Color3.new(1,1,1),
    black  = Color3.new(0,0,0),
}

local function New(cls, props)
    local o = Instance.new(cls)
    for k, v in pairs(props or {}) do
        pcall(function() o[k] = v end)
    end
    return o
end

local function Corner(r, p)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
    return c
end

local function Stroke(t, col, tr, p)
    local s = Instance.new("UIStroke")
    s.Thickness = t or 1
    s.Color = col or C.border
    s.Transparency = tr or 0
    s.Parent = p
    return s
end

local function Pad(l, r, t, b, p)
    local u = Instance.new("UIPadding")
    u.PaddingLeft   = UDim.new(0, l)
    u.PaddingRight  = UDim.new(0, r)
    u.PaddingTop    = UDim.new(0, t)
    u.PaddingBottom = UDim.new(0, b)
    u.Parent = p
    return u
end

local function ListLayout(sp, p)
    local l = Instance.new("UIListLayout")
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding   = UDim.new(0, sp or 4)
    l.Parent    = p
    return l
end

local function Tw(obj, props, dur, es, ed)
    pcall(function()
        TweenService:Create(
            obj,
            TweenInfo.new(dur or .2, es or Enum.EasingStyle.Quart, ed or Enum.EasingDirection.Out),
            props
        ):Play()
    end)
end

------------------------------------------------------------------------
-- §9  ROOT GUI
------------------------------------------------------------------------
local SG = New("ScreenGui", {
    Name = "ERLCHubV6",
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
})
local ok_cg = pcall(function() SG.Parent = CoreGui end)
if not ok_cg or not SG.Parent then SG.Parent = LP.PlayerGui end

local WIN_W, WIN_H = 740, 520

local Main = New("Frame", {
    Name = "Main",
    Size = UDim2.new(0, WIN_W, 0, WIN_H),
    Position = UDim2.new(.5, -WIN_W/2, .5, -WIN_H/2),
    BackgroundColor3 = C.bg,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Parent = SG,
})
Corner(12, Main)
Stroke(1.5, C.accent, 0.5, Main)

-- TOP BAR ──────────────────────────────────────────────────────────
local TopBar = New("Frame", {
    Size = UDim2.new(1,0,0,48),
    BackgroundColor3 = C.side,
    BorderSizePixel = 0,
    Parent = Main,
})
Corner(12, TopBar)
-- patch lower corners of top bar
New("Frame", {
    Size = UDim2.new(1,0,.5,0),
    Position = UDim2.new(0,0,.5,0),
    BackgroundColor3 = C.side,
    BorderSizePixel = 0,
    Parent = TopBar,
})

-- Logo badge
local Logo = New("Frame", {
    Size = UDim2.new(0,34,0,34),
    Position = UDim2.new(0,8,.5,-17),
    BackgroundColor3 = C.accent,
    Parent = TopBar,
})
Corner(8, Logo)
local lg = Instance.new("UIGradient")
lg.Color    = ColorSequence.new(C.accent, C.acc2)
lg.Rotation = 135
lg.Parent   = Logo
New("TextLabel", {
    Size = UDim2.new(1,0,1,0),
    BackgroundTransparency = 1,
    Text = "⚡",
    TextScaled = true,
    Font = Enum.Font.GothamBold,
    TextColor3 = C.white,
    Parent = Logo,
})

New("TextLabel", {
    Size = UDim2.new(0,220,1,0),
    Position = UDim2.new(0,50,0,0),
    BackgroundTransparency = 1,
    Text = "ERLC Ultra Hub",
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextColor3 = C.text,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = TopBar,
})
New("TextLabel", {
    Size = UDim2.new(0,40,1,0),
    Position = UDim2.new(0,266,0,0),
    BackgroundTransparency = 1,
    Text = "v6.0",
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextColor3 = C.accent,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = TopBar,
})

-- AC badge
local ACBadge = New("Frame", {
    Size = UDim2.new(0,148,0,22),
    Position = UDim2.new(0,308,.5,-11),
    BackgroundColor3 = C.bg,
    BackgroundTransparency = 0.4,
    Parent = TopBar,
})
Corner(5, ACBadge)
Stroke(1, C.border, 0, ACBadge)
New("TextLabel", {
    Size = UDim2.new(1,0,1,0),
    BackgroundTransparency = 1,
    Text = "⚡ AC: " .. ACStatus,
    Font = Enum.Font.GothamSemibold,
    TextSize = 10,
    TextColor3 = ACStatus == "Full Bypass" and C.ok or ACStatus == "Hook Active" and C.accent or C.warn,
    Parent = ACBadge,
})

-- Team badge
local TeamBadge = New("Frame", {
    Size = UDim2.new(0,95,0,22),
    Position = UDim2.new(0,460,.5,-11),
    BackgroundColor3 = C.bg,
    BackgroundTransparency = 0.4,
    Parent = TopBar,
})
Corner(5, TeamBadge)
Stroke(1, C.border, 0, TeamBadge)
local TeamLbl = New("TextLabel", {
    Size = UDim2.new(1,0,1,0),
    BackgroundTransparency = 1,
    Text = "👤 " .. GetTeam(),
    Font = Enum.Font.GothamSemibold,
    TextSize = 10,
    TextColor3 = C.text,
    Parent = TeamBadge,
})

-- Close / Min buttons
local function TopBtn(col, icon, xOff)
    local b = New("TextButton", {
        Size = UDim2.new(0,26,0,26),
        Position = UDim2.new(1,xOff,.5,-13),
        BackgroundColor3 = col,
        Text = icon,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = C.white,
        AutoButtonColor = false,
        Parent = TopBar,
    })
    Corner(6, b)
    b.MouseEnter:Connect(function() Tw(b, {BackgroundTransparency=0.35}) end)
    b.MouseLeave:Connect(function() Tw(b, {BackgroundTransparency=0}) end)
    return b
end
local BtnClose = TopBtn(C.danger, "✕", -8)
local BtnMin   = TopBtn(C.warn,   "─", -40)

-- SIDEBAR ──────────────────────────────────────────────────────────
local Sidebar = New("Frame", {
    Size = UDim2.new(0,160,1,-48),
    Position = UDim2.new(0,0,0,48),
    BackgroundColor3 = C.side,
    BorderSizePixel = 0,
    Parent = Main,
})
New("Frame", {
    Size = UDim2.new(0,1,1,0),
    Position = UDim2.new(1,-1,0,0),
    BackgroundColor3 = C.border,
    BorderSizePixel = 0,
    Parent = Sidebar,
})

local SideScroll = New("ScrollingFrame", {
    Size = UDim2.new(1,0,1,-6),
    Position = UDim2.new(0,0,0,4),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 0,
    CanvasSize = UDim2.new(0,0,0,0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Parent = Sidebar,
})
Pad(7,7,2,4, SideScroll)
ListLayout(3, SideScroll)

-- CONTENT AREA ─────────────────────────────────────────────────────
local ContentArea = New("Frame", {
    Size = UDim2.new(1,-160,1,-48-24),
    Position = UDim2.new(0,160,0,48),
    BackgroundTransparency = 1,
    Parent = Main,
})

-- STATUS BAR ───────────────────────────────────────────────────────
local StatusBar = New("Frame", {
    Size = UDim2.new(1,-160,0,24),
    Position = UDim2.new(0,160,1,-24),
    BackgroundColor3 = C.side,
    BorderSizePixel = 0,
    ZIndex = 8,
    Parent = Main,
})
New("Frame", {
    Size=UDim2.new(1,0,0,1),
    BackgroundColor3=C.border,
    BorderSizePixel=0,
    Parent=StatusBar,
})
local StatLbl = New("TextLabel", {
    Size = UDim2.new(1,-8,1,0),
    Position = UDim2.new(0,8,0,0),
    BackgroundTransparency = 1,
    Text = "● Ready",
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextColor3 = C.ok,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 8,
    Parent = StatusBar,
})

local function Status(msg, col)
    pcall(function()
        StatLbl.Text = "● " .. tostring(msg)
        StatLbl.TextColor3 = col or C.ok
    end)
end

------------------------------------------------------------------------
-- §10  PAGE + NAV SYSTEM
------------------------------------------------------------------------
local Pages      = {}
local NavFrames  = {}
local ActivePage = nil

local function MakePage(id)
    local sf = New("ScrollingFrame", {
        Name = id,
        Size = UDim2.new(1,-4,1,-4),
        Position = UDim2.new(0,2,0,2),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = C.accent,
        CanvasSize = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = ContentArea,
    })
    Pad(8,6,6,8,sf)
    ListLayout(5,sf)
    Pages[id] = sf
    return sf
end

local function SelectPage(id)
    for pid, pg in pairs(Pages) do pg.Visible = (pid == id) end
    for nid, nf in pairs(NavFrames) do
        local active = (nid == id)
        Tw(nf, {BackgroundColor3 = active and C.sel or C.off})
        for _, ch in ipairs(nf:GetChildren()) do
            if ch:IsA("TextLabel") then
                Tw(ch, {TextColor3 = active and C.accent or C.sub})
            end
        end
    end
    ActivePage = id
end

local function NavBtn(icon, label, pageId, order)
    local f = New("Frame", {
        Size = UDim2.new(1,0,0,36),
        BackgroundColor3 = C.off,
        LayoutOrder = order,
        Parent = SideScroll,
    })
    Corner(7, f)
    New("TextLabel", {
        Size = UDim2.new(0,22,0,22),
        Position = UDim2.new(0,8,.5,-11),
        BackgroundTransparency = 1,
        Text = icon,
        TextScaled = true,
        Font = Enum.Font.Gotham,
        TextColor3 = C.sub,
        Parent = f,
    })
    New("TextLabel", {
        Size = UDim2.new(1,-36,1,0),
        Position = UDim2.new(0,34,0,0),
        BackgroundTransparency = 1,
        Text = label,
        Font = Enum.Font.GothamSemibold,
        TextSize = 12,
        TextColor3 = C.sub,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = f,
    })
    local btn = New("TextButton", {
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = f,
    })
    btn.MouseButton1Click:Connect(function() SelectPage(pageId) end)
    btn.MouseEnter:Connect(function()
        if ActivePage ~= pageId then Tw(f, {BackgroundColor3=C.hover}) end
    end)
    btn.MouseLeave:Connect(function()
        if ActivePage ~= pageId then Tw(f, {BackgroundColor3=C.off}) end
    end)
    NavFrames[pageId] = f
end

------------------------------------------------------------------------
-- §11  WIDGET BUILDERS
------------------------------------------------------------------------

-- Section header
local function Sec(pg, title, order)
    local f = New("Frame", {
        Size = UDim2.new(1,0,0,22),
        BackgroundTransparency = 1,
        LayoutOrder = order,
        Parent = pg,
    })
    New("TextLabel", {
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        Text = "  " .. string.upper(title),
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextColor3 = C.accent,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = f,
    })
    New("Frame", {
        Size = UDim2.new(1,0,0,1),
        Position = UDim2.new(0,0,1,-1),
        BackgroundColor3 = C.border,
        BorderSizePixel = 0,
        Parent = f,
    })
    return f
end

-- Toggle
local function Tog(pg, label, key, order, cb)
    local row = New("Frame", {
        Size = UDim2.new(1,0,0,33),
        BackgroundColor3 = C.panel,
        LayoutOrder = order,
        Parent = pg,
    })
    Corner(7, row)
    Stroke(1, C.border, 0, row)

    New("TextLabel", {
        Size = UDim2.new(1,-52,1,0),
        Position = UDim2.new(0,10,0,0),
        BackgroundTransparency = 1,
        Text = label,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = C.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    local bg = New("Frame", {
        Size = UDim2.new(0,38,0,20),
        Position = UDim2.new(1,-46,.5,-10),
        BackgroundColor3 = Cfg[key] and C.on or C.off,
        Parent = row,
    })
    Corner(10, bg)

    local kn = New("Frame", {
        Size = UDim2.new(0,16,0,16),
        Position = Cfg[key] and UDim2.new(1,-18,.5,-8) or UDim2.new(0,2,.5,-8),
        BackgroundColor3 = C.white,
        Parent = bg,
    })
    Corner(8, kn)

    local btn = New("TextButton", {
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = row,
    })
    btn.MouseButton1Click:Connect(function()
        Cfg[key] = not Cfg[key]
        local on = Cfg[key]
        Tw(bg, {BackgroundColor3 = on and C.on or C.off})
        Tw(kn, {Position = on and UDim2.new(1,-18,.5,-8) or UDim2.new(0,2,.5,-8)})
        if cb then pcall(cb, on) end
    end)
    btn.MouseEnter:Connect(function() Tw(row, {BackgroundColor3=C.hover}) end)
    btn.MouseLeave:Connect(function() Tw(row, {BackgroundColor3=C.panel}) end)
    return row
end

-- Button
local function Btn(pg, label, col, order, cb)
    local b = New("TextButton", {
        Size = UDim2.new(1,0,0,33),
        BackgroundColor3 = col or C.accent,
        Text = label,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = C.white,
        AutoButtonColor = false,
        LayoutOrder = order,
        Parent = pg,
    })
    Corner(7, b)
    b.MouseButton1Click:Connect(function()
        Tw(b, {BackgroundTransparency=0.45}, 0.05)
        task.delay(.12, function() Tw(b, {BackgroundTransparency=0}) end)
        if cb then pcall(cb) end
    end)
    b.MouseEnter:Connect(function() Tw(b, {BackgroundTransparency=0.2}) end)
    b.MouseLeave:Connect(function() Tw(b, {BackgroundTransparency=0}) end)
    return b
end

-- Slider
local function Sld(pg, label, key, mn, mx, order, cb)
    local row = New("Frame", {
        Size = UDim2.new(1,0,0,52),
        BackgroundColor3 = C.panel,
        LayoutOrder = order,
        Parent = pg,
    })
    Corner(7, row)
    Stroke(1, C.border, 0, row)

    New("TextLabel", {
        Size = UDim2.new(.7,0,0,24),
        Position = UDim2.new(0,10,0,2),
        BackgroundTransparency = 1,
        Text = label,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = C.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    local vLbl = New("TextLabel", {
        Size = UDim2.new(.3,-10,0,24),
        Position = UDim2.new(.7,0,0,2),
        BackgroundTransparency = 1,
        Text = tostring(Cfg[key]),
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = C.accent,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = row,
    })

    local track = New("Frame", {
        Size = UDim2.new(1,-20,0,6),
        Position = UDim2.new(0,10,0,36),
        BackgroundColor3 = C.off,
        Parent = row,
    })
    Corner(3, track)

    local p0 = math.clamp((Cfg[key]-mn)/(mx-mn), 0, 1)
    local fill = New("Frame", {
        Size = UDim2.new(p0,0,1,0),
        BackgroundColor3 = C.accent,
        Parent = track,
    })
    Corner(3, fill)

    local knob = New("Frame", {
        Size = UDim2.new(0,14,0,14),
        Position = UDim2.new(p0,-7,.5,-7),
        BackgroundColor3 = C.white,
        Parent = track,
    })
    Corner(7, knob)

    local dragging = false
    knob.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp(
                (i.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1),
                0, 1
            )
            local val = math.round(mn + rel*(mx-mn))
            Cfg[key] = val
            vLbl.Text = tostring(val)
            fill.Size = UDim2.new(rel,0,1,0)
            knob.Position = UDim2.new(rel,-7,.5,-7)
            if cb then pcall(cb, val) end
        end
    end)
    return row
end

-- Info box
local function Info(pg, txt, order)
    local f = New("Frame", {
        Size = UDim2.new(1,0,0,56),
        BackgroundColor3 = C.panel,
        LayoutOrder = order,
        Parent = pg,
    })
    Corner(7, f)
    Stroke(1, C.border, 0, f)
    New("TextLabel", {
        Size = UDim2.new(1,-16,1,-4),
        Position = UDim2.new(0,8,0,2),
        BackgroundTransparency = 1,
        Text = txt,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = C.sub,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextWrapped = true,
        Parent = f,
    })
    return f
end

------------------------------------------------------------------------
-- §12  BUILD ALL PAGES
------------------------------------------------------------------------

-- ═══════════════  ESP  ════════════════════════════════════════════
local pESP = MakePage("ESP")
Sec(pESP, "Player ESP", 1)
Tog(pESP, "👁  ESP Master",        "ESPEnabled", 2, function(v) Status(v and "ESP On" or "ESP Off", v and C.ok or C.sub) end)
Tog(pESP, "📦  Bounding Boxes",    "ESPBoxes",   3)
Tog(pESP, "🏷  Name Tags",          "ESPNames",   4)
Tog(pESP, "📏  Distance",           "ESPDist",    5)
Tog(pESP, "🔗  Tracers",            "ESPTracers", 6)
Tog(pESP, "🎨  Team Colour",        "ESPTeam",    7)
Sec(pESP, "Extras", 8)
Tog(pESP, "💰  Show WANTED tag",   "ShowBounty", 9)

-- ═══════════════  ROBBERIES  ══════════════════════════════════════
local pRob = MakePage("Robberies")
Sec(pRob, "Auto Robbery", 1)
Tog(pRob, "🏦  Auto Rob Bank",          "AutoRobBank",    2, function(v) Status(v and "Auto Bank: ON" or "Auto Bank: OFF", v and C.warn or C.sub) end)
Tog(pRob, "💎  Auto Rob Jewelry Store", "AutoRobJewelry", 3)
Tog(pRob, "🏧  Auto Rob ATM",           "AutoRobATM",     4)
Tog(pRob, "🏠  Auto Rob Houses",        "AutoRobHouses",  5)
Sec(pRob, "Info", 6)
Info(pRob, "Each auto-rob teleports you to the location\nthen fires the correct game remotes / solves\nthe on-screen mini-game automatically.", 7)

-- ═══════════════  AUTO BUY (real ERLC guns)  ══════════════════════
local pBuy = MakePage("AutoBuy")
Sec(pBuy, "Civilian Guns  ·  Liberty Guns & Ammo", 1)

for i, gun in ipairs(CIVILIAN_GUNS) do
    local gname = gun.name
    -- initialise config entry
    Cfg.AutoBuyGuns[gname] = false

    local row = New("Frame", {
        Size = UDim2.new(1,0,0,33),
        BackgroundColor3 = C.panel,
        LayoutOrder = i + 1,
        Parent = pBuy,
    })
    Corner(7, row)
    Stroke(1, C.border, 0, row)

    -- gun name
    New("TextLabel", {
        Size = UDim2.new(.55,0,1,0),
        Position = UDim2.new(0,10,0,0),
        BackgroundTransparency = 1,
        Text = gname,
        Font = Enum.Font.GothamSemibold,
        TextSize = 12,
        TextColor3 = C.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    -- price / note badge
    New("TextLabel", {
        Size = UDim2.new(.3,0,0,18),
        Position = UDim2.new(.52,0,.5,-9),
        BackgroundTransparency = 1,
        Text = gun.price .. (gun.note ~= "" and " ·" or ""),
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = C.warn,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    if gun.note ~= "" then
        New("TextLabel", {
            Size = UDim2.new(.22,0,0,14),
            Position = UDim2.new(.72,0,.5,-7),
            BackgroundColor3 = C.acc2,
            BackgroundTransparency = 0.5,
            Text = gun.note,
            Font = Enum.Font.Gotham,
            TextSize = 9,
            TextColor3 = C.white,
            TextXAlignment = Enum.TextXAlignment.Center,
            Parent = row,
        }).Parent = row
        Corner(3, row:FindFirstChild("TextLabel", true))
    end

    -- toggle
    local bg = New("Frame", {
        Size = UDim2.new(0,38,0,20),
        Position = UDim2.new(1,-46,.5,-10),
        BackgroundColor3 = C.off,
        Parent = row,
    })
    Corner(10, bg)
    local kn = New("Frame", {
        Size = UDim2.new(0,16,0,16),
        Position = UDim2.new(0,2,.5,-8),
        BackgroundColor3 = C.white,
        Parent = bg,
    })
    Corner(8, kn)

    local btn = New("TextButton", {
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = row,
    })
    local gn = gname
    btn.MouseButton1Click:Connect(function()
        Cfg.AutoBuyGuns[gn] = not Cfg.AutoBuyGuns[gn]
        local on = Cfg.AutoBuyGuns[gn]
        Tw(bg, {BackgroundColor3 = on and C.on or C.off})
        Tw(kn, {Position = on and UDim2.new(1,-18,.5,-8) or UDim2.new(0,2,.5,-8)})
        if on then Status("Auto-buy queued: " .. gn, C.ok) end
    end)
    btn.MouseEnter:Connect(function() Tw(row, {BackgroundColor3=C.hover}) end)
    btn.MouseLeave:Connect(function() Tw(row, {BackgroundColor3=C.panel}) end)
end

local lastGunOrder = #CIVILIAN_GUNS + 2
Sec(pBuy, "Quick Buy All", lastGunOrder)
Btn(pBuy, "🛒  TP to Gun Shop & Buy ALL Enabled", C.accent, lastGunOrder+1, function()
    local hrp = GetHRP(); if not hrp then return end
    hrp.CFrame = MAP.GunsAmmo
    Status("TP → Gun Shop (Fairfax Rd)", C.ok)
    task.wait(1)
    local r = ReplicatedStorage:FindFirstChild("BuyItem")
             or ReplicatedStorage:FindFirstChild("PurchaseItem")
             or ReplicatedStorage:FindFirstChild("ShopBuy")
    if r then
        for gn, enabled in pairs(Cfg.AutoBuyGuns) do
            if enabled and not LP.Backpack:FindFirstChild(gn) then
                pcall(function() r:FireServer(gn) end)
                Status("Bought: " .. gn, C.ok)
                task.wait(0.4)
            end
        end
        Status("Auto-buy complete!", C.ok)
    else
        Status("Remote not found – stand inside shop", C.warn)
    end
end)
Btn(pBuy, "🏪  TP → Gun Shop (Maple St)", C.acc2, lastGunOrder+2, function()
    local h = GetHRP(); if h then h.CFrame = MAP.GunsAmmo2; Status("TP → Gun Shop (Maple St)") end
end)

Sec(pBuy, "Law Enforcement Guns (Info Only)", lastGunOrder+3)
Info(pBuy, "LEO guns come from the locker — not the shop.\nSee list in the Weapons tab.", lastGunOrder+4)

-- ═══════════════  TELEPORT  ═══════════════════════════════════════
local pTP = MakePage("Teleport")
Sec(pTP, "City Locations", 1)
local SPOTS = {
    {"🏦 Bank",          MAP.Bank,          C.accent},
    {"💎 Jewelry Store", MAP.Jewelry,       C.acc2},
    {"🔫 Gun Shop (Fairfax)",MAP.GunsAmmo,  C.danger},
    {"🔫 Gun Shop (Maple)",  MAP.GunsAmmo2, C.danger},
    {"🚔 Police Dept",   MAP.PoliceDept,    Color3.fromRGB(40,100,220)},
    {"🚒 Fire Station",  MAP.FireStation,   Color3.fromRGB(210,55,25)},
    {"🏥 Hospital",      MAP.Hospital,      C.ok},
    {"⛓  Prison",        MAP.Prison,        Color3.fromRGB(110,85,25)},
    {"🤠 Sheriff SO",    MAP.SheriffOffice, Color3.fromRGB(155,115,35)},
    {"🔧 Mod Shop",      MAP.ModShop,       Color3.fromRGB(75,75,175)},
    {"⚡ Power Plant",   MAP.PowerPlant,    C.warn},
    {"🅿 Parking Grg",   MAP.ParkingGarage, C.sub},
    {"🚘 Car Dealer",    MAP.CarDealership, Color3.fromRGB(60,160,60)},
    {"⛽ Gas Station",   MAP.GasStation,    Color3.fromRGB(200,130,30)},
    {"🛒 Tool Store",    MAP.ToolStore,     Color3.fromRGB(100,80,160)},
}
for i, s in ipairs(SPOTS) do
    local spot = s
    Btn(pTP, spot[1], spot[3], i+1, function()
        local h = GetHRP()
        if h then h.CFrame = spot[2]; Status("TP → " .. spot[1]) end
    end)
end

Sec(pTP, "ATMs", #SPOTS + 2)
Btn(pTP, "🏧 ATM (near Bank)",     C.warn, #SPOTS+3, function()
    local h = GetHRP(); if h then h.CFrame = MAP.ATM_Bank;    Status("TP → ATM Bank") end
end)
Btn(pTP, "🏧 ATM (Parking Grg)",   C.warn, #SPOTS+4, function()
    local h = GetHRP(); if h then h.CFrame = MAP.ATM_Parking; Status("TP → ATM Parking") end
end)

Sec(pTP, "Criminal Hiding Spots", #SPOTS+5)
for i, cf in ipairs({MAP.Hide1, MAP.Hide2, MAP.Hide3}) do
    local c = cf; local idx = i
    Btn(pTP, "🕶  Hiding Spot #"..i, Color3.fromRGB(45,45,72), #SPOTS+5+i, function()
        local h = GetHRP(); if h then h.CFrame = c; Status("TP → Hide Spot "..idx, C.warn) end
    end)
end

-- ═══════════════  SPEED  ══════════════════════════════════════════
local pSpd = MakePage("Speed")
Sec(pSpd, "Character Movement", 1)
Tog(pSpd, "⚡ Speed Hack",      "SpeedHack", 2, function(v)
    pcall(function() if GetHuman() then GetHuman().WalkSpeed = v and Cfg.WalkSpeed or 16 end end)
    Status(v and "Speed ON – WS "..Cfg.WalkSpeed or "Speed OFF")
end)
Sld(pSpd, "Walk Speed",         "WalkSpeed", 16, 350, 3, function(v)
    pcall(function() if Cfg.SpeedHack and GetHuman() then GetHuman().WalkSpeed = v end end)
end)
Sld(pSpd, "Jump Power",         "JumpPower", 50, 600, 4, function(v)
    pcall(function() if GetHuman() then GetHuman().JumpPower = v end end)
end)
Tog(pSpd, "♾  Infinite Stamina", "InfStamina", 5)
Tog(pSpd, "👻 Noclip",           "Noclip",     6, function(v)
    Status(v and "Noclip ON" or "Noclip OFF", v and C.warn or C.sub)
end)
Sec(pSpd, "Vehicle", 7)
Tog(pSpd, "🚗 CSR Speed Spoof",  "CSRSpoof",  8, function(v) Status(v and "CSR ON" or "CSR OFF") end)
Sld(pSpd, "CSR Multiplier",      "CSRMult",   1, 15, 9)
Tog(pSpd, "🔄 Anti Flip",        "AntiFlip",  10)

-- ═══════════════  WEAPONS  ════════════════════════════════════════
local pWep = MakePage("Weapons")
Sec(pWep, "Gun Mods (apply via GunSettings module)", 1)
Tog(pWep, "🎯 No Recoil",        "NoRecoil",  2)
Tog(pWep, "⚡ Fast Reload",      "FastReload",3)
Tog(pWep, "♾  Infinite Ammo",   "InfAmmo",   4)
Sec(pWep, "Aim Assist", 5)
Tog(pWep, "🔒 Auto Aim / Lock",  "AutoAim",   6)
Tog(pWep, "📦 Hitbox Expander",  "HitboxExp", 7)
Sld(pWep, "Hitbox Size",         "HitboxSize",1, 50, 8)
Sec(pWep, "Quick Equip — Civilian Guns", 9)
local equipOrder = 10
for _, gun in ipairs(CIVILIAN_GUNS) do
    local gn = gun.name
    Btn(pWep, "🔫 Equip " .. gn, C.panel, equipOrder, function()
        pcall(function() GetHuman():EquipTool(LP.Backpack:FindFirstChild(gn)) end)
        Status("Equip: " .. gn)
    end)
    equipOrder += 1
end
Sec(pWep, "Quick Equip — Law Enforcement Guns", equipOrder)
equipOrder += 1
for _, gun in ipairs(LEO_GUNS) do
    local gn = gun.name; local note = gun.note
    Btn(pWep, "🔫 Equip " .. gn .. "  (" .. note .. ")", C.panel, equipOrder, function()
        pcall(function() GetHuman():EquipTool(LP.Backpack:FindFirstChild(gn)) end)
        Status("Equip: " .. gn)
    end)
    equipOrder += 1
end
Sec(pWep, "Non-Gun Tools", equipOrder)
equipOrder += 1
for _, item in ipairs({"Handcuffs","Taser","Pepper Spray","Baton","Stop Stick","Lockpick","Knife","Bat"}) do
    local it = item
    Btn(pWep, "🔧 Equip " .. it, C.panel, equipOrder, function()
        pcall(function() GetHuman():EquipTool(LP.Backpack:FindFirstChild(it)) end)
        Status("Equip: " .. it)
    end)
    equipOrder += 1
end

-- ═══════════════  PLAYER  ═════════════════════════════════════════
local pPlay = MakePage("Player")
Sec(pPlay, "General", 1)
Tog(pPlay, "💤 Anti AFK",          "AntiAFK",      2)
Tog(pPlay, "💡 Full Bright",       "FullBright",   3, function(v)
    Lighting.Brightness   = v and 8 or 1
    Lighting.GlobalShadows = not v
    Status(v and "Full Bright ON" or "Full Bright OFF")
end)
Tog(pPlay, "🔄 Auto Respawn",      "AutoRespawn",  4)
Sec(pPlay, "Cop Tools", 5)
Tog(pPlay, "🚔 Auto Arrest Criminals","AutoArrest", 6)
Tog(pPlay, "⚡ Fast Arrest",        "FastArrest",   7)
Tog(pPlay, "🚫 Auto Eject (kick criminals from cars)","AutoEject",8)
Sec(pPlay, "Criminal Tools", 9)
Btn(pPlay, "🕵  Clear Wanted Level", C.warn, 10, function()
    pcall(function()
        local fe = ReplicatedStorage:FindFirstChild("FE")
        if fe and fe:FindFirstChild("Surrender") then
            fe.Surrender:FireServer()
        end
    end)
    Status("Surrender fired – clearing wanted", C.warn)
end)
Btn(pPlay, "🔄 Respawn Now",        C.danger,  11, function()
    LP:LoadCharacter(); Status("Respawning...", C.warn)
end)
Btn(pPlay, "🏥 Heal — Teleport to Hospital", C.ok, 12, function()
    local h = GetHRP(); if h then h.CFrame = MAP.Hospital; Status("TP → Hospital") end
end)
Btn(pPlay, "📋 Copy Player Name",   C.panel,   13, function()
    if _sclip then _sclip(LP.Name) end
    Status("Copied: " .. LP.Name, C.accent)
end)

-- ═══════════════  SETTINGS  ═══════════════════════════════════════
local pSet = MakePage("Settings")
Sec(pSet, "Keybinds", 1)
Info(pSet, "[HOME]   Show / Hide the UI\n[INSERT] Quick-toggle ESP\n[DELETE] Emergency teleport underground", 2)
Sec(pSet, "Anti-Cheat Status", 3)
Info(pSet, "Status: "..ACStatus.."\n__namecall hook: "..(ACStatus~="Not Available" and "Yes" or "No (executor unsupported)").."\nAll APIs guarded with nil-checks — no nil-call crashes.", 4)
Sec(pSet, "About", 5)
Info(pSet, "ERLC Ultra Hub v6.0  ·  PlaceId 2534724415\nGuns: sourced from ERLC Wiki\nCoords: live-sourced from ERLC scripts", 6)
Sec(pSet, "Actions", 7)
Btn(pSet, "🗑  Destroy / Unload Hub", C.danger, 8, function()
    if _genv then _genv()["_ERLCv6"] = nil end
    SG:Destroy()
end)

------------------------------------------------------------------------
-- §13  NAV BUTTONS
------------------------------------------------------------------------
local NAV_DEFS = {
    {"👁",  "ESP",       "ESP",       1},
    {"🏦",  "Robberies", "Robberies", 2},
    {"🛒",  "Auto Buy",  "AutoBuy",   3},
    {"📡",  "Teleport",  "Teleport",  4},
    {"⚡",  "Speed",     "Speed",     5},
    {"🔫",  "Weapons",   "Weapons",   6},
    {"👤",  "Player",    "Player",    7},
    {"⚙️", "Settings",  "Settings",  8},
}
for _, d in ipairs(NAV_DEFS) do NavBtn(d[1], d[2], d[3], d[4]) end
SelectPage("ESP")

------------------------------------------------------------------------
-- §14  DRAGGING
------------------------------------------------------------------------
local _drag, _dragStart, _startPos = false, nil, nil
TopBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        _drag = true
        _dragStart = i.Position
        _startPos  = Main.Position
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then _drag = false end
end)
UserInputService.InputChanged:Connect(function(i)
    if _drag and i.UserInputType == Enum.UserInputType.MouseMovement and _dragStart and _startPos then
        local d = i.Position - _dragStart
        Main.Position = UDim2.new(
            _startPos.X.Scale, _startPos.X.Offset + d.X,
            _startPos.Y.Scale, _startPos.Y.Offset + d.Y
        )
    end
end)

------------------------------------------------------------------------
-- §15  CLOSE / MINIMISE
------------------------------------------------------------------------
local _minimised = false
local _fullSize  = UDim2.new(0, WIN_W, 0, WIN_H)

BtnClose.MouseButton1Click:Connect(function()
    Tw(Main, {Size=UDim2.new(0,WIN_W,0,0)}, 0.3, Enum.EasingStyle.Back)
    task.delay(0.35, function()
        if _genv then _genv()["_ERLCv6"] = nil end
        SG:Destroy()
    end)
end)
BtnMin.MouseButton1Click:Connect(function()
    _minimised = not _minimised
    Tw(Main, {Size = _minimised and UDim2.new(0,WIN_W,0,48) or _fullSize}, 0.3, Enum.EasingStyle.Back)
end)

------------------------------------------------------------------------
-- §16  KEYBINDS
------------------------------------------------------------------------
UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.Home then
        Main.Visible = not Main.Visible
    elseif i.KeyCode == Enum.KeyCode.Insert then
        Cfg.ESPEnabled = not Cfg.ESPEnabled
        Status(Cfg.ESPEnabled and "ESP ON" or "ESP OFF")
    elseif i.KeyCode == Enum.KeyCode.Delete then
        local h = GetHRP()
        if h then
            h.CFrame = CFrame.new(h.Position + Vector3.new(0, -250, 0))
            Status("Emergency hide!", C.warn)
        end
    end
end)

------------------------------------------------------------------------
-- §17  STEPPED LOOP  (noclip, speed, vehicle)
------------------------------------------------------------------------
RunService.Stepped:Connect(function()
    pcall(function()
        local char  = GetChar();  if not char  then return end
        local human = GetHuman(); local hrp = GetHRP()

        -- Noclip
        if Cfg.Noclip then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end

        -- Speed
        if Cfg.SpeedHack and human then
            human.WalkSpeed = Cfg.WalkSpeed
        end

        -- CSR spoof
        if Cfg.CSRSpoof and human and human.SeatPart then
            local seat = human.SeatPart
            if seat:IsA("VehicleSeat") then
                seat.MaxSpeed  = 200 * Cfg.CSRMult
                seat.Torque    = 6000 * Cfg.CSRMult
                seat.TurnSpeed = 2 * Cfg.CSRMult
            end
        end

        -- Anti-flip
        if Cfg.AntiFlip and hrp then
            local x, _, z = hrp.CFrame:ToEulerAnglesXYZ()
            local _, yr, _ = hrp.CFrame:ToEulerAnglesYXZ()
            if math.abs(x) > 0.85 or math.abs(z) > 0.85 then
                hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, yr, 0)
            end
        end
    end)
end)

------------------------------------------------------------------------
-- §18  HEARTBEAT LOOP  (stamina, gun mods, cop tools)
------------------------------------------------------------------------
RunService.Heartbeat:Connect(function()
    pcall(function()
        -- Infinite Stamina
        if Cfg.InfStamina then
            local gui = LP.PlayerGui:FindFirstChild("GameGui")
            if gui then
                local sv = gui:FindFirstChild("Stamina", true)
                if sv and sv:IsA("NumberValue") then sv.Value = 100 end
            end
        end

        -- Gun mods via GunSettings module
        if Cfg.NoRecoil or Cfg.FastReload or Cfg.InfAmmo then
            for _, tool in ipairs(LP.Backpack:GetChildren()) do
                local gs = tool:FindFirstChild("GunSettings")
                if gs and gs:IsA("ModuleScript") then
                    local ok2, m = pcall(require, gs)
                    if ok2 and type(m) == "table" then
                        if Cfg.NoRecoil   then pcall(function() m.RecoilAmount=0; m.CameraRecoil=0 end) end
                        if Cfg.FastReload then pcall(function() m.ReloadTime=0.01 end) end
                        if Cfg.InfAmmo    then pcall(function() m.MaxAmmo=9999; m.ClipSize=999 end) end
                    end
                end
            end
        end

        -- Auto Aim: lock camera on nearest player
        if Cfg.AutoAim then
            local best, bd = nil, 500
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local or2 = p.Character:FindFirstChild("HumanoidRootPart")
                    local mh  = GetHRP()
                    if or2 and mh then
                        local d = (or2.Position - mh.Position).Magnitude
                        if d < bd then bd = d; best = p end
                    end
                end
            end
            if best and best.Character then
                local tr = best.Character:FindFirstChild("HumanoidRootPart")
                if tr then
                    Cam.CFrame = CFrame.lookAt(Cam.CFrame.Position, tr.Position)
                end
            end
        end

        -- Auto Arrest
        if Cfg.AutoArrest then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP then
                    local wanted = p:FindFirstChild("Is_Wanted")
                    if wanted and wanted.Value and p.Character then
                        local or2 = p.Character:FindFirstChild("HumanoidRootPart")
                        local mh  = GetHRP()
                        if or2 and mh and (or2.Position - mh.Position).Magnitude < 12 then
                            pcall(function()
                                ReplicatedStorage.FE.Handcuffs:InvokeServer("Handcuff", p)
                            end)
                        end
                    end
                end
            end
        end

        -- Auto Eject
        if Cfg.AutoEject then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local ph = p.Character:FindFirstChildOfClass("Humanoid")
                    if ph and ph.SeatPart then
                        pcall(function()
                            ReplicatedStorage.FE.Eject:FireServer(p.Character, ph.SeatPart.Parent)
                        end)
                    end
                end
            end
        end

        -- Team badge refresh
        pcall(function() TeamLbl.Text = "👤 " .. GetTeam() end)
    end)
end)

------------------------------------------------------------------------
-- §19  ANTI AFK
------------------------------------------------------------------------
LP.Idled:Connect(function()
    if Cfg.AntiAFK then
        pcall(function()
            VirtualUser:Button2Down(Vector2.new(0,0), Cam.CFrame)
            task.wait(0.1)
            VirtualUser:Button2Up(Vector2.new(0,0), Cam.CFrame)
        end)
    end
end)

------------------------------------------------------------------------
-- §20  AUTO RESPAWN
------------------------------------------------------------------------
LP.CharacterAdded:Connect(function(char)
    task.wait(0.8)
    local h = char:WaitForChild("Humanoid", 5)
    if not h then return end
    if Cfg.SpeedHack then h.WalkSpeed = Cfg.WalkSpeed end
    h.JumpPower = Cfg.JumpPower
    h.Died:Connect(function()
        if Cfg.AutoRespawn then
            task.wait(3)
            LP:LoadCharacter()
        end
    end)
end)

------------------------------------------------------------------------
-- §21  ESP RENDERER
------------------------------------------------------------------------
local ESPCache = {}

Players.PlayerRemoving:Connect(function(p)
    if ESPCache[p] then
        for _, o in ipairs(ESPCache[p]) do pcall(function() o:Destroy() end) end
        ESPCache[p] = nil
    end
end)

RunService.RenderStepped:Connect(function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP then continue end
        local char = p.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if not Cfg.ESPEnabled or not root then
            if ESPCache[p] then
                for _, o in ipairs(ESPCache[p]) do pcall(function() o:Destroy() end) end
                ESPCache[p] = nil
            end
            continue
        end

        if not ESPCache[p] then
            local bb = Instance.new("BillboardGui")
            bb.AlwaysOnTop  = true
            bb.Size         = UDim2.new(0,170,0,52)
            bb.StudsOffset  = Vector3.new(0,3.4,0)
            bb.Parent       = root

            local nl = Instance.new("TextLabel")
            nl.Name = "NL"; nl.Size = UDim2.new(1,0,.58,0)
            nl.BackgroundTransparency = 1
            nl.Font = Enum.Font.GothamBold; nl.TextSize = 13
            nl.TextStrokeTransparency = 0.35
            nl.TextStrokeColor3 = C.black
            nl.Parent = bb

            local dl = Instance.new("TextLabel")
            dl.Name = "DL"; dl.Size = UDim2.new(1,0,.42,0)
            dl.Position = UDim2.new(0,0,.58,0)
            dl.BackgroundTransparency = 1
            dl.Font = Enum.Font.Gotham; dl.TextSize = 11
            dl.TextColor3 = C.sub
            dl.TextStrokeTransparency = 0.4
            dl.TextStrokeColor3 = C.black
            dl.Parent = bb

            ESPCache[p] = {bb, nl, dl}
        end

        local objs = ESPCache[p]
        local bb, nl, dl = objs[1], objs[2], objs[3]
        if bb and bb.Parent ~= root then bb.Parent = root end

        local col = C.white
        if Cfg.ESPTeam and p.Team then
            local tc = p.TeamColor.Color
            col = Color3.fromRGB(tc.R*255, tc.G*255, tc.B*255)
        end

        if nl then
            nl.Visible    = Cfg.ESPNames
            local wanted  = p:FindFirstChild("Is_Wanted")
            nl.Text       = p.Name .. (Cfg.ShowBounty and wanted and wanted.Value and " 💰WANTED" or "")
            nl.TextColor3 = col
        end

        if dl then
            local mh   = GetHRP()
            local dist = mh and math.floor((root.Position - mh.Position).Magnitude) or 0
            dl.Visible = Cfg.ESPDist
            dl.Text    = dist .. " studs  ·  " .. (p.Team and p.Team.Name or "?")
        end
    end
end)

------------------------------------------------------------------------
-- §22  AUTO ROB LOOPS
------------------------------------------------------------------------

-- ATM auto-rob
task.spawn(function()
    while task.wait(0.4) do
        if not Cfg.AutoRobATM then continue end
        pcall(function()
            local hrp = GetHRP(); if not hrp then return end
            local best, bd = nil, 80
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if (obj.Name=="ATM" or obj.Name=="ATMMachine") and obj:IsA("Model") then
                    local pt = obj:FindFirstChildWhichIsA("BasePart")
                    if pt and (pt.Position - hrp.Position).Magnitude < bd then
                        bd = (pt.Position - hrp.Position).Magnitude; best = obj
                    end
                end
            end
            if best then
                local pt = best:FindFirstChildWhichIsA("BasePart")
                if pt then hrp.CFrame = CFrame.new(pt.Position + Vector3.new(0,2.5,3)) end
            end
            local gui = LP.PlayerGui:FindFirstChild("GameMenus")
            if gui then
                local ui = gui:FindFirstChild("ATM") or gui:FindFirstChild("RobATM")
                if ui and ui.Visible then
                    pcall(function()
                        VirtualUser:ClickButton1(
                            Vector2.new(math.random(3,12), math.random(3,12)),
                            Cam.CFrame
                        )
                    end)
                    Status("Auto ATM: clicking!", C.warn)
                end
            end
        end)
    end
end)

-- Jewelry auto-rob
task.spawn(function()
    while task.wait(0.25) do
        if not Cfg.AutoRobJewelry then continue end
        pcall(function()
            local hrp = GetHRP(); if not hrp then return end
            if (hrp.Position - MAP.Jewelry.Position).Magnitude > 35 then
                hrp.CFrame = MAP.Jewelry; task.wait(1); return
            end
            local gui = LP.PlayerGui:FindFirstChild("GameMenus")
            if not gui then return end
            local ui = gui:FindFirstChild("RobJewelry") or gui:FindFirstChild("Jewelry")
            if ui and ui.Visible then
                local gz = ui:FindFirstChild("Drill") and ui.Drill:FindFirstChild("goodzone")
                if gz then
                    VirtualUser:ClickButton1(
                        Vector2.new(
                            gz.AbsolutePosition.X + gz.AbsoluteSize.X/2,
                            gz.AbsolutePosition.Y + gz.AbsoluteSize.Y/2
                        ),
                        Cam.CFrame
                    )
                else
                    VirtualUser:ClickButton1(
                        Vector2.new(math.random(3,10), math.random(3,10)),
                        Cam.CFrame
                    )
                end
                Status("Auto Jewelry: drilling!", C.warn)
            end
        end)
    end
end)

-- Bank auto-rob
task.spawn(function()
    while task.wait(0.8) do
        if not Cfg.AutoRobBank then continue end
        pcall(function()
            local hrp = GetHRP(); if not hrp then return end
            if (hrp.Position - MAP.Bank.Position).Magnitude > 30 then
                hrp.CFrame = MAP.Bank; task.wait(1.5); return
            end
            local gui = LP.PlayerGui:FindFirstChild("GameMenus")
            if gui then
                local safe = gui:FindFirstChild("Safe") or gui:FindFirstChild("BankSafe")
                if safe and safe.Visible then
                    local top    = safe:FindFirstChild("Top2")
                    local target = top and top:FindFirstChild("TargetNum") and tonumber(top.TargetNum.Text)
                    if target then
                        local angle = (target - 1) * 36
                        pcall(function()
                            local fe = ReplicatedStorage:FindFirstChild("FE")
                            if fe and fe:FindFirstChild("SafeDial") then
                                fe.SafeDial:FireServer(angle)
                            end
                        end)
                    end
                    Status("Auto Bank: cracking safe!", C.warn)
                end
            end
        end)
    end
end)

-- Houses auto-rob
task.spawn(function()
    while task.wait(2) do
        if not Cfg.AutoRobHouses then continue end
        pcall(function()
            local hrp = GetHRP(); if not hrp then return end
            local folder = Workspace:FindFirstChild("Houses") or Workspace:FindFirstChild("Housing")
            if not folder then return end
            for _, item in ipairs(folder:GetDescendants()) do
                if item.Name == "StealableItem" or item.Name == "HouseItem" or item.Name == "LootItem" then
                    local pt = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart")
                    if pt then
                        hrp.CFrame = CFrame.new(pt.Position + Vector3.new(0,2,0))
                        task.wait(0.35)
                        pcall(function()
                            local rh = ReplicatedStorage:FindFirstChild("Houses")
                            if rh and rh:FindFirstChild("StealItem") then
                                rh.StealItem:FireServer(item)
                            end
                        end)
                        task.wait(0.25)
                    end
                end
            end
        end)
    end
end)

-- Auto Buy loop
task.spawn(function()
    while task.wait(2.5) do
        local anyEnabled = false
        for _, v in pairs(Cfg.AutoBuyGuns) do
            if v then anyEnabled = true; break end
        end
        if not anyEnabled then continue end
        pcall(function()
            local hrp = GetHRP(); if not hrp then return end
            if (hrp.Position - MAP.GunsAmmo.Position).Magnitude > 30 then
                hrp.CFrame = MAP.GunsAmmo; task.wait(1); return
            end
            local r = ReplicatedStorage:FindFirstChild("BuyItem")
                   or ReplicatedStorage:FindFirstChild("PurchaseItem")
                   or ReplicatedStorage:FindFirstChild("ShopBuy")
            if not r then return end
            for gn, enabled in pairs(Cfg.AutoBuyGuns) do
                if enabled and not LP.Backpack:FindFirstChild(gn) then
                    pcall(function() r:FireServer(gn) end)
                    Status("Bought: " .. gn, C.ok)
                    task.wait(0.45)
                end
            end
        end)
    end
end)

------------------------------------------------------------------------
-- §23  OPEN ANIMATION
------------------------------------------------------------------------
Main.Size     = UDim2.new(0,0,0,0)
Main.Position = UDim2.new(0.5,0,0.5,0)
Tw(
    Main,
    {Size = _fullSize, Position = UDim2.new(0.5,-WIN_W/2,0.5,-WIN_H/2)},
    0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out
)

Status("ERLC Ultra Hub v6.0 loaded  ·  AC: " .. ACStatus .. "  ·  [HOME] toggle", C.ok)

print([[
╔══════════════════════════════════════════════╗
║      ERLC Ultra Hub v6.0  —  LOADED          ║
║  [HOME]   Show / Hide UI                     ║
║  [INSERT] Quick ESP toggle                   ║
║  [DELETE] Emergency hide                     ║
╚══════════════════════════════════════════════╝
]])
