# encoding: UTF-8

class NxTasksBoarded

    # NxTasksBoarded::items(board)
    def self.items(board)
        NxTasks::items()
            .select{|item| item["boarduuid"] == board["uuid"] }
            .sort_by{|item| item["position"] }
    end

    # NxTasksBoarded::itemsForListing(board)
    def self.itemsForListing(board)
        # {"items", "unixtime"}
        packet = XCache::getOrNull("9191f53c-b98e-4804-a0dc-22c3166a0b5d:#{board["uuid"]}")
        if packet then
            packet = JSON.parse(packet)
            if (Time.new.to_i - packet["unixtime"]) < 86400 then
                return packet["items"]
            else
                # will make a new one
            end
        else
            # will make a new one
        end
        puts "> computing new set of boarded items"
        items = NxTasksBoarded::items(board).first(100)
        packet = { "items" => items, "unixtime" => Time.new.to_i }
        XCache::set("9191f53c-b98e-4804-a0dc-22c3166a0b5d:#{board["uuid"]}", JSON.generate(packet))
        items
    end
end
