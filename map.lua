game_map = {}

-- height_map = {
--     [9] = 0,
--     [25] = 1,
--     [41] = 2,
--     [57] = 3,
--     [10] = 4,
--     [26] = 5,
--     [42] = 6,
--     [58] = 7
-- }

-- function get_height(x, y)
--     return height_map[mget(x, y)]
-- end

height_map = {}

function set_height(x, y, height)
    local index = x % 32 + flr(y / 32)
    height_map[index] = height
end

function generate_height_map()
    for x = 0, 31 do
        for y = 0, 31 do
            local sprite = mget(x, y)
            if sprite == 25 then
                set_height(x, y, 1)
                set_height(x + 1, y, 1)
                set_height(x + 1, y + 1, 0)
                set_height(x, y + 1, 1)
            elseif sprite == 56 then
                set_height(x, y, 1)
                set_height(x + 1, y, 1)
                set_height(x + 1, y + 1, 0)
                set_height(x, y + 1, 1)
            end
        end
    end
end

function game_map:draw()
    color(3)
    local height_strength = 2
    local tile_size = 8
    for x = 0, 31 do
        for y = 0, 31 do
            local sprite = mget(x, y)
            local spr_x = (sprite % 16) * 8
            local spr_y = (flr(sprite / 16)) * 8
            scrn_x, scrn_y = scrn_xy(x, y, 0)
            sspr(spr_x, spr_y, 8, 8, scrn_x, scrn_y, 8, 4)
            -- local nw_x, nw_y = scrn_xy(x, y, get_height(x + 32, y) / height_strength)
            -- local ne_x, ne_y = scrn_xy(x + 1, y, get_height(x + 1 + 32, y) / height_strength)
            -- local se_x, se_y = scrn_xy(x + 1, y + 1, get_height(x + 1 + 32, y + 1) / height_strength)
            -- local sw_x, sw_y = scrn_xy(x, y + 1, get_height(x + 32, y + 1) / height_strength)

            -- line(nw_x, nw_y, ne_x, ne_y)
            -- line(ne_x, ne_y, se_x, se_y)
            -- line(se_x, se_y, sw_x, sw_y)
            -- line(sw_x, sw_y, nw_x, nw_y)

        end
    end
end