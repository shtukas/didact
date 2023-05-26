
class TxEngines

    # TxEngines::interactivelySelectEngineTypeOrNull()
    def self.interactivelySelectEngineTypeOrNull()
        LucilleCore::selectEntityFromListOfEntitiesOrNull("engine type", ["daily-recovery-time (default, with to 1 hour)", "weekly-time"])
    end

    # TxEngines::interactivelyMakeEngineOrDefault(uuid = nil)
    def self.interactivelyMakeEngineOrDefault(uuid = nil)
        uuid = uuid || SecureRandom.hex
        type = TxEngines::interactivelySelectEngineTypeOrNull()
        if type.nil? then
            return TxEngines::defaultEngine(uuid)
        end
        if type == "daily-recovery-time (default, with to 1 hour)" then
            hours = LucilleCore::askQuestionAnswerAsString("hours: ")
            if hours == "" then
                hours = "1"
            end
            hours = hours.to_f
            return {
                "uuid"  => uuid,
                "type"  => "daily-recovery-time",
                "hours" => hours
            }
        end
        if type == "weekly-time" then
            return {
                "uuid"          => uuid, # used for the completion ratio computation
                "type"          => "weekly-time",
                "hours"         => LucilleCore::askQuestionAnswerAsString("hours: ").to_f,
                "lastResetTime" => 0,
                "capsule"       => SecureRandom.hex # used for the time management
            }
        end
        raise "Houston (39), we have a problem."
    end

    # TxEngines::interactivelyIssueEngineOrNull()
    def self.interactivelyIssueEngineOrNull()
        description = LucilleCore::askQuestionAnswerAsString("description (empty to abort): ")
        return nil if description == ""

        type = TxEngines::interactivelySelectEngineTypeOrNull()
        return nil if type.nil?

        if type == "daily-recovery-time" then
            hours = LucilleCore::askQuestionAnswerAsString("hours: ")
            if hours == "" then
                return TxEngines::interactivelyIssueEngineOrNull()
            end
            hours = hours.to_f

            uuid = SecureRandom.uuid
            Solingen::init("TxEngine", uuid)
            Solingen::setAttribute2(uuid, "mikuType", "TxEngine")
            Solingen::setAttribute2(uuid, "description", description)
            Solingen::setAttribute2(uuid, "type", "daily-recovery-time")
            Solingen::setAttribute2(uuid, "hours", hours)
            return Solingen::getItemOrNull(uuid)
        end

        if type == "weekly-time" then
            return {
                "uuid"          => uuid, # used for the completion ratio computation
                "type"          => "weekly-time",
                "hours"         => LucilleCore::askQuestionAnswerAsString("hours: ").to_f,
                "lastResetTime" => 0,
                "capsule"       => SecureRandom.hex # used for the time management
            }

            uuid = SecureRandom.uuid
            Solingen::init("TxEngine", uuid)
            Solingen::setAttribute2(uuid, "mikuType", "TxEngine")
            Solingen::setAttribute2(uuid, "description", description)
            Solingen::setAttribute2(uuid, "type", "weekly-time")
            Solingen::setAttribute2(uuid, "hours", hours)
            Solingen::setAttribute2(uuid, "lastResetTime", 0)
            Solingen::setAttribute2(uuid, "capsule", SecureRandom.hex)
            return Solingen::getItemOrNull(uuid)
        end

        raise "Houston (4bcee194f1a0), we have a problem."
    end

    # TxEngines::defaultEngine(uuid = nil)
    def self.defaultEngine(uuid = nil)
        uuid = uuid || SecureRandom.hex
        {
            "uuid"          => uuid,
            "type"          => "daily-recovery-time",
            "hours"         => 1,
            "lastResetTime" => Time.new.to_i
        }
    end

    # TxEngines::interactivelyMakeEngine(uuid = nil)
    def self.interactivelyMakeEngine(uuid = nil)
        engine = TxEngines::interactivelyMakeEngineOrDefault(uuid = nil)
        return engine if engine
        puts "using default engine"
        TxEngines::defaultEngine(uuid)
    end

    # TxEngines::dayCompletionRatio(engine)
    def self.dayCompletionRatio(engine)
        if engine["type"] == "daily-recovery-time" then
            return (Bank::recoveredAverageHoursPerDay(engine["uuid"]))/engine["hours"]*3600
        end
        if engine["type"] == "weekly-time" then
            # if completed, we return the highest of both completion ratios
            # if not completed, we return the lowest
            return Bank::getValueAtDate(engine["uuid"], CommonUtils::today()).to_f/((engine["hours"]*3600).to_f/5)
        end
        raise "could not TxEngines::dayCompletionRatio(engine) for engine: #{engine}"
    end

    # TxEngines::periodCompletionRatio(engine)
    def self.periodCompletionRatio(engine)
        if engine["type"] == "daily-recovery-time" then
            return (Bank::recoveredAverageHoursPerDay(engine["uuid"]))/engine["hours"]*3600
        end
        if engine["type"] == "weekly-time" then
            # if completed, we return the highest of both completion ratios
            # if not completed, we return the lowest
            return Bank::getValue(engine["capsule"]).to_f/(engine["hours"]*3600)
        end
        raise "could not TxEngines::dayCompletionRatio(engine) for engine: #{engine}"
    end

    # TxEngines::listingCompletionRatio(engine)
    def self.listingCompletionRatio(engine)
        period = TxEngines::periodCompletionRatio(engine)
        return period if period >= 1
        day = TxEngines::dayCompletionRatio(engine)
        return day if day >= 1
        0.9*day + 0.1*period
    end

    # TxEngines::engineMaintenance(engine)
    def self.engineMaintenance(engine)
        if engine["type"] == "daily-recovery-time" then
            return nil
        end
        if engine["type"] == "weekly-time" then
            return nil if Bank::getValue(engine["capsule"]).to_f/3600 < engine["hours"]
            return nil if (Time.new.to_i - engine["lastResetTime"]) < 86400*7
            if Bank::getValue(engine["capsule"]).to_f/3600 > 1.5*engine["hours"] then
                overflow = 0.5*engine["hours"]*3600
                puts "I am about to smooth engine #{TxEngines::toString(engine)}, overflow: #{(overflow.to_f/3600).round(2)} hours for engine: #{engine["description"]}"
                LucilleCore::pressEnterToContinue()
                NxTimePromises::issue_things(engine, overflow, 20)
                return nil
            end
            puts "> I am about to reset engine: #{TxEngines::toString(engine)}"
            LucilleCore::pressEnterToContinue()
            Bank::put(engine["capsule"], -engine["hours"]*3600)
            if !LucilleCore::askQuestionAnswerAsBoolean("> continue with #{engine["hours"]} hours ? ") then
                hours = LucilleCore::askQuestionAnswerAsString("specify period load in hours (empty for the current value): ")
                if hours.size > 0 then
                    engine["hours"] = hours.to_f
                end
            end
            engine["lastResetTime"] = Time.new.to_i
            return engine
        end
        raise "could not TxEngines::engineMaintenance(engine) for engine: #{engine}, engine: #{engine}"
    end

    # TxEngines::maintenance()
    def self.maintenance()
        Solingen::mikuTypeItems("TxEngine").each{|engine| TxEngines::engineMaintenance(engine) }
    end

    # TxEngines::toString(engine, shouldPad = false)
    def self.toString(engine, shouldPad = false)
        padding =
            if shouldPad then
                XCache::getOrDefaultValue("engine-description-padding-26f3d54692dc", "0").to_i
            else
                0
            end
        if engine["type"] == "daily-recovery-time" then
            return "#{engine["description"].ljust(padding)} (engine: #{(100*TxEngines::dayCompletionRatio(engine)).round(2).to_s.green}% of #{engine["hours"]} hours)"
        end
        if engine["type"] == "weekly-time" then
            strings = []

            strings << "#{engine["description"].ljust(padding)} (engine: today: #{"#{"%5.2f" % (100*TxEngines::dayCompletionRatio(engine))}%".green} of #{"%5.2f" % (engine["hours"].to_f/5)} hours"
            strings << ", period: #{"#{"%5.2f" % (100*TxEngines::periodCompletionRatio(engine))}%".green} of #{"%5.2f" % engine["hours"]} hours"

            hasReachedObjective = Bank::getValue(engine["capsule"]) >= engine["hours"]*3600
            timeSinceResetInDays = (Time.new.to_i - engine["lastResetTime"]).to_f/86400
            itHassBeenAWeek = timeSinceResetInDays >= 7

            if hasReachedObjective and itHassBeenAWeek then
                strings << ", awaiting data management"
            end

            if hasReachedObjective and !itHassBeenAWeek then
                strings << ", objective met, #{(7 - timeSinceResetInDays).round(2)} days before reset"
            end

            if !hasReachedObjective and !itHassBeenAWeek then
                strings << ", #{(engine["hours"] - Bank::getValue(engine["capsule"]).to_f/3600).round(2)} hours to go, #{(7 - timeSinceResetInDays).round(2)} days left in period"
            end

            if !hasReachedObjective and itHassBeenAWeek then
                strings << ", late by #{(timeSinceResetInDays-7).round(2)} days"
            end

            strings << ")"
            return strings.join()
        end
        raise "could not TxEngines::toString(engine) for engine: #{engine}"
    end

    # TxEngines::toString0(engine)
    def self.toString0(engine)
        "(engine) #{engine["description"]}"
    end

    # TxEngines::interactivelySelectOneOrNull()
    def self.interactivelySelectOneOrNull()
        LucilleCore::selectEntityFromListOfEntitiesOrNull("engine", Solingen::mikuTypeItems("TxEngine"), lambda{|item| TxEngines::toString0(item) })
    end

    # TxEngines::listingItems()
    def self.listingItems()
        Solingen::mikuTypeItems("TxEngine")
            .sort_by{|engine| TxEngines::listingCompletionRatio(engine) }
            .select{|engine| TxEngines::listingCompletionRatio(engine) < 1 }
    end

    # TxEngines::program1(engine)
    def self.program1(engine)
        loop {
            actions = ["set hours"]
            action = LucilleCore::selectEntityFromListOfEntitiesOrNull("action", actions)
            return if action.nil?
            if action == "set hours" then
                hours = LucilleCore::askQuestionAnswerAsString("hours (empty to abort): ")
                return if hours == ""
                hours = hours.to_f
                Solingen::setAttribute2(engine["uuid"], "hours", hours)
            end
        }
    end

    # TxEngines::program2()
    def self.program2()
        loop {
            engine = TxEngines::interactivelySelectOneOrNull()
            return if engine.nil?
            TxEngines::program1(engine)
        }
    end
end
