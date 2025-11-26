-- Services
local TweenService = game:GetService("TweenService")

-- Variables
local Bezier = {}

-- Functions
local function Lerp(p0, p1, i)
	return p0 + (p1 - p0) * i
end

local function DrawLine(Position1: Vector3, Position2: Vector3): ()
	local Line = Instance.new("Part")
	local Distance = (Position2 - Position1).Magnitude
	Line.Size = Vector3.new(1, 1, Distance)
	Line.Anchored = true
	Line.Material = Enum.Material.Neon
	Line.Transparency = 0.2
	Line.Parent = workspace

	local Mid = (Position1 + Position2) / 2

	TweenService:Create(Line, TweenInfo.new(1.25), {Transparency = 1}):Play()

	task.delay(1.25, function()
		Line:Destroy()
	end)

	Line:PivotTo(CFrame.lookAt(Mid, Position2))

	return Line
end

local function DrawDot(Position: Vector3, Size: Vector3): ()
	local NewDot = Instance.new("Part")
	NewDot.Position = Position
	NewDot.Size = Size and Vector3.one * Size or Vector3.new(0.5, 0.5, 0.5)
	NewDot.Color = Color3.fromRGB(0, 255, 60)
	NewDot.Material = Enum.Material.Neon
	NewDot.Shape = Enum.PartType.Ball
	NewDot.Transparency = 0.35
	NewDot.CanCollide = false
	NewDot.Anchored = true
	NewDot.Parent = workspace

	task.delay(3, function()
		NewDot:Destroy()
	end)

	return NewDot
end

local function RandomOffset(Padding: number): Vector3
	return Vector3.new(math.random(-Padding, Padding), math.random(-Padding, Padding), math.random(-Padding, Padding))
end

local function Cubic(p0, p1, p2, p3, i)
	local c0 = Lerp(p0, p1, i)
	local c1 = Lerp(p1, p2, i)
	local c2 = Lerp(p2, p3, i)

	local b0 = Lerp(c0, c1, i)
	local b1 = Lerp(c1, c2, i)

	local n0 = Lerp(b0, b1, i)

	return n0
end

local function Quad(p0, p1, p2, i)
	local c0 = Lerp(p0, p1, i)
	local c1 = Lerp(p1, p2, i)

	local b0 = Lerp(c0, c1, i)

	return b0
end

-- Public
Bezier.Drawline = DrawLine
Bezier.DrawDot = DrawDot
Bezier.Lerp = Lerp
Bezier.RandomOffset = RandomOffset
Bezier.Cubic = Cubic
Bezier.Quad = Quad

return Bezier