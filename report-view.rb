class ReportView
    def initialize(screen, tickets, block)
        @screen       = screen
        @mode         = :all
        @real_tickets = tickets
        @tickets      = tickets
        @refresh      = block
        @highlight    = 0
        display_lines
    end

    def refresh
        @real_tickets = @refresh.call
        toggle_open_tickets
        toggle_open_tickets
    end

    def toggle_open_tickets
        @highlight = 0
        if(@mode == :all)
            @tickets = []
            @real_tickets.each do |t|
                if(t.status == "Open")
                    @tickets << t
                end
            end
            @mode = :open
        elsif(@mode == :open || @mode == :search)
            @tickets = @real_tickets
            @mode = :all
        end
        display_lines
    end

    def run_search(term)
        @tickets = []
        @real_tickets.each do |t|
            if(t.match term)
                @tickets << t
            end
        end
        @mode = :search
        display_lines
    end

    def search
        label = TextLineWidget.new(@screen, "search:       ", 0, @screen.maxy-1, 40)
        line  = TextLineWidget.new(@screen, "", 10, @screen.maxy-1, 40)
        label.draw
        line.draw
        while true
            c = Curses.getch
            if(c == "\n" || !line.handle(c))
                run_search(line.value)
                break
            else
                label.draw
                line.draw
            end
        end
    end

    def display_lines
        @screen.clear

        @screen.setpos(0,0)
        @screen.attron(Curses.color_pair(1));
        @screen.addstr("Issue Overview - [a]dd new issue, [t]oggle open issues, [q]uit")
        @screen.attroff(Curses.color_pair(1));

        start = 0
        ylimit = @screen.maxy-1
        upper = ylimit-1
        if(@highlight >= ylimit)
            start = ylimit*(@highlight/ylimit).to_i
            upper = start + ylimit - 1
        end

        if(@tickets.empty?)
            return
        end

        @tickets[start..upper].each_with_index{|tick, idx|
            line = tick.title
            line_id = idx+start
            @screen.setpos(idx+1, 0)
            @screen.addstr(line_id.to_s+".")
            @screen.setpos(idx+1, 4)
            if(tick.status)
                @screen.addstr("["+tick.status[0]+"]")
            end
            @screen.setpos(idx+1, 9)
            if(@highlight == line_id)
                @screen.attron Curses::A_BOLD
                @screen.addstr(line)
                @screen.attroff Curses::A_BOLD
            else
                @screen.addstr(line)
            end
        }
        @screen.setpos(0,0)
        @screen.refresh
    end

    def scroll_up(draw=true)
        if(@highlight > 0)
            @highlight -= 1
            display_lines if draw
        end
    end

    def scroll_down(draw=true)
        if(@highlight < @tickets.length-1)
            @highlight += 1
            display_lines if draw
        end
    end

    def interact
        while true
            result = true
            c = Curses.getch
            case c
            when ?t
                toggle_open_tickets
            when ?a
                at = AddTicketView.new(@screen)
                @screen.clear
                at.display
                ret = at.interact
                if(ret == :do_refresh)
                    refresh
                end
                @screen.clear
                display_lines
            when Curses::KEY_DOWN, Curses::KEY_CTRL_N, ?j
                result = scroll_down
            when Curses::KEY_UP, Curses::KEY_CTRL_P, ?k
                result = scroll_up
            when Curses::KEY_NPAGE, ?\s  # white space
                for i in 0..(@screen.maxy - 2)
                    scroll_down(false)
                end
                display_lines
            when Curses::KEY_PPAGE
                for i in 0..(@screen.maxy - 2)
                    scroll_up(false)
                end
                display_lines
            when Curses::KEY_RIGHT, Curses::KEY_ENTER, ?\n, 13
                tv = TicketView.new(@screen, @tickets[@highlight])
                @screen.clear
                tv.display
                ret = tv.interact
                @screen.clear
                display_lines
            when "/"
                search
            when ?q
                break
            else
                @screen.setpos(0,0)
                @screen.addstr("[unknown key `#{Curses.keyname(c)}'=#{c}] ")
            end
            @screen.setpos(0,0)
        end
        Curses.close_screen
    end
end
