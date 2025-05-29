-- Bazooka

function create_bazooka()
	local function handle_input(item,u)
		if (item.bullet) return
	
		handle_input_aim(u)
		if btnp(❎) and u.z==0 and not u.bullet then
			local b=fire_bullet(
				"bazooka",
				15,
				u.dir/360,
				u.angle/360,
				u.x,u.y
			)
			main_camera.target=b
			item.bullet=b
			item.fired=true
			u:consume_ammo(item.k)
		end
	end
	
	local function update(item,u)
		if item.bullet 
					and item.bullet.killed 
		then
			item.bullet=nil
			item.fired=false
			game:end_turn()
		end
	end
	
	function draw_ui(item,u)
		draw_angle_quadrant(u)
		
		?"⬅️➡️ turn",64-8*2,112,7
		?"❎ fire",64-7*2,120,7
	end
	
	return {
		k=49,
		text="bazooka",
		handle_input=handle_input,
		update=update,
		draw=draw_aim,
		draw_ui=draw_ui
	}
end