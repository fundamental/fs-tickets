
class ButtonWidget
    attr_accessor :active
    def initialize(screen, value, x, y)
        @active = false
        @screen = screen
        @value  = value
        @x      = x
        @y      = y
    end

    def handle(chr)
        if(chr == "\n" || chr == 13)
            true
        else
            false
        end
    end

    def draw
        value = @value
        if(value.empty?)
           value = "XXXXX"
        end

        @screen.attron Curses::A_BOLD if @active

        @screen.setpos(@y,@x)
        @screen.addstr "-"*(2+value.length)
        @screen.setpos(@y+1,@x)
        @screen.addstr("|"+value+"|")
        @screen.setpos(@y+2,@x)
        @screen.addstr "-"*(2+value.length)

        @screen.attroff Curses::A_BOLD if @active
    end
end
