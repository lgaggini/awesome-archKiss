---------------------------
--   "archKiss" rc.lua   --
--      by lgaggini      --
--      CC BY-SA 3.0     --
---------------------------

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
require("eminent")
-- Widget and layout library
local wibox = require("wibox")
-- Sysmon widget library
local vicious = require("vicious")
local lain = require("lain")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
-- Application menu
local freedesktop = require('freedesktop')
-- Hotkeys popup
local hotkeys_popup = require("awful.hotkeys_popup").widget

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
  end
-- }}}

-- set icon preferred size to prevent blur on scale
awesome.set_preferred_icon_size(48)

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/home/lg/.config/awesome/themes/kiss/theme_dark.lua")

-- User / hostname info
user_hostname = true

-- Kernel version monitoring
kernel_mon = true

-- Uptime
uptime = true

-- Nic interfaces to monitor, fifo
nics = {"enp0s31f6", "wlp1s0"}

-- Maildir monitor, false or maildir location
mail_mon = false

-- Switch to enable hwmonitor
hwmonitor = true

-- Switch to enable battery monitoring
laptop = true

-- Mountpoint(s) to monitor
mounts = " /: ${/ used_p}%"

-- Enable full calendar on 2nd monitor
full_cal = true

-- Enable mpris bar
mpris = true

-- Enable mpd bar
mpd = false

-- This is used later as the default applications to run.
terminal = "alacritty"
browser_work = "firefox --class work-default"
browser_personal = "firefox --class personal-default -p personal-default"
im = "slack"
videoconference = "zoom"
task = "resources"
password = "rofi-pass"
clipboard = "rofi -modi \"paste:~/bin/paste-modi.sh\" -show paste"
calculator = "rofi -show calc -modi calc -no-show-match -no-sort"
snippets = "rofi-snippy"
runner = "rofi -show run"
wswitcher = "rofi -show window"

music = "soundcloud"
mpris_data = "playerctl metadata --format '{{lc(status)}}|{{artist}}|{{title}}'"
mpris_toggle = "playerctl play-pause"

lock = "dm-tool lock"
poweroff = "sudo poweroff"
reboot = "sudo reboot"

-- TBD
-- editor = "neovide"
-- filemanager = terminal .. " -e ranger"
-- filemanager_gui = "thunar"
-- email = terminal .. " -e neomutt"
-- email_gui = "thunderbird"
-- pad = "neovide --x11-wm-class pad"
-- pim = terminal .. " -T pim -e tmuxp load pim"
-- news = terminal .. " -T news -e tmuxp load news"
-- note = terminal .. " -T note -e tmuxp load note"
-- irc = terminal .. " -T irc -e weechat"
-- music_stream = "spotify"
-- media = "mpv"
-- bright_down = "xbacklight -dec 10"
-- bright_up = "xbacklight -inc 10"
-- audio_up = "amixer -D pulse sset Master 2%+"
-- audio_down = "amixer -D pulse sset Master 2%-"

-- One line calendar command
onelinecal = [[ cal | tail -n +3 | sed -e "s/\<$(date +%-d)\>/\<span color=\"]] .. theme.fg_widget .. [[\">&\<\/span>/" | sed 's/^[ \t]*//' | tr "\n" " "]]

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
altkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,

}
-- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end
-- }}}

-- {{{ Function definitions
-- Custom widget for sys temp
function systemp()
    local fd = io.popen("sensors|grep 'Package id 0'|tail -1|gawk '{print $4'}", "r")
    local temp = fd:read()
    io.close(fd)
    return temp
end
-- Custom widget for one line calendar
function cal()
    local fd = io.popen(onelinecal, "r")
    local cal = fd:read()
    io.close(fd)
    return cal:gsub("^%s*(.-)%s*$", "%1") .. " "
end
-- }}}

-- {{{ Wallpaper
-- Random selection from theme related wallpaper directory
os.execute("feh --bg-scale $(shuf -en1 ~/.wallpaper/*)")
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags_name = { "", "", "", "", "", "", "", "🎶",""}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() return false, hotkeys_popup.show_help end},
   { "manual", terminal .. " -e man awesome" },
   -- { "edit config", editor .. " " .. awesome.conffile },
   { "restart", awesome.restart }
}

menu_items = { { "terminal", terminal },
          { "browser_work", browser_work },
          -- { "browser_personal", browser_personal },
          -- { "file manager", filemanager_gui },
          -- { "editor", editor },
          { "awesome", myawesomemenu },
          { "lock", lock },
          { "quit", function() awesome.quit() end},
          { "reboot", reboot },
          { "poweroff", poweroff }
        }

mymainmenu = freedesktop.menu.build({
    after = menu_items
})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock("%H:%M ")
mytextmonthandyear = awful.widget.textclock("%B %Y")
mytextday = awful.widget.textclock("%A ")
mytextdaynumber = awful.widget.textclock("%d ")

-- Create an user/hostname widget
if user_hostname then
    hosticon = wibox.widget.imagebox()
    hosticon:set_image(beautiful.os)
    hostwidget = wibox.widget.textbox()
    vicious.register(hostwidget, vicious.widgets.os, "$3 on $4")
end

-- Create an os widget
if kernel_mon then
    osicon = wibox.widget.imagebox()
    osicon:set_image(beautiful.os)
    oswidget = wibox.widget.textbox()
    vicious.register(oswidget, vicious.widgets.os, "$1-$2")
end

-- Create an uptime widget
if uptime then
    upicon = wibox.widget.imagebox()
    upicon:set_image(beautiful.uptime)
    upwidget =  wibox.widget.textbox()
    vicious.register(upwidget, vicious.widgets.uptime,
        function(widget, args)
            return string.format("%02d:%02d ", args[2], args[3])
        end)
end

-- Create a cpu widget
cpuicon = wibox.widget.imagebox()
cpuicon:set_image(beautiful.cpu)
cpuwidget =  wibox.widget.textbox()
vicious.register(cpuwidget, vicious.widgets.cpu, "$1%")

-- Create a ram widget
ramicon = wibox.widget.imagebox()
ramicon:set_image(beautiful.ram)
ramwidget =  wibox.widget.textbox()
vicious.register(ramwidget, vicious.widgets.mem, "$1%")

-- Create an htop button
htopbuttons = awful.util.table.join(
        awful.button({ }, 1, function () awful.util.spawn(task) end)
)
cpuicon:buttons(htopbuttons)
cpuwidget:buttons(htopbuttons)
ramicon:buttons(htopbuttons)
ramwidget:buttons(htopbuttons)

-- Create a temp widget
if hwmonitor then
    tempicon = wibox.widget.imagebox()
    tempicon:set_image(beautiful.temp)
    tempwidget = wibox.widget.textbox()
end

-- Create a fs widget
fsicon = wibox.widget.imagebox()
fsicon:set_image(beautiful.fs)
fswidget = wibox.widget.textbox()
vicious.register(fswidget, vicious.widgets.fs, mounts)

-- Create a fs button
fsbuttons = awful.util.table.join(
       awful.button({ }, 1, function () awful.util.spawn(filemanager_gui) end)
)
fsicon:buttons(fsbuttons)
fswidget:buttons(fsbuttons)

-- Create a net widget
neticon = wibox.widget.imagebox()
neticon:set_image(beautiful.net)
netwidget = wibox.widget.textbox()
vicious.register(netwidget, vicious.widgets.net,
    function(widget, args)
        for i, nic in ipairs(nics) do
            carrier_index = "{" .. nic .. " carrier}"
            if args[carrier_index] == 1
                then
                    upload_index = "{" .. nic .. " up_kb}"
                    download_index = "{" .. nic .. " down_kb}"
                    return args[upload_index] .. "kb/" .. args[download_index] .. "kb "
            end
        end
        return "no network"
    end,1)

-- Create a mpris widget
if mpris then
    mprisicon = wibox.widget.imagebox()
    mprisicon:set_image(beautiful.music)
    mpriswidget = awful.widget.watch(mpris_data, 5,
        function(widget, stdout)
            local split = {}
            for substr in string.gmatch(stdout, "([^|]+)") do
                if substr ~= nil and string.len(substr) > 0 then
                    table.insert(split,substr)
                end
            end
            local status = split[1]
            if  status == "No players found" then
                mprisicon:set_visible(false)
                mpriswidget:set_visible(false)
            else
              mprisicon:set_visible(true)
              local artist = split[2]
              local title = split[3]
              widget:set_text(title)
              if status == "playing" then
                  mprisicon:set_image(beautiful.music)
              elseif status == "paused" then
                  mprisicon:set_image(beautiful.music_pause)
              end
            end
      end)

    -- Create a mpris button
    mprisbuttons = awful.util.table.join(
    awful.button({ }, 1, function () awful.util.spawn_with_shell(mpris_toggle) end)
    )
    mprisicon:buttons(mprisbuttons)
    mpriswidget:buttons(mprisbuttons)
end

-- Create a mpd widget
if mpd then
    mpdicon = wibox.widget.imagebox()
    mpdicon:set_image(beautiful.music)
    mpdwidget = wibox.widget.textbox()
    vicious.register(mpdwidget, vicious.widgets.mpd,
        function (widget, args)
        if args["{state}"] == "Stop" then
            mpdicon.visible = false
            return ""
        elseif args["{state}"] == "Play" then
            mpdicon.visible = true
            mpdicon:set_image(beautiful.music)
            return args["{Artist}"] .. " - " .. args["{Title}"] .. " " .. args["{Elapsed}"] .. " " .. args["{Progress}"]
        elseif args["{state}"] == "Pause" then
            mpdicon.visible = true
            mpdicon:set_image(beautiful.music_pause)
            return args["{Artist}"] .. " - " .. args["{Title}"] .. " " .. args["{Elapsed}"] .. " " .. args["{Progress}"]
        end
        end)

    -- Create a mpd button
    mpdbuttons = awful.util.table.join(
    awful.button({ }, 1, function () awful.util.spawn_with_shell(music_toggle) end)
    )
    mpdicon:buttons(mpdbuttons)
    mpdwidget:buttons(mpdbuttons)
end

-- Create a maildir widget
if mail_mon then
    mdiricon = wibox.widget.imagebox()
    mdiricon:set_image(beautiful.mail)
    mdirwidget = wibox.widget.textbox()
    vicious.register(mdirwidget, vicious.widgets.mdir, 
        function (widget, args)
            return string.format("%02d", args[1]+args[2]) 
        end, 600,  {mail_mon})

    -- Create a maildir button
    mdirbuttons = awful.util.table.join(
        awful.button({ }, 1, function () awful.util.spawn(email) end)
    )
    mdiricon:buttons(mdirbuttons)
    mdirwidget:buttons(mdirbuttons)
end

-- Create a calendar widget
calicon = wibox.widget.imagebox()
calicon:set_image(beautiful.cal)
calwidget = wibox.widget.textbox()

-- Create a battery widget
if laptop then
    batteryicon = wibox.widget.imagebox()
    batteryicon:set_image(beautiful.bat)
    batterywidget = wibox.widget.textbox()
    vicious.register(batterywidget, vicious.widgets.bat, "$2 $1", 61, "BAT0")
end

-- Create a wibox for each screen and add it
local taglist_buttons = awful.util.table.join(
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

local tasklist_buttons = awful.util.table.join(
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
                     awful.button({ }, 3, client_menu_toggle_fn()),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

-- Screens number
screens=screen:count()

awful.screen.connect_for_each_screen(function(s)

    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    local geometry = s.geometry
    if geometry.width < geometry.height then
        awful.tag(tags_name, s, layouts[7])
    else
        awful.tag(tags_name, s, layouts[6])
    end

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
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Create the systray
    mysystray = wibox.widget.systray()
    mysystray:set_base_size(24)

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        {   -- Right widgets
            layout = wibox.layout.fixed.horizontal,

            -- music
            s.index == 1 and mpd and mpdicon,
            s.index == 1 and mpd and mpdwidget,
            s.index == 1 and spotify and spotifyicon,
            s.index == 1 and spotify and spotifywidget,
            s.index == 1 and mpris and mprisicon,
            s.index == 1 and mpris and mpriswidget,

            -- calendar
            s.index == 1 and calicon,
            s.index == 1 and mytextday,
            s.index == 1 and full_cal and calwidget,
            s.index == 1 and mytextdaynumber,
            s.index == 1 and mytextmonthandyear,
            s.index == 1 and mdiricon,
            s.index == 1 and mdirwidget,

            -- info and stats
            s.index == 1 and user_hostname and hosticon,
            s.index == 1 and user_hostname and hostwidget,
            s.index == 1 and osicon,
            s.index == 1 and oswidget,
            s.index == 1 and uptime and upicon,
            s.index == 1 and uptime and upwidget,
            s.index == 1 and cpuicon,
            s.index == 1 and cpuwidget,
            s.index == 1 and ramicon,
            s.index == 1 and ramwidget,
            s.index == 1 and tempicon,
            s.index == 1 and tempwidget,
            s.index == 1 and fsicon,
            s.index == 1 and fswidget,
            s.index == 1 and batteryicon,
            s.index == 1 and batterywidget,
            s.index == 1 and neticon,
            s.index == 1 and netwidget,

            -- systray
            s.index == 1 and mysystray:set_screen(s),
            mysystray,
            s.index == 1 and mytextclock,
            s.mylayoutbox,
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 1, function () mymainmenu:hide() end),
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(

    -- Navigation
    awful.key({ altkey,           }, "h", awful.tag.viewprev       ),
    awful.key({ altkey,           }, "l", awful.tag.viewnext       ),
    awful.key({ altkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ altkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ altkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    -- Alt-Tab replaced by rofi
    --awful.key({ altkey,           }, "Tab",
        --function ()
            --awful.client.focus.history.previous()
            --if client.focus then
                --client.focus:raise()
            --end
        --end),
    awful.key({ altkey,           }, "Tab", function () awful.util.spawn_with_shell(wswitcher) end),

    awful.key({ altkey, "Shift"   }, "Tab",
        function()
            awful.menu.menu_keys.down = { "Down", "Alt_L", "Tab", "j" }
            awful.menu.menu_keys.up = { "Up", "k" }
            lain.util.menu_clients_current_tags({ width = 350 }, { keygrabber = true })
        end),

    -- Standard shortcuts
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),
    awful.key({                   }, "XF86MonBrightnessDown", function () awful.util.spawn_with_shell(bright_down) end),
    awful.key({                   }, "XF86MonBrightnessUp",   function () awful.util.spawn_with_shell(bright_up) end),
    awful.key({                   }, "XF86AudioLowerVolume", function () awful.util.spawn_with_shell(audio_down) end),
    awful.key({                   }, "XF86AudioRaiseVolume",   function () awful.util.spawn_with_shell(audio_up) end),
    awful.key({                   }, "XF86AudioPlay",   function () awful.util.spawn_with_shell(music_toggle) end),
    awful.key({ modkey, "Shift"   }, "p", function () awful.util.spawn_with_shell(mpris_toggle) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    -- Layout manipulation
    awful.key({ altkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ altkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ altkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ altkey,           }, "+",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ altkey,           }, "-",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ altkey, "Shift"   }, "+",     function () awful.tag.incncol( 1)         end),
    awful.key({ altkey, "Shift"   }, "-",     function () awful.tag.incncol(-1)         end),
    awful.key({ altkey,           }, "space", function () awful.layout.inc(awful.layout.layouts,  1) end),
    awful.key({ altkey, "Shift"   }, "space", function () awful.layout.inc(awful.layout.layouts, -1) end),

    awful.key({ altkey, "Control" }, "r", awful.client.restore),

    -- Prompt - replaced by rofi
    --awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              --{description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "l",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
            {description = "lua execute prompt", group = "awesome"}),

    -- Menubar
    awful.key({ modkey }, "x", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"}),

    -- Application launcher common
    -- Basic
    awful.key({ modkey,         }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey,         },"b", function () awful.util.spawn_with_shell(browser_work) end), -- [b]rowser
    awful.key({ modkey,         },"f", function () awful.util.spawn_with_shell(filemanager) end), -- [f]ilemanager
    awful.key({ modkey,         },"e", function () awful.util.spawn_with_shell(editor) end), -- [e]ditor 

    -- Pim
    awful.key({ modkey,         },"m", function () awful.util.spawn_with_shell(email) end), -- e[m]ail
    awful.key({ modkey,         },"n", function () awful.util.spawn_with_shell(note) end), -- [n]ote
    awful.key({ modkey,         },"i", function () awful.util.spawn_with_shell(pim) end), -- p[i]m

    -- Communication
    awful.key({ modkey,         },"c", function () awful.util.spawn_with_shell(im) end), -- [c]hat
    awful.key({ modkey,         },"k", function () awful.util.spawn_with_shell(irc) end), -- ir[k]
    awful.key({ modkey,         },"d", function () awful.util.spawn_with_shell(news) end), -- fee[d]
    awful.key({ modkey,         },"v", function () awful.util.spawn_with_shell(videoconference) end), -- [v]ideoconference

    -- Multimedia
    awful.key({ modkey,         },"a", function () awful.util.spawn_with_shell(music) end), -- [a]udio

    -- Utilities
    awful.key({ modkey,         },"s", function () awful.util.spawn_with_shell(pad) end), -- [s]cratch pad
    awful.key({ modkey,         },"t", function () awful.util.spawn_with_shell(task) end), -- [t]ask manager
    awful.key({ modkey,         },"p", function () awful.util.spawn_with_shell(password) end), -- [p]assword
    awful.key({ modkey,         },"h", function () awful.util.spawn_with_shell(clipboard) end), -- clipboard [h]istory
    awful.key({ modkey,         },"r", function () awful.util.spawn_with_shell(runner) end), -- [r]unner
    awful.key({ modkey,         },"u", function () awful.util.spawn_with_shell(calculator) end), -- calc[u]lator
    awful.key({ modkey,         },"g", function () awful.util.spawn_with_shell(snippets) end), -- snippets [g]
    awful.key({ modkey, "Shift" },"l", function () awful.util.spawn_with_shell(lock) end) -- [l]ock
)

clientkeys = awful.util.table.join(
    awful.key({ altkey, "Shift"   }, "f",       function (c) c.fullscreen = not c.fullscreen end),
    awful.key({ altkey,           }, "c",       function (c) c:kill()                        end),
    awful.key({ altkey,           }, "z",       awful.client.floating.toggle                    ),
    awful.key({ altkey, "Shift"   }, "Return",  function (c) c:swap(awful.client.getmaster())end),
    awful.key({ altkey,           }, "t",       function (c) c.ontop = not c.ontop           end),
    awful.key({ altkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ altkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end),
    awful.key({ altkey, "Shift"   }, "m",       lain.util.magnify_client                        ),

    -- Multiscreen facilities
    awful.key({ altkey,           }, "s",       function () awful.screen.focus_relative( 1) end),
    awful.key({ altkey,           }, "F1",      function () awful.screen.focus(1) end),
    awful.key({ altkey,           }, "F2",      function () awful.screen.focus(2) end),
    awful.key({ altkey, "Shift"   }, "F1",      function () awful.client.movetoscreen(c,1) end),
    awful.key({ altkey, "Shift"   }, "F2",      function () awful.client.movetoscreen(c,2) end),
    awful.key({ altkey,           }, "o",       awful.client.movetoscreen                       )
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ altkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ altkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ altkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ altkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

-- Bind custom keys to tags.
-- Keys to tags association are defined in the tag_keys tables.
--- Main (terms), [x]tools, [w]eb browser, [e]ditor, [p]ost (mail), [r]eaders (doc), [i]m, a[udio] ,[v]irtual
tag_keys = {"Return","x","w","e","p","r","i","a","v"}
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ altkey }, tag_keys[i],
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ altkey, "Control" }, tag_keys[i],
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ altkey, "Shift" }, tag_keys[i],
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ altkey, "Control", "Shift" }, tag_keys[i],
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end


clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

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
                     size_hints_honor = false } },

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }}, 
      properties = { titlebars_enabled = true }},

    -- Floating clients.
    { rule_any = {
        instance = {
        },
        class = {
          "feh",
          "Arandr",
          "pinentry",
          "Resources",
          "zoom",
        },
        name = {
          "Event Tester",  -- xev.
        },
        role = {
        }
      }, properties = { floating = true }},

    -- 1:term Terminal
     { rule = { class = "Alacritty" },
       properties = { screen = 1, tag = tags_name[1], switchtotag = true, maximized_vertical = true, maximized_horizontal = true } },

    -- 2:web Web
     { rule = { class = "work-default" },
       properties = { screen = 1, tag = tags_name[2], switchtotag = true, floating = false } },

     { rule = { class = "personal-default" },
       properties = { screen = screens, tag = tags_name[2], switchtotag = true, floating = false } },

    -- 3:com - Communication
     { rule = { class = "Slack" },
      properties = { screen = 1, tag = tags_name[3], switchtotag = true } },

     { rule = { class = "zoom" },
      properties = { screen = 1, tag = tags_name[3], switchtotag = true } },

    -- 4:tools - Tools

    -- 5:ent Entertainment
     { rule = { name = "Spotify" },
       properties = { screen = screens, tag = tags_name[5], switchtotag = true } },

     { rule = { class = "Soundcloud" },
       properties = { screen = screens, tag = tags_name[5], switchtotag = true } },

}


-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
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

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
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
end)

-- Timer for custom widget

if hwmonitor then
    tempwidget:set_text(systemp())
    temptimer = timer({ timeout = 300 })
    temptimer:connect_signal("timeout", function() tempwidget:set_text(systemp()) end)
    temptimer:start()
end

calwidget:set_markup(cal())

caltimer = timer({ timeout =  300 })
caltimer:connect_signal("timeout", function() calwidget:set_markup(cal()) end)
caltimer:start()

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
