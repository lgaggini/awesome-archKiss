---------------------------
--   "archKiss" rc.lua   --
--      by lgaggini      --
--      CC BY-SA 3.0     --
---------------------------

-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
-- Sysmon widget library
require("vicious")
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
    awesome.add_signal("debug::error", function (err)
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
beautiful.init(awful.util.getdir("config") .. "/themes/kiss/theme.lua")
fg_widget = " <span color=\"" .. beautiful.fg_widget .. "\">"

-- This is used later as the default applications to run.
terminal = "urxvt"
browser = "chromium --disk-cache-dir=/tmp/.cache/chromium"
filemanager = "xfe"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor
geditor = "geany"
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
onelinecal = [[ cal | tail -n +3 | sed -e "s/\<$(date +%-d)\>/\<span color=\"]] .. beautiful.fg_widget .. [[\">&\<\/span>/" | sed 's/^[ \t]*//' | tr "\n" " "]]

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
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
    return fg_widget .. temp .. " | </span>"
end
-- Custom widget for one line calendar
function cal()
    local fd = io.popen(onelinecal, "r")
    local cal = fd:read()
    io.close(fd)
    return cal
end	
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
                                    { "file manager", filemanager },
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

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" }, fg_widget .. "%B %Y %H:%M | </span>")
mytextday = awful.widget.textclock({ align = "left" }, fg_widget .. "%A</span> ")

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create an os widget
osicon = widget({ type = "imagebox" })
osicon.image = image(beautiful.os)
oswidget = widget({ type = "textbox" })
vicious.register(oswidget, vicious.widgets.os, fg_widget .. "$3</span> on" .. fg_widget .. "$1-$2 | </span>")

-- Create an uptime widget
upicon = widget({ type = "imagebox" })
upicon.image = image(beautiful.uptime)
upwidget = widget({ type = "textbox" })
vicious.register(upwidget, vicious.widgets.uptime, 
    function (widget, args)
        return string.format(fg_widget .. "%02d:%02d | </span>", args[2], args[3])
    end, 61)

-- Create a cpu widget
cpuicon = widget({ type = "imagebox" })
cpuicon.image = image(beautiful.cpu)
cpuwidget = widget({ type = "textbox" })
vicious.register(cpuwidget, vicious.widgets.cpu, fg_widget .. "$1% | </span>")

-- Create a ram widget
ramicon = widget({ type = "imagebox" })
ramicon.image = image(beautiful.ram)
ramwidget = widget({ type = "textbox" })
vicious.register(ramwidget, vicious.widgets.mem, fg_widget .. "$1% | </span>")

-- Create an htop button
htopbuttons = awful.util.table.join(
        awful.button({ }, 1, function () awful.util.spawn(task_cmd) end)
)
cpuicon:buttons(htopbuttons)
cpuwidget:buttons(htopbuttons)
ramicon:buttons(htopbuttons)
ramwidget:buttons(htopbuttons)

-- Create a temp widget
tempicon = widget({ type = "imagebox" })
tempicon.image = image(beautiful.temp)
tempwidget = widget({ type = "textbox" })

-- Create a fs widget
fsicon = widget({ type = "imagebox" })
fsicon.image = image(beautiful.fs)
fswidget = widget({ type = "textbox" })
vicious.register(fswidget, vicious.widgets.fs, " /:" .. fg_widget .. "${/ used_p}%</span> ~:" .. fg_widget .. "${/home used_p}%</span> var:" .. fg_widget .. "${/var used_p}% | </span>")

-- Create a fs button
fsbuttons = awful.util.table.join(
        awful.button({ }, 1, function () awful.util.spawn(filemanager) end)
)
fsicon:buttons(fsbuttons)
fswidget:buttons(fsbuttons)

-- Create a net widget
neticon = widget({ type = "imagebox" })
neticon.image = image(beautiful.net)
netwidget = widget({ type = "textbox" })
vicious.register(netwidget, vicious.widgets.net, fg_widget .. "${eth0 up_kb}</span> kb/ " .. fg_widget .. "${eth0 down_kb}</span> kb " .. fg_widget .. "| </span> ")

-- Create a mpd widget
mpdicon = widget({ type = "imagebox" })
mpdicon.image = image(beautiful.music)
mpdwidget = widget({ type = "textbox" })
vicious.register(mpdwidget, vicious.widgets.mpd, 
    function (widget, args)
        if args["{state}"] == "Stop" then
            mpdicon.visible = false
            return ""
        elseif args["{state}"] == "Play" then
            mpdicon.visible = true
            return fg_widget .. args["{Artist}"] .. " - " .. args["{Title}"] .. " | </span>"
        elseif args["{state}"] == "Pause" then
            mpdicon.visible = true
            return fg_widget .. "paused | </span>"
        end
    end)
    
-- Create a mpd button
mpdbuttons = awful.util.table.join(
        awful.button({ }, 1, function () awful.util.spawn(music_cmd) end)
)
mpdicon:buttons(mpdbuttons)
mpdwidget:buttons(mpdbuttons)

-- Create a maildir widget
mdiricon = widget({ type = "imagebox" })
mdiricon.image = image(beautiful.mail)
mdirwidget = widget({ type = "textbox" })
vicious.register(mdirwidget, vicious.widgets.mdir, 
    function (widget, args)
        return string.format(fg_widget .. "%02d | </span>", args[1]+args[2]) 
    end, 600,  {'~/offlinemail/INBOX'})

-- Create a maildir button
mdirbuttons = awful.util.table.join(
        awful.button({ }, 1, function () awful.util.spawn(email_cmd) end)
)
mdiricon:buttons(mdirbuttons)
mdirwidget:buttons(mdirbuttons)

-- Create a calendar widget
calicon = widget({ type = "imagebox" })
calicon.image = image(beautiful.cal)
calwidget = widget({ type = "textbox" })

-- Create a battery widget
-- batterywidget = widget({ type = "textbox" })
-- batteryicon.image = image(beautiful.bat)
-- vicious.register(batterywidget, vicious.widgets.bat, fg_widget .."$2 $1 |</span> ", 61, "BAT0")

-- Create a wibox for each screen and add it
mywibox = {}
mywiboxtasks = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
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
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
       -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        s == 1 and mysystray or nil,
        mdirwidget,
        mdiricon,
        mytextclock,
        calwidget,
        mytextday,
        calicon,
        netwidget,
        neticon,
        fswidget,
        fsicon,
        tempwidget,
        tempicon,
        ramwidget,
        ramicon,
        cpuwidget,
        cpuicon,
        upwidget,
        upicon,
        mpdwidget,
        mpdicon,
        oswidget,
        osicon,
        -- mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
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
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
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
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
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

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
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

    -- Application launcher common
    awful.key({ modkey,         },"b", function () awful.util.spawn_with_shell(browser) end),
    awful.key({ modkey,         },"f", function () awful.util.spawn_with_shell(filemanager) end),
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
    awful.key({                   },"#225", function () awful.util.spawn_with_shell(filemanager) end),
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
    awful.key({ modkey, "Shift"   }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey, "Shift"   }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey, "Shift"   }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
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
    awful.button({ }, 1, function (c) client.focus = c; c:raise(); mymainmenu:hide() end),
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
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     size_hints_honor = false
                   }},
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

     { rule = { class = "Xfe" },
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

     { rule = { class = "epdfiew" },
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
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
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
end)

-- Timer for custom widget
tempwidget.text = systemp()
calwidget.text = cal()

temptimer = timer({ timeout = 300 })
temptimer:add_signal("timeout", function() tempwidget.text = systemp() end)
temptimer:start()

caltimer = timer({ timeout =  300 })
caltimer:add_signal("timeout", function() calwidget.text = cal() end)
caltimer:start()

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- Autorun programs at startup
