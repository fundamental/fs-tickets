class AddTicketView
    def initialize(screen)
        @screen = screen
        @props  = Hash.new
        @title  = TextLineWidget.new(@screen, "",             11,  1, 30)
        @priort = DropdownWidget.new(@screen, "Zero",         11,  2, 30)
        @type   = DropdownWidget.new(@screen, "Unclassified", 11,  3, 30)
        @desc   = TextFieldWidget.new(@screen, "",             0,  5, 78, 14)
        @cancel = ButtonWidget.new(@screen,   "Cancel",        20, 20)
        @submit = ButtonWidget.new(@screen,   "Submit",        0,  20)
        @priort.options = %w{Zero Low Medium High Immediate}
        @type.options   = %w{Incident Code_Defect Build_Problem Documentation Feature_Request}
        @widgets = [@title, @priort, @type, @desc, @submit, @cancel]
        @title.active = true
        @active_id    = 0
    end

    def display
        @screen.clear
        @screen.setpos(0,0)
        @screen.attron(Curses.color_pair(1));
        @screen.addstr("Issue Creation")
        @screen.attroff(Curses.color_pair(1));


        @screen.setpos(1,0)
        @screen.addstr("Title:")
        @screen.setpos(2,0)
        @screen.addstr("Priority:")
        @screen.setpos(3,0)
        @screen.addstr("Type:")
        @screen.setpos(4,0)
        @screen.addstr("Description:")

        ln = 6
        @widgets.each_with_index do |w, idx|
            if(idx != @active_id)
                w.draw
            end
        end

        #Draw the active widget last as it might have an overlay
        @widgets[@active_id].draw
    end

    def changeActive(a)
        a = [a,0].max
        a = [a,@widgets.length-1].min

        if(@active_id != a)
            @widgets[@active_id].active = false
            @active_id = a
            @widgets[@active_id].active = true
        end
    end
    
    def interact
        while true
            result = true
            c = Curses.getch
            case c
            when 27
                break
            when ?\t, 9
                changeActive (@active_id + 1) % @widgets.length
                display
            when ?e
                edit
                display
            else
                if(!@widgets[@active_id].handle(c))
                    if(c == Curses::KEY_UP)
                        changeActive @active_id - 1
                        display
                    elsif(c == Curses::KEY_DOWN)
                        changeActive @active_id + 1
                        display
                    else
                        @screen.setpos(0,0)
                        @screen.addstr("[unknown key `#{Curses.keyname(c)}'=#{c}] ")
                    end
                else
                    if((c == "\n" || c == 13) && @submit == @widgets[@active_id])
                        `fossil ticket add title '#{@title.value}' priority '#{@priort.value}' type '#{@type.value}' icomment '#{@desc.value}' status Open`
                        return :do_refresh
                    elsif((c == "\n" || c == 13) && @cancel == @widgets[@active_id])
                        break
                    else
                        display
                    end
                end
            end
            @screen.setpos(0,0)
        end
    end
    
    def edit
        tmp = File.open("fs-ticket-edit.yaml", "w+")
        tmp.puts({"title"        => @title.value,
                  "priority"     => @priort.value,
                  "type"         => @type.value,
                  "description"  => @desc.value}.to_yaml)
        tmp.close

        system("vim fs-ticket-edit.yaml")

        #Restore curses options
        Curses.raw
        Curses.nonl
        #Curses.cbreak
        Curses.noecho
        Curses.curs_set(0)
        @screen.scrollok(true)
        @screen.keypad(true)

        begin
            tmp = File.open("fs-ticket-edit.yaml", "r")
            yy = YAML.load(tmp.read)
            tmp.close
            @title.value  = yy["title"]
            @priort.value = yy["priority"]
            @type.value   = yy["type"]
            @desc.value   = yy["description"]

            #Later these editing errors should be handled correctly
            #rescue Exception=>e
        end
    end
end
