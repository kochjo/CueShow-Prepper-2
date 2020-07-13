-- ***********************************
-- CREATED AND DEVELOPED BY JONAS KOCH
-- ***********************************
--          Version 1.0.2
-- ***********************************

--********************************************************--
-- *************** Initialize Variables ***************** --
--********************************************************--

local cmd            = function(syntax, ...) gma.cmd(syntax:format(...)) end  -- [function] a shortcut to gma.cmd in combination with string.format
local exec                                                                    -- [int]      (only multi page) the executor on each songpage, containing the song cuelist
local get_handle     = gma.show.getobj.handle
local main_page                                                               -- [int]      executor page with the main menu
local main_seq                                                                -- [int]      sequence for the main menu executor
local nextm                                                                   -- [int]      pool index of the CSP2-NEXT Macro
local NEXT_NAME      = "NEXT_CSP2"                                            -- [str]      name of the CSP2-NEXT Macro
local remom                                                                   -- [int]      pool index of the CSP2-REMOVE Macro
local resetm                                                                  -- [int]      pool index of the CSP2-RESET Macro
local songs          = {}                                                     -- [table]    Containing the name and the number of cues for each song
local starting_page                                                           -- [int]      pool index of the fist song executor page
local STD_CUES       = 5                                                      -- [int]      standart number of cues stored to a song sequence if no other input is given by the user
local HOST_TYPE      = gma.show.getvar("OS")                                  -- [str]      name of the operating system

--********************************************************--
-- ********************* START CODE ********************* --
--********************************************************--

function fits_condition(condition, inputheader, errorheader)
    --[[
        Returns userinput if it fits 'cond'. Otherwise it requests a new input.
        inputheader  = str;
        errorheader  = str;
        returns: userinput
    ]]
    if inputheader == nil then inputheader = 'Enter information.' end
    if errorheader == nil then errorheader = 'Condition not fulfilled. Try again.' end
    local cond, err = load('return function(input) if '..condition..' then return true end end')
    if err then return end
    local input = gma.textinput(inputheader)
    input = tonumber(input)
    if cond()(input) then
        return input
    end
    return fits_condition(condition, errorheader, errorheader)
end

function split(string, symbol, i)
    --[[
        Splits 'string' into two str separated by 'symbol'.
        string = str;
        symbol = str;
        i      = int;
        returns: str, str
    ]]
    local border1, border2 = string:find(symbol)
    if border1 ~= nil then 
        local songname          = string:sub(1,border1-1)
        local amount_of_cues    = string:sub(border2+1)
        if not has_content(songname) then songname = "Song "..i end
        amount_of_cues    = tonumber(amount_of_cues:sub(amount_of_cues:find("%d*")))
        if amount_of_cues == nil then amount_of_cues = STD_CUES end
        return songname, amount_of_cues
    else
        if not has_content(string) then string = "Song "..i end
        return string, STD_CUES
    end
end

function has_content(string)
    --[[
        Returns true if string contains any alphanumeric signs, digits or punctuation.
        string = str;
        returns: bool
    ]]
    local line = string:find('%a')
    if line == nil then
        line = string:find('%d')
        if line == nil then
            line = string:find('%p')
            if line == nil then
                return false
            end
        end
    end
    return true
end

function manual_setlist_input()
    --[[
        Adds userinput to the songs table.
        returns: int
    ]]
    local songname
    local cues
    local amount = fits_condition('type(input)=="number" and input>0', "How many Songs?", "Number of songs must be a natural number.")
    for i = 1, amount do
        local input = gma.textinput("Enter songname "..i.." of "..amount,"")
        songname, cues = split(input, ";;;", i)
        songs[i] = {
            name = songname,
            cues = cues,
            }
    end
    return #songs
end

function pathfinder(OpSys, filename, path, first_flag)
    --[[
        Searches for the filepath of the given filename.
        Returns file object if successive, otherwise returns false.
        OpSys      = str;
        filename   = str;
        path       = str;
        first_flag = bool;
        returns: file object or false
    ]]
    local file
    local checkpath = path
    if OpSys == "WINDOWS" then
        if path == nil then checkpath = gma.show.getvar("pluginpath").."/"..filename end
        file = io.open(checkpath)
        if (file == nil and first_time_flag == true) then
            local user = os.getenv("username")
            checkpath = "C:\\\\Users\\\\"..user.."\\\\Desktop\\\\"..filename
            file = io.open(checkpath)
        end
    elseif OpSys == "LINUX" then
        if path == nil then checkpath = "/media/sdb/gma2/plugins/"..filename end
        file = io.open(checkpath)
        if (file == nil and first_time_flag == true) then
            checkpath = "/media/sdb1/gma2/plugins/"..filename
            file = io.open(checkpath)
            if (file == nil and first_time_flag == true) then
                checkpath = "/media/sdc1/gma2/plugins/"..filename
                file = io.open(checkpath)
            end
        end
    else
        gma.gui.msgbox("ERROR","Hosttype error. Hosttype is: "..OpSys)
        return false
    end
    if file == nil then
        local input = gma.textinput("File not found! Choose between:","1 = other filename, 2 = userdefined path, 3(default) = manual setlist input")
        if input == "1" then
            local newname = gma.textinput("Enter filename (excl. suffix):","")..".txt"
            return pathfinder(OpSys, newname, path, true)
        elseif input == "2" then
            local newpath = gma.textinput("Enter own path (excl. filename):",path)
            return pathfinder(OpSys, filename, newpath)
        else
            return false
        end
    end
    return file
end

function import_setlist(setlist)
    --[[
        Reads the given file object and adds each line as a song to the songs table.
        Returns the number of songs.
        setlist = str;
        returns: int
    ]]
    local songname
    local number_of_cues
    local i = 1
    if not setlist then return manual_setlist_input() end
    io.input(setlist)
    while true do
        local read = io.read()
        if read ~= nil then
            if has_content(read) then
                songname, number_of_cues = split(read, ";;;", i)
                songs[i] = {
                    name = songname,
                    cues = number_of_cues,
                    }
                i = i+1
            end
        else
            if #songs == 0 then
                gma.gui.msgbox("Empty File","The file you chose is empty.\n Go ahead with manual setlist input.")
                return manual_setlist_input()
            else
                return #songs
            end
        end
    end
end

function handlesearcher(start,amount,target)
    --[[
        Searches for 'amount' consecutive free slots in 'target', beginning at index 'start'.
        Returns the first matching pool/preset index.
        start  = int;
        amount = int;
        target = str;
        returns: int
    ]]
    if (target == "Page" and not get_handle("Page 101")) then
        pagegenerator(100)
    end
    local i = 0
    while true do
        local target = string.format("%s 1.%i", target, start)
        local handle1 = get_handle(target)
        if not handle1 then
            for j = start, start+amount-1 do
                local multitarget = string.format("%s 1.%i", target, j)
                local multihandle = get_handle(multitarget)
                if not multihandle then
                    i = i + 1
                else
                    i = 0
                    break
                end
                if i >= amount then
                    if target == "Page" then
                        cmd('page '..start..'; del page '..start-1)
                    end
                    return start
                end
            end
        end
        start = start+1
    end
end

function pagegenerator(amount)
    --[[
        Generates 'amount' executorpages beginning from page 1.
        returns: IS VOID
    ]]
    for i = 1, amount do
        cmd('page %i', i)
    end
    for i = amount, 1, -1 do
        local Page = string.format("Executor %i.*", i)
        if not get_handle(Page) then
            cmd('del Page %i', i)
        end
    end
end

function Cuelist_generator_CSP(primalseq, plugin_version, amount_of_songs, starting_page)
    --[[
        Creates the song sequences and assigns them.
        primalseq       = int;
        plugin_version  = str;
        amount_of_songs = int;
        starting_page   = int;
        returns: IS VOID
    ]]
    local curexec     = 1
    local seq_counter = primalseq
    if plugin_version == 1 then exec = fits_condition('type(input)=="number" and input>0', "Which Executor?", "Exec number must be a natural number.") end
    for i = 1, amount_of_songs-1 do
        local song = songs[i]
        if plugin_version == 1 then
            cmd('page %i', starting_page + i)
            cmd('store seq %i Cue 0.1 "PrepCue" /o; Store seq %i Cue 999 "NEXT" /o', seq_counter, seq_counter)
            cmd('Assign seq %i At Executor %i; Assign Executor %i Cue 999 /cmd= "Macro 1.%s"', seq_counter, exec, exec, NEXT_NAME)
            cmd('Appearance seq %i Cue 0.1 /r=0 /g=50 /b=100; Appearance seq %i Cue 999 /r=100 /g=25 /b=0', seq_counter, seq_counter)
            cmd('store seq %i Cue %i thru %i /nc', seq_counter, 1, song.cues)
            cmd('Assign Executor %i /Priority = "Normal";  Assign Go ExecButton1 %i;  Assign GoBack ExecButton2 %i;  Assign Black ExecButton3 %i', exec, exec, exec, exec)
            cmd('Label Executor %i "%s"; Label Page %i "%s"', exec, song.name, i, song.name)
        elseif plugin_version == 2 then
            cmd('store seq %i Cue 0.1 "PrepCue" /o; Store seq %i Cue 999 "NEXT" /o', seq_counter, seq_counter)
            cmd('Assign seq %i At Executor %i; Assign Executor %i Cue 999 /cmd= "Macro 1.%s"', seq_counter, curexec, curexec, NEXT_NAME)
            cmd('Appearance seq %i Cue 0.1 /r=0 /g=50 /b=100; Appearance seq %i Cue 999 /r=100 /g=25 /b=0', seq_counter, seq_counter)
            cmd('store seq %i Cue %i thru %i /nc', seq_counter, 1, song.cues)
            cmd('Assign Executor %i /Priority = "Normal";  Assign Go ExecButton1 %i;  Assign GoBack ExecButton2 %i;  Assign Black ExecButton3 %i', curexec, curexec, curexec, curexec)
            cmd('Label Executor %i "%s"', curexec, song.name)
        else
            gma.echo("plugin_version Error in Cuelist_generator_CSP|1")
        end
        seq_counter = seq_counter + 1
        curexec     = curexec + 1
    end
    local finalseq = seq_counter - 1
    if plugin_version == 1 then
        cmd('page %i; appearance seq %i thru %i /r=0 /g=50 /b=100 /nc', starting_page, primalseq, finalseq)
        cmd('Select Executor %i; Appearance Executor %i /r=100 /g=100 /b=100 /nc', exec, exec)
    elseif plugin_version == 2 then
        cmd('setus $curexec = 1')
        cmd('appearance seq %i thru %i /r=0 /g=50 /b=100 /nc', primalseq, finalseq)
        cmd('Select Executor 1; Appearance Executor 1 /r=100 /g=100 /b=100 /nc')
        cmd('setus $songpage = "Page %i"', starting_page)
    end
    cmd('del seq %i /nc; del page %i /nc', main_seq, main_page)
end

function CSPnext(plugin_version)
    --[[
        Creates the CSP2_NEXT-Macro
        plugin_version = str;
        returns: IS VOID
    ]]
    local linecmd = string.format("assign macro 1.%i.", nextm)
    cmd('store macro 1.%i; store macro 1.%i.1 thru 5; label macro 1.%i "%s"', nextm, nextm, nextm, NEXT_NAME)
    if plugin_version == 1 then
        cmd('%s 1 /cmd="Off exec %i"', linecmd, exec)
        cmd('%s 2 /cmd="Appearance exec %i /r=100 /g=0 /b=0"', linecmd, exec)
        cmd('%s 3 /cmd="page +"', linecmd)
        cmd('%s 4 /cmd="sel exec %i; appearance exec %i /r=100 /g=100 /b=100 /nc"', linecmd, exec, exec)
        cmd('%s 5 /cmd="Go exec %i"', linecmd, exec)
    else
        cmd('store macro 1.%i; store macro 1.%i.1 thru 5; label macro 1.%i "%s"', nextm, nextm, nextm, NEXT_NAME)
        cmd('%s 1 /cmd="Off exec $curexec"', linecmd)
        cmd('%s 2 /cmd="Appearance exec $curexec /r=100 /g=0 /b=0"', linecmd)
        cmd('%s 3 /cmd="addus $curexec = 1"', linecmd)
        cmd('%s 4 /cmd="sel exec $curexec; appearance exec $curexec /r=100 /g=100 /b=100 /nc"', linecmd)
        cmd('%s 5 /cmd="Go exec $curexec"', linecmd)
    end
    gma.echo("NEXT Macro stored at Macro " .. nextm)
end

function CSPrest(amount_of_songs, primalseq, plugin_version)
    --[[
        Creates CSP2_RESET Macro with 'primalseq' as the first song sequence and 'plugin_version' for Multi Page or Single Page mode.
        primalseq      = int;
        finalseq       = int;
        plugin_version = str;
        returns: IS VOID
    ]]
    local finalseq = primalseq + amount_of_songs-1
    local linecmd = string.format("assign macro 1.%i.", resetm)
    cmd('store macro 1.%i; store macro 1.%i.1 thru 5; label macro 1.%i "RESET_CSP2"', resetm, resetm, resetm)
    if plugin_version == 1 then
        cmd('%s 1 /cmd="SetUserVar $csp2reset = %i;  AddUserVar $csp2reset = (Starting Point?)"', linecmd, starting_page-1)
        cmd('%s 2 /cmd="Page $csp2reset"', linecmd)
        cmd('%s 3 /cmd="Appearance Sequence %i thru %i /r=0 /g=50 /b=100"', linecmd, primalseq, finalseq)
        cmd('%s 4 /cmd="Sel exec %i; Appearance Exec %i /r=100 /g=100 /b=100 /nc"', linecmd, exec, exec)
        cmd('%s 5 /cmd="Kill exec %i"', linecmd, exec)
    else
        cmd('store macro 1.%i; store macro 1.%i.1 thru 4; label macro 1.%i "RESET_CSP2"', resetm, resetm, resetm)
        cmd('%s 1 /cmd="setus $curexec = (Starting Point?)"', linecmd)
        cmd('%s 2 /cmd="Appearance Sequence %i thru %i /r=0 /g=50 /b=100"', linecmd, primalseq, finalseq)
        cmd('%s 3 /cmd="Sel exec $curexec; Appearance Exec $curexec /r=100 /g=100 /b=100 /nc"', linecmd)
        cmd('%s 4 /cmd="Kill exec $curexec"', linecmd)
    end
    gma.echo("RESET Macro stored at Macro " .. resetm)
end

function CSPrem(amount_of_songs, primalseq, plugin_version, starting_page)
    --[[
        Creates the CSP2_REMOVE-Macro with 'primalseq' as the first song sequence and 'amount_of_pages' as the number of executorpages.
        'plugin_version' indicates wether it's Single - or Multi Page mode.
        amount_of_songs = int;
        primalseq       = int;
        plugin_version  = str;
        starting_page   = int;
        returns: IS VOID
    ]]
    local finalseq = primalseq + amount_of_songs-1
    local linecmd  = string.format("assign macro 1.%i.", remom)
    cmd('store macro 1.%i; store macro 1.%i.1 thru 9; label macro 1.%i "REMOVE_CSP2"', remom, remom, remom)
    cmd('%s 1 /cmd="SetUserVar $answer = (Are you shure? Continue by typing 1)"', linecmd)
    cmd('%s 2 /cmd="[$answer == 1] Macro 1.REMOVE_CSP2.4"', linecmd)
    cmd('%s 3 /cmd="Off Macro 1.REMOVE_PrepCues" /wait="go"', linecmd)        
    cmd('%s 4 /cmd="Delete Sequence %i Thru %i /nc"', linecmd, primalseq, finalseq)
    cmd('%s 5 /cmd="Delete Sequence %i /nc; Delete Page %i /nc"', linecmd, main_seq, main_page)
    cmd('%s 6 /cmd="Page 1"', linecmd)
    if plugin_version == 1 then
        cmd('%s 7 /cmd="Delete Page %i Thru %i"', linecmd, starting_page, starting_page + amount_of_songs-1)
        cmd('%s 8 /cmd="SetUserVar $answer ="', linecmd)
        cmd('%s 9 /cmd="Delete Macro 1.NEXT_CSP2; del Macro 1.RESET_CSP2; del Macro 1.REMOVE_CSP2"', linecmd)
    else
        cmd('%s 7 /cmd="Delete Page %i"', linecmd, starting_page)
        cmd('%s 8 /cmd="SetUserVar $answer =; SetUserVar $curexec ="', linecmd)
        cmd('%s 9 /cmd="Delete Macro 1.NEXT_CSP2; del Macro 1.RESET_CSP2; del Macro 1.REMOVE_CSP2"', linecmd)
    end
    gma.echo("REMOVE Macro stored at Macro " .. remom)
end

function userfeedback(primalseq)
    --[[
        Prints the most important informations about created objects.
        primalseq = int;
        returns: IS VOID
    ]]
    gma.echo("\n CueShow Prepper successfully accomplished. \n \n ********************* \n created by Jonas Koch \n *********************")
    gma.feedback("\n You can find \n - the plugin related Macros at "..nextm..", "..resetm..", "..remom..". \n - the song-cuelists from sequence "..primalseq.." upwards. \n - the song-page(s) from page "..starting_page.." upwards.")
    gma.gui.msgbox("INFO","You can find \n - the plugin related Macros at "..nextm..", "..resetm..", "..remom..". \n - the song-cuelists from sequence "..primalseq.." upwards. \n - the song-pages from page "..starting_page.." upwards.")
end

function CSP(ui_choice)
    --[[
        Is the main function of the plugin. It runs the necessary functions.
        'ui_choice' represents the single - or multi page mode.
        ui_choice = str;
        returns: IS VOID
    ]]
    local setlist         = gma.textinput("Enter the filename EXCLUDING suffix ('.txt').","")..".txt"
    local file            = pathfinder(HOST_TYPE, setlist, nil, true)
    local amount_of_songs = import_setlist(file)
    local amount_of_pages = (ui_choice == 1 and amount_of_songs or 1)
    local starting_page   = handlesearcher(101, amount_of_pages, "Page")
    local seq             = handlesearcher(101, amount_of_songs, "Sequence")
    local finalseq        = Cuelist_generator_CSP(seq, ui_choice, amount_of_songs, starting_page)
    nextm                 = handlesearcher(1, 3, "Macro")
    resetm                = nextm + 1
    remom                 = nextm + 2
    CSPnext(ui_choice)
    CSPrest(amount_of_songs, seq, ui_choice)
    CSPrem(amount_of_songs, seq, ui_choice,starting_page)
    userfeedback(seq)
end

function mainmenu()
    --[[
        Creates the main menu executor to let the user choose between single - and multi page mode.
        returns: IS VOID
    ]]
    local CSP1 = "'CSP(1)'"
    local CSP2 = "'CSP(2)'"
    main_seq   = handlesearcher(1,1,"Sequence")
    main_page  = handlesearcher(1,1,"Page")
    gma.echo("Main menu stored at page "..main_page)
    gma.feedback("Main menu stored at page "..main_page)
    cmd('store seq %i cue 1 "Multi Page"; store seq %i cue 2 "Single Page"', main_seq, main_seq)
    cmd('label seq %i "Main Menu CSP 2"', main_seq)
    cmd('setus $CSA = "'..CSP1..'"; setus $CSB = "'..CSP2..'"')
    cmd('assign seq %i cue 1 /cmd="LUA $CSA"; assign seq %i cue 2 /cmd="LUA $CSB"', main_seq, main_seq)
    cmd('page %i; assign seq %i at exec %i.1', main_page, main_seq, main_page)
    cmd('label page %i "CueShow Prepper 2"', main_page)
    cmd('assign goto execbutton1 %i.1', main_page)
    cmd('setvar $CSP2_menu = Goto exec %i.1', main_page)
    cmd('Goto exec %i.1', main_page)
end

function confirmation()
    --[[
        Requests confirmation from the user to run the plugin.
        returns: IS VOID
    ]]
    local confirm = gma.gui.confirm("ATTENTION!","READ THE MANUAL BEFORE CONTINUING!")
    if confirm then
        mainmenu()
    else 
        gma.gui.msgbox("info","CueShow Prepper has been aborted by user.")
        gma.echo("CueShow Prepper has been aborted by user.")
    end
end

return confirmation