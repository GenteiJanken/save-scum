--[[
	Save Scum, a game for Adelaide Game Jam II, theme "Competition"

	Developed by Josh Douglass-Molloy
]]--

MAP = {
	WIDTH = 400,
	HEIGHT = 400
}

commands = {
	save = "SAVE",
	load = "LOAD"
}

--maps players to entities
players = {}

CONTROLS = {

	PLAYER = {
		{
			UP = 'w',
			LEFT = 'a',
			DOWN = 's',
			RIGHT = 'd',
			SAVE = 'lshift',
			LOAD = 'lctrl'
		},

		{
			UP = 'up',
			LEFT = 'left',
			DOWN = 'down',
			RIGHT = 'right',
			SAVE = 'rshift',
			LOAD = 'rctrl'

		}
	},
	
	PASS = " "

}

system = {

	entities = {},
	destroyed = {},	
	saves = {}

} 

function system:new_entity()

	local entity = {
		id = #self.entities + 1,
		pos = {
			x = 0,
			y = 0
		},

		heading = {
			x = 0,
			y = 0
		}

	}
	table.insert(self.entities, entity)

end

function system:del_entity(e)

	destroyed[e] = true
end

love.load = function()
	love.graphics.setBackgroundColor(unpack(COLOURS["BG_COLOUR"]))


end

love.update = function(dt)

end



love.draw = function()

	
end


-- Lightweight Stack
stack = {
	
	elements = {}

}

function stack:push(var) 
	table.insert(self.elements, var)
end


function stack:pop() 
	res = nil

	if #self.elements > 0 then
		res = self.elements[#self.elements]
		table.remove(self.elements)
	end

	if res == nil then
		print("ERROR")	
	else
		return res
	end
end



COLOURS = {

	BG_COLOUR = {255,255,255},

	PLAYER_COLOURS = {
		
		{0, 255, 0},
		{0, 0, 0}
		
	},

	TARGET_COLOUR = {128, 0, 128}
}
