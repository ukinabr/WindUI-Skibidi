local MIRRORS = {
	"https://article-hub-studio.github.io/WindUI-Skibidi/main.lua",
	"https://article-hub-studio.github.io/WindUI-Skibidi/dist/main.lua",
	"https://cdn.jsdelivr.net/gh/article-hub-studio/WindUI-Skibidi@main/dist/main.lua",
	"https://github.com/article-hub-studio/WindUI-Skibidi/releases/latest/download/main.lua",
}

local lastError = "no mirrors tried"

for _, url in ipairs(MIRRORS) do
	local ok, body = pcall(function()
		return game:HttpGet(url)
	end)

	if ok and type(body) == "string" then
		local prefix = string.lower(string.sub(body, 1, 220))
		local blocked = string.find(prefix, "429:", 1, true)
			or string.find(prefix, "too many requests", 1, true)
			or string.find(prefix, "<html", 1, true)
			or string.find(prefix, "<!doctype", 1, true)

		if not blocked and #body > 1000 then
			local chunk, compileError = loadstring(body)
			if chunk then
				return chunk()
			end

			lastError = tostring(compileError)
		else
			lastError = "blocked or invalid response from " .. url
		end
	else
		lastError = tostring(body)
	end
end

error("[WindUI Modded] Failed to load any mirror: " .. tostring(lastError))
