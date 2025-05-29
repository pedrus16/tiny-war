-- Camera

main_camera={
	target=nil,
	x=16,
	y=16,
	speed=16,
	offset={
		x=0,
		y=0
	}
}


function draw_camera()
	camera(main_camera.x*8-64,main_camera.y*8-64)	
end


function update_camera()
	if main_camera.target then
		local tx=main_camera.target.x
		local ty=main_camera.target.y
		
		if menu.open then
			tx += main_camera.offset.x
			ty += main_camera.offset.y
		end

		if abs(tx-main_camera.x)<.125 then
			main_camera.x=tx
		else
			main_camera.x+=(tx-main_camera.x)/fps*main_camera.speed
		end
		if abs(ty-main_camera.y)<.125 then
			main_camera.y=ty
		else
			main_camera.y+=(ty-main_camera.y)/fps*main_camera.speed
		end
	end
end