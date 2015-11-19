class TicketView
    def initialize(screen, ticket)
        @screen = screen
        @ticket = ticket
    end

    def display
        @screen.setpos(0,0)
        @screen.attron(Curses.color_pair(1));
        @screen.addstr("Issue Details - [f]ix [q]uit")
        @screen.attroff(Curses.color_pair(1));


        @screen.setpos(1,0)
        @screen.addstr("Title:     #{@ticket.title}")
        @screen.setpos(2,0)
        @screen.addstr("Status:    #{@ticket.status}")
        @screen.setpos(3,0)
        @screen.addstr("Priority:  #{@ticket.priority}")
        @screen.setpos(4,0)
        @screen.addstr("Type:      #{@ticket.type}")
        @screen.setpos(5,0)
        @screen.addstr("Comments:")
        ln = 6
        @ticket.comments.split("\n").each do |l|
            @screen.setpos(ln,0)
            @screen.addstr(l)
            ln += 1
        end
    end
    
    def interact
        while true
            result = true
            c = Curses.getch
            case c
            when Curses::KEY_LEFT
                break
            when ?q
                break
            when ?f
                @ticket.resolve
                display
            else
                @screen.setpos(0,0)
                @screen.addstr("[unknown key `#{Curses.keyname(c)}'=#{c}] ")
            end
            @screen.setpos(0,0)
        end
    end
end
