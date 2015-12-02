#Widgets
require_relative "widget/text-line-widget.rb"
require_relative "widget/text-field-widget.rb"
require_relative "widget/dropdown-widget.rb"
require_relative "widget/button-widget.rb"

#Application Views
require_relative "view/report-view.rb"
require_relative "view/ticket-view.rb"
require_relative "view/add-ticket-view.rb"


#Curses render
class TableRender
    def initialize(&block)
        @tickets   = block.call
        @screen    = nil
        init_curses
        view = ReportView.new(@screen, @tickets, block)
        view.interact
    end

    # Perform the curses setup
    def init_curses
        # signal(SIGINT, finish)

        Curses.init_screen
        Curses.raw
        Curses.nonl
        #Curses.cbreak
        Curses.noecho
        Curses.curs_set(0)
        Curses.ESCDELAY = 10
        Curses.start_color
        Curses.init_pair(1, Curses::COLOR_WHITE, Curses::COLOR_BLUE);

        @screen = Curses.stdscr

        @screen.scrollok(true)
        @screen.keypad(true)
    end
end
