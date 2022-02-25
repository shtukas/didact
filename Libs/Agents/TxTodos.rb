# encoding: UTF-8

class TxTodoLibrarian # This class should not be renamed unless also updated in LibrarianObjects

    # TxTodoLibrarian::getTxTodoObjectsByUniverseLimitByOrdinal(universe, n)
    def self.getTxTodoObjectsByUniverseLimitByOrdinal(universe, n)
        db = SQLite3::Database.new("/Users/pascal/Galaxy/DataBank/Catalyst/TxTdo-Objects.sqlite3")
        db.busy_timeout = 117
        db.busy_handler { |count| true }
        db.results_as_hash = true
        answer = []
        db.execute("select * from _objects_ where _mikuType_=? and _universe_=? order by _ordinal_ limit ?", ["TxTodo", universe, n]) do |row|
            answer << JSON.parse(row['_object_'])
        end
        db.close
        answer
    end

    # TxTodoLibrarian::commit(object)
    def self.commit(object)

        # We also make a last effort to help with a problem TxTodos in Catalyst had.

        # Object.const_defined?('Multiverse') ensures that we are calling `LibrarianObjects::commit` 
        # from within Catalyst.

        # One would argue that this code should be in TxCode in Catalyst, but with transmutations 
        # we could not guarantee that we knew all the places `LibrarianObjects::commit` is called from
        # on a TxTodo.

        # TxTdo-Objects.sqlite3
        # CREATE TABLE _objects_ (_objectuuid_ text primary key, _mikuType_ text, _object_ string, _ordinal_ float, _universe_ string);

        ordinal = object["ordinal"] || 0
        universe = Multiverse::getUniverseOrDefault(object["uuid"])

        db = SQLite3::Database.new("/Users/pascal/Galaxy/DataBank/Catalyst/TxTdo-Objects.sqlite3")
        db.execute "delete from _objects_ where _objectuuid_=?", [object["uuid"]]
        db.execute "insert into _objects_ (_objectuuid_, _mikuType_, _object_, _ordinal_, _universe_) values (?,?,?,?,?)", [object["uuid"], object["mikuType"], JSON.generate(object), ordinal, universe]
        db.close
    end
end

class TxTodos

    # TxTodos::items()
    def self.items()
        LibrarianObjects::getObjectsByMikuType("TxTodo")
    end

    # TxTodos::itemsForUniverse(universe)
    def self.itemsForUniverse(universe)
        TxTodos::items().select{|item| Multiverse::getUniverseOrDefault(item["uuid"]) == universe }
    end

    # TxTodos::itemsCardinal(n)
    def self.itemsCardinal(n)
        LibrarianObjects::getObjectsByMikuTypeLimitByOrdinal("TxTodo", n)
    end

    # TxTodos::itemsForUniverseWithCardinal(universe, n)
    def self.itemsForUniverseWithCardinal(universe, n)
        TxTodoLibrarian::getTxTodoObjectsByUniverseLimitByOrdinal(universe, n)
    end

    # TxTodos::destroy(uuid)
    def self.destroy(uuid)
        LibrarianObjects::destroy(uuid)

        db = SQLite3::Database.new("/Users/pascal/Galaxy/DataBank/Catalyst/TxTdo-Objects.sqlite3")
        db.execute "delete from _objects_ where _objectuuid_=?", [uuid]
        db.close
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

        atom       = CoreData5::interactivelyCreateNewAtomOrNull()
        return nil if atom.nil?

        LibrarianObjects::commit(atom)

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
        LibrarianObjects::commit(item)
        Multiverse::setObjectUniverse(uuid, universe)
        item
    end

    # TxTodos::interactivelyIssueItemUsingInboxLocation2(location)
    def self.interactivelyIssueItemUsingInboxLocation2(location)
        uuid        = SecureRandom.uuid
        description = Inbox::interactivelyDecideBestDescriptionForLocation(location)
        unixtime    = Time.new.to_i
        datetime    = Time.new.utc.iso8601
        atom        = CoreData5::issueAionPointAtomUsingLocation(location)
        LibrarianObjects::commit(atom)

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
        LibrarianObjects::commit(item)
        Multiverse::setObjectUniverse(uuid, universe)
        item
    end

    # TxTodos::issueSpreadItem(location, description, ordinal)
    def self.issueSpreadItem(location, description, ordinal)
        uuid       = SecureRandom.uuid
        unixtime   = Time.new.to_i
        datetime   = Time.new.utc.iso8601
        atom       = CoreData5::issueAionPointAtomUsingLocation(location)
        LibrarianObjects::commit(atom)
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
        LibrarianObjects::commit(item)
        Multiverse::setObjectUniverse(uuid, "xstream")
        item
    end

    # TxTodos::issueViennaURL(url)
    def self.issueViennaURL(url)
        uuid        = SecureRandom.uuid
        description = url
        unixtime    = Time.new.to_i
        datetime    = Time.new.utc.iso8601
        atom        = CoreData5::issueUrlAtomUsingUrl(url)
        LibrarianObjects::commit(atom)
        ordinal     = TxTodos::ordinalBetweenN1thAndN2th("xstream", 20, 30)

        item = {
          "uuid"        => uuid,
          "mikuType"    => "TxTodo",
          "description" => description,
          "unixtime"    => unixtime,
          "datetime"    => datetime,
          "atomuuid"    => atom["uuid"],
          "ordinal"     => ordinal
        }
        LibrarianObjects::commit(item)
        Multiverse::setObjectUniverse(uuid, "xstream")
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
        "[todo] (#{"%4.2f" % rt}) #{nx50["description"]}#{AgentsUtils::atomTypeForToStrings(" ", nx50["atomuuid"])} (#{Multiverse::getObjectUniverseOrNull(nx50["uuid"])})"
    end

    # TxTodos::toStringForNS19(nx50)
    def self.toStringForNS19(nx50)
        "[nx50] #{nx50["description"]}"
    end

    # --------------------------------------------------
    # Operations

    # TxTodos::importspread()
    # We are not running this automatically, we do manual runs from nslog 
    def self.importspread()
        locations = LucilleCore::locationsAtFolder("/Users/pascal/Galaxy/DataBank/Catalyst/TxTodos Spread")
 
        if locations.size > 0 then

            puts "Starting to import spread (first item: #{locations.first})"
 
            ordinals = TxTodos::items().map{|item| item["ordinal"] }
 
            if ordinals.size < 2 then
                start1 = ordinals.max + 1
                end1   = ordinals.max + 1 + locations.size
            else
                start1 = ordinals.min
                end1   = ordinals.max + 1
            end
 
            spread = end1 - start1
 
            step = spread.to_f/locations.size
 
            cursor = start1
 
            locations.each{|location|
                cursor = cursor + step
                puts "[quark] (#{cursor}) #{location}"
                TxTodos::issueSpreadItem(location, File.basename(location), cursor)
                LucilleCore::removeFileSystemLocation(location)
            }
        end
    end

    # TxTodos::run(nx50)
    def self.run(nx50)

        system("clear")

        uuid = nx50["uuid"]

        NxBallsService::issue(uuid, nx50["description"], [uuid])

        loop {

            system("clear")

            puts "#{TxTodos::toString(nx50)}#{NxBallsService::runningStringOrEmptyString(" (", uuid, ")")}".green
            puts "uuid: #{uuid}".yellow
            puts "universe: #{Multiverse::getObjectUniverseOrNull(uuid)}".yellow
            puts "ordinal: #{nx50["ordinal"]}".yellow

            puts "DoNotDisplayUntil: #{DoNotShowUntil::getDateTimeOrNull(nx50["uuid"])}".yellow
            puts "RT: #{BankExtended::stdRecoveredDailyTimeInHours(uuid)}".yellow

            LibrarianNotes::getObjectNotes(uuid).each{|note|
                puts "note: #{note["text"]}"
            }

            AgentsUtils::atomLandingPresentation(nx50["atomuuid"])

            #Librarian::notes(uuid).each{|note|
            #    puts "note: #{note["text"]}"
            #}

            puts "access | <datecode> | description | atom | ordinal | rotate | transmute | note | universe | show json | >nyx | destroy (gg) | exit (xx)".yellow

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
                LibrarianObjects::commit(nx50)
                next
            end

            if Interpreting::match("atom", command) then
                atom = CoreData5::interactivelyCreateNewAtomOrNull()
                next if atom.nil?
                atom["uuid"] = nx50["atomuuid"]
                LibrarianObjects::commit(atom)
                next
            end

            if Interpreting::match("note", command) then
                text = Utils::editTextSynchronously("").strip
                LibrarianNotes::addNote(nx50["uuid"], text)
                next
            end

            if Interpreting::match("universe", command) then
                Multiverse::interactivelySetObjectUniverse(nx50["uuid"])
                break
            end

            if Interpreting::match("ordinal", command) then
                universe = Multiverse::interactivelySelectUniverse()
                ordinal = TxTodos::interactivelyDecideNewOrdinal(universe)
                nx50["ordinal"] = ordinal
                LibrarianObjects::commit(nx50)
                Multiverse::setObjectUniverse(nx50["uuid"], universe)
                next
            end

            if Interpreting::match("rotate", command) then
                universe = Multiverse::interactivelySelectUniverse()
                ordinal = TxTodos::nextOrdinal(universe)
                nx50["ordinal"] = ordinal
                LibrarianObjects::commit(nx50)
                Multiverse::setObjectUniverse(nx50["uuid"], universe)
                break
            end

            if Interpreting::match("transmute", command) then
                CommandsOps::transmutation2(nx50, "TxTodo")
                break
            end

            if Interpreting::match("show json", command) then
                puts JSON.pretty_generate(nx50)
                LucilleCore::pressEnterToContinue()
                break
            end

            if command == "destroy" then
                if LucilleCore::askQuestionAnswerAsBoolean("destroy '#{TxTodos::toString(nx50)}' ? ", true) then
                    TxTodos::destroy(nx50["uuid"])
                    break
                end
                next
            end

            if command == "gg" then
                if LucilleCore::askQuestionAnswerAsBoolean("destroy '#{TxTodos::toString(nx50)}' ? ", true) then
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

        NxBallsService::closeWithAsking(uuid)
    end

    # --------------------------------------------------
    # nx16s

    # TxTodos::ns16(nx50)
    def self.ns16(nx50)
        uuid = nx50["uuid"]
        rt = BankExtended::stdRecoveredDailyTimeInHours(uuid)
        {
            "uuid"     => uuid,
            "NS198"    => "NS16:TxTodo",
            "announce" => TxTodos::toStringForNS16(nx50, rt).gsub("(0.00)", "      "),
            "commands" => ["..", "done"],
            "ordinal"  => nx50["ordinal"],
            "TxTodo"   => nx50,
            "rt"       => rt
        }
    end

    # TxTodos::ns16s(universe)
    def self.ns16s(universe)
        TxTodos::itemsForUniverseWithCardinal(universe, 50)
            .select{|item| Multiverse::getUniverseOrDefault(item["uuid"]) == universe }
            .map{|item| TxTodos::ns16(item) }
    end

    # TxTodos::ns16sOverflowing(universe)
    def self.ns16sOverflowing(universe)
        TxTodos::itemsForUniverseWithCardinal(universe, 50)
            .select{|item| Multiverse::getUniverseOrDefault(item["uuid"]) == universe }
            .map{|item| TxTodos::ns16(item) }
            .select{|ns16| ns16["rt"] > 1 }
    end

    # --------------------------------------------------

    # TxTodos::nx19s()
    def self.nx19s()
        TxTodos::items().map{|item|
            {
                "uuid"     => item["uuid"],
                "announce" => TxTodos::toStringForNS19(item),
                "lambda"   => lambda { TxTodos::run(item) }
            }
        }
    end
end
