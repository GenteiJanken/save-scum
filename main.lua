--[[
	Save Scum, a game for Adelaide Game Jam II, theme "Competition"

	Developed by Josh Douglass-Molloy
]]--
elapsed_time = 0

love.load = function()
	love.graphics.setBackgroundColor( unpack(COLOURS['BG_COLOUR']) )
	love.graphics.setNewFont(22)
	for i, __ in ipairs(SPAWN_POINTS) do
		spawns_used[i] = false
	end
	
	players = {}
	system.entities = {}
	system.destroyed = {}
	system.saves = {}
	system.state = 'PLAYING'
	win_text = ""

	--assign players
	for i = 1, 2 do
		spawn = SPAWN_POINTS[i]
		currplayer = system:new_entity()
		currplayer.type = 'player'
		currplayer.pid = i
		currplayer.size = 15
		currplayer.speed = 100
		currplayer.pos.x = spawn[1]
		currplayer.pos.y = spawn[2]
		currplayer.points = 0
		currplayer.saves = 3
		currplayer.loads = 3
		table.insert(players, currplayer.id)
	end
		
	--make targets
	
	for i = 5, #SPAWN_POINTS do
		spawn = SPAWN_POINTS[i]
		currtarget = system:new_entity()
		currtarget.type = 'target'
		currtarget.size = 15
		currtarget.speed = 100
		currtarget.pos.x = spawn[1]
		currtarget.pos.y = spawn[2]
		
	
	end
	elasped_time = 0

	system:save(elapsed_time)


end

function win_game(pid)
	system.state = 'GAME_OVER'
	love.graphics.setColor(255, 0, 0)
	sw = love.graphics.getWidth()
	sh = love.graphics.getHeight()
	 
	win_text = 'Player ' .. pid .. ' wins! Press r to restart'
	love.graphics.print(win_text, sw/2, sh/2)
end


function get_spawn(start)


end


function draw_player(self)


	love.graphics.setColor(unpack(COLOURS.PLAYER_COLOURS[self.pid]))
	offset = {self.pos.x - self.size, self.pos.y - self.size}
	screencoord = worldtoscreen(offset[1], offset[2])

	love.graphics.rectangle("fill", screencoord[1], screencoord[2], 2 * self.size, 2 * self.size)	


end

function draw_target(self)

	love.graphics.setColor(unpack(COLOURS.TARGET_COLOUR))
	screencoord = worldtoscreen(self.pos.x, self.pos.y)
	love.graphics.circle("fill", screencoord[1], screencoord[2], self.size)
--[[	love.graphics.setColor(255, 0, 0)
	sw = love.graphics.getWidth()
	sh = love.graphics.getHeight()
	text = "TARGET AT " .. self.pos.x .. ", " .. self.pos.y
	love.graphics.print(text, sw/2, sh/2)
]]--

end


function draw_trap(self)

end


function love.keyreleased(key)

	for i, v in ipairs(players) do
		e = system.entities[v]

		if key == CONTROLS.PLAYER[i].SAVE and e.saves > 0 then
			stack.push('SAVE')
			e.saves = e.saves - 1 
		elseif key == CONTROLS.PLAYER[i].LOAD and e.loads > 0 then
			stack.push('LOAD')
			e.saves = e.loads - 1
		end
	end

	if key == 'escape' then
		love.event.push('quit')
	
	elseif key == CONTROLS.PASS then
		flush_stack()
	elseif system.state == 'GAME_OVER' and key == 'r' then
		love.load()
	end


end



function collide_entities(e0, e1)
	return (euclid(e0.pos.x, e0.pos.y, e1.pos.x, e1.pos.y) <= e0.size + e1.size + 5) 
end

function love.update(dt)
	elapsed_time = elapsed_time + dt

	--target collision
	
	for i, v in ipairs(players) do
		
		p = system.entities[v]
	
		for __, t in pairs(system.entities) do
			
			if t.type == "target" and collide_entities(p, t) then
				p.points = p.points + 1
				system:del_entity(t)
				
				if p.points > NUM_TARGETS / 2 then
					win_game(p.pid)
				end
			end
		
		end

	end
	
	--trap collision


	--remove any destroyed entities
	
	for entity,_ in pairs(system.destroyed) do
			for i,e in ipairs(system.entities) do
				if entity == e then
					table.remove(system.entities, i)
					break
				end
			end
	end
	
	
	--player movement
	for i, v in ipairs(players) do
		e = system.entities[v]

		if love.keyboard.isDown(CONTROLS.PLAYER[i].UP) then
			e.pos.y =  clamp(e.pos.y + e.speed * dt, 0, MAP.HEIGHT)
		end
		if love.keyboard.isDown(CONTROLS.PLAYER[i].LEFT) then
			e.pos.x =  clamp(e.pos.x - e.speed * dt, 0, MAP.WIDTH)
		end
		if love.keyboard.isDown(CONTROLS.PLAYER[i].DOWN) then
			e.pos.y =  clamp(e.pos.y - e.speed * dt, 0, MAP.HEIGHT)
		end
		if love.keyboard.isDown(CONTROLS.PLAYER[i].RIGHT) then
			e.pos.x =  clamp(e.pos.x + e.speed * dt, 0, MAP.WIDTH)
		end	
	end

	--calculate target headings
	for i, entity in ipairs(system.entities) do
	
		if entity.type == 'target' then	
			for j, v in ipairs(players) do
				p = system.entities[v]
				if euclid(entity.pos.x, entity.pos.y, p.pos.x, p.pos.y) < MAP.WIDTH/3 then
					vec = normalise(entity.pos.x - p.pos.x, entity.pos.y - p.pos.y)
					entity.heading.x = entity.heading.x + vec[1]
					entity.heading.y = entity.heading.y + vec[2]
			

				end
			end
			
			if entity.heading.x ~= 0 and entity.heading.y ~= 0 then
				norm = normalise(entity.heading.x, entity.heading.y)
				entity.heading.x = norm[1]
				entity.heading.y = norm[2]
				entity.pos.x = clamp(entity.pos.x + entity.speed * entity.heading.x * dt, 0, MAP.WIDTH)
				entity.pos.y = clamp(entity.pos.y + entity.speed * entity.heading.y * dt, 0, MAP.HEIGHT)
				e.heading.x = 0
				e.heading.y = 0
			end
		end
		
	end
		


end

function love.draw ()

	for i, v in ipairs(system.entities) do
		if system.entities[i].type == "player" then
			draw_player(system.entities[i])
		elseif system.entities[i].type == "target" then
			draw_target(system.entities[i])
		end
	end

	if system.state == 'GAME_OVER' then
	love.graphics.setColor(255, 0, 0)
	sw = love.graphics.getWidth()
	sh = love.graphics.getHeight()
	 
	--win_text = 'Player ' .. pid .. ' wins! Press r to restart'
	love.graphics.print(win_text, sw/2, sh/2)
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
		data.pos.x = system.entities[v].pos.x
		data.pos.y = system.entities[v].pos.y
 
		system.saves[i] = data
	end

end

--loads positions for all players
function system:load()

	for i, v in ipairs(system.saves) do
		e = system.entities[players[i]]

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
	return entity

end

function system:del_entity(e)

	system.destroyed[e] = true
end



--executes all the SAVE/LOAD commands on the stack
function flush_stack()
	while(true) do 
		cmd = stack:pop()
		
		if cmd then
		
			if cmd == 'SAVE' then
				system:save(elapsed_time)
			elseif cmd == 'LOAD' then
				system.load(elapsed_time)
			end
		else
			break
		
		end
	end
end

-- Lightweight Stack
stack = {
	
	elements = {}

}

function stack.push(var) 
	table.insert(stack.elements, var)
end

--returns top element of stack or nil if stack is empty
function stack.pop() 
	res = nil

	if #stack.elements > 0 then
		res = stack.elements[#stack.elements]
		table.remove(stack.elements)
	end

	
	return res

end


NUM_TARGETS = 3

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
	PASS = ' '
}

COLOURS = {

	BG_COLOUR = {255, 255, 255},

	PLAYER_COLOURS = {
		
		{0, 255, 0},
		{0, 0, 0}
		
	},

	TARGET_COLOUR = {128, 0, 128},
	TRAP_COLOUR = {255, 0, 0}
	
}

MAP = {
	WIDTH = 800,
	HEIGHT = 800
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

--converts world coordinates to a position on the screen 
function worldtoscreen(x, y)
	sw = love.graphics.getWidth()
	sh = love.graphics.getHeight()
	 
	res = {x/MAP.WIDTH * sw, (1.0 - y/MAP.HEIGHT) * sh }
	return res
end


--vector stuff

function euclid(x0, y0, x1, y1)
	return math.sqrt(math.pow(x1 - x0, 2) + math.pow(y1 - y0, 2)) 
end

function magnitude(x, y)
	return math.sqrt(math.pow(x, 2) + math.pow(y, 2))
end

--normalises pair of vector components
function normalise(x, y)
	mag = magnitude(x, y)
		
	xdash = x/mag
	ydash = y/mag
	
	
	res = {xdash, ydash}
	
	return res
end

function clamp(x, minimum, maximum)
	if x > maximum then
		return maximum
	elseif x < minimum then
		return minimum
	else
		return x
	end
end
