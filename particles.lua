-- Particle System

particles={
	smoke_trail={
		emit="continuous",
		rate=0.1,
		colors={7,6,6,6,6,6,6},
		radius={1.5,6},
		fill={█,▒,▒,░,░,░,░},
		lifetime=1.5,
	}
}


function create_particle(x,y,z,key)
	local params=particles[key]
	local p={
		x=x,y=y,z=z,
		key=key,
		update=update_particle,
		draw=draw_particle,
		timer=0
	}
	
	add(ents, p)
	
	return p
end


function update_particle(p)
	local params=particles[p.key]
	p.timer+=1/fps
	
	if p.timer>params.lifetime then
		del(ents,p)
	end
	
	-- interpolate values
	local r=p.timer/params.lifetime
	-- fill pattern
	local n=#params.fill
	local i=flr(r*n)+1
	p.fill=params.fill[i]
	-- radius
	local d=params.radius[2]-params.radius[1]
	i=r*d
	p.radius=params.radius[1]+i
	-- color
	n=#params.colors
	i=flr(r*n)+1
	p.color=params.colors[i]
end


function draw_particle(p)
	local params=particles[p.key]
	local x,y=scrn_xy(p.x,p.y,p.z)
	fillp(p.fill)
	circfill(x,y,p.radius,p.color)
	fillp()
end


function emit(x,y,z,key)
	local e={
		key=key,
		x=x,y=y,z=z,
		update=update_emitter,
		draw=noop,
		timer=0
	}
	
	add(ents,e)
	
	create_particle(e.x,e.y,e.z,e.key)
	
	return e
end



function update_emitter(e)
	local params=particles[e.key]
	e.timer+=1/fps
	
	if e.timer>=params.rate then
		e.timer=params.rate-e.timer -- reset timer
		create_particle(e.x,e.y,e.z,e.key)
	end
end