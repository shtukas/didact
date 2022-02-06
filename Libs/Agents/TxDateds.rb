# encoding: UTF-8

class TxDateds

    # TxDateds::items()
    def self.items()
        LibrarianObjects::getObjectsByMikuType("TxDated")
    end

    # TxDateds::destroy(uuid)
    def self.destroy(uuid)
        LibrarianObjects::destroy(uuid)
    end

    # --------------------------------------------------
    # Makers

    # TxDateds::interactivelyCreateNewOrNull()
    def self.interactivelyCreateNewOrNull()
        description = LucilleCore::askQuestionAnswerAsString("description (empty to abort): ")
        return nil if description == ""

        datetime = Utils::interactivelySelectAUTCIso8601DateTimeOrNull()
        return nil if datetime.nil?

        atom = Atoms5::interactivelyCreateNewAtomOrNull()
        return nil if atom.nil?

        uuid       = SecureRandom.uuid
        unixtime   = Time.new.to_i
        datetime   = datetime
        domainx    = DomainsX::interactivelySelectDomainX()

        item = {
          "uuid"        => uuid,
          "mikuType"    => "TxDated",
          "description" => description,
          "unixtime"    => unixtime,
          "datetime"    => datetime,
          "atomuuid"    => atom["uuid"],
          "domainx"     => domainx
        }
        LibrarianObjects::commit(item)
        item
    end

    # TxDateds::interactivelyCreateNewTodayOrNull()
    def self.interactivelyCreateNewTodayOrNull()
        description = LucilleCore::askQuestionAnswerAsString("description (empty to abort): ")
        return nil if description == ""

        atom = Atoms5::interactivelyCreateNewAtomOrNull()
        return nil if atom.nil?

        uuid       = SecureRandom.uuid
        unixtime   = Time.new.to_i
        datetime   = Time.new.utc.iso8601
        domainx    = DomainsX::interactivelySelectDomainX()

        item = {
          "uuid"        => uuid,
          "mikuType"    => "TxDated",
          "description" => description,
          "unixtime"    => unixtime,
          "datetime"    => datetime,
          "atomuuid"    => atom["uuid"],
          "domainx"     => domainx
        }
        LibrarianObjects::commit(item)
        item
    end

    # --------------------------------------------------
    # toString

    # TxDateds::toString(mx49)
    def self.toString(mx49)
        "(ondate) [#{mx49["datetime"][0, 10]}] #{mx49["description"]}"
    end

    # TxDateds::toStringForNS19(mx49)
    def self.toStringForNS19(mx49)
        "[date] #{mx49["description"]}"
    end

    # --------------------------------------------------
    # Operations

    # TxDateds::run(mx49)
    def self.run(mx49)

        system("clear")

        uuid = mx49["uuid"]

        NxBallsService::issue(
            uuid, 
            TxDateds::toString(mx49), 
            [uuid, DomainsX::domainXToAccountNumber(mx49["domainx"])]
        )

        loop {

            system("clear")

            puts TxDateds::toString(mx49).green
            puts "uuid: #{uuid}".yellow
            puts "date: #{mx49["datetime"][0, 10]}".yellow
            puts "domain: #{mx49["domainx"]}".yellow

            AgentsUtils::atomLandingPresentation(mx49["atomuuid"])

            #Librarian::notes(uuid).each{|note|
            #    puts "note: #{note["text"]}"
            #}

            puts "access | date | description | atom | note | show json | destroy (gg) | exit (xx)".yellow

            command = LucilleCore::askQuestionAnswerAsString("> ")

            break if command == "exit"
            break if command == "xx"

            if Interpreting::match("access", command) then
                AgentsUtils::accessAtom(mx49["atomuuid"])
                next
            end

            if Interpreting::match("date", command) then
                datetime = Utils::interactivelySelectAUTCIso8601DateTimeOrNull()
                next if datetime.nil?
                mx49["datetime"] = datetime
                LibrarianObjects::commit(mx49)
                next
            end

            if Interpreting::match("description", command) then
                description = Utils::editTextSynchronously(mx49["description"]).strip
                next if description == ""
                mx49["description"] = description
                LibrarianObjects::commit(mx49)
                next
            end

            if Interpreting::match("atom", command) then
                atom = Atoms5::interactivelyCreateNewAtomOrNull()
                next if atom.nil?
                atom["uuid"] = mx49["atomuuid"]
                LibrarianObjects::commit(atom)
                next
            end

            if Interpreting::match("note", command) then
            #    text = Utils::editTextSynchronously("").strip
            #    Librarian::addNote(mx49["uuid"], SecureRandom.uuid, Time.new.to_i, text)
            #    next
            end

            if Interpreting::match("show json", command) then
                puts JSON.pretty_generate(mx49)
                LucilleCore::pressEnterToContinue()
                break
            end

            if command == "destroy" then
                if LucilleCore::askQuestionAnswerAsBoolean("destroy '#{TxDateds::toString(mx49)}' ? ", true) then
                    TxDateds::destroy(mx49["uuid"])
                    break
                end
                next
            end

            if command == "gg" then
                if LucilleCore::askQuestionAnswerAsBoolean("destroy '#{TxDateds::toString(mx49)}' ? ", true) then
                    TxDateds::destroy(mx49["uuid"])
                    break
                end
                next
            end
        }

        NxBallsService::closeWithAsking(uuid)
    end

    # TxDateds::dive()
    def self.dive()
        loop {
            items = TxDateds::items().sort{|i1, i2| i1["datetime"] <=> i2["datetime"] }
            item = LucilleCore::selectEntityFromListOfEntitiesOrNull("dated", items, lambda{|item| TxDateds::toString(item) })
            break if item.nil?
            TxDateds::run(item)
        }
    end

    # --------------------------------------------------
    # nx16s

    # TxDateds::ns16(mx49)
    def self.ns16(mx49)
        uuid = mx49["uuid"]
        {
            "uuid"     => uuid,
            "NS198"    => "NS16:TxDated",
            "announce" => "(ondate) [#{mx49["datetime"][0, 10]}] #{mx49["description"]}",
            "commands" => ["..", "done", "redate", ">> (transmute)", "''"],
            "TxDated"     => mx49
        }
    end

    # TxDateds::ns16s()
    def self.ns16s()
        focus = DomainsX::focusOrNull()
        TxDateds::items()
            .select{|item| focus.nil? or (item["domainx"] == focus) }
            .select{|mx49| mx49["datetime"][0, 10] <= Utils::today() }
            .sort{|i1, i2| i1["datetime"] <=> i2["datetime"] }
            .map{|mx49| TxDateds::ns16(mx49) }
    end

    # --------------------------------------------------

    # TxDateds::nx19s()
    def self.nx19s()
        TxDateds::items().map{|item|
            {
                "uuid"     => item["uuid"],
                "announce" => TxDateds::toStringForNS19(item),
                "lambda"   => lambda { TxDateds::run(item) }
            }
        }
    end
end
