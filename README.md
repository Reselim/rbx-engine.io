## Example

```lua
local Engine = require(script.Engine)
local Socket = Engine.new() -- Connects to localhost

Socket:On("open", function()
	print("Connected")
	Socket:Send("test")
end)

Socket:On("message", function(data)
	print("Message recieved: " .. data)
end)

Socket:On("close", function(data)
	print("Disconnected")
end)
```
