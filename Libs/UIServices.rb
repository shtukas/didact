# encoding: UTF-8

# ------------------------------------------------------------------------------------------

class Fitness
    # Fitness::ns16s()
    def self.ns16s()
        ns16s = JSON.parse(`/Users/pascal/Galaxy/LucilleOS/Binaries/fitness ns16s`)
        ns16s.map{|ns16|
            ns16["commands"] = [".."]
            ns16["interpreter"] = lambda {|command|
                if command == ".." then
                    system("/Users/pascal/Galaxy/LucilleOS/Binaries/fitness doing #{ns16["fitness-domain"]}") 
                end
            }
            ns16["run"] = lambda {
                system("/Users/pascal/Galaxy/LucilleOS/Binaries/fitness doing #{ns16["fitness-domain"]}") 
            }
            ns16
        }
    end
end

class AmandaBins
    # AmandaBins::ns16s()
    def self.ns16s()
        JSON.parse(`/Users/pascal/Galaxy/LucilleOS/Binaries/amanda-bin-monitor`)
    end
end

class NS16sOperator
    # NS16sOperator::ns16s(domain)
    def self.ns16s(domain)
        [
            Anniversaries::ns16s(),
            Calendar::ns16s(),
            Dated::ns16s(),
            AmandaBins::ns16s(),
            Fitness::ns16s(),
            DrivesBackups::ns16s(),
            Waves::ns16s(domain),
            Inbox::ns16s(),
            Today::ns16s(),
            Nx50s::ns16s(domain),
        ]
            .flatten
            .compact
            .select{|item| DoNotShowUntil::isVisible(item["uuid"]) }
            .select{|ns16| InternetStatus::ns16ShouldShow(ns16["uuid"]) }
    end
end

class ItemStore
    def initialize() # : Integer
        @items = []
        @defaultItem = nil
    end
    def register(item)
        cursor = @items.size
        @items << item
        cursor 
    end
    def registerDefault(item)
        @defaultItem = item
    end
    def get(indx)
        @items[indx].clone
    end
    def getDefault()
        @defaultItem.clone
    end
end

class InternetStatus

    # InternetStatus::setInternetOn()
    def self.setInternetOn()
        KeyValueStore::destroy(nil, "099dc001-c211-4e37-b631-8f3cf7ef6f2d")
    end

    # InternetStatus::setInternetOff()
    def self.setInternetOff()
        KeyValueStore::set(nil, "099dc001-c211-4e37-b631-8f3cf7ef6f2d", "off")
    end

    # InternetStatus::internetIsActive()
    def self.internetIsActive()
        KeyValueStore::getOrNull(nil, "099dc001-c211-4e37-b631-8f3cf7ef6f2d").nil?
    end

    # InternetStatus::markIdAsRequiringInternet(id)
    def self.markIdAsRequiringInternet(id)
        KeyValueStore::set(nil, "29f7d6a5-91ed-4623-9f52-543684881f33:#{id}", "require")
    end

    # InternetStatus::trueIfElementRequiresInternet(id)
    def self.trueIfElementRequiresInternet(id)
        KeyValueStore::getOrNull(nil, "29f7d6a5-91ed-4623-9f52-543684881f33:#{id}") == "require"
    end

    # InternetStatus::ns16ShouldShow(id)
    def self.ns16ShouldShow(id)
        InternetStatus::internetIsActive() or !InternetStatus::trueIfElementRequiresInternet(id)
    end

    # InternetStatus::putsInternetCommands()
    def self.putsInternetCommands()
        "internet on | internet off | requires internet"
    end

    # InternetStatus::interpreter(command, store)
    def self.interpreter(command, store)

        if Interpreting::match("internet on", command) then
            InternetStatus::setInternetOn()
        end

        if Interpreting::match("internet off", command) then
            InternetStatus::setInternetOff()
        end

        if Interpreting::match("requires internet", command) then
            ns16 = store.getDefault()
            return if ns16.nil?
            InternetStatus::markIdAsRequiringInternet(ns16["uuid"])
        end
    end
end

class UIServices

    # UIServices::todoOverflow(store, realDomain)
    def self.todoOverflow(store, realDomain)
        [
            "",
            "todo overflow:",
            Nx50s::structure(realDomain)["overflow"]
                .map{|object|
                    "(#{store.register(object).to_s.rjust(3, " ")}) #{object["announce"].green}"
                }
        ].flatten.join("\n")
    end

    # UIServices::backlog(store, realDomain)
    def self.backlog(store, realDomain)
        [
            "",
            "backlog:",
            DetachedRunning::ns16s()
                .map{|object|
                    "(#{store.register(object).to_s.rjust(3, " ")}) #{object["announce"].green}"
                }
        ].flatten.join("\n")
    end

    # UIServices::mainView(extendedDomain, realDomain, ns16s)
    def self.mainView(extendedDomain, realDomain, ns16s)
        system("clear")

        vspaceleft = Utils::screenHeight()-5

        infolines = [
            "      " + Interpreters::listingCommands(),
            "      " + Interpreters::makersCommands(),
            "      " + Interpreters::diversCommands(),
            "      " + Domain::domainsMenuCommands(),
            "      " + InternetStatus::putsInternetCommands()
        ].join("\n").yellow

        vspaceleft = vspaceleft - Utils::verticalSize(infolines)

        store = ItemStore.new()

        puts ""
        if extendedDomain != "(multiplex)" then
            puts "--> #{extendedDomain}".green
        else
            puts "--> #{extendedDomain} #{realDomain}".green
        end

        vspaceleft = vspaceleft - 2

        if !InternetStatus::internetIsActive() then
            puts ""
            puts "INTERNET IS OFF".green
            vspaceleft = vspaceleft - 2
        end

        puts ""
        puts "commands:"
        puts infolines

        puts ""
        puts "floats:"
        vspaceleft = vspaceleft - 2
        Floats::items(realDomain)
            .each{|object|
                line = "(#{store.register(object).to_s.rjust(3, " ")}) #{object["announce"].yellow}"
                puts line
                vspaceleft = vspaceleft - Utils::verticalSize(line)
            }

        puts ""
        puts "hud:"
        vspaceleft = vspaceleft - 2
        PriorityFile::ns16s()
            .each{|object|
                line = "(#{store.register(object).to_s.rjust(3, " ")}) #{object["announce"].green}"
                puts line
                vspaceleft = vspaceleft - Utils::verticalSize(line)
            }
        Hud::ns16s()
            .each{|object|
                line = "(#{store.register(object).to_s.rjust(3, " ")}) #{object["announce"].green}"
                puts line
                vspaceleft = vspaceleft - Utils::verticalSize(line)
            }

        puts ""
        puts "detached runnings:"
        vspaceleft = vspaceleft - 2
        DetachedRunning::ns16s()
            .each{|object|
                line = "(#{store.register(object).to_s.rjust(3, " ")}) #{object["announce"].green}"
                puts line
                vspaceleft = vspaceleft - Utils::verticalSize(line)
            }

        backlog = UIServices::backlog(store, realDomain)
        vspaceleft = vspaceleft - Utils::verticalSize(backlog)

        todoOverflow = UIServices::todoOverflow(store, realDomain)
        vspaceleft = vspaceleft - Utils::verticalSize(todoOverflow)

        commandStrWithPrefix = lambda{|ns16, isDefaultItem|
            return "" if !isDefaultItem
            return "" if ns16["commands"].nil?
            return "" if ns16["commands"].empty?
            " (commands: #{ns16["commands"].join(", ")})".yellow
        }

        if ns16s.size > 0 then
            store.registerDefault(ns16s[0])
        end

        puts ""
        puts "todo:"
        vspaceleft = vspaceleft - 2
        ns16s
            .each_with_index{|ns16|
                indx = store.register(ns16)
                isDefaultItem = ns16["uuid"] == (store.getDefault() ? store.getDefault()["uuid"] : "")
                posStr = isDefaultItem ? "(-->)" : "(#{"%3d" % indx})"
                announce = "#{posStr} #{ns16["announce"]}#{commandStrWithPrefix.call(ns16, isDefaultItem)}"
                break if ((indx > 0) and ((vspaceleft - Utils::verticalSize(announce)) < 0))
                puts announce
                vspaceleft = vspaceleft - Utils::verticalSize(announce)
            }

        puts backlog

        puts todoOverflow

        puts ""
        command = LucilleCore::askQuestionAnswerAsString("> ")

        return if command == ""

        # We first interpret the command as an index and call "run"
        # Or interpret it a command and run it by the default element interpreter.
        # Otherwise we try a bunch of generic interpreters.

        if command == ".." and store.getDefault() and store.getDefault()["run"] then
            store.getDefault()["run"].call()
            return
        end

        if (i = Interpreting::readAsIntegerOrNull(command)) then
            item = store.get(i)
            return if item.nil?
            item["run"].call()
            return
        end

        Interpreters::listingInterpreter(store, command)
        Interpreters::makersAndDiversInterpreter(command)
        Domain::domainsCommandInterpreter(command)
        InternetStatus::interpreter(command, store)

        if store.getDefault() then
            item = store.getDefault()
            if item["interpreter"] then
                item["interpreter"].call(command)
            end
        end
    end
end

class Fsck
    # Fsck::fsck()
    def self.fsck()

        Anniversaries::anniversaries().each{|item|
            puts JSON.pretty_generate(item)
        }

        Dated::items().each{|item|
            puts JSON.pretty_generate(item)
            status = CoreData::fsck(item["coreDataId"])
            if !status then
                puts "[problem]".red
                exit
            end
        }

        Waves::items().each{|item|
            puts JSON.pretty_generate(item)
            status = CoreData::fsck(item["coreDataId"])
            if !status then
                puts "[problem]".red
                exit
            end
        }

        Nx50s::nx50s().each{|item|
            puts JSON.pretty_generate(item)
            status = CoreData::fsck(item["coreDataId"])
            if !status then 
                puts "[problem]".red
                LucilleCore::pressEnterToContinue()
            end
        }

        puts "Fsck Completed!".green
        LucilleCore::pressEnterToContinue()
    end
end
