class DropdownWidget
    attr_reader :active
    attr_reader :options
    attr_reader :value

    def active=(a)
        if(!a)
            @mode = :normal
        end
        @active = a
    end

    def options=(o)
        @options = o
        fix_sel
    end

    def value=(v)
        @value = v
        fix_sel
    end

    #Fix the selection when either the value or options change
    def fix_sel
        @options.each_with_index do |o, idx|
            if(@value == o)
                @sel = idx
            end
        end
    end

    def initialize(screen, value, x, y, w)
        @active  = false
        @screen  = screen
        @value   = value
        @x       = x
        @y       = y
        @w       = w
        @mode    = :normal
        @options = [value]
        @sel     = 0
    end

    def draw
        if(@mode == :normal)
            @screen.setpos(@y,@x)
            @screen.attron Curses::A_BOLD if @active
            @screen.addstr(@value)
            @screen.attroff Curses::A_BOLD if @active
        elsif(@mode == :selecting)
            sel_width = @w-2
            @screen.setpos(@y,@x)
            @screen.addstr("-"*@w)

            @options.each_with_index do |opt, idx|
                @screen.setpos(@y+idx+1,@x)
                padded_str = " "*sel_width
                opt.chars.each_with_index do |chr, idx|
                    padded_str[idx] = chr
                end
                @screen.attron  Curses::A_BOLD if idx == @sel
                @screen.addstr "|"+padded_str+"|"
                @screen.attroff Curses::A_BOLD if idx == @sel
            end

            @screen.setpos(@y+@options.length+1,@x)
            @screen.addstr("-"*@w)
        end
    end

    def handle(chr)
        if(chr == Curses::KEY_RIGHT)
            @mode  = :selecting
            @value = @options[@sel]
            true
        elsif(chr == Curses::KEY_LEFT)
            @mode = :normal
            true
        elsif(chr == Curses::KEY_DOWN && @mode == :selecting)
            @sel   = [@sel+1, @options.length-1].min
            @value = @options[@sel]
            true
        elsif(chr == Curses::KEY_UP && @mode == :selecting)
            @sel   = [@sel-1, 0].max
            @value = @options[@sel]
            true
        else
            false
        end
    end
end
