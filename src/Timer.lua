local Timer = {}
Timer.__index = Timer

function Timer.new(handler)
	return setmetatable({
		Handler = handler,
		Active = false
	}, Timer)
end

function Timer:Start(time)
	self.Active = true
	self.Time = time

	spawn(function()
		while true do
			wait(self.Time)

			if not self.Active then
				break
			end

			spawn(self.Handler)
		end
	end)

	return self
end

function Timer:Stop()
	self.Active = false
end

return Timer
