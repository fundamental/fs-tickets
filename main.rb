require "sqlite3"
require "curses"
require "pp"

require_relative "ticket.rb"
require_relative "render.rb"
FossilCheckoutName = ".fslckout"

fossil_repo_db = nil

#1. Identify Fossil Checkout File
#2. Identify Main Repo File
#3. Obtain A Full Dump of Tickets

#Verify File Exists
f = File.open(FossilCheckoutName)
f.close

#Grab The Real Repo
SQLite3::Database.new(FossilCheckoutName) do |db|
    db.execute("select value from vvar where name is \"repository\"") do |val|
        fossil_repo_db = val[0]
    end
end

#Verify The Real Repo Exists
f = File.open(fossil_repo_db)
f.close

#Grab The Tickets
tickets = []
SQLite3::Database.new(fossil_repo_db) do |db|
    db.execute("select tkt_uuid from ticket order by tkt_ctime") do |val|
        tickets << val[0]
    end
end

#Display The Tickets
tkt_objs   = []
display_id = 1
db = SQLite3::Database.new(fossil_repo_db)
tickets.each do |id|
    db.execute("select title, status from ticket where tkt_uuid = \"#{id}\"") do |val|
        if(val[1] != "Fixed")
            #puts "#{display_id}. [#{val[1]}] #{val[0]}"
            display_id += 1
        end
        tkt_objs << Ticket.new(db, id)
        #puts tkt_objs[-1].title
        #puts tkt_objs[-1].status
    end
end



TableRender.new(tkt_objs)

db.close
#Grab an action
# A - add  [id]
# F - fix  [id]
# V - view [id]
