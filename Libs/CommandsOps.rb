
class Commands

    # Commands::terminalDisplayCommand()
    def self.terminalDisplayCommand()
        ".. | <n> | <datecode> | expose"
    end

    # Commands::makersCommands()
    def self.makersCommands()
        "wave | anniversary | float | spaceship | drop | today | ondate | todo"
    end

    # Commands::diversCommands()
    def self.diversCommands()
        "calendar | waves | anniversaries | ondates | todos | focus eva/work/null  | search | nyx"
    end

    # Commands::makersAndDiversCommands()
    def self.makersAndDiversCommands()
        [
            Commands::makersCommands(),
            Commands::diversCommands()
        ].join(" | ")
    end
end

class CommandsOps

    # CommandsOps::closeAnyNxBallWithThisID(uuid)
    def self.closeAnyNxBallWithThisID(uuid)
        NxBallsService::close(uuid, true)
    end

    # CommandsOps::operator1(object, command)
    def self.operator1(object, command)

        return if object.nil?

        # puts "CommandsOps, object: #{object}, command: #{command}"

        if object["NS198"] == "NS16:Anniversary1" and command == ".." then
            Anniversaries::run(object["anniversary"])
        end

        if object["NS198"] == "NS16:Anniversary1" and command == "done" then
            anniversary = object["anniversary"]
            puts Anniversaries::toString(anniversary).green
            anniversary["lastCelebrationDate"] = Time.new.to_s[0, 10]
            Anniversaries::commitAnniversaryToDisk(anniversary)
        end

        if object["NS198"] == "NS16:Calendar1" and command == ".." then
            Calendar::run(object["item"])
        end

        if object["NS198"] == "NS16:Calendar1" and command == "done" then
            Calendar::moveToArchives(object["item"])
        end

        if object["NS198"] == "NS16:CatalystTxt" and command == ".." then
            line = object["line"]
            action = LucilleCore::selectEntityFromListOfEntitiesOrNull("action", ["start", "done"])
            return if action.nil?
            if action == "start" then
                account = DomainsX::selectAccount()
                NxBallsService::issue(SecureRandom.uuid, line, [account])
            end
            if action == "done" then
                CatalystTxt::rewriteCatalystTxtFileWithoutThisLine(line)
            end
        end

        if object["NS198"] == "NS16:CatalystTxt" and command == "done" then
            Utils::copyFileToBinTimeline("/Users/pascal/Desktop/Catalyst.txt")
            CatalystTxt::rewriteCatalystTxtFileWithoutThisLine(object["line"])
        end

        if object["NS198"] == "NS16:CatalystTxt" and command == "''" then
            line = object["line"]
            ItemStoreOps::delistForDefault(CatalystTxt::lineToUuid(line))
        end

        if object["NS198"] == "NS16:Fitness1" and command == ".." then
            system("/Users/pascal/Galaxy/LucilleOS/Binaries/fitness doing #{object["fitness-domain"]}")
        end

        if object["NS198"] == "NS16:Inbox1" and command == ".." then
            Inbox::run(object["location"])
        end

        if object["NS198"] == "NS16:Inbox1" and command == ">>" then
            location = object["location"]
            CommandsOps::transmutation2(location, "inbox")
        end

        if object["NS198"] == "NS16:TxDated" and command == ".." then
            TxDateds::run(object["TxDated"])
        end

        if object["NS198"] == "NS16:TxDated" and command == "done" then
            mx49 = object["TxDated"]
            TxDateds::destroy(mx49["uuid"])
        end

        if object["NS198"] == "NS16:TxDated" and command == "redate" then
            mx49 = object["TxDated"]
            datetime = (Utils::interactivelySelectAUTCIso8601DateTimeOrNull() || Time.new.utc.iso8601)
            Librarian::updateMikuDatetime(mx49["uuid"], datetime)
        end

        if object["NS198"] == "NS16:TxDated" and command == ">>" then
            mx49 = object["TxDated"]
            CommandsOps::transmutation2(mx49, "TxDated")
        end

        if object["NS198"] == "NS16:TxDated" and command == "''" then
            mx49 = object["TxDated"]
            ItemStoreOps::delistForDefault(mx49["uuid"])
        end

        if object["NS198"] == "NS16:TxDrop" and command == ".." then
            nx70 = object["TxDrop"]
            action = LucilleCore::selectEntityFromListOfEntitiesOrNull("action", ["run", "done"])
            return if action.nil?
            if action == "run" then
                TxDrops::run(nx70)
            end
            if action == "done" then
                TxDrops::destroy(nx70["uuid"])
            end
        end

        if object["NS198"] == "NS16:TxDrop" and command == "done" then
            nx70 = object["TxDrop"]
            TxDrops::destroy(nx70["uuid"])
        end

        if object["NS198"] == "NS16:TxDrop" and command == "''" then
            nx70 = object["TxDrop"]
            ItemStoreOps::delistForDefault(nx70["uuid"])
        end

        if object["NS198"] == "NS16:TxDrop" and command == ">>" then
            nx70 = object["TxDrop"]
            CommandsOps::transmutation2(nx70, "TxDrop")
        end

        if object["NS198"] == "NS16:TxFloat" and command == ".." then
            TxFloats::run(object["TxFloat"])
        end

        if object["NS198"] == "NS16:TxSpaceship" and command == ".." then
            nx60 = object["TxSpaceship"]
            TxSpaceships::run(nx60)
        end

        if object["NS198"] == "NS16:TxSpaceship" and command == "''" then
            nx60 = object["TxSpaceship"]
            ItemStoreOps::delistForDefault(nx60["uuid"])
        end

        if object["NS198"] == "NS16:TxSpaceship" and command == ">>" then
            nx60 = object["TxSpaceship"]
            CommandsOps::transmutation2(nx60, "TxSpaceship")
        end

        if object["NS198"] == "NS16:TxTodo" and command == ".." then
            TxTodos::run(object["TxTodo"])
        end

        if object["NS198"] == "NS16:TxTodo" and command == "done" then
            nx50 = object["TxTodo"]
            if LucilleCore::askQuestionAnswerAsBoolean("destroy '#{TxTodos::toString(nx50)}' ? ", true) then
                TxTodos::destroy(nx50["uuid"])
                CommandsOps::closeAnyNxBallWithThisID(object["uuid"])
            end
        end

        if object["NS198"] == "NS16:TxWorkItem" and command == ".." then
            TxWorkItems::run(object["TxWorkItem"])
        end

        if object["NS198"] == "NS16:TxWorkItem" and command == "done" then
            mx51 = object["TxWorkItem"]
            if LucilleCore::askQuestionAnswerAsBoolean("destroy '#{TxWorkItems::toString(mx51)}' ? ", true) then
                TxWorkItems::destroy(mx51["uuid"])
                CommandsOps::closeAnyNxBallWithThisID(object["uuid"])
            end
        end

        if object["NS198"] == "NS16:TxWorkItem" and command == ">>" then
            mx51 = object["TxWorkItem"]
            CommandsOps::transmutation2(mx51, "TxWorkItem")
        end

        if object["NS198"] == "NS16:Wave1" and command == ".." then
            Waves::run(object["wave"])
        end

        if object["NS198"] == "NS16:Wave1" and command == "landing" then
            Waves::landing(object["wave"])
        end

        if object["NS198"] == "NS16:Wave1" and command == "done" then
            Waves::performDone(object["wave"])
            CommandsOps::closeAnyNxBallWithThisID(object["uuid"])
        end

        if object["NS198"] == "NxBallDelegate1" and command == ".." then
            uuid = object["NxBallUUID"]

            action = LucilleCore::selectEntityFromListOfEntitiesOrNull("action", ["close", "pursue", "pause"])
            if action == "close" then
                NxBallsService::close(uuid, true)
            end
            if action == "pursue" then
                NxBallsService::pursue(uuid)
            end
            if action == "pause" then
                NxBallsService::pause(uuid)
            end
        end

        if Interpreting::match("require internet", command) then
            InternetStatus::markIdAsRequiringInternet(object["uuid"])
        end
    end

    # CommandsOps::operator4(command)
    def self.operator4(command)

        if command == "start" then
            description = LucilleCore::askQuestionAnswerAsString("description (empty to abort): ")
            return if description == ""
            account = DomainsX::selectAccount()
            NxBallsService::issue(SecureRandom.uuid, description, [account])
        end

        if command == "float" then
            TxFloats::interactivelyCreateNewOrNull()
        end

        if command == "spaceship" then
            TxSpaceships::interactivelyCreateNewOrNull()
        end

        if command == "drop" then
            TxDrops::interactivelyCreateNewOrNull()
        end

        if Interpreting::match("ondate", command) then
            item = TxDateds::interactivelyCreateNewOrNull()
            return if item.nil?
            puts JSON.pretty_generate(item)
        end

        if command == "today" then
            mx49 = TxDateds::interactivelyCreateNewTodayOrNull()
            return if mx49.nil?
            puts JSON.pretty_generate(mx49)
        end

        if command == "todo" then
            type = LucilleCore::selectEntityFromListOfEntitiesOrNull("type", ["TxTodo", "TxWorkItems"])
            if type == "TxTodo" then
                item = TxTodos::interactivelyCreateNewOrNull()
                return if item.nil?
                puts JSON.pretty_generate(item)
            end
            if type == "TxWorkItems" then
                item = TxWorkItems::interactivelyCreateNewOrNull()
                return if item.nil?
                puts JSON.pretty_generate(item)
            end
        end

        if Interpreting::match("wave", command) then
            item = Waves::issueNewWaveInteractivelyOrNull()
            return if item.nil?
            puts JSON.pretty_generate(item)
        end

        if Interpreting::match("anniversary", command) then
            item = Anniversaries::issueNewAnniversaryOrNullInteractively()
            return if item.nil?
            puts JSON.pretty_generate(item)
        end

        if Interpreting::match("anniversaries", command) then
            Anniversaries::anniversariesDive()
        end

        if Interpreting::match("calendar", command) then
            Calendar::main()
        end

        if Interpreting::match("waves", command) then
            Waves::waves()
        end

        if Interpreting::match("ondates", command) then
            TxDateds::dive()
        end

        if Interpreting::match("todos", command) then
            type = LucilleCore::selectEntityFromListOfEntitiesOrNull("type", ["TxTodos", "Nx51s (work items)"])
            if type == "TxTodos" then
                nx50s = TxTodos::nx50s()
                if LucilleCore::askQuestionAnswerAsBoolean("limit ? ", true) then
                    nx50s = nx50s.first(Utils::screenHeight()-2)
                end
                loop {
                    nx50 = LucilleCore::selectEntityFromListOfEntitiesOrNull("nx50", nx50s, lambda {|nx50| TxTodos::toString(nx50) })
                    return if nx50.nil?
                    TxTodos::run(nx50)
                }
            end
            if type == "Nx51s (work items)" then
                mx51s = TxWorkItems::items()
                if LucilleCore::askQuestionAnswerAsBoolean("limit ? ", true) then
                    mx51s = mx51s.first(Utils::screenHeight()-2)
                end
                loop {
                    mx51 = LucilleCore::selectEntityFromListOfEntitiesOrNull("mx51", mx51s, lambda {|mx51| TxWorkItems::toString(mx51) })
                    return if mx51.nil?
                    TxWorkItems::run(mx51)
                }
            end

        end

        if Interpreting::match("search", command) then
            Search::search()
        end

        if Interpreting::match("nyx", command) then
            system("/Users/pascal/Galaxy/Software/Nyx/nyx")
        end

        if command == "commands" then
            puts [
                    "      " + Commands::terminalDisplayCommand(),
                    "      " + Commands::makersCommands(),
                    "      " + Commands::diversCommands(),
                    "      internet on | internet off | require internet"
                 ].join("\n").yellow
            LucilleCore::pressEnterToContinue()
        end

        if Interpreting::match("internet on", command) then
            InternetStatus::setInternetOn()
        end

        if Interpreting::match("internet off", command) then
            InternetStatus::setInternetOff()
        end

        if Interpreting::match("focus eva", command) then
            KeyValueStore::set(nil, "c68fc8de-81fd-4e76-b995-e171d0374661:#{Utils::today()}", "eva")
        end

        if Interpreting::match("focus work", command) then
            KeyValueStore::set(nil, "c68fc8de-81fd-4e76-b995-e171d0374661:#{Utils::today()}", "work")
        end

        if Interpreting::match("focus null", command) then
            KeyValueStore::destroy(nil, "c68fc8de-81fd-4e76-b995-e171d0374661:#{Utils::today()}")
        end

        if Interpreting::match("exit", command) then
            exit
        end
    end

    # CommandsOps::transmutation1(object, source, target)
    # source: "TxDated" (dated) | "TxTodo" | "TxWorkItem" | "TxFloat" (float) | "inbox"
    # target: "TxDated" (dated) | "TxTodo" | "TxWorkItem" | "TxFloat" (float)
    def self.transmutation1(object, source, target)

        if source == "inbox" and target == "TxTodo" then
            location = object
            description = Inbox::interactivelyDecideBestDescriptionForLocation(location)
            ordinal = TxTodos::interactivelyDecideNewOrdinal()
            atom = CoreData5::issueAionPointAtomUsingLocation(location)
            nx50 = {
                "uuid"        => SecureRandom.uuid,
                "unixtime"    => Time.new.to_i,
                "ordinal"     => ordinal,
                "description" => description,
                "atom"        => atom
            }
            TxTodos::commit(nx50)
            LucilleCore::removeFileSystemLocation(location)
            return
        end

        if source == "inbox" and target == "TxWorkItem" then
            location = object
            description = Inbox::interactivelyDecideBestDescriptionForLocation(location)
            ordinal = TxWorkItems::interactivelyDecideNewOrdinal()
            atom = CoreData5::issueAionPointAtomUsingLocation(location)
            mx51 = {
                "uuid"        => SecureRandom.uuid,
                "unixtime"    => Time.new.to_i,
                "ordinal"     => ordinal,
                "description" => description,
                "atom"        => atom
            }
            TxWorkItems::commit(mx51)
            LucilleCore::removeFileSystemLocation(location)
            return
        end

        if source == "TxDated" and target == "TxTodo" then
            mx49 = object
            ordinal = TxTodos::interactivelyDecideNewOrdinal()
            nx50 = {
                "uuid"        => SecureRandom.uuid,
                "unixtime"    => Time.new.to_i,
                "ordinal"     => ordinal,
                "description" => mx49["description"],
                "atom"        => mx49["atom"]
            }
            TxTodos::commit(nx50)
            TxDateds::destroy(mx49["uuid"])
            return
        end

        if source == "TxDated" and target == "TxSpaceship" then
            Librarian::updateMikuClassification(object["uuid"], "CatalystTxSpaceship")
            return
        end

        if source == "TxDated" and target == "TxDrop" then
            Librarian::updateMikuClassification(object["uuid"], "CatalystTxDrop")
            return
        end

        if source == "TxDrop" and target == "TxWorkItem" then
            ordinal = TxWorkItems::interactivelyDecideNewOrdinal()
            mx51 = {
                "uuid"        => SecureRandom.uuid,
                "unixtime"    => Time.new.to_i,
                "ordinal"     => ordinal,
                "description" => object["description"],
                "atom"        => object["atom"]
            }
            TxWorkItems::commit(mx51)
            TxDrops::destroy(object["uuid"])
            return
        end

        if source == "TxDrop" and target == "TxSpaceship" then
            Librarian::updateMikuClassification(object["uuid"], "CatalystTxSpaceship")
            return
        end

        if source == "TxSpaceship" and target == "TxFloat" then
            Librarian::updateMikuClassification(object["uuid"], "CatalystTxFloat")
            return
        end

        if source == "TxSpaceship" and target == "TxDated" then
            datetime = Utils::interactivelySelectAUTCIso8601DateTimeOrNull()
            return if datetime.nil?
            Librarian::updateMikuClassification(object["uuid"], "CatalystTxDated")
            Librarian::updateMikuDatetime(object["uuid"], datetime)
            return
        end

        if source == "TxWorkItem" and target == "TxFloat" then
            uuid           = SecureRandom.uuid
            description    = object["description"]
            atom           = object["atom"]
            unixtime       = Time.new.to_i
            datetime       = Time.new.utc.iso8601
            classification = "CatalystTxFloat"
            extras = {
                "domainx" => object["domainx"]
            }
            Librarian::spawnNewMikuFileOrError(uuid, description, unixtime, datetime, classification, atom, extras)
            Librarian::getMikuOrNull(uuid)

            TxWorkItems::destroy(object["uuid"])
            return
        end

        puts "I do not yet know how to transmute from '#{source}' to '#{target}'"
        LucilleCore::pressEnterToContinue()
    end

    # CommandsOps::interactivelyGetTransmutationTargetOrNull()
    def self.interactivelyGetTransmutationTargetOrNull()
        options = ["TxFloat", "TxDated", "TxSpaceship", "TxTodo", "TxWorkItem", ]
        option = LucilleCore::selectEntityFromListOfEntitiesOrNull("target", options)
        return nil if option.nil?
        option
    end

    # CommandsOps::transmutation2(object, source)
    def self.transmutation2(object, source)
        target = CommandsOps::interactivelyGetTransmutationTargetOrNull()
        return if target.nil?
        CommandsOps::transmutation1(object, source, target)
    end
end
