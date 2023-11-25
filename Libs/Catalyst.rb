

class Catalyst

    # Catalyst::editItem(item)
    def self.editItem(item)
        item = JSON.parse(CommonUtils::editTextSynchronously(JSON.pretty_generate(item)))
        item.to_a.each{|key, value|
            DataCenter::setAttribute(item["uuid"], key, value)
        }
    end

    # Catalyst::program2(elements)
    def self.program2(elements)
        loop {

            elements = elements.map{|item| DataCenter::itemOrNull(item["uuid"]) }.compact
            return if elements.empty?

            system("clear")

            store = ItemStore.new()

            puts  ""

            elements
                .each{|item|
                    store.register(item, Listing::canBeDefault(item))
                    puts  Listing::toString2(store, item)
                }

            puts ""
            puts "task | pile | sort | move"
            input = LucilleCore::askQuestionAnswerAsString("> ")
            return if input == "exit"
            return if input == ""

            if input == "task" then
                puts "task is not defined in this context"
                LucilleCore::pressEnterToContinue()
                next
            end

            if input == "pile" then
                puts "pile is not defined in this context"
                LucilleCore::pressEnterToContinue()
                next
            end

            if input == "sort" then
                puts "sort is not defined in this context"
                LucilleCore::pressEnterToContinue()
                next
            end

            if input == "move" then
                NxShips::selectSubsetAndMoveToSelectedShip(elements)
                next
            end

            puts ""
            ListingCommandsAndInterpreters::interpreter(input, store)
        }
    end

    # Catalyst::program3(selector)
    def self.program3(selector)
        loop {

            elements = selector.call()
            return if elements.empty?

            system("clear")

            store = ItemStore.new()

            puts  ""

            elements
                .each{|item|
                    store.register(item, Listing::canBeDefault(item))
                    puts  Listing::toString2(store, item)
                }

            puts ""
            puts "task | pile | sort | move"
            input = LucilleCore::askQuestionAnswerAsString("> ")
            return if input == "exit"
            return if input == ""

            if input == "task" then
                puts "task is not defined in this context"
                LucilleCore::pressEnterToContinue()
                next
            end

            if input == "pile" then
                puts "pile is not defined in this context"
                LucilleCore::pressEnterToContinue()
                next
            end

            if input == "sort" then
                puts "sort is not defined in this context"
                LucilleCore::pressEnterToContinue()
                next
            end

            if input == "move" then
                NxShips::selectSubsetAndMoveToSelectedShip(elements)
                next
            end

            puts ""
            ListingCommandsAndInterpreters::interpreter(input, store)
        }
    end

    # Catalyst::listing_maintenance()
    def self.listing_maintenance()
        if Config::isPrimaryInstance() then
            puts "> Catalyst::listing_maintenance() on primary instance"
            NxTasks::maintenance()
            TxEngines::maintenance0924()
        end
    end

    # Catalyst::expectedTimeToCompletionInSeconds(item)
    def self.expectedTimeToCompletionInSeconds(item)
        if item["mikuType"] == "NxSticky" then
            return 0
        end
        if item["engine-0916"] then
            return 3600
        end
        if item["time-to-completion-packet"] then
            return item["time-to-completion-packet"]["time"]
        end
        timeInMinutes = LucilleCore::askQuestionAnswerAsString("'#{PolyFunctions::toString(item).green}' completion time in minutes: ").to_f
        timeInSeconds = timeInMinutes*60
        packet = {
            "time"     => timeInSeconds,
            "unixtime" => Time.new.to_i
        }
        DataCenter::setAttribute(item["uuid"], "time-to-completion-packet", packet)
        timeInSeconds
    end

    # Catalyst::cumulatedTimeInSeconds(items)
    def self.cumulatedTimeInSeconds(items)
        items
            .reduce(0){|time, item|
                time + Catalyst::expectedTimeToCompletionInSeconds(item)
            }
    end

    # Catalyst::donationSuffix(item)
    def self.donationSuffix(item)
        return "" if item["donation-1751"].nil?
        target = DataCenter::itemOrNull(item["donation-1751"])
        return "" if target.nil?
        " (#{target["description"]})".green
    end
end
