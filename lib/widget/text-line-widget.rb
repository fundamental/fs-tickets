class TextLineWidget
    attr_accessor :active
    attr_accessor :value
    def initialize(screen, value, x, y, w)
        @active = false
        @screen = screen
        @value  = value
        @x      = x
        @y      = y
        @w      = w
    end

    def handle(chr)
        if(chr.class == String && chr.match(/[a-zA-Z\- .]/))
            @value += chr
            true
        elsif(chr == Curses::KEY_BACKSPACE || chr == 127)
            @value = @value[0..-2]
            true
        else
            false
        end
    end

    def draw
        value = @value
        if(value.empty?)
           value = "_________________"
        end

        @screen.setpos(@y,@x)
        @screen.attron Curses::A_BOLD if @active
        @screen.addstr(value)
        @screen.attroff Curses::A_BOLD if @active
    end
end
