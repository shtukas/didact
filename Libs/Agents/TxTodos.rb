# encoding: UTF-8

class TxTodos

    # TxTodos::items()
    def self.items()
        Librarian6Objects::getObjectsByMikuType("TxTodo")
    end

    # TxTodos::itemsCardinal(n)
    def self.itemsCardinal(n)
        Librarian6Objects::getObjectsByMikuTypeLimitByOrdinal("TxTodo", n)
    end

    # TxTodos::itemsForUniverse(universe)
    def self.itemsForUniverse(universe)
        TxTodos::items()
            .select{|item| 
                objuniverse = ObjectUniverseMapping::getObjectUniverseMappingOrNull(item["uuid"])
                universe.nil? or objuniverse.nil? or (objuniverse == universe)
            }
    end

    # TxTodos::itemsForUniverseWithCardinal(universe, n)
    def self.itemsForUniverseWithCardinal(universe, n)
        TxTodos::itemsForUniverse(universe).first(n)
    end

    # TxTodos::destroy(uuid)
    def self.destroy(uuid)
        Librarian6Objects::destroy(uuid)
    end

    # --------------------------------------------------
    # Ordinals

    # TxTodos::nextOrdinal(universe)
    def self.nextOrdinal(universe)
        biggest = ([0] + TxTodos::itemsForUniverse(universe).map{|nx50| nx50["ordinal"] }).max
        (biggest + 1).floor
    end

    # TxTodos::ordinalBetweenN1thAndN2th(universe, n1, n2)
    def self.ordinalBetweenN1thAndN2th(universe, n1, n2)
        nx50s = TxTodos::itemsForUniverseWithCardinal(universe, n2)
        if nx50s.size < n1+2 then
            return TxTodos::nextOrdinal(universe)
        end
        ordinals = nx50s.map{|nx50| nx50["ordinal"] }.sort.drop(n1).take(n2-n1)
        ordinals.min + rand*(ordinals.max-ordinals.min)
    end

    # TxTodos::interactivelyDecideNewOrdinal(universe)
    def self.interactivelyDecideNewOrdinal(universe)
        action = LucilleCore::selectEntityFromListOfEntitiesOrNull("action", ["fine selection near the top", "random within [10-20] (default)", "next"])
        if action == "fine selection near the top" then
            TxTodos::itemsForUniverseWithCardinal(universe, 50)
                .each{|nx50| 
                    puts "- #{TxTodos::toStringWithOrdinal(nx50)}"
                }
            return LucilleCore::askQuestionAnswerAsString("> ordinal ? : ").to_f
        end
        if action == "random within [10-20] (default)" or action.nil? then
            return TxTodos::ordinalBetweenN1thAndN2th(universe, 10, 20)
        end
        if action == "next" then
            return TxTodos::nextOrdinal(universe)
        end
        raise "5fe95417-192b-4256-a021-447ba02be4aa"
    end

    # --------------------------------------------------
    # Makers

    # TxTodos::interactivelyCreateNewOrNull()
    def self.interactivelyCreateNewOrNull()
        description = LucilleCore::askQuestionAnswerAsString("description (empty to abort): ")
        return nil if description == ""

        atom       = Librarian5Atoms::interactivelyCreateNewAtomOrNull()
        return nil if atom.nil?

        Librarian6Objects::commit(atom)

        uuid       = SecureRandom.uuid
        unixtime   = Time.new.to_i
        datetime   = Time.new.utc.iso8601
        universe   = Multiverse::interactivelySelectUniverse()
        ordinal    = TxTodos::interactivelyDecideNewOrdinal(universe)

        item = {
          "uuid"        => uuid,
          "mikuType"    => "TxTodo",
          "description" => description,
          "unixtime"    => unixtime,
          "datetime"    => datetime,
          "atomuuid"    => atom["uuid"],
          "ordinal"     => ordinal
        }
        Librarian6Objects::commit(item)
        ObjectUniverseMapping::setObjectUniverseMapping(uuid, universe)
        item
    end

    # TxTodos::interactivelyIssueItemUsingInboxLocation2(location)
    def self.interactivelyIssueItemUsingInboxLocation2(location)
        uuid        = SecureRandom.uuid
        description = Inbox::interactivelyDecideBestDescriptionForLocation(location)
        unixtime    = Time.new.to_i
        datetime    = Time.new.utc.iso8601
        atom        = Librarian5Atoms::issueMatterAtomUsingLocation(SecureRandom.uuid, location)
        Librarian6Objects::commit(atom)

        universe    = Multiverse::interactivelySelectUniverse()
        ordinal     = TxTodos::interactivelyDecideNewOrdinal(universe)

        item = {
          "uuid"        => uuid,
          "mikuType"    => "TxTodo",
          "description" => description,
          "unixtime"    => unixtime,
          "datetime"    => datetime,
          "atomuuid"    => atom["uuid"],
          "ordinal"     => ordinal
        }
        Librarian6Objects::commit(item)
        ObjectUniverseMapping::setObjectUniverseMapping(uuid, universe)
        item
    end

    # TxTodos::issueSpreadItem(location, description, ordinal)
    def self.issueSpreadItem(location, description, ordinal)
        uuid       = SecureRandom.uuid
        unixtime   = Time.new.to_i
        datetime   = Time.new.utc.iso8601
        atom       = Librarian5Atoms::issueMatterAtomUsingLocation(SecureRandom.uuid, location)
        Librarian6Objects::commit(atom)
        ordinal    = ordinal

        item = {
          "uuid"        => uuid,
          "mikuType"    => "TxTodo",
          "description" => description,
          "unixtime"    => unixtime,
          "datetime"    => datetime,
          "atomuuid"    => atom["uuid"],
          "ordinal"     => ordinal
        }
        Librarian6Objects::commit(item)
        ObjectUniverseMapping::setObjectUniverseMapping(uuid, "backlog")
        item
    end

    # TxTodos::issueViennaURL(url)
    def self.issueViennaURL(url)
        uuid        = SecureRandom.uuid
        description = url
        unixtime    = Time.new.to_i
        datetime    = Time.new.utc.iso8601
        atom        = Librarian5Atoms::issueUrlAtomUsingUrl(url)
        Librarian6Objects::commit(atom)

        ordinal     = TxTodos::ordinalBetweenN1thAndN2th("backlog", 20, 30)

        item = {
          "uuid"        => uuid,
          "mikuType"    => "TxTodo",
          "description" => description,
          "unixtime"    => unixtime,
          "datetime"    => datetime,
          "atomuuid"    => atom["uuid"],
          "ordinal"     => ordinal
        }
        Librarian6Objects::commit(item)
        ObjectUniverseMapping::setObjectUniverseMapping(uuid, "backlog")
        item
    end

    # --------------------------------------------------
    # toString

    # TxTodos::toString(nx50)
    def self.toString(nx50)
        "[nx50] #{nx50["description"]}#{AgentsUtils::atomTypeForToStrings(" ", nx50["atomuuid"])}"
    end

    # TxTodos::toStringWithOrdinal(nx50)
    def self.toStringWithOrdinal(nx50)
        "[nx50] (ord: #{nx50["ordinal"]}) #{nx50["description"]}#{AgentsUtils::atomTypeForToStrings(" ", nx50["atomuuid"])}"
    end

    # TxTodos::toStringForNS16(nx50, rt)
    def self.toStringForNS16(nx50, rt)
        "[todo] (#{"%4.2f" % rt}) #{nx50["description"]}#{AgentsUtils::atomTypeForToStrings(" ", nx50["atomuuid"])} (#{ObjectUniverseMapping::getObjectUniverseMappingOrNull(nx50["uuid"])})"
    end

    # TxTodos::toStringForNS19(nx50)
    def self.toStringForNS19(nx50)
        "[nx50] #{nx50["description"]}"
    end

    # --------------------------------------------------
    # Operations

    # TxTodos::access(nx50)
    def self.access(nx50)

        system("clear")

        uuid = nx50["uuid"]

        loop {

            system("clear")

            puts "#{TxTodos::toString(nx50)}#{NxBallsService::runningStringOrEmptyString(" (", uuid, ")")}".green
            puts "uuid: #{uuid}".yellow
            puts "universe: #{ObjectUniverseMapping::getObjectUniverseMappingOrNull(uuid)}".yellow
            puts "ordinal: #{nx50["ordinal"]}".yellow

            puts "DoNotDisplayUntil: #{DoNotShowUntil::getDateTimeOrNull(nx50["uuid"])}".yellow
            puts "RT: #{BankExtended::stdRecoveredDailyTimeInHours(uuid)}".yellow

            Librarian7Notes::getObjectNotes(uuid).each{|note|
                puts "note: #{note["text"]}"
            }

            AgentsUtils::atomLandingPresentation(nx50["atomuuid"])

            #Librarian::notes(uuid).each{|note|
            #    puts "note: #{note["text"]}"
            #}

            puts "access | <datecode> | description | atom | ordinal | rotate | transmute | note | notes | universe | show json | >nyx | destroy (gg) | exit (xx)".yellow

            command = LucilleCore::askQuestionAnswerAsString("> ")

            break if command == "exit"
            break if command == "xx"

            if (unixtime = Utils::codeToUnixtimeOrNull(command.gsub(" ", ""))) then
                DoNotShowUntil::setUnixtime(uuid, unixtime)
                break
            end

            if Interpreting::match("access", command) then
                AgentsUtils::accessAtom(nx50["atomuuid"])
                next
            end

            if Interpreting::match("description", command) then
                description = Utils::editTextSynchronously(nx50["description"]).strip
                next if description == ""
                nx50["description"] = description
                Librarian6Objects::commit(nx50)
                next
            end

            if Interpreting::match("atom", command) then
                atom = Librarian5Atoms::interactivelyCreateNewAtomOrNull()
                next if atom.nil?
                atom["uuid"] = nx50["atomuuid"]
                Librarian6Objects::commit(atom)
                next
            end

            if Interpreting::match("note", command) then
                text = Utils::editTextSynchronously("").strip
                Librarian7Notes::addNote(nx50["uuid"], text)
                next
            end

            if Interpreting::match("notes", command) then
                Librarian7Notes::notesLanding(nx50["uuid"])
                next
            end

            if Interpreting::match("universe", command) then
                ObjectUniverseMapping::interactivelySetObjectUniverseMapping(nx50["uuid"])
                break
            end

            if Interpreting::match("ordinal", command) then
                universe = Multiverse::interactivelySelectUniverse()
                ordinal = TxTodos::interactivelyDecideNewOrdinal(universe)
                nx50["ordinal"] = ordinal
                Librarian6Objects::commit(nx50)
                ObjectUniverseMapping::setObjectUniverseMapping(nx50["uuid"], universe)
                next
            end

            if Interpreting::match("rotate", command) then
                universe = Multiverse::interactivelySelectUniverse()
                ordinal = TxTodos::nextOrdinal(universe)
                nx50["ordinal"] = ordinal
                Librarian6Objects::commit(nx50)
                ObjectUniverseMapping::setObjectUniverseMapping(nx50["uuid"], universe)
                break
            end

            if Interpreting::match("transmute", command) then
                TerminalUtils::transmutation2(nx50, "TxTodo")
                break
            end

            if Interpreting::match("show json", command) then
                puts JSON.pretty_generate(nx50)
                LucilleCore::pressEnterToContinue()
                break
            end

            if command == "destroy" or command == "gg" then
                if LucilleCore::askQuestionAnswerAsBoolean("destroy '#{TxTodos::toString(nx50)}' ? ", true) then
                    NxBallsService::close(nx50["uuid"], true)
                    TxTodos::destroy(nx50["uuid"])
                    break
                end
                next
            end

            if command == ">nyx" then
                NyxAdapter::nx50ToNyx(nx50)
                break
            end
        }
    end

    # TxTodos::importNx50BacklogInbox()
    def self.importNx50BacklogInbox()
        LucilleCore::locationsAtFolder("/Users/pascal/Desktop/Nx50 Backlog Inbox").each{|location|
            next if File.basename(location).start_with?(".")

            puts "> importing: #{location}"

            uuid        = SecureRandom.uuid
            description = File.basename(location)
            unixtime    = Time.new.to_i
            datetime    = Time.new.utc.iso8601
            atom        = Librarian5Atoms::issueMatterAtomUsingLocation(SecureRandom.uuid, location)
            Librarian6Objects::commit(atom)

            universe    = "backlog"
            ordinal     = TxTodos::ordinalBetweenN1thAndN2th(universe, 10, 20)

            item = {
              "uuid"        => uuid,
              "mikuType"    => "TxTodo",
              "description" => description,
              "unixtime"    => unixtime,
              "datetime"    => datetime,
              "atomuuid"    => atom["uuid"],
              "ordinal"     => ordinal
            }
            Librarian6Objects::commit(item)
            ObjectUniverseMapping::setObjectUniverseMapping(uuid, universe)

            check = lambda{|itemuuid|
                puts "fsck: itemuuid: #{itemuuid}"
                item = Librarian6Objects::getObjectByUUIDOrNull(itemuuid)
                return [false, "could not extract item"] if item.nil?
                atomuuid = item["atomuuid"]
                atom = Librarian6Objects::getObjectByUUIDOrNull(atomuuid)
                return [false, "could not extract atom"] if atom.nil?
                status = Librarian5Atoms::fsck(atom)
                return [false, "atom fsck failed"]
                return [true, nil]
            }

            raise "(error: ce75724f-4905-4808-91d9-33c8e82d4dde)" if !check.call(item["uuid"])

            LucilleCore::removeFileSystemLocation(location)
        }
    end

    # --------------------------------------------------
    # nx16s

    # TxTodos::ns16(nx50)
    def self.ns16(nx50)
        uuid = nx50["uuid"]
        rt = BankExtended::stdRecoveredDailyTimeInHours(uuid)
        {
            "uuid"     => uuid,
            "mikuType" => "NS16:TxTodo",
            "announce" => TxTodos::toStringForNS16(nx50, rt).gsub("(0.00)", "      "),
            "ordinal"  => nx50["ordinal"],
            "TxTodo"   => nx50,
            "rt"       => rt,
            "nonListingDefaultable" => (rt > 1)
        }
    end

    # TxTodos::ns16s(universe)
    def self.ns16s(universe)
        makeItems = lambda {|universe|
            key = "a489d77e-255e-467f-a302-7ead5337f005:#{$GENERAL_SYSTEM_RUN_ID}:#{universe}"
            items = KeyValueStore::getOrNull(nil, key)
            if items then
                items = JSON.parse(items)
            else
                puts "> computing items from scratch @ universe: #{universe}"
                items =
                    if universe then
                        TxTodos::itemsForUniverseWithCardinal(universe, 50)
                    else
                        TxTodos::itemsCardinal(100)
                    end
                KeyValueStore::set(nil, key, JSON.generate(items))
            end
            items
                .select{|item| Librarian6Objects::getObjectByUUIDOrNull(item["uuid"]) }
                .compact
        }

        ns16s = makeItems.call(universe)
            .select{|item| 
                objuniverse = ObjectUniverseMapping::getObjectUniverseMappingOrNull(item["uuid"])
                universe.nil? or objuniverse.nil? or (objuniverse == universe)
            }
            .map{|item| TxTodos::ns16(item) }

        ns16s1 = ns16s.take(5)
        ns16s2 = ns16s.drop(5)

        ns16s1 = ns16s1.sort{|x1, x2| x1["rt"] <=> x2["rt"] }

        ns16s1 + ns16s2
    end

    # --------------------------------------------------

    # TxTodos::nx19s()
    def self.nx19s()
        Librarian6Objects::getObjectsByMikuType("TxTodo").map{|item|
            {
                "uuid"     => item["uuid"],
                "announce" => TxTodos::toStringForNS19(item),
                "lambda"   => lambda { TxTodos::access(item) }
            }
        }
    end
end
