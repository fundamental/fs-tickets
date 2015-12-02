require 'yaml'

class TicketView
    def initialize(screen, ticket)
        @screen = screen
        @ticket = ticket
    end

    def display
        @screen.clear
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
        @screen.addstr("Subsystem: #{@ticket.subsystem}")
        @screen.setpos(6,0)
        @screen.addstr("Comments:")
        ln = 7
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
            when ?e
                edit
                display
            else
                @screen.setpos(0,0)
                @screen.addstr("[unknown key `#{Curses.keyname(c)}'=#{c}] ")
            end
            @screen.setpos(0,0)
        end
    end

    def edit
        tmp = File.open("fs-ticket-edit.txt", "w+")
        tmp.puts({"title"    => @ticket.title,
                  "status"   => @ticket.status,
                  "priority" => @ticket.priority,
                  "type"     => @ticket.type,
                  "comment"  => @ticket.comments}.to_yaml)
        tmp.close

        system("vim fs-ticket-edit.txt")

        #Restore curses options
        Curses.raw
        Curses.nonl
        #Curses.cbreak
        Curses.noecho
        Curses.curs_set(0)
        @screen.scrollok(true)
        @screen.keypad(true)
    end
end
