-- Bullet

function init_bullet_data()

	bullets={
		bazooka={
			dmg=50,
			radius=3,
			collision=explode,
			detonate=noop,
			frame=101
		},
		grenade={
			dmg=30,
			radius=3,
			collision=bounce,
			detonate=explode,
			fuse=3,
			frame=112
		}
	}
end

function fire_bullet(key,spd,dir,a,x,y)
	local m=cos(a)
	local vx=cos(dir)*spd*m
	local vy=sin(dir)*spd*m
	local vz=-sin(a)*spd
	local params=bullets[key]
	local bullet={
		dmg=params.dmg,
		radius=params.radius,
		x=x,y=y,z=0.5,
		vx=vx,vy=vy,vz=vz,
		update=update_bullet,
		draw=draw_bullet,
		collide=params.collision,
		detonate=params.detonate,
		fuse=params.fuse,
		frame=params.frame
	}
	add(ents, bullet)
	sfx(0,0)
	bullet.emitter=emit(bullet.x,bullet.y,bullet.z,"smoke_trail")

	return bullet
end


function bounce(b,nor)
	local f=0.9 -- friction
	b.vx*=f	b.vy*=f
	b.vz=abs(b.vz)*nor.z*0.75
end


-- todo check height
function damage_area(p,r,dmg)
	for t in all (game.teams) do
		for u in all (t.units) do
			local s=8
			local dx=p.x-u.x
			local dy=p.y-u.y
			local dz=p.z-u.z
			local d1=sqrt(dx*dx+dy*dy)
			local dist=sqrt(d1*d1+dz+dz)
			if (dist<=r) then
				local scale=(r-dist)/r
				if (dist>0) then
					u.vx=-dx/dist*s*scale
					u.vy=-dy/dist*s*scale
					u.vz=-dz/dist*s*scale
				end
				u.vz=s*scale
				local dmg=flr(dmg*scale)
				u:take_damage(dmg)
			end
		end
	end
end


function explode(b)
	del(ents, b)
	del(ents, b.emitter)
	b.vx=0 b.vy=0 b.vz=0
	b.killed=true
	sfx(-1,0)
	create_explosion(b,b.radius,b.dmg)
end


function create_explosion(p,radius,dmg)
	local function update_explosion(e)
		e.f+=1/fps*e.spd
		e.r=e.f/e.n*radius
		if e.f>e.n then
		 del(ents,e)
		end
	end
	
	local function draw_explosion(e)
		local x,y=scrn_xy(
			e.x-e.size/2,
			e.y-e.size/2,e.z)
		spr(e.begin+flr(e.f)*2, 
			x,y,2,2)
			
		x,y=scrn_xy(e.x,e.y,e.z)
		fillp(▒)
		circ(x,y,e.r*8,7)
		fillp()
	end
	
	sfx(1,1)
	damage_area(
		{x=p.x,y=p.y,z=p.z},
		radius,
		dmg
	)
	
	local e={
		x=p.x,y=p.y,z=p.z,
		begin=64, n=3, f=0,
		size=2, spd=16,
		r=0,
		update=update_explosion,
		draw=draw_explosion
	}
	add(ents,e)
end


function update_bullet(b)
	move(b)
	b.vz+=gravity/fps
	
	-- collide with ground
	if b.z<=0 then
		b:collide({x=0,y=0,z=1})
	end
	
	b.emitter.x=b.x
	b.emitter.y=b.y-0.1
	b.emitter.z=b.z
	b.emitter:update()
	
	if b.fuse!=nil then
		if (b.fuse>0)	b.fuse-=1/fps
		if (b.fuse<=0) b:detonate()
	end
end


function draw_bullet(b)
	local x,y=scrn_xy(b.x,b.y,b.z)
	local sx,sy=scrn_xy(b.x,b.y,0)
	ovalfill(sx-2,sy-1,sx+2,sy+1,5)
	spr(b.frame,
	x-4,y-4,1,1)
	
	if b.fuse!=nil then
		local txt=tostr(ceil(b.fuse))
		?txt,x-#txt*2,y-12,7
	end
end