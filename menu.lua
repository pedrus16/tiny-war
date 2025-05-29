--  Menu

menu={
	open=false,
	index=1				 -- number of slots
}

function menu:handle_input(u)
	if self.open then
		local i=self.index
	
		-- confirm
		if btnp(❎) then
			u.item=u.inventory[i].item
			self.open=false
			return
		end
		
		-- cycle through inventory
		local size=#u.inventory
		if btnp(🅾️) then
			self.index = i < size and self.index + 1 or 1
		end

		-- move camera
		local dx=0
		local dy=0
		if (btn(⬅️)) dx-=1 u.dx=-1
		if (btn(➡️)) dx+=1 u.dx= 1
		if (btn(⬆️)) dy-=1 u.dy=-1
		if (btn(⬇️)) dy+=1 u.dy= 1
		
		-- normalize dir
		local l=sqrt(dx*dx+dy*dy)
		if (l>0)	dx/=l	dy/=l

		local view_distance = 8
		main_camera.offset.x = dx * view_distance
		main_camera.offset.y = dy * view_distance


	else
		if (btnp(🅾️)) self.open=true
	end
end


function menu:draw(u)
	if (not u) return
	
	camera(-2, -2)
	pal()
	if not self.open then
		print("🅾️ inventory",0,0,7)
		if (u.item) then
			spr(u.item.k,0,8)
			print(u.item.text,10,9,7)
		end
	else
		local n=#u.inventory
		local w=11
		
		-- background grid
		rectfill(0,0,n*w,w,0)
		for i=0,n-1 do
			rect(i*w,0,(i+1)*w,w,5)
		end
		
		-- selected item highlight
		local i=self.index-1
		rect(i*w,0,(i+1)*w,w,7)
		
		-- items sprites
		for i=0,n-1 do
			local slot = u.inventory[i+1]
			local item = slot.item
			local sprite = 48
			if (item) sprite = item.k
			spr(sprite,2+i*w,2)
			if slot.ammo then
				?slot.ammo,8+i*w,6
			end
		end
		
		-- caption
		local slot=u.inventory[self.index]
		local item = slot.item
		local txt="move"
		if (item) txt=item.text
		if (slot.ammo) txt=txt.." x"..slot.ammo
		?txt,0,14,7

		-- user help
		camera(0, 0)
		?"🅾️ next item",64-11*2,112,7
		?"❎ confirm",64-10*2,120,7
	end
end