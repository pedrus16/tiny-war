-- Item

function handle_input_aim(u)
	local angle_ac=1
	if (u.angle==nil) u.angle=0
	if (u.dir==nil) u.dir=0
	
	if (btn(⬆️)) u.angle+=angle_ac
	if (btn(⬇️)) u.angle-=angle_ac
	if (u.angle>90) u.angle=90
	if (u.angle<-90) u.angle=-90
	
	local dir_ac=1
	if (btn(⬅️)) u.dir+=dir_ac
	if (btn(➡️)) u.dir-=dir_ac
	u.dir=u.dir%360
end


function draw_angle_quadrant(u)
	local a=0
	if (u.angle!=nil) a=u.angle/360
	local r=24 -- radius
	local sx=127 -- screen x
	local sy=r+1 -- screen y
	
	-- horiz line
	line(sx,sy,sx-r,sy,6)
	line(sx,sy,sx,sy-r,2)
	line(sx,sy,sx,sy+r,2)

	local ic=.5/180*10 -- 10 deg/dt
	-- angle dots
	for i=-.25,.25,ic do
			local x=cos(i)*-r
			local y=sin(i)*r
			circ(sx+x,sy+y,0,6)
	end
	
	-- key hints
	print("⬆️",sx-r/2-4,sy-7,6)
	print("⬇️",sx-r/2-4,sy+3,6)

	-- needle
	local x=cos(a)*-r
	local y=sin(a)*r
	line(sx,sy,sx+x,sy+y,8)
	
	-- base
	circfill(sx,sy,4,8)
	
	-- debug
	if (debug) ?flr(a*360),sx-16,sy-12,7
end

function draw_dir_arrow(dir,x,y)
	local d=8 -- distance from unit
	local l=6 -- arrow length
	
	-- ground line
	local x1=x+cos(dir)*d
	local y1=y+sin(dir)*d
	local x2=x+cos(dir)*(d+l)
	local y2=y+sin(dir)*(d+l)
	line(x1,y1,x2,y2,8)
	
	-- debug
	if (debug) ?flr(dir*360),x,y,10
end


function draw_aim(item,u)
	-- direction arrow
	local dir=0
	if (u.dir!=nil) dir=u.dir/360
	local x,y=scrn_xy(u.x,u.y,u.z)
	draw_dir_arrow(dir,x,y)
end