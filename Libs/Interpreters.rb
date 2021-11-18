# encoding: UTF-8

# ------------------------------------------------------------------------------------------

class Interpreters

    # Interpreters::listingCommands()
    def self.listingCommands()
        ".. | <n> | <datecode> | start <n> | stop <n> | hide <n> <datecode> | expose"
    end

    # Interpreters::listingInterpreter(store, command)
    def self.listingInterpreter(store, command)

        # The case <n> should hve already been captured by UIServices

        # The case [] should have already been caputred by UIServices

        if (unixtime = Utils::codeToUnixtimeOrNull(command.gsub(" ", ""))) then
            ns16 = store.getDefault()
            return if ns16.nil? 
            DoNotShowUntil::setUnixtime(ns16["uuid"], unixtime)
            puts "Hidden until: #{Time.at(unixtime).to_s}"
        end

        if Interpreting::match("start *", command) then
            _, ordinal = Interpreting::tokenizer(command)
            ordinal = ordinal.to_i
            ns16 = store.get(ordinal)
            return if ns16.nil?
            bankAccounts = 
                if ns16["bank-accounts"].nil? then
                    [Domain::getDomainBankAccount(Domain::interactivelySelectDomain())]
                else
                    ns16["bank-accounts"]
                end
            NxBallsService::issueOrIncreaseOwnerCount(ns16["uuid"], bankAccounts)
        end

        if Interpreting::match("stop *", command) then
            _, ordinal = Interpreting::tokenizer(command)
            ordinal = ordinal.to_i
            ns16 = store.get(ordinal)
            return if ns16.nil?
            NxBallsService::decreaseOwnerCountOrClose(ns16["uuid"], true)
        end

        if Interpreting::match("hide * *", command) then
            _, ordinal, datecode = Interpreting::tokenizer(command)
            ordinal = ordinal.to_i
            ns16 = store.get(ordinal)
            return if ns16.nil?
            unixtime = Utils::codeToUnixtimeOrNull(datecode)
            return if unixtime.nil?
            DoNotShowUntil::setUnixtime(ns16["uuid"], unixtime)
        end

        if Interpreting::match("expose", command) then
            ns16 = store.getDefault()
            return if ns16.nil? 
            puts JSON.pretty_generate(ns16)
            LucilleCore::pressEnterToContinue()
        end
    end

    # Interpreters::makersCommands()
    def self.makersCommands()
        "start # unscheduled | today | todo | float | wave | ondate | anniversary | Nx50"
    end

    # Interpreters::diversCommands()
    def self.diversCommands()
        "calendar | waves | ondates | Nx50s | anniversaries | search | fsck | nyx"
    end

    # Interpreters::makersAndDiversCommands()
    def self.makersAndDiversCommands()
        [
            Interpreters::makersCommands(),
            Interpreters::diversCommands()
        ].join(" | ")
    end

    # Interpreters::makersAndDiversInterpreter(command)
    def self.makersAndDiversInterpreter(command)

        if command == "today" then
            Today::interactivelyIssueNewOrNull()
        end

        if command == "todo" then
            Nx50s::interactivelyCreateNewOrNull()
        end

        if Interpreting::match("float", command) then
            Floats::interactivelyCreateNewOrNull()
        end

        if Interpreting::match("wave", command) then
            item = Waves::issueNewWaveInteractivelyOrNull()
            return if item.nil?
            puts JSON.pretty_generate(item)
        end

        if Interpreting::match("ondate", command) then
            item = Dated::interactivelyIssueNewOrNull()
            return if item.nil?
            puts JSON.pretty_generate(item)
        end

        if Interpreting::match("Nx50", command) then
            item = Nx50s::interactivelyCreateNewOrNull()
            return if item.nil?
            puts JSON.pretty_generate(item)
        end

        if Interpreting::match("anniversary", command) then
            item = Anniversaries::issueNewAnniversaryOrNullInteractively()
            return if item.nil?
            puts JSON.pretty_generate(item)
        end

        if Interpreting::match("ondates", command) then
            Dated::main()
        end

        if Interpreting::match("anniversaries", command) then
            Anniversaries::anniversariesDive()
        end

        if Interpreting::match("calendar", command) then
            Calendar::main()
        end

        if Interpreting::match("waves", command) then
            domain = Domain::interactivelySelectDomain()
            Waves::waves(domain)
        end

        if Interpreting::match("Nx50s", command) then
            nx50s = Nx50s::nx50s()
            if LucilleCore::askQuestionAnswerAsBoolean("limit ? ", true) then
                nx50s = nx50s.first(Utils::screenHeight()-1)
            end
            loop {
                nx50 = LucilleCore::selectEntityFromListOfEntitiesOrNull("nx50", nx50s, lambda {|nx50| Nx50s::toString(nx50) })
                return if nx50.nil?
                Nx50s::run(nx50)
            }
        end

        if command == "start" then
            description = LucilleCore::askQuestionAnswerAsString("description (empty to abort): ")
            return if description == ""
            domain = Domain::interactivelySelectDomain()
            domainBankAccount = Domain::getDomainBankAccount(domain)
            NxBallsService::issueOrIncreaseOwnerCount("04b8932b-986a-4f25-8320-5fc00c076dc1", [domainBankAccount])
            ns16 = {
                "uuid"     => "f05fe844-128b-4e80-b13e-e0756c84204c",
                "announce" => "[unscheduled] #{description}".green, 
                "commands" => ["done"],
            }
            KeyValueStore::set(nil, "f05fe844-128b-4e80-b13e-e0756c84204c", JSON.generate(ns16))
        end

        if Interpreting::match("search", command) then
            Search::search()
        end

        if Interpreting::match("fsck", command) then
            Fsck::fsck()
        end

        if Interpreting::match("nyx", command) then
            system("/Users/pascal/Galaxy/Software/Nyx/nyx")
        end
    end
end
