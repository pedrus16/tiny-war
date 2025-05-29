-- Game State

game={
	state=nil,
	timer=0,
	over=false,
	winner=nil,
	team_id=1,
	teams={
		{
			name="blue",
			col=12,
			units={},
			unit_id=1
		},
		{
			name="red",
			col=8,
			units={},
			unit_id=1
		}
	}
}

function game:handle_input()
		local s=self.state:handle_input(self)
		if s then
			self.state=s
			s:enter(self)
		end
	end

function game:update()
	local s=self.state:update(self)
	if s then
		self.state=s
		s:enter(self)
	end
end


function game:init()
	self.state=create_spawn_state()
	self.state:enter(self)
end


function game:end_turn()
	self.state=create_post_turn_state()
	self.state:enter(self)
end


-- pre game
function create_spawn_state()
	local function enter(s,g)
		g.timer=pregame_time
	end

	local function handle_input(s,g)
		if btnp(❎) then
			return create_player_turn_state(true)
		end
	end
	
	local function update(s,g)
		g.timer-=1/fps
		if g.timer<=0 then
			return create_player_turn_state(true)
		end
	end
	
	return {
		name="spawning",
		enter=enter,
		handle_input=handle_input,
		update=update
	}
end

-- player turn
function create_player_turn_state(first)
	local function enter(s,g)
	
		if not first then
				-- select next unit
			local t=g.teams[g.team_id]
			t.unit_id+=1
			if (t.unit_id>#t.units) t.unit_id=1
			
						-- select next team
			g.team_id+=1
			if (g.team_id>#g.teams) g.team_id=1
		end
	
		g.timer=turn_time
		local t=g.teams[g.team_id]
		local u=t.units[t.unit_id]
		g.unit=u
		main_camera.target=g.unit
	end

	local function handle_input(s,g)
		if not menu.open then
			if g.unit.item then
				g.unit.item:handle_input(g.unit)
			else
				g.unit:handle_input()
			end
		end
		
		if not g.unit.item 
					or not g.unit.item.fired
		then
			menu:handle_input(g.unit)
		end
	end
	
	local function update(s,g)
		g.timer-=1/fps
		if g.timer<=0 then
			return create_post_turn_state()
		end
	end


	return {
		name="player_turn",
		enter=enter,
		handle_input=handle_input,
		update=update
	}
end


-- post turn
function create_post_turn_state()
	local function enter(s,g)
		menu.index=1
		menu.open=false
		g.unit.item=nil
		
		g.timer=postturn_time
	end

	local function update(s,g)
		-- wait for units to be stable
		local stable=true
		for e in all(ents) do
			if e.idle==false then
				stable=false
			end
		end
		
		if stable then
			g.timer-=1/fps
		end
		if g.timer<=0 then
			local gameover,winner=check_victory()
			if not gameover then
				return create_player_turn_state()
			else
				game.over=true
				game.winner=winner
				return create_end_game_state()
			end
		end
	end
	
	return {
		name="post_turn",
		enter=enter,
		handle_input=noop,
		update=update
	}
end


-- post game
function create_end_game_state()
	return {
		name="end_game",
		enter=noop,
		handle_input=noop,
		update=noop
	}
end


function check_victory()
	local c=0 -- # of teams with units alive
	local tid=nil -- team id
	for k,t in pairs(game.teams) do
		if (#t.units>0) then
			c+=1
			tid=k
		end
	end
	
	local gameover=false
	local winner=nil
	if (c<=1) gameover=true
	if (c==1) winner=tid
	
	return gameover,winner
end