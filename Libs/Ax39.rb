# encoding: UTF-8

class Ax39

    # Ax39::types()
    def self.types()
        ["daily-time-commitment", "weekly-time-commitment", "work:(mon-to-fri)+(week-end-overflow)"]
    end

    # Ax39::interactivelySelectTypeOrNull()
    def self.interactivelySelectTypeOrNull()
        LucilleCore::selectEntityFromListOfEntitiesOrNull("type:", Ax39::types())
    end

    # Ax39::interactivelyCreateNewAxOrNull()
    def self.interactivelyCreateNewAxOrNull()
        type = Ax39::interactivelySelectTypeOrNull()
        return nil if type.nil?
        if type == "daily-time-commitment" then
            hours = LucilleCore::askQuestionAnswerAsString("daily hours : ")
            return nil if hours == ""
            return {
                "type"  => "daily-time-commitment",
                "hours" => hours.to_f
            }
        end
        if type == "weekly-time-commitment" then
            hours = LucilleCore::askQuestionAnswerAsString("weekly hours : ")
            return nil if hours == ""
            return {
                "type"  => "weekly-time-commitment",
                "hours" => hours.to_f
            }
        end
        if type == "work:(mon-to-fri)+(week-end-overflow)" then
            hours = LucilleCore::askQuestionAnswerAsString("weekly hours : ")
            return nil if hours == ""
            return {
                "type"  => "work:(mon-to-fri)+(week-end-overflow)",
                "hours" => hours.to_f
            }
        end
    end

    # Ax39::interactivelyCreateNewAx()
    def self.interactivelyCreateNewAx()
        loop {
            ax39 = Ax39::interactivelyCreateNewAxOrNull()
            if ax39 then
                return ax39
            end
        }
    end

    # Ax39::toString(ax39)
    def self.toString(ax39)
        if ax39["type"] == "daily-time-commitment" then
            return "daily #{"%4.2f" % ax39["hours"]} hours"
        end
        if ax39["type"] == "weekly-time-commitment" then
            return "weekly #{"%4.2f" % ax39["hours"]} hours"
        end
        if ax39["type"] == "work:(mon-to-fri)+(week-end-overflow)" then
            return "work #{"%4.2f" % ax39["hours"]} hours"
        end

    end

    # Ax39::completionRatio(uuid, ax39)
    def self.completionRatio(uuid, ax39)
        raise "(error: 92e23de4-61eb-4a07-a128-526e4be0e72a)" if ax39.nil?
        return 1 if !DoNotShowUntil::isVisible(uuid)
        if ax39["type"] == "daily-time-commitment" then
            return BankExtended::stdRecoveredDailyTimeInHours(uuid).to_f/ax39["hours"]
        end
        if ax39["type"] == "weekly-time-commitment" then
            dates = CommonUtils::datesSinceLastSaturday()
            idealTimeDoneInSeconds  = ([dates.size, 5].min.to_f/5)*ax39["hours"]*3600
            actualTimeDoneInSeconds = Bank::combinedValueOnThoseDays(uuid, dates)
            ratio = actualTimeDoneInSeconds.to_f/idealTimeDoneInSeconds
            return ratio
        end
        if ax39["type"] == "work:(mon-to-fri)+(week-end-overflow)" then
            dates = CommonUtils::datesSinceLastMonday()
            idealTimeDoneInSeconds  = ([dates.size, 5].min.to_f/5)*ax39["hours"]*3600
            actualTimeDoneInSeconds = Bank::combinedValueOnThoseDays(uuid, dates)
            ratio = actualTimeDoneInSeconds.to_f/idealTimeDoneInSeconds
            return ratio
        end
    end
end
