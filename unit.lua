-- Unit

function create_unit(x,y,col)
	
	local function handle_input(u)
		local s=u.state:handle_input(u)
		if s then
			u.state=s
			s:enter(u)
		end
	end
	
	
	local function update(u)
		if (u.item) u.item:update(u)
		
		local s=u.state:update(u)
		if s then
			u.state=s
			s:enter(u)
		end
	end
	
	
	local function draw(u)
		local x,y=scrn_xy(u.x,u.y,u.z)
		local sx,sy=scrn_xy(u.x,u.y,0)
		pal(13, u.col)
		ovalfill(sx-2,sy-1,sx+2,sy+1,5)
		spr(u.f,
		 x-4,y-8,
		 1,1, u.dx==-1
		)
		pal()
		
		-- draw hp
		if menu.open then
			local hp=tostr(u.hp)
			print(hp,x-#hp*2,y-14,7)
		end
	end

	local u={
	 x=x,y=y,z=8,
	 vx=0,vy=0,vz=0,
	 dx=1,dy=1,
	 col=col, -- color
	 f=1, -- frame
	 hp=100,
	 death_radius=2,
	 death_dmg=25,
	 idle_timer=0,
	 idle=true,
	 state=create_standing_state(),
	 item=nil,
	 inventory={
		{item=nil},
		{item=create_bazooka()},
		{item=create_hand_grenade(), ammo=3},
		{item=create_skip()}
	 },
	 fired=false,
	 handle_input=handle_input,
	 update=update,
	 draw=draw,
	 take_damage=take_damage,
	 kill=kill,
	 consume_ammo=consume_ammo
	}

	return u
end


function update_unit_physics(u)
	move(u)

	-- bouncing back
	if (u.z<=0 and u.vz<-0.1) then
	 u.vz*=-0.25
	end
	
	-- gravity
	if (u.z>0) u.vz+=gravity/fps
	
	-- snap to ground
	if u.z<0.0125 then
		u.z=0
		if (u.vz<0.1) u.vz=0
	end
	
	-- friction (lower for more)
	local f=.2
	if (u.z==0) u.vx*=f u.vy*=f
	
		-- check collisions
	if (u.x<0) u.x=0
	if (u.y<0) u.y=0
	if (u.x>map_size) u.x=map_size
	if (u.y>map_size) u.y=map_size

	-- reset vel when close to 0
	if (abs(u.vx)<=0.0001) u.vx=0
	if (abs(u.vy)<=0.0001) u.vy=0
	if (abs(u.vz)<=0.0001) u.vz=0
	
	if not is_moving(u) then
		u.idle_timer+=1/fps
	else
		u.idle_timer=0
		u.idle=false
	end
	
	if u.idle_timer>=0.1 then
		u.idle=true
	end
end

-- standing state
function create_standing_state()
	return {
		enter=function(s,u)
			u.f=1
		end,
		handle_input=function(s,u)
			ac=3 -- acceleration
		
			local dx=0
			local dy=0
			if (btn(⬅️)) dx-=1 u.dx=-1
			if (btn(➡️)) dx+=1 u.dx= 1
			if (btn(⬆️)) dy-=1 u.dy=-1
			if (btn(⬇️)) dy+=1 u.dy= 1
			
			-- normalize dir
			local l=sqrt(dx*dx+dy*dy)
			if (l>0)	dx/=l	dy/=l
			
			u.vx+=dx*ac	u.vy+=dy*ac
			
			-- update sprite frame
			u.f=1
			if (u.dy==-1) u.f=2
		end,
		update=function(s,u)
			update_unit_physics(u)
			
			if u.z>0.0125 then
				return create_flying_state()
			end
			
			if u.hp<=0 and u.idle then
				return create_dying_state()
			end
		end
	}
end

-- flying state
function create_flying_state()
	return {
		grounded_time=0,
		enter=function(s,u)
			u.f=5
		end,
		handle_input=noop,
		update=function(s,u)
			update_unit_physics(u)
			
			if u.z<=0.0125 then
				s.grounded_time+=1/fps
			end
			
			if s.grounded_time>=0.2 then
				return create_standing_state()
			end
		end
	}
end

-- dying state
function create_dying_state()
	return {
		anim_t=0,
		anim_dur=0.25,
		anim_start=17,
		anim_frames=2,
		expld_t=0,
		expld_delay=0.5,
		enter=function(s,u)
			u.f=s.anim_start
			u.idle=false
		end,
		handle_input=noop,
		update=function(s,u)
			if s.anim_t<s.anim_dur then
				s.anim_t+=1/fps
			elseif s.expld_t<s.expld_delay then
				s.expld_t+=1/fps
			else
				create_explosion(
					u,u.death_radius,u.death_dmg
				)
				return create_dead_state()
			end
			
			u.f=s.anim_start+s.anim_t/s.anim_dur*s.anim_frames
		end
	}
end

-- dead state
function create_dead_state()
	return {
		enter=function(s,u)
			u.f=20
			u.dead=true
			u.idle=true
		end,
		handle_input=noop,
		update=noop
	}
end

function consume_ammo(u, id)
	for i in all(u.inventory) do
		if i and i.k==id and i.ammo then
			i.ammo-=1
			if i.ammo<=0 then
				del(u.inventory, i)
			end
		end
	end
end


function take_damage(u,amount)
	main_camera.target=u
	u.hp=max(0,u.hp-amount)
	if (u.hp<=0) u:kill()
end


function kill(u)
	for t in all(game.teams) do
		local deleted=del(t.units, u)
		
		-- adjust active unit index
		if deleted and 
					t.unit_id>#t.units 
		then
			t.unit_id=1
		end
	end
end