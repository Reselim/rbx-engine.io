local HttpService = game:GetService("HttpService")

local Transport = require(script.Transport)
local Emitter = require(script.Emitter)
local Timer = require(script.Timer)

local Socket = setmetatable({}, Emitter)
Socket.__index = Socket

function Socket.new(uri, path)
	local self = setmetatable(Emitter.new(), Socket)

	if uri then
		local schema = uri:match("^(%s+)://")
		local host = uri:gsub("^%w+://", ""):match("^([%w%.-]+:?%d*)")

		self.Host = host
		self.Secure = schema == "https" or schema == "wss"
	else
		self.Host = "localhost"
		self.Secure = false
	end

	self.Path = path or "/engine.io"

	self:Open()

	return self
end

function Socket:Open()
	self._transport = Transport.new({
		Host = self.Host,
		Secure = self.Secure,
		Path = self.Path
	})

	self._transport:On("packet", function(packet)
		if packet.Type == "open" then
			local data = HttpService:JSONDecode(packet.Data)

			self._transport.Id = data.sid

			self._pingTimeout = data.pingTimeout / 1000
			self._pingInterval = data.pingInterval / 1000

			self._pingTimer = Timer.new(function()
				self:Ping()
			end):Start(self._pingInterval)
		elseif packet.Type == "error" then
			self:Close(true)
		end

		self:Emit(packet.Type, packet.Data)
	end)

	self._transport:On("error", function()
		self:Close(true)
	end)
end

function Socket:Ping()
	self:Emit("ping")

	spawn(function()
		local success = false

		delay(self._pingTimeout, function()
			if not success then
				self:Close(true, "Timed out")
			end
		end)

		self._transport:Write({ Type = "ping" })
		self:Wait("pong")

		success = true
	end)
end

function Socket:Send(data)
	self._transport:Write({
		Type = "message",
		Data = data
	})
end

function Socket:Close(error)
	if not error then
		self._transport:Write({ Type = "close" })
		self._transport:Flush(true)
		self._transport:Close()
	else
		self:Emit("close")
	end

	if self._pingTimer then
		self._pingTimer:Stop()
	end
end

return Socket
