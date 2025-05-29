-- Skip

function create_skip()
	local function handle_input(item,u)
		u:handle_input() -- allow move
		if btnp(❎) then
			game:end_turn()
		end
	end
	
	
	function draw_ui(item,u)
		?"❎ skip turn",64-12*2,120,7
	end

	return {
		k=51,
		text="skip",
		handle_input=handle_input,
		update=noop,
		draw=noop,
		draw_ui=draw_ui
	}
end