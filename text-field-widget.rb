class TextFieldWidget
    attr_accessor :active
    attr_accessor :value
    def initialize(screen, value, x, y, w, h)
        @active = false
        @screen = screen
        @value  = value
        @x      = x
        @y      = y
        @w      = w
        @h      = h
    end

    def handle(chr)
        if(chr.class == String && chr.match(/[[:print:]\n]/))
            @value += chr
            true
        elsif(chr == Curses::KEY_ENTER || chr == 13)
            @value += "\n"
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
            (0..@h).each do |x|
                value += "_"*@w+"\n"
            end
        end

        @screen.setpos(@y,@x)
        @screen.attron Curses::A_BOLD if @active
        @screen.addstr(value)
        @screen.attroff Curses::A_BOLD if @active
    end
end
