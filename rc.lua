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

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/home/lg/.config/awesome/themes/kiss/theme_default.lua")

-- User / hostname info
user_hostname = true

-- Kernel version monitoring
kernel_mon = true

-- Uptime
uptime = true

-- Nic interfaces to monitor, fifo
nics = {"enp0s25", "wlo1"}

-- Maildir monitor, false or maildir location
mail_mon = false

-- Switch to enable hwmonitor
hwmonitor = true

-- Switch to enable battery monitoring
laptop = true

-- Mountpoint(s) to monitor
mounts = " /: ${/ used_p}% ~: ${/home used_p}%"

-- Enable full calendar on 2nd monitor
full_cal = true

-- Enable mpd bar
mpd = true

-- Enable spotify bar
spotify = true

-- This is used later as the default applications to run.
terminal = "urxvt"
browser = "chromium --password-store=gnome"
editor = "gvim"
email = terminal .. " -e neomutt"
email_gui = "thunderbird"
pad = "leafpad"
pim = terminal .. " -title pim -e tmuxp load pim"
news = terminal .. " -title news -e tmuxp load news"
note = terminal .. " -title note -e tmuxp load note"
filemanager = terminal .. " -e ranger"
task = "lxtask"
im = "pidgin"
irc = terminal .. " -title irc -e weechat"
teams = "teams"
music = terminal .. " -e ncmpc"
music_toggle = "mpc toggle"
music_stream = "spotify"
music_stream_toggle = "sp play"
music_stream_data = "sp current-oneline"
media = "smplayer"
password_man = "qtpass"
password = "pass -c master"
vm = "virtualbox"
remote = "remmina"
bright_down = "xbacklight -dec 10"
bright_up = "xbacklight -inc 10"
audio_toggle = "mpc toggle"
lock = "xflock4"
poweroff = "sudo poweroff"
reboot = "sudo reboot"

-- One line calendar command
onelinecal = [[ cal | tail -n +3 | sed -e "s/\<$(date +%-d)\>/\<span color=\"]] .. "#1994d1" .. [[\">&\<\/span>/" | sed 's/^[ \t]*//' | tr "\n" " "]]

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
    awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,

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
os.execute("find " .. beautiful.wallpaper_dir .. " -type f -print0 | shuf -n1 -z | xargs -0 feh --bg-scale")
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags_name = { "", "", "", "", "", "", "", "",""}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() return false, hotkeys_popup.show_help end},
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end}
}

menu_items = { { "terminal", terminal },
          { "browser", browser },
          { "file manager", filemanager },
          { "editor", editor },
          { "awesome", myawesomemenu },
          { "lock", lock },
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
       awful.button({ }, 1, function () awful.util.spawn(filemanager) end)
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


-- Create a spotify widget (https://github.com/streetturtle/awesome-wm-widgets/tree/master/spotify-widget)
if spotify then
    spotifyicon = wibox.widget.imagebox()
    spotifyicon:set_image(beautiful.music)
    spotifywidget = awful.widget.watch(music_stream_data, 5,
        function(widget, stdout)
            if string.find(stdout, "Error: Spotify is not running.") ~= nil then
                spotifyicon:set_visible(false)
                widget:set_visible(false)
            else
                spotifyicon:set_visible(true)
                widget:set_visible(true)
                split = {}
                for substr in string.gmatch(stdout, "[^|]*") do
                    if substr ~= nil and string.len(substr) > 0 then
                        table.insert(split,substr)
                    end
                end
                if  split[1] == "Paused" then
                    spotifyicon:set_image(beautiful.music_pause)
                elseif split[1] == "Playing" then
                    spotifyicon:set_image(beautiful.music)
                end
                widget:set_text(split[2])
            end
        end)

    -- Create a spotify button
    spotifybuttons = awful.util.table.join(
    awful.button({ }, 1, function () awful.util.spawn_with_shell(music_stream_toggle) end)
    )
    spotifyicon:buttons(spotifybuttons)
    spotifywidget:buttons(spotifybuttons)
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
    awful.tag(tags_name, s, layouts[6])

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

    -- Create the systary
    mysystray = wibox.widget.systray()

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
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            screens == 2 and s.index == 1 and user_hostname and hosticon,
            screens == 2 and s.index == 1 and user_hostname and hostwidget,
            s.index == 1 and osicon,
            s.index == 1 and oswidget,
            screens == 2 and s.index == 1 and uptime and upicon,
            screens == 2 and s.index == 1 and uptime and upwidget,
            cpuicon,
            cpuwidget,
            ramicon,
            ramwidget,
            tempicon,
            tempwidget,
            fsicon,
            fswidget,
            screens == 1 and calicon,
            screens == 2 and s.index == 2 and calicon,
            screens == 1 and mytextday,
            screens == 2 and s.index == 2 and mytextday,
            s.index == 2 and full_cal and s.geometry.width >= 1920 and calwidget,
            s.index == 2 and (not full_cal or s.geometry.width < 1920) and mytextdaynumber,
            screens == 1 and mytextdaynumber,
            screens == 1 and mytextmonthandyear,
            screens == 2 and s.index == 2 and mytextmonthandyear,
            mdiricon,
            mdirwidget,
            (screens == 1 or screens == 2) and s.index == 1 and s.geometry.width >= 1920 and mpd and mpdicon,
            (screens == 1 or screens == 2) and s.index == 1 and s.geometry.width >= 1920 and mpd and mpdwidget,
            (screens == 1 or screens == 2) and s.index == 1 and s.geometry.width >= 1920 and spotify and spotifyicon,
            (screens == 1 or screens == 2) and s.index == 1 and s.geometry.width >= 1920 and spotify and spotifywidget,
            batteryicon,
            batterywidget,
            neticon,
            netwidget,
            screens == 2 and s.index == 2 and mysystray:set_screen(s),
            mysystray,
            screens == 1 and mytextclock,
            screens == 2 and s.index == 2 and mytextclock,
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
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

    -- Layout manipulation
    awful.key({ altkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ altkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ altkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ altkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    awful.key({ altkey, "Shift"   }, "Tab",
        function()
            awful.menu.menu_keys.down = { "Down", "Alt_L", "Tab", "j" }
            awful.menu.menu_keys.up = { "Up", "k" }
            lain.util.menu_clients_current_tags({ width = 350 }, { keygrabber = true })
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({                   }, "XF86MonBrightnessDown", function () awful.util.spawn_with_shell(bright_down) end),
    awful.key({                   }, "XF86MonBrightnessUp",   function () awful.util.spawn_with_shell(bright_up) end),
    awful.key({ modkey, "Shift"   }, "p", function () awful.util.spawn_with_shell(audio_toggle) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ altkey,           }, "+",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ altkey,           }, "-",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ altkey, "Shift"   }, "+",     function () awful.tag.incncol( 1)         end),
    awful.key({ altkey, "Shift"   }, "-",     function () awful.tag.incncol(-1)         end),
    awful.key({ altkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ altkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ altkey, "Control" }, "r", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

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
    awful.key({ modkey,         },"b", function () awful.util.spawn_with_shell(browser) end), -- [b]rowser
    awful.key({ modkey,         },"f", function () awful.util.spawn_with_shell(filemanager) end), -- [f]ilemanager
    awful.key({ modkey,         },"e", function () awful.util.spawn_with_shell(editor) end), -- [e]ditor 
    awful.key({ modkey,         },"m", function () awful.util.spawn_with_shell(email) end), -- e[m]ail
    awful.key({ modkey,         },"s", function () awful.util.spawn_with_shell(pad) end), -- [s]cratch pad
    awful.key({ modkey,         },"n", function () awful.util.spawn_with_shell(note) end), -- [n]ote
    awful.key({ modkey,         },"c", function () awful.util.spawn_with_shell(teams) end), -- [c]hat
    awful.key({ modkey,         },"k", function () awful.util.spawn_with_shell(irc) end), -- ir[k]
    awful.key({ modkey,         },"i", function () awful.util.spawn_with_shell(pim) end), -- p[i]m
    awful.key({ modkey,         },"d", function () awful.util.spawn_with_shell(news) end), -- fee[d]
    awful.key({ modkey,         },"v", function () awful.util.spawn_with_shell(remote) end), -- [v]irtual / rdp
    awful.key({ modkey,         },"t", function () awful.util.spawn_with_shell(task) end), -- [t]ask manager
    awful.key({ modkey,         },"p", function () awful.util.spawn_with_shell(password) end), -- [p]assword
    awful.key({ modkey,         },"q", function () awful.util.spawn_with_shell(password_man) end), -- [q]t-pass 
    awful.key({ modkey,         },"a", function () awful.util.spawn_with_shell(music) end), -- [a]udio
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
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
        },
        class = {
          "Arandr",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Wpa_gui",
          "pinentry",
          "veromix",
          "xtightvncviewer"},

        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = screens, tag = "2" } },

    -- 1:adm Admin
     { rule = { class = "URxvt" },
       properties = { screen = 1, tag = tags_name[1], switchtotag = true, maximized_vertical = true, maximized_horizontal = true } },

     { rule = { class = "Wireshark" },
       properties = { screen = screens, tag = tags_name[1], switchtotag = true, maximized_vertical = true, maximized_horizontal = true } },

      -- 2:util Utils
     { rule = { class = "Pcmanfm" },
       properties = { screen = screens, tag = tags_name[2], switchtotag = true } },

     { rule = { name = "ranger" },
       properties = { screen = screens, tag = tags_name[2], switchtotag = true } },

     { rule = { class = "Arandr" },
       properties = { screen = screens, tag = tags_name[2], switchtotag = true } },

     { rule = { class = "Filezilla" },
       properties = { screen = screens, tag = tags_name[2], switchtotag = true } },

     { rule = { class = "File-roller" },
       properties = { floating = true, tag = tags_name[2]} },

     { rule = { class = "Lxtask" },
       properties = { screen = screens, tag = tags_name[2], switchtotag = true } },

     { rule = { class = "Wicd-client.py" },
       properties = { screen = screens, tag = tags_name[2], switchtotag = true } },

     { rule = { class = "Pwsafe" },
       properties = { screen = screens, tag = tags_name[2], switchtotag = true } },

     { rule = { class = "QtPass" },
       properties = { floating = true, ontop = true } },

     -- 3:web Web
     { rule = { instance = "chromium" },
       properties = { screen = screens, tag = tags_name[3], switchtotag = true, floating = false } },

     { rule = { class = "Firefox" },
       properties = { screen = screens, tag = tags_name[3], switchtotag = true, floating = false } },

     -- 4:dev - Development
     { rule = { class = "Gvim" },
       properties = { screen = 1, tag = tags_name[4], switchtotag = true } },

     { rule = { class = "Gitg" },
       properties = { screen = screens, tag = tags_name[9], switchtotag = true } },

     { rule = { name = "note" },
       properties = { screen = screens, tag = tags_name[6], switchtotag = true } },

    -- 5:mail - Mail
     { rule = { class = "Thunderbird" },
        properties = { screen = screens, tag = tags_name[5], switchtotag = true } },

     { rule = { class = "Thunderbird", role = "Msgcompose" },
        properties = { screen = screens, tag = tags_name[4], switchtotag = true } },

     { rule = { name = "neomutt" },
        properties = { screen = screens, tag = tags_name[5], switchtotag = true } },

     { rule = { name = "pim" },
       properties = { screen = screens, tag = tags_name[5], switchtotag = true } },

     -- 6:doc - Documentation
     { rule = { name = "LibreOffice" },
       properties = { screen = screens, tag = tags_name[6], switchtotag = true } },

     { rule = { class = "libreoffice-writer" },
       properties = { screen = screens, tag = tags_name[6], switchtotag = true, floating = false } },

     { rule = { class = "libreoffice-calc" },
       properties = { screen = screens, tag = tags_name[6], switchtotag = true, floating = false } },

     { rule = { class = "libreoffice-impress" },
       properties = { screen = screens, tag = tags_name[6], switchtotag = true, floating = false } },

     { rule = { class = "Zathura" },
       properties = { screen = screens, tag = tags_name[6], switchtotag = true } },

     { rule = { class = "Leafpad" },
       properties = { floating = true, sticky = true, ontop = true } },

     { rule = { class = "Ristretto" },
       properties = { screen = screens, tag = tags_name[6], switchtotag = true } },

     { rule = { name = "news" },
       properties = { screen = screens, tag = tags_name[6], switchtotag = true } },

     -- 7:com - Communication
     { rule = { class = "Pidgin", role = "buddy_list" },
       properties = { screen = screens, tag = tags_name[7], switchtotag = true, floating = true, maximized = false },

       callback = function( c )
        local strutwidth = 200
        local w_area = screen[ c.screen ].workarea
        local cl_strut = c:struts()
        if c:isvisible() and cl_strut ~= nil and cl_strut.left > 0 then 
            c:geometry( { x= w_area.x - cl_strut.left, y = w_area.y, width=cl_strut.left } )
        else
            c:struts( { left = strutwidth, right=0 } )
            c:geometry({x = w_area.x, y = w_area.y, width = strutwidth})
        end
       end
     },
     
     { rule = { class = "Pidgin", role = "conversation" },
      properties = { screen = screens, tag = tags_name[7], switchtotag = true, floating = true, maximized = true } },
     
     { rule = { name = "irc" },
       properties = { screen = screens, tag = tags_name[7], switchtotag = true } },

    { rule = { instance = "crx_oliclofkahmgfbchdnaelnmcohjmceic" },
       properties = { screen = screens, tag = tags_name[7], switchtotag = true, floating=false } },

     -- 8:ent Entertainment
     { rule = { class = "Smplayer" },
       properties = { screen = screens, tag = tags_name[8], switchtotag = true } },

     { rule = { class = "Sonata" },
       properties = { screen = screens, tag = tags_name[8], switchtotag = true } },

     { rule = { instance = "crx_pfohnoakpeoeabclnomoejgnhakdkjbk" },
       properties = { screen = screens, tag = tags_name[8], switchtotag = true, floating=false } },

     { rule = { class = "Spotify" },
       properties = { screen = screens, tag = tags_name[8], switchtotag = true } },

     { rule = { name = "ncmpc" },
       properties = { screen = screens, tag = tags_name[8], switchtotag = true } },

     { rule = { class = "Deadbeef" },
       properties = { screen = screens, floating = true } },

    -- 9:vm Virtual Machines
     { rule = { class = "VirtualBox" },
       properties = { screen = screens, tag = tags_name[9], switchtotag = true } },

     { rule = { class = "Remmina" },
       properties = { screen = screens, tag = tags_name[9], switchtotag = true, maximized_vertical = true, maximized_horizontal = true } },

     { rule = { class = "sun-applet-PluginMain" },
       properties = { screen = screens, tag = tags_name[9], switchtotag = true } },
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
