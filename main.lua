--[[
	Save Scum, a game for Adelaide Game Jam II, theme "Competition"

	Developed by Josh Douglass-Molloy
]]--

love.load = function()
	love.graphics.setBackgroundColor( unpack(COLOURS['BG_COLOUR']) )
	
	for i, __ in ipairs(SPAWN_POINTS) do
		spawns_used[i] = false
	end

	--assign players
	for i = 1, 2 do
		currplayer = system:new_entity()

	end
	

end

--maps players to entities
players = {}

--transition table for game states
game_states = {

	t = {	
		PLAYING = 'WAITING',
		WAITING = 'PLAYING',
		GAME_OVER = 'PLAYING'
	}
}

function game_states:switch(state)
	return self.t[state]
end


system = {

	entities = {},
	destroyed = {},	
	saves = {}, --one for each player 
	
	state = 'PLAYING'

} 

--saves positions for all players
function system:save(time)

	for i, v in ipairs(players) do
		data = {
			pos = {
				x = 0,
				y = 0		
			}
		}
		data.pos.x = self.entities[v].pos.x
		data.pos.y = self.entities[v].pos.y
 
		self.saves[i] = data
	end

end

--loads positions for all players
function system:load()

	for i, v in ipairs(saves) do
		e = self.entities[i]

		e.pos.x = v.pos.x
		e.pos.y = v.pos.y
	end

end

function system:new_entity()

	local entity = {
		id = #self.entities + 1,
		type = "",
		pos = {
			x = 0,
			y = 0
		},

		heading = {
			x = 0,
			y = 0
		},

		speed = 0,
		spawn_point = 0
	}

	table.insert(self.entities, entity)

end

function system:del_entity(e)

	destroyed[e] = true
end


love.update = function(dt)

	--player movement
	for i, v in ipairs(players) do
		e = v

		if love.keyboard.isDown(CONTROLS.PLAYER[i].UP) then
			v.pos.y =  v.pos.y + v.speed
		elseif love.keyboard.isDown(CONTROLS.PLAYER[i].LEFT) then
			v.pos.x =  v.pos.x - v.speed
		elseif love.keyboard.isDown(CONTROLS.PLAYER[i].DOWN) then
			v.pos.y =  v.pos.y - v.speed
		elseif love.keyboard.isDown(CONTROLS.PLAYER[i].RIGHT) then
			v.pos.x =  v.pos.x + v.speed
		end	
	end

end

love.draw = function()

	for i, v in ipairs(system.entities) do
	
	end
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

	if res then
		return res
	end
end


CONTROLS = {

	PLAYER = {
		{
			UP = 'w',
			LEFT = 'a',
			DOWN = 's',
			RIGHT = 'd'
		},
		{
			UP = 'up',
			LEFT = 'left',
			DOWN = 'down',
			RIGHT = 'right'
		}
	},	
	PASS = ' ',
	SAVE = 'f5',
	LOAD = 'f9'
}

COLOURS = {

	BG_COLOUR = {255, 255, 255},

	PLAYER_COLOURS = {
		
		{0, 255, 0},
		{0, 0, 0}
		
	},

	TARGET_COLOUR = {128, 0, 128}
}

MAP = {
	WIDTH = 400,
	HEIGHT = 400
}

SPAWN_POINTS = {

		{MAP.WIDTH * 0.1, MAP.HEIGHT * 0.1}, -- bottom left
		{MAP.WIDTH - MAP.WIDTH * 0.1, MAP.HEIGHT * 0.1}, -- bottom right
		{MAP.WIDTH * 0.1, MAP.HEIGHT - MAP.HEIGHT * 0.1}, -- top left
		{MAP.WIDTH - MAP.WIDTH * 0.1, MAP.HEIGHT - MAP.HEIGHT * 0.1}, -- top right
		{MAP.WIDTH / 2, MAP.HEIGHT - MAP.HEIGHT * 0.1}, --top centre
		{MAP.WIDTH / 2, MAP.HEIGHT * 0.1}, --bottom centre
		{MAP.WIDTH / 2, MAP.HEIGHT / 2} -- centre

}

spawns_used = {}
