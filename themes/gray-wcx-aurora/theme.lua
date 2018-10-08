local gears = require("gears")
local lain  = require("lain")
local awful = require("awful")
local wibox = require("wibox")
local os    = { getenv = os.getenv }

local theme                                     = {}
theme.dir                                       = os.getenv("HOME") .. "/.config/awesome/themes/gray-wcx-aurora"
-- theme.wallpaper                                 = theme.dir .. "/wall.png"
theme.font                                      = "Iosevka Term 9"
theme.taglist_font                              = "Hack 10"
theme.fg_normal                                 = "#666666"
theme.fg_focus                                  = "#131112"
theme.fg_urgent                                 = "#dddddd"
theme.bg_normal                                 = "#14191efe"
theme.bg_focus                                  = "#D0D0D0fe"
theme.bg_urgent                                 = "#31e183"
theme.bg_systray                                = theme.bg_normal
theme.border_width                              = 0
theme.border_normal                             = "#3F3F3F"
theme.border_focus                              = "#0e9e97"
theme.border_marked                             = "#333333"
theme.tasklist_bg_focus                         = "#1A1A1A"
theme.titlebar_bg_focus                         = theme.bg_normal
theme.titlebar_bg_normal                        = theme.bg_normal
theme.titlebar_fg_normal                        = theme.fg_normal
theme.titlebar_fg_focus                         = theme.fg_normal
-- theme.taglist_fg_occupied                       = ""
-- theme.taglist_bg_occupied                       = ""
theme.taglist_fg_empty                          = "#2e2e2e"
-- theme.taglist_bg_empty                          = ""
theme.menu_height                               = 18
theme.menu_width                                = 140
theme.menu_submenu_icon                         = theme.dir .. "/icons/submenu.png"
-- theme.taglist_squares_sel                       = theme.dir .. "/icons/square_sel.png"
-- theme.taglist_squares_unsel                     = theme.dir .. "/icons/square_unsel.png"
theme.layout_tile                               = theme.dir .. "/icons/tile.png"
theme.layout_tileleft                           = theme.dir .. "/icons/tileleft.png"
theme.layout_tilebottom                         = theme.dir .. "/icons/tilebottom.png"
theme.layout_tiletop                            = theme.dir .. "/icons/tiletop.png"
theme.layout_fairv                              = theme.dir .. "/icons/fairv.png"
theme.layout_fairh                              = theme.dir .. "/icons/fairh.png"
theme.layout_spiral                             = theme.dir .. "/icons/spiral.png"
theme.layout_dwindle                            = theme.dir .. "/icons/dwindle.png"
theme.layout_max                                = theme.dir .. "/icons/max.png"
theme.layout_fullscreen                         = theme.dir .. "/icons/fullscreen.png"
theme.layout_magnifier                          = theme.dir .. "/icons/magnifier.png"
theme.layout_floating                           = theme.dir .. "/icons/floating.png"
theme.widget_ac                                 = theme.dir .. "/icons/ac.png"
theme.widget_battery                            = theme.dir .. "/icons/battery.png"
theme.widget_battery_low                        = theme.dir .. "/icons/battery_low.png"
theme.widget_battery_empty                      = theme.dir .. "/icons/battery_empty.png"
theme.widget_mem                                = theme.dir .. "/icons/mem.png"
theme.widget_cpu                                = theme.dir .. "/icons/cpu.png"
theme.widget_temp                               = theme.dir .. "/icons/temp.png"
theme.widget_net                                = theme.dir .. "/icons/net.png"
theme.widget_hdd                                = theme.dir .. "/icons/hdd.png"
theme.widget_music                              = theme.dir .. "/icons/note.png"
theme.widget_music_on                           = theme.dir .. "/icons/note_on.png"
theme.widget_vol                                = theme.dir .. "/icons/vol.png"
theme.widget_vol_low                            = theme.dir .. "/icons/vol_low.png"
theme.widget_vol_no                             = theme.dir .. "/icons/vol_no.png"
theme.widget_vol_mute                           = theme.dir .. "/icons/vol_mute.png"
theme.widget_mail                               = theme.dir .. "/icons/mail.png"
theme.widget_mail_on                            = theme.dir .. "/icons/mail_on.png"
theme.tasklist_plain_task_name                  = true
theme.tasklist_disable_icon                     = true
theme.useless_gap                               = 0
theme.titlebar_close_button_focus               = theme.dir .. "/icons/titlebar/close_focus.png"
theme.titlebar_close_button_normal              = theme.dir .. "/icons/titlebar/close_normal.png"
theme.titlebar_ontop_button_focus_active        = theme.dir .. "/icons/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active       = theme.dir .. "/icons/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive      = theme.dir .. "/icons/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive     = theme.dir .. "/icons/titlebar/ontop_normal_inactive.png"
theme.titlebar_sticky_button_focus_active       = theme.dir .. "/icons/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active      = theme.dir .. "/icons/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive     = theme.dir .. "/icons/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive    = theme.dir .. "/icons/titlebar/sticky_normal_inactive.png"
theme.titlebar_floating_button_focus_active     = theme.dir .. "/icons/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active    = theme.dir .. "/icons/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive   = theme.dir .. "/icons/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive  = theme.dir .. "/icons/titlebar/floating_normal_inactive.png"
theme.titlebar_maximized_button_focus_active    = theme.dir .. "/icons/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active   = theme.dir .. "/icons/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = theme.dir .. "/icons/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = theme.dir .. "/icons/titlebar/maximized_normal_inactive.png"

theme.notification_bg = "#000000fe"
theme.notification_fg = "#dddddd"
theme.notification_font = "Hack 9"
theme.notification_border_width = 1
theme.notification_border_color = theme.bg_normal
theme.notification_margin = 3
theme.notification_shape = function(cr, width, height)
   gears.shape.rounded_rect(cr, width, height, 4)
end

local markup = lain.util.markup
local separators = lain.util.separators

-- Textclock
local clockicon = wibox.widget.imagebox(theme.widget_clock)
local clock = awful.widget.watch(
    "date +'%a %d %b %I:%M%P'", 60,
    function(widget, stdout)
        widget:set_markup(markup(theme.fg_urgent, " " .. markup.font(theme.font, stdout)))
    end
)

-- Calendar
theme.cal = lain.widget.calendar({
    attach_to = { clock.widget },
    notification_preset = {
        font = "xos4 Hack 10",
        fg   = theme.fg_urgent,
        bg   = theme.bg_normal
    }
})

-- MEM
local mem = lain.widget.mem({
    settings = function()
        widget:set_markup(markup.font(theme.font, markup(theme.fg_normal, "mem ") .. markup(theme.fg_urgent, mem_now.perc .. "% ")))
    end
})

-- CPU
local cpu = lain.widget.cpu({
    settings = function()
        widget:set_markup(markup.font(theme.font, markup(theme.fg_normal, "cpu ") .. markup(theme.fg_urgent, string.format("%2d", cpu_now.usage) .. "% ")))
    end
})

-- Coretemp
local temp = lain.widget.temp({
    settings = function()
        widget:set_markup(markup.font(theme.font, markup(theme.fg_normal, "temp ") .. markup(theme.fg_urgent, string.format("%.2d", coretemp_now) .. "°C ")))
    end,
    tempfile = "/sys/class/thermal/thermal_zone4/temp"
})

-- Battery
local baticon = wibox.widget.imagebox(theme.widget_battery)
local bat = lain.widget.bat({
    settings = function()
        if bat_now.status ~= "N/A" then
            if bat_now.ac_status == 1 then
                widget:set_markup(markup.font(theme.font, " AC "))
                baticon:set_image(theme.widget_ac)
                return
            elseif not bat_now.perc and tonumber(bat_now.perc) <= 5 then
                baticon:set_image(theme.widget_battery_empty)
            elseif not bat_now.perc and tonumber(bat_now.perc) <= 15 then
                baticon:set_image(theme.widget_battery_low)
            else
                baticon:set_image(theme.widget_battery)
            end
            widget:set_markup(markup.font(theme.font, " " .. bat_now.perc .. "% "))
        else
            widget:set_markup(markup.font(theme.font, " AC "))
            baticon:set_image(theme.widget_ac)
        end
    end
})

-- -- ALSA volume
-- local volicon = wibox.widget.imagebox(theme.widget_vol)
-- theme.volume = lain.widget.pulseaudio({
--     settings = function()
--         if volume_now.muted == "yes" then
--             volicon:set_image(theme.widget_vol_mute)
--         elseif tonumber(volume_now.left) == 0 then
--             volicon:set_image(theme.widget_vol_no)
--         elseif tonumber(volume_now.left) <= 50 then
--             volicon:set_image(theme.widget_vol_low)
--         else
--             volicon:set_image(theme.widget_vol)
--         end

--         widget:set_markup(markup.font(theme.font, markup(theme.fg_normal, "vol ") .. markup(theme.fg_focus, volume_now.left .. "% ")))
--     end
-- })

function humanize_bytes(value)
   suff = {"T", "G", "M", "K", "B"}
   value = tonumber(value)
   while(value > 1024 and #suff > 0) do
      value = value / 1024
      -- removing the first element is expensive in lua, do everything backwards
      table.remove(suff)
   end
   return string.format("% 4s%s", string.format("%.4s", value), suff[#suff])
end

-- Net
local neticon = wibox.widget.imagebox(theme.widget_net)
local net = lain.widget.net({
    settings = function()
       widget:set_markup(markup.font(theme.font, markup(theme.fg_normal, "net") ..
                                        markup("#0e9e97", " " .. humanize_bytes(net_now.received))
                                        .. " " ..
                                        markup("#dddddd", "" .. humanize_bytes(net_now.sent) .. " ")))
    end,
    -- Ensure we get bytes
    units = 1
})

-- Separators
local spr     = wibox.widget.textbox(' ')
local arrl_dl = separators.arrow_left(theme.bg_focus, "alpha")
local arrl_ld = separators.arrow_left("alpha", "#252d35")

function theme.at_screen_connect(s)
    -- Quake application
   -- s.quake = lain.util.quake({ app = awful.util.terminal })

    -- If wallpaper is a function, call it with the screen
    local wallpaper = theme.wallpaper
    if type(wallpaper) == "function" then
        wallpaper = wallpaper(s)
    end
    gears.wallpaper.maximized(wallpaper, s, true)

    -- Tags
    -- awful.tag(awful.util.tagnames, s, awful.layout.layouts)

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, awful.util.taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, awful.util.tasklist_buttons)

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, height = 20, bg = theme.bg_normal, fg = theme.fg_normal })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            --spr,
            s.mytaglist,
            spr,
            s.mypromptbox,
            spr,
        },
        -- s.mytasklist, -- Middle widget
        spr,
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            spr,
            -- wibox.container.background(mpdicon),
            -- wibox.container.background(theme.mpd.widget),
            wibox.container.background(cpu.widget),
            mem.widget,
            wibox.container.background(temp.widget),
            -- baticon,
            -- bat.widget,
            wibox.container.background(net.widget),
            spr,
            wibox.widget.systray(),
            spr,
            clock,
            spr,
            arrl_ld,
            wibox.container.background(s.mylayoutbox, "#252d35"),
        },
    }
end

return theme
