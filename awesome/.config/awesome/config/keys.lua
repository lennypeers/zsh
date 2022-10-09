local gears = require("gears")
local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup")
local menubar = require("menubar")
local spawn_media = require("tools.media").spawn_media

local script_path = "/home/lenny/bin/"
-- {{{
-- Switch tag, while skipping empty ones
-- with teleportation !
local function tag_view_nonempty(step, pinned_only)
    local s = awful.screen.focused()
    local tags = s.tags
    local start

    if s.selected_tag == nil then
        return
    end
    start = s.selected_tag.index

    -- checking if there is enough pinned tabs
    local pinned_count = 0
    for i = 1, #tags do
        if tags[i].pinned then
            pinned_count = pinned_count + 1
        end
    end
    pinned_only = pinned_only and pinned_count > 1

    -- sliding through all the tabs
    local i = start + step
    while i ~= start do
        if i < 1 or #tags < i then
            i = step > 0 and 1 or #tags
        end

        if #tags[i]:clients() > 0 and not pinned_only or tags[i].pinned then
            tags[i]:view_only()
            return
        end

        -- Nothing to do bru
        if i == start then
            return
        end

        i = i + step
    end
end

-- Switch from xbindkeys
awesome.connect_signal("tag_switch", function(step)
    tag_view_nonempty(step, true)
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(awful.button({}, 3, function()
    mymainmenu:toggle()
end)))
-- }}}

-- {{{ Key bindings
awful.keyboard.append_global_keybindings({
    -- {{{ tags
    awful.key({ modkey }, "[", function()
        tag_view_nonempty(-1)
    end, { description = "view previous", group = "tag" }),
    awful.key({ modkey }, "]", function()
        tag_view_nonempty(1)
    end, { description = "view next", group = "tag" }),
    awful.key({ "Mod1", "Shift" }, "Tab", function()
        tag_view_nonempty(-1, true)
    end, { description = "view previous pinned", group = "tag" }),
    awful.key({ "Mod1" }, "Tab", function()
        tag_view_nonempty(1, true)
    end, { description = "view next pinned", group = "tag" }),
    awful.key({ modkey }, ".", function()
        local tag = awful.screen.focused().selected_tag
        tag.pinned = not tag.pinned
        tag.update()
    end, { description = "toggle pin", group = "tag" }),
    -- }}}

    -- {{{ focus switch
    awful.key({ modkey }, "m", function()
        awful.client.focus.byidx(1)
    end, { description = "focus next by index", group = "client" }),
    awful.key({ modkey }, "n", function()
        awful.client.focus.byidx(-1)
    end, { description = "focus previous by index", group = "client" }),
    awful.key({ modkey }, "h", function()
        awful.client.focus.global_bydirection("left", client.focus)
    end, { description = "focus left window", group = "client" }),
    awful.key({ modkey }, "j", function()
        awful.client.focus.global_bydirection("down", client.focus)
    end, { description = "focus underneath window", group = "client" }),
    awful.key({ modkey }, "k", function()
        awful.client.focus.global_bydirection("up", client.focus)
    end, { description = "focus top window", group = "client" }),
    awful.key({ modkey }, "l", function()
        awful.client.focus.global_bydirection("right", client.focus)
    end, { description = "focus right window", group = "client" }),
    -- }}}

    -- {{{ Notifications
    awful.key({ modkey }, "b", function()
        awesome.emit_signal("notification::mode_toggle")
    end, { description = "Toggle silent mode", group = "notification" }),
    --  awful.key({ modkey }, "v", function()
    --      awesome.emit_signal("control_center::toggle")
    --  end, { description = "Show the control center", group = "notification" }),
    -- }}}

    -- {{{ Layout manipulation
    awful.key({ modkey }, "d", function()
        awful.client.swap.byidx(1)
    end, {
        description = "swap with next client by index",
        group = "client",
    }),
    awful.key(
        { modkey },
        "a",
        function()
            awful.client.swap.byidx(-1)
        end,
        { description = "swap with previous client by index", group = "client" }
    ),
    awful.key({ modkey }, "Tab", function()
        awful.layout.inc(1)
    end, { description = "change layout", group = "client" }),
    awful.key({ modkey, "Shift" }, "Tab", function()
        awful.layout.inc(-1)
    end, { description = "change layout (reverse)", group = "client" }),
    -- }}}

    -- {{{ Standard program
    awful.key({ modkey, "Shift" }, "Return", function()
        awful.spawn(terminal .. " --class terminal")
    end, { description = "open a terminal", group = "launcher" }),
    awful.key({ modkey }, "Return", function()
        awful.spawn(terminal .. " --class Terminal")
    end, { description = "open a terminal (floating)", group = "launcher" }),
    -- }}}

    -- {{{ Misc
    awful.key(
        { modkey },
        "f",
        hotkeys_popup.show_help,
        { description = "show help", group = "awesome" }
    ),
    awful.key(
        { modkey, "Shift" },
        "r",
        awesome.restart,
        { description = "reload awesome", group = "awesome" }
    ),
    awful.key(
        { modkey, "Shift" },
        "q",
        awesome.quit,
        { description = "quit awesome", group = "awesome" }
    ),
    awful.key({ modkey }, "z", function()
        local s = awful.screen.focused()
        s.bar.visible = not s.bar.visible
    end, {
        description = "Toggle bar on focused screen",
        group = "awesome",
    }),
    -- }}}

    -- {{{ Restore minimize
    awful.key({ modkey, "Shift" }, "s", function()
        local c = awful.client.restore()
        if c then
            c:emit_signal(
                "request::activate",
                "key.unminimize",
                { raise = true }
            )
        end
    end, { description = "restore minimized", group = "client" }),
    -- }}}

    -- Menubar
    awful.key({ modkey }, "p", function()
        menubar.show()
    end, { description = "show the menubar", group = "launcher" }),

    -- Launcher
    awful.key({ modkey }, "space", function()
        awesome.emit_signal("spotlight_show")
    end, { description = "run spotlight", group = "launcher" }),

    -- {{{ Volume
    awful.key({ "Shift" }, "XF86AudioRaiseVolume", function()
        awful.spawn(script_path .. "volume -i 1")
    end, { description = "Raise volume", group = "media" }),
    awful.key({}, "XF86AudioRaiseVolume", function()
        awful.spawn(script_path .. "volume -i 5")
    end, { description = "Raise volume", group = "media" }),
    awful.key({ "Shift" }, "XF86AudioLowerVolume", function()
        awful.spawn(script_path .. "volume -d 1")
    end, { description = "Lower volume", group = "media" }),
    awful.key({}, "XF86AudioLowerVolume", function()
        awful.spawn(script_path .. "volume -d 5")
    end, { description = "Lower volume", group = "media" }),
    awful.key({}, "XF86AudioMute", function()
        awful.spawn(script_path .. "volume -t")
    end, { description = "Toggle mute", group = "media" }),
    -- }}}

    -- {{{ Screenshots
    awful.key({}, "Print", function()
        awful.spawn(script_path .. "screenshot -a")
    end, { description = "Screenshot the whole screens", group = "media" }),
    awful.key({ "Shift" }, "Print", function()
        awful.spawn(script_path .. "screenshot -w -S")
    end, { description = "Screenshot the focused window", group = "media" }),
    awful.key({}, "F10", function()
        awful.spawn(script_path .. "screenshot -s -S")
    end, {
        description = "Screenshot the selected content",
        group = "media",
    }),
    -- }}}

    -- {{{ Media keys
    awful.key({}, "XF86AudioPlay", function()
        awful.spawn("playerctl play-pause")
    end, { description = "Pause media", group = "media" }),
    awful.key({}, "XF86AudioNext", function()
        awful.spawn("playerctl next")
    end, { description = "Next media", group = "media" }),
    awful.key({}, "XF86AudioPrev", function()
        awful.spawn("playerctl previous")
    end, { description = "Previous media", group = "media" }),
    -- }}}

    -- {{{ Brightness
    awful.key({}, "XF86MonBrightnessUp", function()
        spawn_media(
            script_path .. "backlight -l -i 1%",
            "screen_backlight_change"
        )
    end, { description = "Increase brightness (1%)", group = "media" }),
    awful.key({ "Shift" }, "XF86MonBrightnessUp", function()
        spawn_media(
            script_path .. "backlight -l -i 1",
            "screen_backlight_change"
        )
    end, { description = "Increase brightness", group = "media" }),
    awful.key({}, "XF86MonBrightnessDown", function()
        spawn_media(
            script_path .. "backlight -l -d 1%",
            "screen_backlight_change"
        )
    end, { description = "Decrease brightness (1%)", group = "media" }),
    awful.key({ "Shift" }, "XF86MonBrightnessDown", function()
        spawn_media(
            script_path .. "backlight -l -d 1",
            "screen_backlight_change"
        )
    end, { description = "Decrease brightness", group = "media" }),
    -- }}}

    -- {{{ Kb backlight
    awful.key({}, "XF86KbdBrightnessUp", function()
        spawn_media(
            script_path .. "backlight -k -i 1%",
            "keyboard_backlight_change"
        )
    end, {
        description = "Increase keyboard backlight brightness",
        group = "media",
    }),
    awful.key({}, "XF86KbdBrightnessDown", function()
        spawn_media(
            script_path .. "backlight -k -d 1%",
            "keyboard_backlight_change"
        )
    end, {
        description = "Decrease keyboard backlight brightness",
        group = "media",
    }),
    -- }}}

    -- {{{ Gaps and borders

    awful.key({ modkey }, "-", function()
        awful.tag.incgap(-1, nil)
    end, { description = "Decrease gap", group = "visual" }),
    awful.key({ modkey }, "=", function()
        awful.tag.incgap(1, nil)
    end, { description = "Increase gap", group = "visual" }),
    awful.key({ modkey, "Shift" }, "-", function()
        local s = awful.screen.focused()
        local t = s.selected_tag
        local padding = t.padding
            or {
                left = 1,
                right = 1,
                top = 1,
                bottom = 1,
            }
        padding.left = padding.left - 1
        padding.right = padding.right - 1
        padding.top = padding.top - 1
        padding.bottom = padding.bottom - 1
        s.padding = padding
        t.padding = padding
    end, { description = "Decrease outter gap", group = "visual" }),
    awful.key({ modkey, "Shift" }, "=", function()
        local s = awful.screen.focused()
        local t = s.selected_tag
        local padding = t.padding
            or {
                left = 0,
                right = 0,
                top = 0,
                bottom = 0,
            }
        padding.left = padding.left + 1
        padding.right = padding.right + 1
        padding.top = padding.top + 1
        padding.bottom = padding.bottom + 1
        s.padding = padding
        t.padding = padding
    end, { description = "Increase outter gap", group = "visual" }),
    -- }}}
})

-- Resize
for i = 1, 4 do
    awful.keyboard.append_client_keybinding(
        awful.key({ modkey, "Shift" }, "#" .. i + 9, function(c)
            local geo = awful.screen.focused().geometry
            c:geometry({
                width = geo.width / (i + 1),
                height = geo.height / (i + 1),
            })
        end)
    )
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
for i = 1, 10 do
    awful.keyboard.append_global_keybindings({
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9, function()
            local screen = awful.screen.focused()
            local tag = screen.tags[i]
            if tag then
                tag:view_only()
            end
        end, { description = "view tag #" .. i, group = "tag" }),
        -- Toggle tag display.
        awful.key(
            -- TODO find a better keybind. bruh
            { modkey, "Mod1" },
            "#" .. i + 9,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    awful.tag.viewtoggle(tag)
                end
            end,
            { description = "toggle tag #" .. i, group = "tag" }
        ),
        -- Move client to tag.
        awful.key(
            { modkey, "Shift" },
            "#" .. i + 9,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end,
            { description = "move focused client to tag #" .. i, group = "tag" }
        ),
    })
end

client.connect_signal("request::default_mousebindings", function()
    awful.mouse.append_client_mousebindings({
        awful.button({}, 1, function(c)
            c:activate({ context = "mouse_click" })
        end),
        awful.button({ "Mod1" }, 1, function(c)
            c:activate({ context = "mouse_click", action = "mouse_move" })
        end),
        awful.button({ "Mod1", "Shift" }, 1, function(c)
            c:activate({ context = "mouse_click", action = "mouse_resize" })
        end),
    })
end)

client.connect_signal("request::default_keybindings", function()
    awful.keyboard.append_client_keybindings({
        awful.key({ "Mod1" }, "Escape", function(c)
            if c.fullscreen then
                -- Restore old floating state
                c.floating = c.old_floating or false
            else
                -- Saving floating state
                c.old_floating = c.floating
                c.floating = true
            end
            -- Toggling fullscreen
            c.fullscreen = not c.fullscreen
            c:raise()
        end, { description = "toggle fullscreen", group = "client" }),
        awful.key({ modkey }, "q", function(c)
            c:kill()
        end, { description = "close", group = "client" }),
        awful.key({ modkey, "Shift" }, "space", function(c)
            c.floating = not c.floating
            if c.floating then
                local geo = awful.screen.focused().geometry
                local w, h = geo.width / 2, geo.height / 2
                c:geometry({
                    x = geo.x + w,
                    y = geo.y + h,
                    width = w,
                    height = h,
                })
            end
        end, { description = "toggle floating", group = "client" }),
        awful.key({ modkey }, "w", function(c)
            c:swap(awful.client.getmaster())
        end, { description = "move to master", group = "client" }),
        awful.key({ modkey }, "c", function(c)
            c:move_to_screen()
        end, { description = "move to screen", group = "client" }),
        awful.key({ modkey }, "v", function(c)
            local index = c.first_tag.index
            c:move_to_screen()
            c:move_to_tag(c.screen.tags[index])
        end, {
            description = "move to screen (keeping the tag)",
            group = "client",
        }),
        awful.key({ modkey }, "t", function(c)
            c.ontop = not c.ontop
        end, { description = "toggle keep on top", group = "client" }),
        awful.key({ modkey }, "s", function(c)
            c.minimized = true
        end, { description = "minimize", group = "client" }),
        awful.key({ modkey }, "g", function(c)
            c.sticky = not c.sticky
        end, { description = "toggle sticky window", group = "client" }),
    })

    local dir_map = {
        h = { -10, 0, -0.02 },
        j = { 0, -10, -0.02 },
        k = { 0, 10, 0.02 },
        l = { 10, 0, 0.02 },
    }
    for dir, val in pairs(dir_map) do
        awful.keyboard.append_client_keybinding(
            awful.key({ modkey, "Shift" }, dir, function(c)
                -- Fullscreen
                if c.fullscreen then
                    return
                end

                -- Floating
                if c.floating then
                    c:relative_move(nil, nil, val[1], val[2])
                    return
                end

                -- Tiled
                local layout = awful.layout.get(awful.screen.focused())
                local vertical_tiling = (
                    layout == awful.layout.suit.tile
                    or layout == awful.layout.suit.tile.left
                )
                -- Swapped branched when tiled horizontally
                if
                    vertical_tiling and (dir == "h" or dir == "l")
                    or not vertical_tiling and (dir == "j" or dir == "k")
                then
                    awful.tag.incmwfact(val[3])
                else
                    awful.client.incwfact(val[3])
                end
            end, {
                description = "resize window " .. dir,
                group = "client",
            })
        )
    end
end)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
