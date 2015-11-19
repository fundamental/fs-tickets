require_relative "./report-view.rb"
require_relative "./ticket-view.rb"

#Curses render
class TableRender
    def initialize(tickets)
        @tickets   = tickets
        @screen    = nil
        init_curses
        view = ReportView.new(@screen, @tickets)
        view.interact
    end

    # Perform the curses setup
    def init_curses
        # signal(SIGINT, finish)

        Curses.init_screen
        Curses.raw
        Curses.nonl
        Curses.cbreak
        Curses.noecho
        Curses.curs_set(0)
        Curses.start_color
        Curses.init_pair(1, Curses::COLOR_WHITE, Curses::COLOR_BLUE);

        @screen = Curses.stdscr

        @screen.scrollok(true)
        @screen.keypad(true)
    end
end
