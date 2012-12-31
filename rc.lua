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
-- Widget and layout library
local wibox = require("wibox")
-- Sysmon widget library
local vicious = require("vicious")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
-- Application menu
require('freedesktop.utils')
require('freedesktop.menu')

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
beautiful.init("/home/lorenzo/.config/awesome/themes/kiss/theme.lua")

-- This is used later as the default applications to run.
terminal = "urxvt"
browser = "chromium --disk-cache-dir=/tmp/.cache/chromium"
filemanager = "ranger"
filemanager_cmd = terminal .. " -name " .. filemanager .. " -e " .. filemanager
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -name " .. editor .. " -e " .. editor
geditor = "gvim"
email= "mutt"
email_cmd = terminal .. " -name " .. email .. " -e " .. email
news= "newsbeuter"
news_cmd = terminal .. " -name " .. news .. " -e " .. news 
music= "ncmpcpp"
music_cmd = terminal .. " -name " .. music .. " -e " .. music
media= "smplayer"
task= "htop"
task_cmd = terminal .. " -name " .. task .. " -e " .. task 
gtask= "lxtask"
irc="irssi"
irc_cmd= terminal .. " -name " .. irc .. " -e screen " .. irc
girc= "xchat"
jabber= "gajim"
--lock= "slock"
--single= "sh ~/bin/single.sh"
--dual= "sh ~/bin/dual-above.sh"
poweroff= "sudo poweroff"
reboot= "sudo reboot"

-- One line calendar command
onelinecal = [[ cal | tail -n +3 | sed -e "s/\<$(date +%-d)\>/\<span color=\"]] .. "#1994d1" .. [[\">&\<\/span>/" | sed 's/^[ \t]*//' | tr "\n" " "]]

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

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
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Function definitions
-- Custom widget for sys temp
function systemp()
    local fd = io.popen("sensors|grep SYSTIN|gawk '{print $2'}", "r")
    local temp = fd:read()
    io.close(fd)
    return temp
end
-- Custom widget for one line calendar
function cal()
    local fd = io.popen(onelinecal, "r")
    local cal = fd:read()
    io.close(fd)
    return cal
end	
-- }}}

-- {{{ Wallpaper
-- if beautiful.wallpaper then
--  for s = 1, screen.count() do
--     gears.wallpaper.maximized(beautiful.wallpaper, s, true)
--  end
--end

os.execute("find " .. beautiful.wallpaper_dir .. " -type f -print0 | shuf -n1 -z | xargs -0 feh --bg-scale")
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ "1:adm", "2:web", "3:com", "4:dev", "5:media"}, s, layouts[6])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

menu_items = freedesktop.menu.new()

mymainmenu = awful.menu({ items = { { "applications", menu_items },
                                    { "terminal", terminal },
                                    { "browser", browser },
                                    { "file manager", filemanager_cmd },
                                    { "editor", geditor },
                                    { "email", email_cmd },
                                    { "feed",  news_cmd },
                                    { "jabber", jabber },
                                    { "irc",  irc_cmd },
                                    { "music", music_cmd },
                                    { "media", media },
                                    { "tasks", gtask },
                                    { "awesome", myawesomemenu },
                                    { "reboot", reboot },
                                    { "poweroff", poweroff }
                                    }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock("%B %Y %H:%M")
mytextday = awful.widget.textclock("%A ")

-- Create an os widget
osicon = wibox.widget.imagebox()
osicon:set_image(beautiful.os)
oswidget = wibox.widget.textbox()
vicious.register(oswidget, vicious.widgets.os, "$1-$2")

-- Create an uptime widget
upicon = wibox.widget.imagebox()
upicon:set_image(beautiful.uptime)
upwidget =  wibox.widget.textbox()
vicious.register(upwidget, vicious.widgets.uptime, 
    function (widget, args)
      return string.format("%02d:%02d", args[2], args[3])
    end, 61)

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
        awful.button({ }, 1, function () awful.util.spawn(task_cmd) end)
 )
cpuicon:buttons(htopbuttons)
cpuwidget:buttons(htopbuttons)
ramicon:buttons(htopbuttons)
ramwidget:buttons(htopbuttons)

-- Create a temp widget
tempicon = wibox.widget.imagebox()
tempicon:set_image(beautiful.temp)
tempwidget = wibox.widget.textbox()

-- Create a fs widget
fsicon = wibox.widget.imagebox()
fsicon:set_image(beautiful.fs)
fswidget = wibox.widget.textbox()
vicious.register(fswidget, vicious.widgets.fs, " /: ${/ used_p}% ~: ${/home used_p}% var: ${/var used_p}%")

-- Create a fs button
fsbuttons = awful.util.table.join(
       awful.button({ }, 1, function () awful.util.spawn(filemanager) end)
 )
-- fsicon:buttons(fsbuttons)
fswidget:buttons(fsbuttons)

-- Create a net widget
neticon = wibox.widget.imagebox()
neticon:set_image(beautiful.net)
netwidget = wibox.widget.textbox()
vicious.register(netwidget, vicious.widgets.net, "${eth0 up_kb} kb/ ${eth0 down_kb} kb")

-- Create a mpd widget
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
        return  args["{Artist}"] .. " - " .. args["{Title}"]
      elseif args["{state}"] == "Pause" then
        mpdicon.visible = true
        return "paused"
      end
    end)
    
-- Create a mpd button
mpdbuttons = awful.util.table.join(
  awful.button({ }, 1, function () awful.util.spawn(music_cmd) end)
)
mpdicon:buttons(mpdbuttons)
mpdwidget:buttons(mpdbuttons)

-- Create a maildir widget
mdiricon = wibox.widget.imagebox()
mdiricon:set_image(beautiful.mail)
mdirwidget = wibox.widget.textbox()
vicious.register(mdirwidget, vicious.widgets.mdir, 
    function (widget, args)
       return string.format("%02d", args[1]+args[2]) 
    end, 600,  {'~/offlinemail/INBOX'})

-- Create a maildir button
mdirbuttons = awful.util.table.join(
        awful.button({ }, 1, function () awful.util.spawn(email_cmd) end)
)
mdiricon:buttons(mdirbuttons)
mdirwidget:buttons(mdirbuttons)

-- Create a calendar widget
calicon = wibox.widget.imagebox()
calicon:set_image(beautiful.cal)
calwidget = wibox.widget.textbox()

-- Create a battery widget
-- batterywidget = wibox.widget.textbox()
-- batteryicon:set_image(beautiful.bat)
-- vicious.register(batterywidget, vicious.widgets.bat, fg_widget .."$2 $1 |</span> ", 61, "BAT0")

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    right_layout:add(osicon)
    right_layout:add(oswidget)
    right_layout:add(upicon)
    right_layout:add(upwidget)
    right_layout:add(cpuicon)
    right_layout:add(cpuwidget)
    right_layout:add(ramicon)
    right_layout:add(ramwidget)
    right_layout:add(tempicon)
    right_layout:add(tempwidget)
    right_layout:add(fsicon)
    right_layout:add(fswidget)
    right_layout:add(neticon)
    right_layout:add(netwidget)
    right_layout:add(calicon)
    right_layout:add(mytextday)
    right_layout:add(calwidget)
    right_layout:add(mytextclock)
    right_layout:add(mdiricon)
    right_layout:add(mdirwidget)
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
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
    awful.key({ modkey,           }, "h",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "l",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey,           }, "o", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey,           }, "n", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "+",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "-",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "+",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "-",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "+",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "-",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end),

    -- Application launcher common
    awful.key({ modkey,         },"b", function () awful.util.spawn_with_shell(browser) end),
    awful.key({ modkey,         },"f", function () awful.util.spawn_with_shell(filemanager_cmd) end),
    awful.key({ modkey,         },"e", function () awful.util.spawn_with_shell(geditor) end),
    awful.key({ modkey,         },"m", function () awful.util.spawn_with_shell(email_cmd) end),
    awful.key({ modkey,         },"a", function () awful.util.spawn_with_shell(music_cmd) end),
    awful.key({ modkey,         },"v", function () awful.util.spawn_with_shell(media) end),
    awful.key({ modkey,         },"n", function () awful.util.spawn_with_shell(news_cmd) end),
    awful.key({ modkey,         },"i", function () awful.util.spawn_with_shell(irc) end),
    awful.key({ modkey,         },"g", function () awful.util.spawn_with_shell(jabber) end),
    awful.key({ modkey,         },"t", function () awful.util.spawn_with_shell(gtask) end),

    -- Application launcher extra
    awful.key({                   },"#152", function () awful.util.spawn_with_shell(terminal) end),
    awful.key({                   },"#180", function () awful.util.spawn_with_shell(browser) end),
    awful.key({                   },"#225", function () awful.util.spawn_with_shell(filemanager_cmd) end),
    awful.key({                   },"#181", function () awful.util.spawn_with_shell(editor) end),
    awful.key({                   },"#163", function () awful.util.spawn_with_shell(email_cmd) end),
    awful.key({                   },"#166", function () awful.util.spawn_with_shell(news_cmd) end),
    awful.key({                   },"#164", function () awful.util.spawn_with_shell(music_cmd) end),
    awful.key({                   },"#179", function () awful.util.spawn_with_shell(media) end),
    awful.key({                   },"#167", function () awful.util.spawn_with_shell(task) end),

    -- Multimedia keys
    awful.key({                   },"#122", function () awful.util.spawn_with_shell("amixer -q set Master 5- unmute") end),
    awful.key({                   },"#123", function () awful.util.spawn_with_shell("amixer -q set Master 5+ unmute") end),
    awful.key({                   },"#121", function () awful.util.spawn_with_shell("amixer -q set Master toggle") end),
    awful.key({                   },"#174", function () awful.util.spawn_with_shell("mpc stop") end),
    awful.key({                   },"#172", function () awful.util.spawn_with_shell("mpc toggle") end),
    awful.key({                   },"#173", function () awful.util.spawn_with_shell("mpc prev") end),
    awful.key({                   },"#171", function () awful.util.spawn_with_shell("mpc next") end)

)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber))
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },

 -- 1:admin Admin
     { rule = { class = "URxvt" },
       properties = { tag = tags[1][1], switchtotag = true } },

     { rule = { name = "ranger" },
       properties = { tag = tags[1][1], switchtotag = true } },

     { rule = { class = "File-roller" },
       properties = { tag = tags[1][1], switchtotag = true } },

     { rule = { class = "Lxtask" },
       properties = { tag = tags[1][1], switchtotag = true } },

     { rule = { instance = "htop" },
       properties = { tag = tags[1][1], switchtotag = true } },

     { rule = { class = "gFTP" },
       properties = { tag = tags[1][1], switchtotag = true } },  


     -- 2:web Web
     { rule = { class = "Chromium" },
       properties = { tag = tags[1][2], switchtotag = true, floating = false } },

     { rule = { instance = "links" },
       properties = { tag = tags[1][2], switchtotag = true } },

     { rule = { instance = "newsbeuter" },
       properties = { tag = tags[1][3], switchtotag = true } }, 

     { rule = { class = "fbreader" },
       properties = { tag = tags[1][2], switchtotag = true } },

     { rule = { class = "Zathura" },
       properties = { tag = tags[1][2], switchtotag = true } },


     -- 3:com - Communications
     { rule = { class = "Gajim", role = "roster" },
       properties = { tag = tags[1][3], switchtotag = true, floating = true } ,
       
       callback = function( c )
        local w_area = screen[ c.screen ].workarea
        local strutwidth = 200
        c:struts( { right = strutwidth } )
        c:geometry( { x = w_area.width, width = strutwidth, y = w_area.y + 15, height = w_area.height - 15 } )
      end
     },
     
     { rule = { class = "Gajim" },
      properties = { tag = tags[1][3], switchtotag = true } },
     
     { rule = { instance = "mutt" },
       properties = { tag = tags[1][3], switchtotag = true } },

     { rule = { class = "Xchat" },
       properties = { tag = tags[1][3], switchtotag = true } },
       
     { rule = { instance = "irssi" },
       properties = { tag = tags[1][3], switchtotag = true } }, 


     -- 4:dev - Development
     { rule = { class = "Gvim" },
       properties = { tag = tags[1][4], switchtotag = true } },

     { rule = { name = "LibreOffice" },
       properties = { tag = tags[1][4], switchtotag = true } },

     { rule = { name = "* - LibreOffice Writer" },
       properties = { tag = tags[1][4], switchtotag = true, floating = false } },

     { rule = { name = "* - LibreOffice Calc" },
       properties = { tag = tags[1][4], switchtotag = true, floating = false } }, 

     { rule = { name = "* - LibreOffice Impress" },
       properties = { tag = tags[1][4], switchtotag = true, floating = false } }, 


     -- 5:media - Multimedia
     { rule = { class = "Smplayer" },
       properties = { tag = tags[1][5], switchtotag = true } },    

     { rule = { instance = "ncmpcpp" },
       properties = { tag = tags[1][5], switchtotag = true } },

     { rule = { class = "Easytag" },
       properties = { tag = tags[1][5], switchtotag = true } },

     { rule = { class = "recorder" },
       properties = { tag = tags[1][5], switchtotag = true } },

}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = true
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local title = awful.titlebar.widget.titlewidget(c)
        title:buttons(awful.util.table.join(
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
                ))

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(title)

        awful.titlebar(c):set_widget(layout)
    end
end)

-- Timer for custom widget
tempwidget:set_text(systemp())
calwidget:set_markup(cal())

temptimer = timer({ timeout = 300 })
temptimer:connect_signal("timeout", function() tempwidget:set_text(systemp()) end)
temptimer:start()

caltimer = timer({ timeout =  300 })
caltimer:connect_signal("timeout", function() calwidget:set_markup(cal()) end)
caltimer:start()

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
