local Database = {}

Database.Maps = {
	[1] = {
		Name = 'Forest',
		Image = 'rbxassetid://83978212876861',
		MinimapId = 'rbxassetid://92968083739791'
	},
	
	[2] = {
		Name = 'Beach',
		Image = 'rbxassetid://84721477003431',
		MinimapId = 'rbxassetid://79396801656951',
	},
	
	[3] = {
		Name = 'Desert',
		Image = 'rbxassetid://117899772262354',
		MinimapId = 'rbxassetid://123760584370993'
	},
	
	[4] = {
		Name = 'Neon City',
		Image = 'rbxassetid://124030107185382',
		MinimapId = 'rbxassetid://79979734317193'
	}
}

Database.Trails = {
	['Basic'] = {
		WalkSpeed = 20,
		Icon = 'rbxassetid://140250247922423',
		Description = '20 Walk Speed (+4)',
		LayoutOrder = 0,
		Color = Color3.fromRGB(173, 192, 194)
	},
	
	['Intermediate'] = {
		WalkSpeed = 24,
		Icon = 'rbxassetid://133366986568660',
		Description = '24 Walk Speed (+8)',
		LayoutOrder = 1,
		Cost = 20,
		Color = Color3.fromRGB(250, 189, 43)
	},
	
	['Advanced'] = {
		WalkSpeed = 28,
		Icon = 'rbxassetid://130114767174062',--'rbxassetid://109125138508131',
		Description = '28 Walk Speed (+8)',
		LayoutOrder = 2,
		Cost = 50,
		Color = Color3.fromRGB(255, 123, 67)
	},
	
	['Pro'] = {
		WalkSpeed = 32,
		Icon = 'rbxassetid://88673530368995',
		Description = '32 Walk Speed (+12)',
		LayoutOrder = 3,
		Cost = 200,
		Color = Color3.fromRGB(27, 26, 23)
	}
}

return Database