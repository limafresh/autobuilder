local function create_formspec()
	return "size[8,6]" ..
		"field[1,1;4,1;block;" .. S("Block") .. ";default:stone]" ..
		"field[1,3;2,1;size_x;" .. S("Size X") .. ";5]" ..
		"field[3,3;2,1;size_y;" .. S("Size Y") .. ";5]" ..
		"field[5,3;2,1;size_z;" .. S("Size Z") .. ";5]" ..
		"checkbox[1,4;empty_inside;" .. S("Empty inside") .. ";true]" ..
		"button[3,5;2,1;ok;OK]"
end

local player_settings = {}
local player_settings_tmp = {}
S = core.get_translator("autobuilder")

core.register_chatcommand("autobuilder", {
	description = S("Open Autobuilder menu"),
	func = function(name)
		local formspec = create_formspec()
		core.show_formspec(name, "autobuilder:form", formspec)
	end
})

core.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "autobuilder:form" then return end
	local name = player:get_player_name()

	if fields.empty_inside then
		player_settings_tmp[name] = (fields.empty_inside == "true")
	end

	if fields.ok and fields.block ~= "" then
		local hollow = player_settings_tmp[name] ~= false

		player_settings[name] = {
			block = fields.block,
			size_x = tonumber(fields.size_x) or 5,
			size_y = tonumber(fields.size_y) or 5,
			size_z = tonumber(fields.size_z) or 5,
			hollow = hollow
		}
		core.chat_send_player(
			name,
			S("Now click with the Autobuilder Wand (autobuilder:wand) tool on the block where the structure should begin")
		)
		core.close_formspec(name, formname)
	end
end)

core.register_tool("autobuilder:wand", {
	description = S("Autobuilder Wand"),
	inventory_image = "default_stick.png",
	on_use = function(itemstack, player, pointed_thing)
		if pointed_thing.type ~= "node" then return itemstack end
		local name = player:get_player_name()
		local settings = player_settings[name]
		if not settings then
			core.chat_send_player(name, S("First, open /autobuilder"))
			return itemstack
		end

		local pos = pointed_thing.above

		for x = 0, settings.size_x - 1 do
			for y = 0, settings.size_y - 1 do
				for z = 0, settings.size_z - 1 do
					local p = {x = pos.x + x, y = pos.y + y, z = pos.z + z}
					if settings.hollow then
						if x == 0 or x == settings.size_x - 1
						or y == 0 or y == settings.size_y - 1
						or z == 0 or z == settings.size_z - 1 then
							core.set_node(p, {name = settings.block})
						end
					else
						core.set_node(p, {name = settings.block})
					end
				end
			end
		end
	end
})
