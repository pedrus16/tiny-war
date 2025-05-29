-- Utils

pi = 3.14159265359

function noop() end

-- convert 3D map coords to screen coords
function scrn_xy(x,y,z)
    local size = 8
    local angle = main_camera.angle / 360
    local ca,sa = cos(angle), sin(angle)
    local ox = x * size * ca - y * size * sa
    local oy = x * size * sa + y * size * ca
    return ox, oy * (1 - main_camera.tilt) - z * size
	-- return x*8,(y*0.5-z)*8
end

function move(e)
	e.x+=e.vx/fps
	e.y+=e.vy/fps
	e.z+=e.vz/fps
end

function is_moving(e)
	return e.vx~=0 or e.vy~=0 or e.vz~=0
end

function by_depth(a,b)
	return a.y-b.y
end

function heapsort(t, cmp)
 local n = #t
 local i, j, temp
 local lower = flr(n / 2) + 1
 local upper = n
 while 1 do
  if lower > 1 then
   lower -= 1
   temp = t[lower]
  else
   temp = t[upper]
   t[upper] = t[1]
   upper -= 1
   if upper == 1 then
    t[1] = temp
    return
   end
  end

  i = lower
  j = lower * 2
  while j <= upper do
   if j < upper and cmp(t[j], t[j+1]) < 0 then
    j += 1
   end
   if cmp(temp, t[j]) < 0 then
    t[i] = t[j]
    i = j
    j += i
   else
    j = upper + 1
   end
  end
  t[i] = temp
 end
end