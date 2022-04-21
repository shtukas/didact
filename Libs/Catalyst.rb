# encoding: UTF-8

class TerminalUtils

    # TerminalUtils::removeDuplicatesOnAttribute(array, attribute)
    def self.removeDuplicatesOnAttribute(array, attribute)
        array.reduce([]){|selected, element|
            if selected.none?{|x| x[attribute] == element[attribute] } then
                selected + [element]
            else
                selected
            end
        }
    end

    # TerminalUtils::removeRedundanciesInSecondArrayRelativelyToFirstArray(array1, array2)
    def self.removeRedundanciesInSecondArrayRelativelyToFirstArray(array1, array2)
        uuids1 = array1.map{|ns16| ns16["uuid"] }
        array2.select{|ns16| !uuids1.include?(ns16["uuid"]) }
    end

    # TerminalUtils::inputParser(input, store)
    def self.inputParser(input, store) # [command or null, ns16 or null]
        # This function take an input from the prompt and 
        # attempt to retrieve a command and optionaly an object (from the store)
        # Note that the command can also be null if a command could not be extrated

        outputForCommandAndOrdinal = lambda {|command, ordinal, store|
            ordinal = ordinal.to_i
            ns16 = store.get(ordinal)
            if ns16 then
                return [command, ns16]
            else
                return [nil, nil]
            end
        }

        if Interpreting::match("[]", input) then
            return ["[]", nil]
        end

        if Interpreting::match(">>", input) then
            return [">>", nil]
        end

        if Interpreting::match("..", input) then
            return ["..", store.getDefault()]
        end

        if Interpreting::match(".. *", input) then
            _, ordinal = Interpreting::tokenizer(input)
            return outputForCommandAndOrdinal.call("..", ordinal, store)
        end

        if Interpreting::match(">todo", input) then
            return [">todo", store.getDefault()]
        end

        if Interpreting::match("access", input) then
            return ["access", store.getDefault()]
        end

        if Interpreting::match("access *", input) then
            _, ordinal = Interpreting::tokenizer(input)
            return outputForCommandAndOrdinal.call("access", ordinal, store)
        end

        if Interpreting::match("anniversaries", input) then
            return ["anniversaries", nil]
        end

        if Interpreting::match("calendar item", input) then
            return ["calendar item", nil]
        end

        if Interpreting::match("calendar", input) then
            return ["calendar", nil]
        end

        if Interpreting::match("done", input) then
            return ["done", store.getDefault()]
        end

        if Interpreting::match("done *", input) then
            _, ordinal = Interpreting::tokenizer(input)
            return outputForCommandAndOrdinal.call("done", ordinal, store)
        end

        if Interpreting::match("fyre", input) then
            return ["fyre", nil]
        end

        if Interpreting::match("expose", input) then
            return ["expose", store.getDefault()]
        end

        if Interpreting::match("expose *", input) then
            _, ordinal = Interpreting::tokenizer(input)
            return outputForCommandAndOrdinal.call("expose", ordinal, store)
        end

        if Interpreting::match("float", input) then
            return ["float", nil]
        end

        if Interpreting::match("fsck", input) then
            return ["fsck", nil]
        end

        if Interpreting::match("internet off", input) then
            return ["internet off", nil]
        end

        if Interpreting::match("internet on", input) then
            return ["internet on", nil]
        end

        if Interpreting::match("landing", input) then
            return ["landing", store.getDefault()]
        end

        if Interpreting::match("landing *", input) then
            _, ordinal = Interpreting::tokenizer(input)
            return outputForCommandAndOrdinal.call("landing", ordinal, store)
        end

        if Interpreting::match("librarian", input) then
            return ["librarian", nil]
        end

        if Interpreting::match("nyx", input) then
            return ["nyx", nil]
        end

        if Interpreting::match("ondate", input) then
            return ["ondate", nil]
        end

        if Interpreting::match("pursue", input) then
            return ["pursue", store.getDefault()]
        end

        if Interpreting::match("pursue *", input) then
            _, ordinal = Interpreting::tokenizer(input)
            return outputForCommandAndOrdinal.call("pursue", ordinal, store)
        end

        if Interpreting::match("redate", input) then
            return ["redate", store.getDefault()]
        end

        if Interpreting::match("redate *", input) then
            _, ordinal = Interpreting::tokenizer(input)
            return outputForCommandAndOrdinal.call("redate", ordinal, store)
        end

        if Interpreting::match("require internet", input) then
            return ["require internet", store.getDefault()]
        end

        if Interpreting::match("start something", input) then
            return ["start something", nil]
        end

        if Interpreting::match("search", input) then
            return ["search", store.getDefault()]
        end

        if Interpreting::match("start", input) then
            return ["start", store.getDefault()]
        end

        if Interpreting::match("start *", input) then
            _, ordinal = Interpreting::tokenizer(input)
            return outputForCommandAndOrdinal.call("start", ordinal, store)
        end

        if Interpreting::match("stop", input) then
            return ["stop", store.getDefault()]
        end

        if Interpreting::match("stop *", input) then
            _, ordinal = Interpreting::tokenizer(input)
            return outputForCommandAndOrdinal.call("stop", ordinal, store)
        end

        if Interpreting::match("top", input) then
            return ["top", nil]
        end

        if Interpreting::match("today", input) then
            return ["today", nil]
        end

        if Interpreting::match("todo", input) then
            return ["todo", store.getDefault()]
        end

        if Interpreting::match("transmute", input) then
            return ["transmute", store.getDefault()]
        end

        if Interpreting::match("transmute *", input) then
            _, ordinal = Interpreting::tokenizer(input)
            return outputForCommandAndOrdinal.call("transmute", ordinal, store)
        end

        if Interpreting::match("universe", input) then
            return ["universe", store.getDefault()]
        end

        if Interpreting::match("universe *", input) then
            _, ordinal = Interpreting::tokenizer(input)
            return outputForCommandAndOrdinal.call("universe", ordinal, store)
        end

        if Interpreting::match("wave", input) then
            return ["wave", nil]
        end

        [nil, nil]
    end
end

class Commands

    # Commands::terminalDisplayCommand()
    def self.terminalDisplayCommand()
        "<datecode> | <n> | .. (<n>) | expose (<n>) | transmute (<n>) | start (<n>) | search | nyx | >nyx"
    end

    # Commands::makersCommands()
    def self.makersCommands()
        "wave | anniversary | calendar item | float | fyre | today | ondate | todo"
    end

    # Commands::diversCommands()
    def self.diversCommands()
        "waves | anniversaries | calendar | ondates | todos"
    end
end

class ItemStore

    def initialize() # : Integer
        @items = []
        @defaultItem = nil
    end

    def register(item, canBeDefault)
        cursor = @items.size
        @items << item
        if @defaultItem.nil? and canBeDefault then
            @defaultItem = item
        end
        @items.size-1
    end

    def latestEnteredItemIsDefault()
        return false if @defaultItem.nil?
        @items.last["uuid"] == @defaultItem["uuid"]
    end

    def prefixString()
        indx = @items.size-1
        latestEnteredItemIsDefault() ? "(-->)".green : "(#{"%3d" % indx})"
    end

    def get(indx)
        @items[indx].clone
    end

    def getDefault()
        @defaultItem.clone
    end
end

class NS16sOperator

    # NS16sOperator::section2(universe)
    def self.section2(universe)
        # Section 2 shows what's current, fyres and todos with more than an hour in their Bank
        fyres = TxFyres::topDisplay(universe)
                    .select{|item| DoNotShowUntil::isVisible(item["uuid"]) }
                    .select{|ns16| InternetStatus::ns16ShouldShow(ns16["uuid"]) }
        todos = TxTodos::section2(universe)
        fyres + todos
    end

    # NS16sOperator::section3(universe)
    def self.section3(universe)
        [
            Anniversaries::ns16s(),
            JSON.parse(`/Users/pascal/Galaxy/LucilleOS/Binaries/fitness ns16s`),
            TxDateds::ns16s(),
            Waves::ns16s(universe),
            Inbox::ns16s(),
            TxFyres::ns16s(universe),
            TxTodos::ns16s(universe)
        ]
            .flatten
            .select{|item| DoNotShowUntil::isVisible(item["uuid"]) }
            .select{|ns16| InternetStatus::ns16ShouldShow(ns16["uuid"]) }
    end
end

class TerminalDisplayOperator

    # TerminalDisplayOperator::ns16HasStarted(ns16)
    def self.ns16HasStarted(ns16)
        NxBallsService::isRunning(ns16["uuid"])
    end

    # TerminalDisplayOperator::standardDisplay(universe, floats, section2, section3)
    def self.standardDisplay(universe, floats, section2, section3)
        system("clear")

        vspaceleft = Utils::screenHeight()-3

        puts ""
        reference = 12395 # 20th April 2022 @ 08:00
        current = TxDateds::items().size + TxFyres::items().size + TxTodos::items().size
        percentage = 100*(current.to_f/reference)
        puts "👩‍💻 🔥 #{current}, #{percentage.round(3)}% (#{universe})"
        vspaceleft = vspaceleft - 2

        store = ItemStore.new()

        if !InternetStatus::internetIsActive() then
            puts ""
            puts "INTERNET IS OFF".green
            vspaceleft = vspaceleft - 2
        end

        if !Mercury::isEmpty("055e1acb-164c-49cd-b17a-7946ba02c583") then
            puts ""
            puts "You have pending Dx8Units maintenance (use the librarian)"
            vspaceleft = vspaceleft - 2
        end

        if floats.size>0 then
            puts ""
            vspaceleft = vspaceleft - 1
        end
        floats.each{|ns16|
            store.register(ns16, false)
            line = "#{store.prefixString()} [#{Time.at(ns16["TxFloat"]["unixtime"]).to_s[0, 10]}] #{ns16["announce"]}".yellow
            puts line
            vspaceleft = vspaceleft - Utils::verticalSize(line)
        }

        if section2.size>0 then
            puts ""
            vspaceleft = vspaceleft - 1
        end
        section2.each{|ns16|
            store.register(ns16, false)
            line = "#{store.prefixString()} #{ns16["announce"]}"
            puts line
            vspaceleft = vspaceleft - Utils::verticalSize(line)
        }

        running = BTreeSets::values(nil, "a69583a5-8a13-46d9-a965-86f95feb6f68")
        listingUUIDs = section3.map{|item| item["uuid"] }
        running = running.select{|nxball| !listingUUIDs.include?(nxball["uuid"]) }
        if running.size>0 then
            puts ""
            vspaceleft = vspaceleft - 1
        end
        running
                .sort{|t1, t2| t1["unixtime"] <=> t2["unixtime"] } # || 0 because we had some running while updating this
                .each{|nxball|
                    delegate = {
                        "uuid"       => nxball["uuid"],
                        "mikuType"   => "NxBallNS16Delegate1" 
                    }
                    store.register(delegate, true)
                    line = "#{store.prefixString()} #{nxball["description"]} (#{NxBallsService::runningStringOrEmptyString("", nxball["uuid"], "")})".green
                    puts line
                    vspaceleft = vspaceleft - Utils::verticalSize(line)
                }

        top = Topping::getText(universe)
        if top and top.strip.size > 0 then
            puts ""
            puts "(top)"
            top = top.lines.first(10).join()
            puts top
            vspaceleft = vspaceleft - Utils::verticalSize(top) - 2
        end

        if section3.size>0 then
            puts ""
            vspaceleft = vspaceleft - 1
        end
        section3
            .each{|ns16|
                canBeDefault = true
                if ns16["nonListingDefaultable"] then
                    canBeDefault = false
                end
                store.register(ns16, canBeDefault)
                line = ns16["announce"]
                line = "#{store.prefixString()} #{(ObjectUniverseMapping::getObjectUniverseMappingOrNull(ns16["uuid"]) || "").ljust(7)} #{line}"
                break if (vspaceleft - Utils::verticalSize(line)) < 0
                if TerminalDisplayOperator::ns16HasStarted(ns16) then
                    line = "#{line} (#{NxBallsService::runningStringOrEmptyString("", ns16["uuid"], "")})".green
                end
                puts line
                vspaceleft = vspaceleft - Utils::verticalSize(line)
            }

        puts ""

        input = LucilleCore::askQuestionAnswerAsString("> ")

        return if input == ""

        if (unixtime = Utils::codeToUnixtimeOrNull(input.gsub(" ", ""))) then
            if (item = store.getDefault()) then
                DoNotShowUntil::setUnixtime(item["uuid"], unixtime)
                return
            end
        end

        command, objectOpt = TerminalUtils::inputParser(input, store)
        #puts "parser: command:#{command}, objectOpt: #{objectOpt}"
        LxAction::action(command, objectOpt)
    end
end

class Catalyst

    # Catalyst::program()
    def self.program()
        initialCodeTrace = Utils::codeTrace()
        loop {
            if Utils::codeTrace() != initialCodeTrace then
                puts "Code change detected"
                break
            end

            if !NxBallsService::somethingIsRunning() then
                if (uni2 = StoredUniverse::getUniverseOrNull()) then
                    StoredUniverse::setUniverse(uni2)
                end
            end

            universe = StoredUniverse::getUniverseOrNull()
            floats = TxFloats::ns16s(universe)
                        .select{|item| DoNotShowUntil::isVisible(item["uuid"]) }
                        .select{|ns16| InternetStatus::ns16ShouldShow(ns16["uuid"]) }

            section2 = NS16sOperator::section2(universe)

            section3 = NS16sOperator::section3(universe)
            TerminalDisplayOperator::standardDisplay(universe, floats, section2, section3)
        }
    end
end
