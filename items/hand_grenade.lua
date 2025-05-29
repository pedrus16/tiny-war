-- Hand Grenade

function create_hand_grenade()
	local function handle_input(item,u)
		if not item.bullet then
			handle_input_aim(u)
			if btnp(❎) and u.z==0 then
				local b=fire_bullet(
					"grenade",
					15,
					u.dir/360,
					u.angle/360,
					u.x,u.y
				)
				main_camera.target=b
				item.bullet=b
				item.fired=true
				game.timer=b.fuse
				u:consume_ammo(item.k)
			end
		else
			if btnp(❎) then
				item.bullet:detonate()
			end
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
		?"❎ fire, ❎ detonate",64-20*2,120,7
	end
	
	return {
		k=50,
		text="hand grenade",
		handle_input=handle_input,
		update=update,
		draw=draw_aim,
		draw_ui=draw_ui
	}
end