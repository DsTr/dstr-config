-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
require("awful.util")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
require("vicious")
require('calendar2')
-- require("inotify")

-- Themes define colours, icons, and wallpapers
beautiful.init("/usr/share/awesome/themes/default/theme.lua")

nodename = awful.util.pread('uname -n')

--require('delightful.widgets.weather')
--require('delightful.widgets.cpu')
--require('delightful.widgets.memory')
--require('delightful.widgets.network')
--install_delightful = {
			--delightful.widgets.network,
			--delightful.widgets.cpu,
			--delightful.widgets.memory,
----		    delightful.widgets.weather,
----		    delightful.widgets.battery,
----		    delightful.widgets.pulseaudio,
----		    delightful.widgets.datetime
--}

--delightful_config = {
    --[delightful.widgets.cpu] = {
        --command = 'gnome-system-monitor',
    --},

    --[delightful.widgets.memory] = {
        --command = 'gnome-system-monitor',
    --},
    ----[delightful.widgets.weather] = {
        ----{
			----station_code = 'ULLI',
            ----command = 'gnome-www-browser http://pogoda.yandex.ru',
        ----},
    ----},
--}

if nodename:find('netbook') then
	require('delightful.widgets.battery')
	install_delightful[4] = delightful.widgets.battery 
	delightful_config[delightful.widgets.battery] = {battery = 'BAT0'}
end

-- Prepare the container that is used when constructing the wibox
--local delightful_container = { widgets = {}, icons = {} }
--if install_delightful then
    --for _, widget in pairs(awful.util.table.reverse(install_delightful)) do
        --local config = delightful_config and delightful_config[widget]
        --local widgets, icons = widget:load(config)
        --if widgets then
            --if not icons then
                --icons = {}
            --end
            --table.insert(delightful_container.widgets, awful.util.table.reverse(widgets))
            --table.insert(delightful_container.icons,   awful.util.table.reverse(icons))
        --end
    --end
--end

-- {{{ Variable definitions

-- where can be 'left' 'right' 'center' nil
function client_snap(c, where, geom)
    local sg = screen[c.screen].geometry
    local cg = geom or c:geometry()
    local cs = c:struts()
    cs['left'] = 0
    cs['top'] = 0
    cs['bottom'] = 0
    cs['right'] = 0
    if where == 'right' then
        cg.x = sg.width - cg.width
        cs[where] = cg.width
        c:struts(cs)
        c:geometry(cg)
    elseif where == 'left' then
        cg.x = 0
        cs[where] = cg.width
        c:struts(cs)
        c:geometry(cg)
    elseif where == 'bottom' then
        awful.placement.centered(c)
        cg = c:geometry()
        cg.y = sg.height - cg.height - beautiful.wibox_bottom_height
        cs[where] = cg.height + beautiful.wibox_bottom_height
        c:struts(cs)
        c:geometry(cg)
    elseif where == nil then
        c:struts(cs)
        c:geometry(cg)
    elseif where == 'center' then
        c:struts(cs)
        awful.placement.centered(c)
    else
        return
    end
end
-- {{{ functions to help launch run commands in a terminal using ":" keyword 
function check_for_terminal (command)
   if command:sub(1,1) == ":" then
      command = terminal .. ' -e ' .. command:sub(2)
   end
   awful.util.spawn(command)
end
   
function clean_for_completion (command, cur_pos, ncomp, shell)
   local term = false
   if command:sub(1,1) == ":" then
      term = true
      command = command:sub(2)
      cur_pos = cur_pos - 1
   end
   command, cur_pos =  awful.completion.shell(command, cur_pos,ncomp,shell)
   if term == true then
      command = ':' .. command
      cur_pos = cur_pos + 1
   end
   return command, cur_pos
end
-- }}}
--{{{ Debug
function dbg(vars)
local text = ""
for i=1, #vars-1 do text = text .. tostring(vars[i]) .. " | " end
text = text .. tostring(vars[#vars])
naughty.notify({ text = text, timeout = 10 })
end

function dbg_client(c)
local text = ""
if c.class then
text = text .. "Class: " .. c.class .. " "
end
if c.instance then
text = text .. "Instance: ".. c.instance .. " "
end
if c.role then
text = text .. "Role: ".. c.role .. " "
end
if c.type then
text = text .. "Type: ".. c.type .. " "
end

text = text .. "Full name: '" .. client_name(c) .. "'"

dbg({text})
end
--}}}

-- This is used later as the default terminal and editor to run.
terminal = "xterm"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

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
  --  awful.layout.suit.tile.left,
  --  awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
  --  awful.layout.suit.fair,
  --  awful.layout.suit.fair.horizontal,
  --  awful.layout.suit.spiral,
  --  awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
  --  awful.layout.suit.max.fullscreen,
  --  awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
deflayout = awful.layout.suit.floating
if nodename:find('netbook') then

	deflayout = awful.layout.suit.max
end
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ "term", "dev", "inet", "im", 5, "study", "VB", "AV", "VoIP" }, s, deflayout)
end

-- IM Tag sessings:
-- awful.tag.setmwfact(0.2, tags[1][2])
-- awful.tag.setproperty(tags[1][2], 'layout', awful.layout.suit.tile)
--awful.tag.setncol(2, tags[1][2])
--awful.tag.setnmaster (1, tags[1][2])


awful.tag.setproperty(tags[1][1], 'layout', layouts[2])       -- MAIN tile
awful.tag.setproperty(tags[1][3], 'layout', layouts[4])       -- WEB MAX
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" })
calendar2.addCalendarToWidget(mytextclock, "<span color='green'>%s</span>")

-- Create a systray
mysystray = widget({ type = "systray" })

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
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
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

cpuwidget = awful.widget.graph()
-- Graph properties
cpuwidget:set_width(50)
cpuwidget:set_background_color("#494B4F")
cpuwidget:set_color("#FF5656")
cpuwidget:set_gradient_colors({ "#FF5656", "#88A175", "#AECF96" })
-- Register widget
vicious.register(cpuwidget, vicious.widgets.cpu, "$1")


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
	--mywibox[s].widgets = {
		--{
			--mylauncher,
			--mytaglist[s],
			--mypromptbox[s],
			--layout = awful.widget.layout.horizontal.leftright
		--},
		--mylayoutbox[s],
		--cpuwindget,
		--mytextclock,
		--s == 1 and mysystray or nil,
		--mytasklist[s],
		--layout = awful.widget.layout.horizontal.rightleft
	--}


local widgets_front = {
	{
		mylauncher,
		mytaglist[s],
		mypromptbox[s],
		layout = awful.widget.layout.horizontal.leftright
	},
	mylayoutbox[s],
}
local widgets_middle = {}
for delightful_container_index, delightful_container_data in pairs(delightful_container.widgets) do
	for widget_index, widget_data in pairs(delightful_container_data) do
		table.insert(widgets_middle, widget_data)
		if delightful_container.icons[delightful_container_index] and delightful_container.icons[delightful_container_index][widget_index] then
			table.insert(widgets_middle, delightful_container.icons[delightful_container_index][widget_index])
		end
	end
end
local widgets_end = {
	mytextclock,
	s == 1 and mysystray or nil,
	mytasklist[s],
	layout = awful.widget.layout.horizontal.rightleft
}
mywibox[s].widgets = awful.util.table.join(widgets_front, widgets_middle, widgets_end)

end
-- }}}


-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
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

    -- Prompt
    awful.key({ modkey }, "a", function ()
    awful.prompt.run({ prompt = "Calculate: " }, mypromptbox[mouse.screen].widget,
        function (expr)
		    local cal = awful.util.pread("/usr/bin/calc '" .. expr .. "'")
            naughty.notify({ text = expr .. " = " ..  cal, timeout = 30 })
        end)
  end),
 awful.key({ modkey,           }, "s", function ()
        awful.prompt.run({ prompt = "ssh: " },
        mypromptbox[mouse.screen].widget,
        function(h)
                awful.util.spawn(terminal .. " -e ssh " .. h)
        end,
        function(cmd, cur_pos, ncomp)
                -- get the hosts
                local hosts = {}
                f = io.popen('cut -d " " -f1 ' .. os.getenv("HOME") ..  '/.ssh/known_hosts | cut -d, -f1')
                for host in f:lines() do
                        table.insert(hosts, host)
                end
                f:close()
                -- abort completion under certain circumstances
                if #cmd == 0 or (cur_pos ~= #cmd + 1 and cmd:sub(cur_pos, cur_pos) ~= " ") then
                        return cmd, cur_pos
                end
                -- match
                local matches = {}
                table.foreach(hosts, function(x)
                        if hosts[x]:find("^" .. cmd:sub(1,cur_pos)) then
                                table.insert(matches, hosts[x])
                        end
                end)
                -- if there are no matches
                if #matches == 0 then
                        return
                end
                -- cycle
                while ncomp > #matches do
                        ncomp = ncomp - #matches
                end
                -- return match and position
                return matches[ncomp], cur_pos
        end,
        awful.util.getdir("cache") .. "/ssh_history")
end),   

   -- awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),
   awful.key({ modkey,           }, "r", 
              function () awful.prompt.run({prompt="Старт:"},
                                           mypromptbox[mouse.screen].widget,
                                           check_for_terminal,
                                           clean_for_completion,
                                           awful.util.getdir("cache") .. "/history") end), 
   awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Запустить ЛУА код: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ altkey }, "F6", function (c) 
        dbg_client(c) 
    end),
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey,           }, "m",
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
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
	{ rule = { class = "psi" },
	  properties = { tag = tags[1][4] } },
	{ rule = { instance = "psi-plus" },
	  properties = { tag = tags[1][4] } },
	{ rule = { instance = "psi" },
	  properties = { tag = tags[1][4] } },
	{ rule = { class = "Qutim" },
	    properties = { tag = tags[1][4] } },
    { rule = { class = "Firefox" },
     properties = { tag = tags[1][3] } },
    { rule = { class = "Skype" },
     properties = { tag = tags[1][9] } },
	 -- Multimedia to AV tag --------
    { rule = { class = "Deadbeef" },
     properties = { tag = tags[1][8], floating = true } },
    { rule = { instance = "smplayer" },
     properties = { tag = tags[1][8], switchtotag = true, floating = true } },
    { rule = { instance = "vlc" },
     properties = { tag = tags[1][8], switchtotag = true, floating = true } },
	 -------------------------------
    { rule = { class = "VirtualBox" },
     properties = { tag = tags[1][7], floating = true } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

	-- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

	 selectedTagName = awful.tag.selected(1).name
	 if c.instance == "urxvt" and not (selectedTagName:find("dev") or selectedTagName:find("main"))	then
        awful.client.floating.set(c, true)
--		awful.placement.under_mouse (c)
--		awful.placement.no_offscreen (c)
	 end
	 --if c.instance == "evince" and selectedTagName:find("main")	then
        --awful.client.floating.set(c, true)
	 --end

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
	 --if not ( c.instance == "main" or c.instance == "psi" or c.instance == "psi-plus" ) and c.class == "psi" then
		--awful.client.setslave(c)
	 --end
				  
	 --if c.class == "Qutim" and not c.role:find("contactlist") then
		--awful.client.setslave(c)
	 --end
			   			
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

