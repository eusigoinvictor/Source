-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables
local Services = {}
local ServicesManager = {}
local StartTime = time()
local LoadedCount = 0
local InitializedCount = 0
local RemoteFunction = ReplicatedStorage.Remotes.RemoteFunction
local RemoteEvent = ReplicatedStorage.Remotes.RemoteEvent

-- Private
local function ManageRemotes(Path: Instance): ()	
	if Path.Name == 'Client' then		
		RemoteEvent.OnClientEvent:Connect(function(ServiceName, Args)			
			if not Services[ServiceName] then
				return warn(`Service {ServiceName} not found - Remotes Manager`)
			end
			
			if not Services[ServiceName].OnClientEvent then
				return warn(`Service {ServiceName} was found but there was no Remote Receiver - Remotes Manager`)
			end

			Services[ServiceName].OnClientEvent(Args)
		end)

		RemoteFunction.OnClientInvoke = function(ServiceName, Args)
			if not Services[ServiceName] then
				return warn(`Service {ServiceName} not found - Remotes Manager`)
			end
			
			if not Services[ServiceName].OnClientInvoke then
				return warn(`Service {ServiceName} was found but there was no Remote Receiver - Remotes Manager`)
			end

			return Services[ServiceName].OnClientInvoke(Args)	
		end
	elseif Path.Name == 'Server' then
		RemoteEvent.OnServerEvent:Connect(function(Player, ServiceName, Args)
			if not Services[ServiceName] then
				return warn(`Service {ServiceName} not found - Remotes Manager`)
			end
			
			if not Services[ServiceName].OnServerEvent then
				return warn(`Service {ServiceName} was found but there was no Remote Receiver - Remotes Manager`)
			end

			Services[ServiceName].OnServerEvent(Player, Args)
		end)

		RemoteFunction.OnServerInvoke = function(Player, ServiceName, Args)			
			if not Services[ServiceName] then
				return warn(`Service {ServiceName} not found - Remotes Manager`)
			end
			
			if not Services[ServiceName].OnServerInvoke then
				return warn(`Service {ServiceName} was found but there was no Remote Receiver - Remotes Manager`)
			end

			return Services[ServiceName].OnServerInvoke(Player, Args)	
		end
	end
end

local function LoadServices(Path: Instance): ()
	for _, Module in Path:GetDescendants() do	
		if not Module:IsA("ModuleScript") then
			continue
		end
		
		local StartTime = time()

		Services[Module.Name] = require(Module)
	end
end

local function InitServices(Path: Instance): ()	
	for ServiceName, Service in Services do
		Service.Services = Services
		
		if not Service.Init then			
			continue
		end

		task.spawn(function()
			local StartTime = time()
			
			Service.Init()
			Service.Initialized = true
						
			local Time = math.round((time() - StartTime) * 10) / 10
			
			if Time > 0 then
				warn(`Took {Time}s to initialize [{ServiceName}]`)
			end
		end)	
	end
end

-- Public
function ServicesManager.Init(Path)		
	LoadServices(Path)
	ManageRemotes(Path)
	InitServices(Path)
end

return ServicesManager