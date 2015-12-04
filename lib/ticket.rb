class Ticket
    def initialize(database, id)
        @db = database
        @ticketid = id
        refresh
    end

    def select(field)
        result = nil
        @db.execute(
            "select #{field} from ticket where tkt_uuid is ?",
            @ticketid.to_s) do |val|
                result = val[0]
            end
        result
    end

    def title
        @title ||= select("title")
    end
    
    def status
        @status ||= select("status")
    end
    
    def type
        @type ||= select("type")
    end
    
    def subsystem
        @subsystem ||= select("subsystem")
    end

    def comment_id
        @comment_id ||= select("tkt_id")
    end

    def old_comments
        res   = select("comment")
        res ||= ""
    end


    def comments
        if(!@comments)
            old = old_comments
            res = @db.execute("select icomment from ticketchng where tkt_id is ?", comment_id)
            if(res)
                @comments = old+res.join
            else
                @comments = old+""
            end
            @comments.gsub!(/\r\n/, "\n")
        end
        @comments
    end
    
    def priority
        @priority ||= select("priority")
    end
    
    def resolution
        @resolution ||= select("resolution")
    end


    def resolve
        if(status == "Open")
            `fossil ticket set #{@ticketid} status Fixed`
            @status = nil
        end
    end

    def id
        @ticketid
    end

    def refresh
        @title      = nil
        @status     = nil
        @type       = nil
        @subsystem  = nil
        @priority   = nil
        @resolution = nil
        @comments   = nil
    end

    def match(regex)
        (comments && comments.match(regex)) || (title && title.match(regex))
    end
end

