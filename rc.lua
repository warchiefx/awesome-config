--[[

   Ricardo's AwesomeWM Config
   github.com/warchiefx/awesome-config

--]]

-- {{{ Required libraries
local awesome, client, screen, tag = awesome, client, screen, tag
local ipairs, string, os, table, tostring, tonumber, type = ipairs, string, os, table, tostring, tonumber, type

local gears         = require("gears")
local awful         = require("awful")
                      require("awful.autofocus")
local wibox         = require("wibox")
local beautiful     = require("beautiful")
local naughty       = require("naughty")
local lain          = require("lain")
local cyclefocus = require('cyclefocus')
-- local tyrannical = require('tyrannical')
local sharedtags = require("sharedtags")

--local menubar       = require("menubar")
local freedesktop   = require("freedesktop")
local hotkeys_popup = require("awful.hotkeys_popup").widget
-- }}}

-- Limit notification height
naughty.config.defaults['icon_size'] = 50

-- {{{ Error handling
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Autostart windowless processes
local default_apps = {}

local function run_once(cmd_arr)
    for _, cmd in ipairs(cmd_arr) do
        findme = cmd
        firstspace = cmd:find(" ")
        if firstspace then
            findme = cmd:sub(0, firstspace-1)
        end
        awful.spawn.easy_async_with_shell(string.format("pgrep -u $USER -x %s > /dev/null || (%s)", findme, cmd),
                               function(stdout, stderr, reason, exit_code)
                                  -- Intentionally left blank
                               end)
    end
end

local function get_default_app(tbl, var, mimetype, default)
   awful.spawn.easy_async('xdg-mime query default '..mimetype, function(stdout, stderr, reason, exit_code)
                             local app = nil
                             if exit_code == 0 then
                                local app_name, num = stdout:gsub(".desktop", "")
                                app = 'gtk-launch ' .. app_name
                                tbl[var] = app
                             else
                                tbl[var] = default
                             end
   end)
end

awesome.connect_signal("startup", function()
                          get_default_app(default_apps, 'browser', 'text/html', 'firefox')
                          get_default_app(default_apps, 'telegram', 'x-scheme-handler/tg', 'flatpak run org.telegram.desktop')
                          awful.spawn.with_shell("~/.config/awesome/autorun.sh")
end)

awesome.connect_signal("exit", function(reason_restart)
                          if reason_restart then
                             -- Restarting
                          else
                             -- Shutting down
                          end
end)

-- }}}

-- {{{ Variable definitions
local chosen_theme = "gray-wcx-aurora"
local modkey       = "Mod4"
local altkey       = "Mod1"
local terminal     = "termite" or "xterm"
local editor       = os.getenv("EDITOR") or "nano" or "vi"
local gui_editor   = "emacs"
local runner       = "rofi -show combi -config ~/.config/awesome/rofi.conf"


-- get_default_app(default_apps, 'telegram', 'x-scheme-handler/tg', 'flatpak run org.telegram.desktop')

awful.util.terminal = terminal

awful.layout.layouts = {
   awful.layout.suit.floating,
   awful.layout.suit.max,
   awful.layout.suit.tile,
   awful.layout.suit.tile.left,
   awful.layout.suit.tile.bottom,
   awful.layout.suit.tile.top,
   awful.layout.suit.fair,
   --awful.layout.suit.fair.horizontal,
   --awful.layout.suit.spiral,
   --awful.layout.suit.spiral.dwindle,
   --awful.layout.suit.max.fullscreen,
   --awful.layout.suit.magnifier,
   --awful.layout.suit.corner.nw,
   --awful.layout.suit.corner.ne,
   --awful.layout.suit.corner.sw,
   --awful.layout.suit.corner.se,
   --lain.layout.cascade,
   --lain.layout.cascade.tile,
   --lain.layout.centerwork,
   --lain.layout.centerwork.horizontal,
   --lain.layout.termfair,
   --lain.layout.termfair.center,
}

local tags = sharedtags({
    { name = "web", layout = awful.layout.suit.max },
    { name = "chat", layout = awful.layout.suit.max },
    { name = "mail", layout = awful.layout.suit.max },
    { name = "dev", layout = awful.layout.suit.max },
    { name = "work", layout = awful.layout.suit.floating },
    { name = "misc", screen = 2, layout = awful.layout.suit.floating },
    { name = "media", screen = 2, layout = awful.layout.floating },
    { name = "opt1", screen = 2, layout = awful.layout.floating },
    { name = "opt2", screen = 2, layout = awful.layout.floating },
    { name = "opt3", screen = 2, layout = awful.layout.floating },
})

awful.util.taglist_buttons = awful.util.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )
awful.util.tasklist_buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() and c.first_tag then
                                                      c.first_tag:view_only()
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function()
                         local instance = nil

                         return function ()
                             if instance and instance.wibox.visible then
                                 instance:hide()
                                 instance = nil
                             else
                                 instance = awful.menu.clients({ theme = { width = 250 } })
                            end
                        end
                     end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

lain.layout.termfair.nmaster           = 3
lain.layout.termfair.ncol              = 1
lain.layout.termfair.center.nmaster    = 3
lain.layout.termfair.center.ncol       = 1
lain.layout.cascade.tile.offset_x      = 2
lain.layout.cascade.tile.offset_y      = 32
lain.layout.cascade.tile.extra_padding = 5
lain.layout.cascade.tile.nmaster       = 5
lain.layout.cascade.tile.ncol          = 2

local theme_path = string.format("%s/.config/awesome/themes/%s/theme.lua", os.getenv("HOME"), chosen_theme)
beautiful.init(theme_path)
-- }}}

-- {{{ Menu
-- local myawesomemenu = {
--     { "hotkeys", function() return false, hotkeys_popup.show_help end },
--     { "manual", terminal .. " -e man awesome" },
--     { "edit config", string.format("%s -e %s %s", terminal, editor, awesome.conffile) },
--     { "restart", awesome.restart },
--     { "quit", function() awesome.quit() end }
-- }
-- awful.util.mymainmenu = freedesktop.menu.build({
--     icon_size = beautiful.menu_height or 16,
--     before = {
--         { "Awesome", myawesomemenu, beautiful.awesome_icon },
--         -- other triads can be put here
--     },
--     after = {
--         { "Open terminal", terminal },
--         -- other triads can be put here
--     }
-- })
-- --menubar.utils.terminal = terminal -- Set the Menubar terminal for applications that require it
-- }}}

function on_screen_change(s)
   -- Wallpaper
   -- if beautiful.wallpaper then
   --     local wallpaper = beautiful.wallpaper
   --     -- If wallpaper is a function, call it with the screen
   --     if type(wallpaper) == "function" then
   --         wallpaper = wallpaper(s)
   --     end
   --     gears.wallpaper.maximized(wallpaper, s, true)
   -- end

   -- Make nitrogen restore the wallpaper
   awful.spawn.with_shell('nitrogen --restore')
   awesome.restart()
end

-- {{{ Screen
-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", function(s)
                         on_screen_change(s)
end)

screen.connect_signal("list", function(s)
                         on_screen_change(s)
end)

-- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(function(s) beautiful.at_screen_connect(s) end)
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    -- awful.button({ }, 3, function () awful.util.mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

function launcher()
   if runner == nil then
      awful.screen.focused().mypromptbox:run()
   else
      run_once({runner})
   end
end

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    -- Take a screenshot
    -- https://github.com/copycat-killer/dots/blob/master/bin/screenshot
    awful.key({ }, "Print", function() awful.util.spawn("gnome-screenshot") end),
    awful.key({ "Shift" }, "Print", function() awful.util.spawn("gnome-screenshot -i") end),
    awful.key({ altkey }, "Print", function() awful.util.spawn("gnome-screenshot -w") end),

    awful.key({ }, "Pause",  function () awful.util.spawn("gnome-screensaver-command --lock") end),
    awful.key({modkey, altkey}, "l",  function () awful.util.spawn("gnome-screensaver-command --lock") end),

    -- modkey+Tab: cycle through all clients.
    awful.key({ modkey }, "Tab", function(c)
          cyclefocus.cycle({modifier="Super_L"})
    end),
    -- modkey+Shift+Tab: backwards
    awful.key({ modkey, "Shift" }, "Tab", function(c)
          cyclefocus.cycle({modifier="Super_L"})
    end),

    -- Hotkeys
    awful.key({ modkey,           }, "?",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    -- Tag browsing
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    -- Non-empty tag browsing
    awful.key({ altkey, "Control" }, "Left", function () lain.util.tag_view_nonempty(-1) end,
              {description = "view  previous nonempty", group = "tag"}),
    awful.key({ altkey, "Control" }, "Right", function () lain.util.tag_view_nonempty(1) end,
              {description = "view  previous nonempty", group = "tag"}),

    -- Brightness Keys
    awful.key({}, "XF86MonBrightnessUp", function()
          awful.util.spawn("acpilight -ctrl intel_backlight -inc 10", false)
    end),
    awful.key({}, "XF86MonBrightnessDown", function()
          awful.util.spawn("acpilight -ctrl intel_backlight -dec 10", false)
    end),

    -- Media Keys
    awful.key({}, "XF86AudioPlay", function()
          awful.util.spawn("playerctl play-pause", false)
    end),
    awful.key({}, "XF86AudioNext", function()
          awful.util.spawn("playerctl next", false)
    end),
    awful.key({}, "XF86AudioPrev", function()
          awful.util.spawn("playerctl previous", false)
    end),
    awful.key({}, "XF86AudioStop", function()
          awful.util.spawn("playerctl stop", false)
    end),

    -- Monitor handling
    awful.key({modkey}, "F7", function()
          awful.util.spawn("autorandr --change --force", false)
    end),

    awful.key({modkey, "Shift"}, "F7", function()
          awful.util.spawn("autorandr -l mobile --force", false)
    end),


    -- Default client focus
    awful.key({ altkey, }, "Tab",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ altkey, "Shift" }, "Tab",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),

    -- By direction client focus
    awful.key({ modkey }, "j",
        function()
            awful.client.focus.bydirection("down")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "k",
        function()
            awful.client.focus.bydirection("up")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "h",
        function()
            awful.client.focus.bydirection("left")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "l",
        function()
            awful.client.focus.bydirection("right")
            if client.focus then client.focus:raise() end
        end),
    -- awful.key({ modkey,           }, "w", function () awful.util.mymainmenu:show() end,
    --           {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Show/Hide Wibox
    awful.key({ modkey }, "b", function ()
        for s in screen do
            s.mywibox.visible = not s.mywibox.visible
            if s.mybottomwibox then
                s.mybottomwibox.visible = not s.mybottomwibox.visible
            end
        end
    end),

    -- On the fly useless gaps change
    awful.key({ altkey, "Control" }, "+", function () lain.util.useless_gaps_resize(1) end),
    awful.key({ altkey, "Control" }, "-", function () lain.util.useless_gaps_resize(-1) end),

    -- Dynamic tagging
    awful.key({ modkey, "Shift" }, "n", function () lain.util.add_tag() end),
    awful.key({ modkey, "Shift" }, "r", function () lain.util.rename_tag() end),
    awful.key({ modkey, "Shift" }, "Left", function () lain.util.move_tag(-1) end),  -- move to previous tag
    awful.key({ modkey, "Shift" }, "Right", function () lain.util.move_tag(1) end),  -- move to next tag
    awful.key({ modkey, "Shift" }, "d", function () lain.util.delete_tag() end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Control"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ altkey, "Shift"   }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ altkey, "Shift"   }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Dropdown application
    awful.key({ modkey, }, "z", function () awful.screen.focused().quake:toggle() end),

    -- Widgets popups
    -- awful.key({ altkey, }, "c", function () lain.widget.calendar.show(7) end),
    --awful.key({ altkey, }, "h", function () if beautiful.fs then beautiful.fs.show(7) end end),
    -- awful.key({ altkey, }, "w", function () if beautiful.weather then beautiful.weather.show(7) end end),

    -- Copy primary to clipboard (terminals to gtk)
    awful.key({ modkey }, "c", function () awful.spawn("xsel | xsel -i -b") end),
    -- Copy clipboard to primary (gtk to terminals)
    awful.key({ modkey }, "v", function () awful.spawn("xsel -b | xsel") end),

    -- User programs
    awful.key({ modkey }, "e", function () run_once({gui_editor}) end),
    awful.key({ modkey }, "w", function () awful.spawn(default_apps['browser']) end),
    awful.key({ modkey }, "p", function () awful.spawn(default_apps['telegram']) end),
    awful.key({ modkey }, "t", function () run_once({"evolution"}) end),
    awful.key({ modkey }, "s", function () run_once({"flatpak run com.slack.Slack"}) end),
    awful.key({ modkey }, "a", function () run_once({"flatpak run com.spotify.Client"}) end),
    awful.key({ modkey }, "i", function () awful.spawn("nautilus") end),
    awful.key({ modkey, "Shift" }, "a", function () awful.spawn("pavucontrol") end),
    awful.key({ modkey, "Shift" }, "g", function () awful.spawn("lxappearance") end),

    -- Default
    --[[ Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"})
    --]]
    --[[ dmenu
    awful.key({ modkey }, "x", function ()
        awful.spawn(string.format("dmenu_run -i -fn 'Monospace' -nb '%s' -nf '%s' -sb '%s' -sf '%s'",
        beautiful.bg_normal, beautiful.fg_normal, beautiful.bg_focus, beautiful.fg_focus))
        end)
    --]]
    -- Prompt
    awful.key({ modkey }, "r", launcher,
       {description = "run prompt", group = "launcher"}),
    -- awful.key({ ctrlkey, altkey }, "Tab", launcher,
    --    {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"})
    --]]
)

clientkeys = awful.util.table.join(
    awful.key({ modkey, "Shift"   }, "m",      lain.util.magnify_client                         ),
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Control" }, "t",
       awful.titlebar.toggle,
       {description = "Toggle title bar", group = "Clients"}),

    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "maximize", group = "client"})
)

-- Setup keybindings for sharedtags
for i = 1, 10 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = tags[i]
                        if tag then
                           sharedtags.viewonly(tag, screen)
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = tags[i]
                      if tag then
                         sharedtags.viewtoggle(tag, screen)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

local clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

local clientbuttons_jetbrains = gears.table.join(
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize)
)


-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                     size_hints_honor = true
     }
    },

    -- Titlebars
    { rule_any = { type = { "dialog", "normal" } },
      properties = { titlebars_d = true } },
    -- { rule_any = { maximized = true },
    --   properties = { titlebars_enabled = false }},

    {rule_any = {type={"dialog"}},
     properties = {floating=true},
     callback = function (c)
        awful.placement.centered(c,nil)
     end
    },

    -- Browsers
    {rule_any = {class={"chromium", "Chromium", "chromium-browser", "Chromium-browser", "Navigator", "Firefox",
                        "Opera", "brave-browser", "Brave-browser", "vivaldi-stable", "Vivaldi-stable"}},
     properties={ titlebars_enabled=false, maximized=true }},

    -- Dev
    {rule_any = {class = {"Emacs", "emacs", "terminator", "Terminator", "code", "Code", "sakura", "Sakura",
                          "termite", "Termite"}},
     properties = {tag = tags[4], switchtotag=true, titlebars_enabled=false, gap=0}},
    {rule_any = {class = {"jetbrains-pycharm", "jetbrains-webstorm"}},
     properties = {maximized = true, titlebars_enabled=false}},

    -- Email
    {rule_any = {class={"evolution", "Evolution", "mailspring", "Mailspring"}},
     properties={ tag = tags[3], maximized=true }},

    -- Chat
    {rule_any = {class = {"TelegramDesktop", "slack", "Slack"}}, properties = {tag = tags[2]}},

    -- Music
    {rule_any = {class = {"Spotify", "spotify"}, name = {"Spotify"}}, properties = {tag = tags[7], maximized=false }},

    -- Zeal
    {rule = {class = "Zeal"}, properties={ tag=tags[8], switchtotag=true,}},

    -- Jetbrains apps
    {rule = {class = "jetbrains-.*",},
     properties = { focus = true, buttons = clientbuttons_jetbrains }
    },
    {rule = {class = "jetbrains-.*", name = "win.*"},
     properties = { titlebars_enabled = false, focusable = false, focus = true, floating = true, placement = awful.placement.restore }
    },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- Custom
    if beautiful.titlebar_fun then
        beautiful.titlebar_fun(c)
        return
    end

    -- Default
    -- buttons for the titlebar
    local buttons = awful.util.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
    )

    local titlewidget = awful.titlebar.widget.titlewidget(c)
    titlewidget.font = "Ioseveka Medium 8"
    awful.titlebar(c, {size = 16, font = "Ioseveka Medium 8"}) : setup {
        { -- Left
            -- awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = titlewidget
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }

    if c.maximized then
       awful.titlebar.hide(c)
    end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

-- Only show titlebar for floating windows
-- client.connect_signal("property::floating", function(c)
--                          if c.floating or not c.maximized or not awful.screen.focused().selected_tag.layout ~= awful.layout.suit.max then
--                             awful.titlebar.show(c)
--                          else
--                             awful.titlebar.hide(c)
--                          end
-- end)

-- Disallow minimization
client.connect_signal("property::minimized", function(c)
                         c.minimized = false
end)

-- client.connect_signal("property::maximized", function(c)
--                          if c.maximized then
--                             awful.titlebar.hide(c)
--                          else
--                             awful.titlebar.show(c)
--                          end
-- end)

-- client.connect_signal("property::geometry", function (c)
--   delayed_call(function()
--     gears.surface.apply_shape_bounding(c, gears.shape.rounded_rect, 15)
--   end)
-- end)

-- No border for maximized clients
-- Transparency for unfocused clients
client.connect_signal("focus",
    function(c)
        if c.maximized then -- no borders if only 1 client visible
            c.border_width = 0
        elseif #awful.screen.focused().clients > 1 then
            c.border_width = beautiful.border_width
            c.border_color = beautiful.border_focus
        end
        -- c.opacity = 1
    end)
client.connect_signal("unfocus", function(c)
                         c.border_color = beautiful.border_normal
                         -- if not c.maximized then
                         --    c.opacity = 0.9
                         -- else
                         --    c.opacity = 1
                         -- end
end)

-- Create rounded rectangle shape

local rect = function()
    return function(cr, width, height)
        gears.shape.rectangle(cr, width, height)
    end
end

local rrect = function(radius)
    return function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, radius)
        --gears.shape.octogon(cr, width, height, radius)
        --gears.shape.rounded_bar(cr, width, height)
    end
end

-- Rounded corners
if beautiful.border_radius ~= 0 then
    client.connect_signal("manage", function (c, startup)
        if not c.fullscreen or not c.first_tag.layout.name == "max" then
            c.shape = rrect(beautiful.border_radius)
        end
    end)

    -- Fullscreen & maximised clients should not have rounded corners
    local function no_round_corners (c)
        if c.fullscreen or c.maximized or c.first_tag.layout.name == "max" then
            c.shape = rect()
        else
            c.shape = rrect(beautiful.border_radius)
        end
    end

    client.connect_signal("property::fullscreen", no_round_corners)
    client.connect_signal("property::maximized", no_round_corners)
end

-- Save and restore tags, when monitor setup is changed
local naughty = require("naughty")
local tag_store = {}
tag.connect_signal("request::screen", function(t)
  local fallback_tag = nil

  -- find tag with same name on any other screen
  for other_screen in screen do
    if other_screen ~= t.screen then
      fallback_tag = awful.tag.find_by_name(other_screen, t.name)
      if fallback_tag ~= nil then
        break
      end
    end
  end

  -- no tag with same name exists, chose random one
  if fallback_tag == nil then
    fallback_tag = awful.tag.find_fallback()
  end

  if not (fallback_tag == nil) then
    local output = next(t.screen.outputs)

    if tag_store[output] == nil then
      tag_store[output] = {}
    end

    clients = t:clients()
    tag_store[output][t.name] = clients

    for _, c in ipairs(clients) do
      c:move_to_tag(fallback_tag)
    end
  end
end)

screen.connect_signal("added", function(s)
  local output = next(s.outputs)
  naughty.notify({ text = output .. " Connected" })

  tags = tag_store[output]
  if not (tags == nil) then
    naughty.notify({ text = "Restoring Tags" })

    for _, tag in ipairs(s.tags) do
      clients = tags[tag.name]
      if not (clients == nil) then
        for _, client in ipairs(clients) do
          client:move_to_tag(tag)
        end
      end
    end
  end
end)

-- -- Titlebars only on floating windows
-- client.connect_signal("property::floating", function(c)
--     if c.floating then
--         awful.titlebar.show(c)
--     else
--         awful.titlebar.hide(c)
--     end
-- end)

-- client.connect_signal("manage", function(c)
--     if c.floating or c.first_tag.layout.name == "floating" then
--         awful.titlebar.show(c)
--     else
--         awful.titlebar.hide(c)
--     end
-- end)

-- tag.connect_signal("property::layout", function(t)
--     local clients = t:clients()
--     for k,c in pairs(clients) do
--         if c.floating or c.first_tag.layout.name == "floating" then
--             awful.titlebar.show(c)
--         else
--             awful.titlebar.hide(c)
--         end
--     end
-- end)

-- screen.connect_signal("arrange", function(s)
--     for _, c in pairs(s.clients) do
--         if #s.tiled_clients == 1 and c.floating == false or c.maximized then
--            awful.titlebar.hide(c)
--         elseif #s.tiled_clients > 1 then
--            awful.titlebar.show(c)
--         end
--     end
-- end)
-- }}}
