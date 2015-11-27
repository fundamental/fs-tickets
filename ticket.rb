class Ticket
    def initialize(database, id)
        @db = database
        @ticketid = id
        @title = nil
        @status = nil
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

    def comment_id
        @comment_id ||= select("tkt_id")
    end

    def comments
        res = @db.execute("select icomment from ticketchng where tkt_id is ?", comment_id)
        if(res)
            res.join
        else
            ""
        end
    end
    
    def priority
        @priority ||= select("priority")
    end


    def resolve
        if(status == "Open")
            `fossil ticket set #{@ticketid} status Fixed`
            @status = nil
        end
    end
end
