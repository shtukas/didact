
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
            hours = LucilleCore::askQuestionAnswerAsString("hours: ").to_f
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

    # s(uuid = nil)
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

    # TxEngines::completionRatio(engine)
    def self.completionRatio(engine)
        if engine["type"] == "one sitting" then
            engine = TxEngines::defaultEngine(engine["uuid"])
        end
        if engine["type"] == "daily-recovery-time" then
            return (Bank::recoveredAverageHoursPerDay(engine["uuid"]))/engine["hours"]*3600
        end
        if engine["type"] == "weekly-time" then
            # if completed, we return the highest of both completion ratios
            # if not completed, we return the lowest
            day_completion_ratio = Bank::getValueAtDate(engine["uuid"], CommonUtils::today()).to_f/((engine["hours"]*3600).to_f/5)
            period_completion_ratio = Bank::getValue(engine["capsule"]).to_f/(engine["hours"]*3600)
            return [day_completion_ratio, period_completion_ratio].max
        end
        raise "could not TxEngines::completionRatio(engine) for engine: #{engine}"
    end

    # TxEngines::engineMaintenance(description, engine)
    def self.engineMaintenance(description, engine)
        if engine["type"] == "one sitting" then
            engine = TxEngines::defaultEngine(engine["uuid"])
        end
        if engine["type"] == "daily-recovery-time" then
            return nil
        end
        if engine["type"] == "weekly-time" then
            return nil if Bank::getValue(engine["capsule"]).to_f/3600 < engine["hours"]
            return nil if (Time.new.to_i - engine["lastResetTime"]) < 86400*7
            if Bank::getValue(engine["capsule"]).to_f/3600 > 1.5*engine["hours"] then
                overflow = 0.5*engine["hours"]*3600
                puts "I am about to smooth engine: #{engine}, overflow: #{(overflow.to_f/3600).round(2)} hours (for description: #{description})"
                LucilleCore::pressEnterToContinue()
                NxTimePromises::smooth_effect(engine["capsule"], -overflow, 20)
                return nil
            end
            puts "I am about to reset engine: #{engine} (for description: #{description})"
            LucilleCore::pressEnterToContinue()
            Bank::put(engine["capsule"], -engine["hours"]*3600)
            engine["lastResetTime"] = Time.new.to_i
            return engine
        end
        raise "could not TxEngines::engineMaintenance(description, engine) for engine: #{engine}"
    end

    # TxEngines::toString(engine)
    def self.toString(engine)
        if engine["type"] == "one sitting" then
            engine = TxEngines::defaultEngine(engine["uuid"])
        end
        if engine["type"] == "daily-recovery-time" then
            todayDoneInHours = Bank::recoveredAverageHoursPerDay(engine["uuid"])
            percentage = 100*todayDoneInHours.to_f/engine["hours"]
            return "(engine: #{todayDoneInHours.round(2)} (#{"#{percentage.round(2)}%".green}) of daily #{engine["hours"]} hours)"
        end
        if engine["type"] == "weekly-time" then
            strings = []
            todayDoneInHours = Bank::getValueAtDate(engine["uuid"], CommonUtils::today()).to_f/3600
            todayIdealInHours = engine["hours"].to_f/5
            percentage = 100*todayDoneInHours.to_f/todayIdealInHours

            strings << "(engine: #{todayDoneInHours.round(2)} (#{"#{percentage.round(2)}%".green }) of today #{todayIdealInHours} hours"
            strings << ", #{(Bank::getValue(engine["capsule"]).to_f/3600).round(2)} (#{"#{(100*TxEngines::completionRatio(engine)).round(2)}%".green}) of weekly #{engine["hours"]} hours"

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
end