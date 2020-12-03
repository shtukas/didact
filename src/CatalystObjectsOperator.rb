
# encoding: UTF-8

# -- SingleExecutionContext ----------------------------------------------------------

class SingleExecutionContext

    # SingleExecutionContext::metric(itemBankAccount)
    def self.metric(itemBankAccount)
        return 0 if BankExtended::recoveredDailyTimeInHours("SingleExecutionContext-ECBED390-DE32-496D-BAA1-4418B6FD64C2") > 2
        0.6 - 0.1*BankExtended::recoveredDailyTimeInHours(itemBankAccount)
    end
end


# -- NG12TimeReports ----------------------------------------------------------

=begin

NG12TimeReport {
    "description"                     : Float
    "dailyTimeExpectationInHours"     : Float
    "currentExpectationRealisedRatio" : Float
    "landing"                         : Lambda
}

=end

class NG12TimeReports

    # NG12TimeReports::singleExecutionContextNG12TimeReport()
    def self.singleExecutionContextNG12TimeReport()
        {
            "description"                     => "Single Execution Context",
            "dailyTimeExpectationInHours"     => 2,
            "currentExpectationRealisedRatio" => BankExtended::recoveredDailyTimeInHours("SingleExecutionContext-ECBED390-DE32-496D-BAA1-4418B6FD64C2").to_f/2,
            "landing"                         => lambda {
                puts "There currently is no particular implementation of the Single Execution Context lambda"
                LucilleCore::pressEnterToContinue()
            }
        }
    end

    # NG12TimeReports::reports()
    def self.reports()
        objects1 = Asteroids::asteroidsDailyTimeCommitments()
                        .sort{|a1, a2| Asteroids::dailyTimeCommitmentRatioOrNull(a1) <=> Asteroids::dailyTimeCommitmentRatioOrNull(a2) }
                        .map{|asteroid|
                            {
                                "description"                     => Asteroids::toString(asteroid),
                                "dailyTimeExpectationInHours"     => asteroid["orbital"]["time-commitment-in-hours"],
                                "currentExpectationRealisedRatio" => BankExtended::recoveredDailyTimeInHours(asteroid["uuid"]).to_f/asteroid["orbital"]["time-commitment-in-hours"],
                                "landing"                         => lambda { Asteroids::landing(asteroid) }
                            }
                        }
        objects2 = [ NG12TimeReports::singleExecutionContextNG12TimeReport() ]
        objects1 + objects2
    end

end


# -- CatalystObjectsOperator ----------------------------------------------------------

class CatalystObjectsOperator

    # CatalystObjectsOperator::getCatalystListingObjectsOrdered()
    def self.getCatalystListingObjectsOrdered()
        objects = [
            Asteroids::catalystObjects(),
            BackupsMonitor::catalystObjects(),
            Calendar::catalystObjects(),
            Curation::catalystObjects(),
            VideoStream::catalystObjects(),
            Waves::catalystObjects(),
        ].flatten.compact
        objects = objects
                    .select{|object| object['metric'] >= 0.2 }

        objects = objects
                    .select{|object| DoNotShowUntil::isVisible(object["uuid"]) or object["isRunning"] }
                    .sort{|o1, o2| o1["metric"]<=>o2["metric"] }
                    .reverse

        objects
    end

    # CatalystObjectsOperator::generationSpeedReport()
    def self.generationSpeedReport()
        generators = [
            {
                "name" => "Asteroids",
                "exec" => lambda{ Asteroids::catalystObjects() }
            },
            {
                "name" => "BackupsMonitor",
                "exec" => lambda{ BackupsMonitor::catalystObjects() }
            },
            {
                "name" => "Calendar",
                "exec" => lambda{ Calendar::catalystObjects() }
            },
            {
                "name" => "Curation",
                "exec" => lambda{ Curation::catalystObjects() }
            },
            {
                "name" => "VideoStream",
                "exec" => lambda{ VideoStream::catalystObjects() }
            },
            {
                "name" => "Waves",
                "exec" => lambda{ Waves::catalystObjects() }
            }
        ]

        generators = generators
                        .map{|item|
                            time1 = Time.new.to_f
                            item["exec"].call()
                            item["runtime"] = Time.new.to_f - time1
                            item
                        }
        generators = generators.sort{|item1, item2| item1["runtime"] <=> item2["runtime"] }.reverse
        generators.each{|item|
            puts "#{item["name"].ljust(20)} : #{item["runtime"].round(2)}"
        }
        LucilleCore::pressEnterToContinue()
    end
end
