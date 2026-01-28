-- Advanced Anti-Aim Script
-- Lua script for CS:GO game modification

require("keydown")
require("customrenderer")

client.notify("Initializing...")

-- Configuration variables
local val = 60
local MAX_CHOKE = 14
local flick = 0
local side = 180
local pitch = 90
local screen_size = engine.get_screen_size()

local tahoma_bold = renderer.setup_font("C:/windows/fonts/tahomabd.ttf", 50, 0)
local prev_angle = 0
local yawanglenumb = 0
local lastflick = 0
local modangles = 0
local ticknumb = 32
local ticknumb2 = 16
local ticknumb3 = 8

local next_lby_update = globalvars.get_tick_count() + 21

-- Main Menu Configuration
local tabselect = ui.add_combo_box("[Advanced AA] Tab Selection", "tabselect", 
    {"Main", "AntiAim", "Misc/Visuals", "Advanced Settings"}, 0)

local main_header = ui.add_check_box(">>> [Advanced Anti-Aim System]", "main_header", true)
local version = ui.add_check_box(">>> [Version 1.3]", "version", true)
local discord = ui.add_check_box(">>> [Discord (Coming Soon)]", "discord", false)

-- Anti-Aim Configuration
local antiaim_master = ui.add_check_box("Sun AA", "antiaim_master", false)
local antibrute = ui.add_check_box("Anti-brute Randomization", "antibrute", false)
local treehouse_mode = ui.add_check_box("180 Treehouse Mode", "treehouse_mode", false)
local antiprevangle = ui.add_check_box("Anti Previous Angle", "antiprevangle", false)
local apat = ui.add_slider_int("Anti Previous Angle Threshold", "apat", 0, 180, 25)
local left_side = ui.add_key_bind("Left Side", "left_side", 0, 1)
local right_side = ui.add_key_bind("Right Side", "right_side", 0, 1)

local chokonsafe = ui.add_check_box("Choke Lag on Safe Angle", "chokonsafe", false)
local randc = ui.add_check_box("Random Choke", "randc", false)

-- Choke Configuration
local consss = ui.add_slider_int("Safe Side Choke Value", "consss", 0, 16, 16)
local consus = ui.add_slider_int("Unsafe Side Choke Value", "consus", 0, 16, 4)

-- Flick Configuration
local toflick = ui.add_check_box("Flick 1", "toflick", false)
local toflick2 = ui.add_check_box("Flick 2", "toflick2", false)
local toflick3 = ui.add_check_box("Flick 3", "toflick3", false)

local upflick = ui.add_check_box("Up Flick on Tick", "upflick", false)
local randtick = ui.add_check_box("Flick on Random Tick", "randtick", false)
local flicktick = ui.add_slider_int("Flick Tick", "flicktick", 1, 64, 54)

-- Visual Configuration
local thirdperson_distance_enable = ui.add_check_box("Third Person Distance", "thirdperson_distance_enable", false)
local thirdperson_distance_value = ui.add_slider_int("Distance Value", "thirdperson_distance_value", 0, 250, 100)

local animclantag = ui.add_check_box("Animated Clan Tag", "animclantag", false)
local tagpick = ui.add_combo_box("Clan Tag Type", "tagpickkey", 
    {"Advanced AA System", "Typing Animation", "Default", "180 Treehouse"}, 2)
local visclantag = ui.add_check_box("Visualize Clan Tag", "visclantag", false)

-- Watermark Configuration
local wmcheck = ui.add_check_box("Watermark", "wmcheck", true)
local ctecheck = ui.add_check_box("Custom Text Effect", "ctecheck", true)
local wmcolor = ui.add_color_edit("Watermark Background Color", "wmcolor", true, 
    color_t.new(255, 255, 255, 100))
local crtc1 = ui.add_color_edit("Color 1", "crtc1", true, 
    color_t.new(0, 153, 51, 255))
local crtc2 = ui.add_color_edit("Color 2", "crtc2", true, 
    color_t.new(51, 204, 255, 255))
local debuginfo = ui.add_check_box("Show Debug Information", "debuginfo", false)

-- Advanced Configuration
local abaat = ui.add_slider_int("Anti-brute Max Random Angle Threshold", "abaat", 0, 180, 60)
local apaat = ui.add_slider_int("Anti Previous Angles Max Random Threshold", "apaat", 0, 180, 15)
local flicktick2 = ui.add_slider_int("Flick 2 Tick", "flicktick2", 1, 64)
local flicktick3 = ui.add_slider_int("Flick 3 Tick", "flicktick3", 1, 64)

local chokeonflick = ui.add_check_box("Choke on Flick (Enhanced Desync)", "chokeonflick", false)
local randnocmd = ui.add_check_box("Random Choke Command", "randnocmd", false)

-- Menu Visibility Management
function tab_selection_function()
    -- Main Tab
    local is_main_tab = tabselect:get_value() == 0
    main_header:set_visible(is_main_tab)
    version:set_visible(is_main_tab)
    discord:set_visible(is_main_tab)

    -- AntiAim Tab
    local is_antiaim_tab = tabselect:get_value() == 1
    local antiaim_elements = {
        antiaim_master, antibrute, treehouse_mode, chokonsafe, antiprevangle, 
        consss, consus, randc, apat, left_side, right_side, toflick, 
        toflick2, toflick3, upflick, randtick, flicktick
    }
    for _, element in ipairs(antiaim_elements) do
        element:set_visible(is_antiaim_tab)
    end

    -- Visuals Tab
    local is_visuals_tab = tabselect:get_value() == 2
    local visual_elements = {
        thirdperson_distance_enable, thirdperson_distance_value, debuginfo,
        animclantag, tagpick, visclantag, wmcheck, ctecheck, wmcolor,
        crtc1, crtc2
    }
    for _, element in ipairs(visual_elements) do
        element:set_visible(is_visuals_tab)
    end

    -- Advanced Tab
    local is_advanced_tab = tabselect:get_value() == 3
    local advanced_elements = {
        abaat, apaat, flicktick2, flicktick3, chokeonflick, randnocmd
    }
    for _, element in ipairs(advanced_elements) do
        element:set_visible(is_advanced_tab)
    end
end

client.register_callback("paint", tab_selection_function)

-- Main Anti-Aim Logic
client.register_callback("create_move", function(cmd)
    if not engine.is_in_game() then return end
    
    local localplayer = entitylist.get_local_player()
    if not localplayer or not localplayer:is_alive() or localplayer:is_dormant() then return end
    
    if client.is_key_pressed(0x45) or client.is_key_pressed(0x1) then
        return  -- Allow normal movement when using specific keys
    end

    -- Pitch configuration
    pitch = 0
    ui.get_combo_box("antihit_antiaim_pitch"):set_value(1)

    -- Side selection
    if left_side:is_active() then
        side = 180
    elseif right_side:is_active() then
        side = 0
    end

    -- Random command packet handling
    if randnocmd:get_value() then
        cmd.send_packet = math.random(0, 1) == 1
    end

    if antiaim_master:get_value() then
        -- Rising Sun AA algorithm
        if val < 170 then
            val = val + 1
        else
            val = 80
        end

        -- Flick logic implementation
        local function handle_flick(flick_enabled, tick_number, target_tick)
            if not flick_enabled then return end
            
            if (64 - (globalvars.get_tick_count() % 64)) / tick_number == 1 then
                if randtick:get_value() then
                    tick_number = math.random(1, 64)
                else
                    tick_number = target_tick
                end
                
                flick = -180 + math.random(-30, 30)
                if upflick:get_value() then
                    ui.get_combo_box("antihit_antiaim_pitch"):set_value(3)
                else
                    ui.get_combo_box("antihit_antiaim_pitch"):set_value(1)
                end
            else
                flick = 0
            end
            return tick_number
        end

        ticknumb = handle_flick(toflick:get_value(), ticknumb, flicktick:get_value())
        ticknumb2 = handle_flick(toflick2:get_value(), ticknumb2, flicktick:get_value())
        ticknumb3 = handle_flick(toflick3:get_value(), ticknumb3, flicktick:get_value())

        -- Anti-brute randomization
        local antibruteangle = 0
        if antibrute:get_value() then
            antibruteangle = math.random(-abaat:get_value(), abaat:get_value())
        end

        -- Angle calculation
        modangles = (val + side + antibruteangle) + flick
        yawanglenumb = (cmd.viewangles.yaw + val + side + antibruteangle) + flick

        -- Anti-previous angle protection
        if antiprevangle:get_value() and 
           yawanglenumb < prev_angle + apat:get_value() and 
           yawanglenumb > prev_angle - apat:get_value() then
            yawanglenumb = yawanglenumb + math.random(-apaat:get_value(), apaat:get_value())
        else
            prev_angle = yawanglenumb
        end

        -- Choke logic for safe angles
        if chokonsafe:get_value() then
            if (side == 0 and modangles > 0 and modangles < 180) or 
               (side == 180 and modangles > 180 and modangles < 360) then
                ui.get_slider_int("antihit_fakelag_limit"):set_value(consss:get_value())
                cmd.send_packet = true
            else
                cmd.send_packet = math.random(1, 2) == 1
                if randc:get_value() then
                    ui.get_slider_int("antihit_fakelag_limit"):set_value(math.random(1, 16))
                else
                    ui.get_slider_int("antihit_fakelag_limit"):set_value(consus:get_value())
                end
            end
        end

        -- Treehouse mode
        if treehouse_mode:get_value() then
            yawanglenumb = math.random(0, 32767)
        end

        -- Choke on flick for enhanced desync
        if chokeonflick:get_value() then
            local currenttick = globalvars.get_tick_count()
            if currenttick > next_lby_update then
                cmd.send_packet = true
                next_lby_update = currenttick + math.random(1, 4)
            else
                cmd.send_packet = false
            end
        end

        -- Apply calculated yaw
        cmd.viewangles.yaw = yawanglenumb
    end
    
    cmd.viewangles.pitch = pitch
end)

-- Render Functions
local function calculate_text_size(text)
    return renderer.get_text_size(tahoma_bold, 25, text)
end

local function on_paint()
    -- Third person distance adjustment
    if thirdperson_distance_enable:get_value() then
        local distance = thirdperson_distance_value:get_value()
        se.get_convar("c_mindistance"):set_int(distance)
        se.get_convar("c_maxdistance"):set_int(distance)
    end

    if not engine.is_in_game() then
        renderer.text("Advanced AA: Awaiting Game", tahoma_bold, 
            vec2_t.new((screen_size.x / 2) - 25, (1080 / 2) + 100), 
            25, color_t.new(255, 255, 255, 255))
        return
    end

    -- Direction indicators
    local breh = calculate_text_size(">")
    local breh2 = calculate_text_size("<")
    
    if side == 0 then
        renderer.text(">", tahoma_bold, 
            vec2_t.new((screen_size.x / 2) - (breh.x / 2) + 25, (1080 / 2) - 15), 
            25, color_t.new(255, 255, 255, 255))
    else
        renderer.text("<", tahoma_bold, 
            vec2_t.new((screen_size.x / 2) - (breh2.x / 2) - 25, (1080 / 2) - 15), 
            25, color_t.new(255, 255, 255, 255))
    end

    -- Debug information display
    if debuginfo:get_value() then
        local debug_y_offset = 25
        local debug_colors = {
            default = color_t.new(255, 255, 255, 255),
            warning = color_t.new(200, 0, 0, 255),
            success = color_t.new(0, 180, 0, 255)
        }

        -- Mode display
        local mode_text = "Mode: " .. tostring(side)
        local mode_size = calculate_text_size(mode_text)
        renderer.text(mode_text, tahoma_bold, 
            vec2_t.new((screen_size.x / 2) - (mode_size.x / 2), (1080 / 2) + debug_y_offset), 
            25, debug_colors.default)
        debug_y_offset = debug_y_offset + 25

        -- Flick status
        if toflick:get_value() then
            local flick_text = "Flicking"
            local flick_size = calculate_text_size(flick_text)
            local flick_color = (64 - (globalvars.get_tick_count() % 64)) / flicktick:get_value() == 1 
                and debug_colors.warning or debug_colors.success
            renderer.text(flick_text, tahoma_bold, 
                vec2_t.new((screen_size.x / 2) - (flick_size.x / 2), (1080 / 2) + debug_y_offset), 
                25, flick_color)
            debug_y_offset = debug_y_offset + 25
        end

        -- Yaw display with angle validation
        local yaw_text = "Yaw: " .. tostring(math.floor(yawanglenumb))
        local yaw_size = calculate_text_size(yaw_text)
        local yaw_color = debug_colors.default
        
        if (side == 0 and yawanglenumb < 0) or (side == 180 and yawanglenumb < 180) then
            yaw_color = debug_colors.warning
        end
        
        renderer.text(yaw_text, tahoma_bold, 
            vec2_t.new((screen_size.x / 2) - (yaw_size.x / 2), (1080 / 2) + debug_y_offset), 
            25, yaw_color)
        debug_y_offset = debug_y_offset + 25

        -- Choke value
        local choke_text = "Choke: " .. tostring(math.floor(ui.get_slider_int("antihit_fakelag_limit"):get_value()))
        local choke_size = calculate_text_size(choke_text)
        renderer.text(choke_text, tahoma_bold, 
            vec2_t.new((screen_size.x / 2) - (choke_size.x / 2), (1080 / 2) + debug_y_offset), 
            25, debug_colors.default)
        debug_y_offset = debug_y_offset + 25

        -- Track last flick
        if (64 - (globalvars.get_tick_count() % 64)) / flicktick:get_value() == 1 then
            lastflick = yawanglenumb
        end
        
        local last_flick_text = "Last Flick: " .. tostring(math.floor(lastflick))
        local last_flick_size = calculate_text_size(last_flick_text)
        renderer.text(last_flick_text, tahoma_bold, 
            vec2_t.new((screen_size.x / 2) - (last_flick_size.x / 2), (1080 / 2) + debug_y_offset), 
            25, debug_colors.default)
    end
end

client.register_callback("paint", on_paint)

-- Watermark Functionality
local function watermarkfunc()
    if not wmcheck:get_value() then return end
    
    local hours, minutes, seconds = client.get_system_time()
    local username = client.get_username()
    local ping = se.get_latency()
    local tick_count = globalvars.get_tick_count()
    local max_clients = globalvars.get_max_clients()

    local watermarktext = string.format("Advanced AA v1.3 | %s | %02d:%02d:%02d | Ping: %d | Tick: %d | Clients: %d",
        username, hours, minutes, seconds, ping, tick_count, max_clients)
    
    local wm_size = calculate_text_size(watermarktext)
    local wmx = wm_size.x + 25
    local wmy = wm_size.y + 25

    local ssx = screen_size.x
    local ssy = screen_size.y
    
    -- Watermark background polygon
    local points = {
        vec2_t.new(ssx - 100, 25),
        vec2_t.new(ssx - 80, 50),
        vec2_t.new((ssx - 80) - wmx, 50),
        vec2_t.new((ssx - 100) - wmx, 25)
    }
    
    renderer.filled_polygon(points, wmcolor:get_value())

    -- Watermark text
    local text_position = vec2_t.new((ssx - 80) - wmx, 25)
    if ctecheck:get_value() then
        DrawEnchantedText(1, watermarktext, tahoma_bold, text_position, 
            25, crtc1:get_value(), crtc2:get_value())
    else
        renderer.text(watermarktext, tahoma_bold, text_position, 
            25, color_t.new(255, 255, 255, 255))
    end
end

client.register_callback("paint", watermarkfunc)

-- Animated Clan Tag System
local clan_tag_animations = {
    advanced = {
        "c             | ",
        "c           a | ",
        "c      a    d | ",
        "ca     d    v | ",
        "cadv   a    n | ",
        "cadva  n    c | ",
        "cadvna c    e | ",
        "cadvnac e    d | ",
        "cadvnace d    | ",
        "cadvnaced     | ",
        "cadvnaced A   | ",
        "cadvnaced AA  | ",
        "advnaced AA S | ",
        "dvnaced AA Sy | ",
        "vnaced AA Sys | ",
        "naced AA Syst | ",
        "aced AA Syste | ",
        "ced AA System | ",
        "ed AA System  | ",
        "d AA System   | ",
        " AA System    | ",
        "AA System     | ",
        "A System      | ",
        " System       | ",
        "System        | ",
        "System        | ",
        " System       | ",
        "A System      | ",
        "AA System     | ",
        " AA System    | ",
        "d AA System   | ",
        "ed AA System  | ",
        "ced AA System | ",
        "aced AA Syste | ",
        "naced AA Syst | ",
        "vnaced AA Sys | ",
        "dvnaced AA Sy | ",
        "advnaced AA S | ",
        "cadvnaced AA  | ",
        "cadvnaced A   | ",
        "cadvnaced     | ",
        "cadvnace d    | ",
        "cadvnac e    d | ",
        "cadvna c    e | ",
        "cadva  n    c | ",
        "cadv   a    n | ",
        "ca     d    v | ",
        "c      a    d | ",
        "c           a | ",
        "c             | "
    },
    
    typing = {
        "a........ user | ",
        "a.......d user | ",
        "a.....d.v user | ",
        "a...d.v.a user | ",
        "a.d.v.a.n user | ",
        "ad.v.a.n. user | ",
        "adv.a.n.c user | ",
        "adva.n.c. user | ",
        "advan.c.e user | ",
        "advanc.e. user | ",
        "advance.d user | ",
        "advanced. user | ",
        "advanced user | ",
        "dvanced user  | ",
        "vanced user   | ",
        "anced user    | ",
        "nced user     | ",
        "ced user      | ",
        "ed user       | ",
        "d user        | ",
        " user         | ",
        "user |        | ",
        "user -|       | ",
        "user - |      | ",
        "user - s|     | ",
        "user - sy|    | ",
        "user - sys|   | ",
        "user - syst|  | ",
        "user - syste| | ",
        "user - system|| ",
        "user - system | "
    },
    
    default = {
        ".............| ",
        "............a| ",
        "...........ad| ",
        "..........adv| ",
        ".........adva| ",
        "........advan| ",
        ".......advanc| ",
        "......advance| ",
        ".....advanced| ",
        "....advanced.| ",
        "...advanced.a| ",
        "..advanced.aa| ",
        ".advanced.aas| ",
        "advanced.aasy| ",
        "advanced.aasy| ",
        ".advanced.aas| ",
        "..advanced.aa| ",
        "...advanced.a| ",
        "....advanced.| ",
        ".....advanced| ",
        "......advance| ",
        ".......advanc| ",
        "........advan| ",
        ".........adva| ",
        "..........adv| ",
        "...........ad| ",
        "............a| ",
        ".............| "
    },
    
    treehouse = {
        "1|",
        "18|",
        "180|",
        "180 |",
        "180 t|",
        "180 tr|",
        "180 tre|",
        "180 tree|",
        "180 tree |",
        "180 tree h|",
        "180 tree ho|",
        "180 tree hou|",
        "180 tree hous|",
        "180 tree house|",
        "180 tree house|",
        "180 tree hous|",
        "180 tree hou|",
        "180 tree ho|",
        "180 tree h|",
        "180 tree |",
        "180 tree|",
        "180 tre|",
        "180 tr|",
        "180 t|",
        "180 |",
        "180|",
        "18|",
        "1|"
    }
}

local animation_frame = 0
local next_frame_time = 0
local animation_lengths = {
    [0] = 32,  -- advanced
    [1] = 63,  -- typing
    [2] = 30,  -- default
    [3] = 29   -- treehouse
}

local function update_clan_tag()
    if not engine.is_in_game() or not animclantag:get_value() then return end
    
    local tag_type = tagpick:get_value()
    local current_animation = clan_tag_animations[
        tag_type == 0 and "advanced" or
        tag_type == 1 and "typing" or
        tag_type == 2 and "default" or
        "treehouse"
    ]
    
    local length = animation_lengths[tag_type] or 30
    
    -- Visual clan tag display
    if visclantag:get_value() and current_animation[animation_frame] then
        renderer.text(tostring(current_animation[animation_frame]), tahoma_bold, 
            vec2_t.new((screen_size.y / 2) + 390, (1080 / 2) - 75), 
            15, color_t.new(255, 255, 255, 255))
    end
    
    -- Update animation frame
    if next_frame_time < globalvars.get_tick_count() then
        animation_frame = animation_frame + 1
        if animation_frame > length then
            animation_frame = 0
        end
        
        if current_animation[animation_frame] then
            se.set_clantag(current_animation[animation_frame])
        end
        
        next_frame_time = globalvars.get_tick_count() + 18
    end
end

client.register_callback("paint", update_clan_tag)

-- Finalization
client.notify("Initialization Complete!")
client.notify("Thank you " .. tostring(client.get_username()) .. 
    " for using Advanced Anti-Aim System!")
