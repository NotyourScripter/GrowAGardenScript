local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local PlaceId = game.PlaceId
local JobId = game.JobId
local player = Players.LocalPlayer

local function getServers()
	local servers = {}
	local cursor = ""
	local pagesChecked = 0

	repeat
		local url = "https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"..(cursor ~= "" and "&cursor="..cursor or "")
		local success, result = pcall(function()
			return HttpService:JSONDecode(game:HttpGet(url))
		end)

		if success and result and result.data then
			for _, server in pairs(result.data) do
				local isNotCurrent = server.id ~= JobId
				local hasPlayers = server.playing > 0
				local notFull = server.playing < server.maxPlayers

				if isNotCurrent and hasPlayers and notFull then
					table.insert(servers, server)
				end
			end
			cursor = result.nextPageCursor or ""
		else
			warn("Failed to fetch servers.")
			break
		end

		pagesChecked += 1
		wait(0.1)
	until cursor == "" or pagesChecked >= 5

	return servers
end

local function hopToBestServer()
	local servers = getServers()
	if #servers == 0 then
		warn("No suitable servers found.")
		return
	end

	-- Sort by fewest players first (simulate lowest ping by prioritizing early entries)
	table.sort(servers, function(a, b)
		return a.playing < b.playing
	end)

	local bestServer = servers[1]
	TeleportService:TeleportToPlaceInstance(PlaceId, bestServer.id, player)
end

hopToBestServer()
