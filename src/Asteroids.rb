# encoding: UTF-8

class Asteroids

    # -------------------------------------------------------------------
    # Building

    # Asteroids::asteroidOrbitalTypes()
    def self.asteroidOrbitalTypes()
        [
            "inbox-cb1e2cb7-4264-4c66-acef-687846e4ff860",
            "daily-time-commitment-e1180643-fc7e-42bb-a2",
            "burner-5d333e86-230d-4fab-aaee-a5548ec4b955",
            "single-execution-context-ceb9f3cf-fa19-41d1",
            "stream-78680b9b-a450-4b7f-8e15-d61b2a6c5f7c",
        ]
    end

    # Asteroids::makeOrbitalInteractivelyOrNull()
    def self.makeOrbitalInteractivelyOrNull()
        orbitalTypes = Asteroids::asteroidOrbitalTypes()
        orbitalType = LucilleCore::selectEntityFromListOfEntitiesOrNull("orbital type", orbitalTypes)
        return nil if orbitalType.nil?
        if orbitalType == "inbox-cb1e2cb7-4264-4c66-acef-687846e4ff860" then
            return {
                "type" => "inbox-cb1e2cb7-4264-4c66-acef-687846e4ff860"
            }
        end
        if orbitalType == "daily-time-commitment-e1180643-fc7e-42bb-a2" then
            return {
                "type" => "daily-time-commitment-e1180643-fc7e-42bb-a2",
                "time-commitment-in-hours" => LucilleCore::askQuestionAnswerAsString("time commitment in hours: ").to_f
            }
        end
        if orbitalType == "burner-5d333e86-230d-4fab-aaee-a5548ec4b955" then
            return {
                "type" => "burner-5d333e86-230d-4fab-aaee-a5548ec4b955"
            }
        end
        if orbitalType == "single-execution-context-ceb9f3cf-fa19-41d1" then
            return {
                "type" => "single-execution-context-ceb9f3cf-fa19-41d1"
            }
        end
        if orbitalType == "stream-78680b9b-a450-4b7f-8e15-d61b2a6c5f7c" then
            return {
                "type" => "stream-78680b9b-a450-4b7f-8e15-d61b2a6c5f7c"
            }
        end
        raise "ef349b18-55ed-4fdb-abb0-1014f752416a"
    end

    # Asteroids::issueAsteroidInteractivelyOrNull()
    def self.issueAsteroidInteractivelyOrNull()
        description = LucilleCore::askQuestionAnswerAsString("asteroid description: ")
        return nil if (description == "")
        orbital = Asteroids::makeOrbitalInteractivelyOrNull()
        return nil if orbital.nil?
        asteroid = {
            "uuid"        => SecureRandom.hex,
            "nyxNxSet"    => "b66318f4-2662-4621-a991-a6b966fb4398",
            "unixtime"    => Time.new.to_f,
            "orbital"     => orbital,
            "description" => description
        }
        NyxObjects2::put(asteroid)
        asteroid
    end

    # Asteroids::issueDatapointAndAsteroidInteractivelyOrNull()
    def self.issueDatapointAndAsteroidInteractivelyOrNull()
        datapoint = Patricia::makeNewDatapointOrNull()
        return if datapoint.nil?
        orbital = Asteroids::makeOrbitalInteractivelyOrNull()
        return nil if orbital.nil?
        asteroid = {
            "uuid"       => SecureRandom.hex,
            "nyxNxSet"   => "b66318f4-2662-4621-a991-a6b966fb4398",
            "unixtime"   => Time.new.to_f,
            "orbital"    => orbital,
        }
        NyxObjects2::put(asteroid)
        Arrows::issueOrException(asteroid, datapoint)
        asteroid
    end

    # Asteroids::issueAsteroidInboxFromTarget(target)
    def self.issueAsteroidInboxFromTarget(target)
        orbital = {
            "type" => "inbox-cb1e2cb7-4264-4c66-acef-687846e4ff860"
        }
        asteroid = {
            "uuid"     => SecureRandom.uuid,
            "nyxNxSet" => "b66318f4-2662-4621-a991-a6b966fb4398",
            "unixtime" => Time.new.to_f,
            "orbital"  => orbital,
        }
        NyxObjects2::put(asteroid)
        Arrows::issueOrException(asteroid, target)
        asteroid
    end

    # Asteroids::issueAsteroidBurnerFromTarget(target)
    def self.issueAsteroidBurnerFromTarget(target)
        orbital = {
            "type" => "burner-5d333e86-230d-4fab-aaee-a5548ec4b955"
        }
        asteroid = {
            "uuid"       => SecureRandom.uuid,
            "nyxNxSet"   => "b66318f4-2662-4621-a991-a6b966fb4398",
            "unixtime"   => Time.new.to_f,
            "orbital"    => orbital,
        }
        NyxObjects2::put(asteroid)
        Arrows::issueOrException(asteroid, target)
        asteroid
    end

    # -------------------------------------------------------------------
    # Data Extraction

    # Asteroids::asteroids()
    def self.asteroids()
        NyxObjects2::getSet("b66318f4-2662-4621-a991-a6b966fb4398")
    end

    # Asteroids::getAsteroidOrNull(uuid)
    def self.getAsteroidOrNull(uuid)
        object = NyxObjects2::getOrNull(uuid)
        return nil if object.nil?
        return nil if (object["nyxNxSet"] != "b66318f4-2662-4621-a991-a6b966fb4398")
        object
    end

    # Asteroids::asteroidOrbitalAsUserFriendlyString(orbital)
    def self.asteroidOrbitalAsUserFriendlyString(orbital)
        return "📥" if orbital["type"] == "inbox-cb1e2cb7-4264-4c66-acef-687846e4ff860"
        return "💫" if orbital["type"] == "daily-time-commitment-e1180643-fc7e-42bb-a2"
        return "🔥" if orbital["type"] == "burner-5d333e86-230d-4fab-aaee-a5548ec4b955"
        return "⏱ " if orbital["type"] == "single-execution-context-ceb9f3cf-fa19-41d1"
        return "✨" if orbital["type"] == "stream-78680b9b-a450-4b7f-8e15-d61b2a6c5f7c"
    end

    # Asteroids::asteroidDescription(asteroid)
    def self.asteroidDescription(asteroid)
        targets = Arrows::getTargetsForSource(asteroid)
        if asteroid["description"] then
            return "#{asteroid["description"]}"
        end
        if targets.size == 0 then
            return "no description / no target"
        end 
        if targets.size == 1 then
            return Patricia::toString(targets[0])
        end 
        return "(#{targets.size} targets)"
    end

    # Asteroids::toString(asteroid)
    def self.toString(asteroid)
        uuid = asteroid["uuid"]
        isRunning = Runner::isRunning?(uuid)
        p1 = "[asteroid]"
        p2 = " #{Asteroids::asteroidOrbitalAsUserFriendlyString(asteroid["orbital"])}"
        p3 = " #{Asteroids::asteroidDescription(asteroid)}"
        p4 =
            if isRunning then
                " (running for #{(Runner::runTimeInSecondsOrNull(uuid).to_f/3600).round(2)} hours)"
            else
                ""
            end

        "#{p1}#{p2}#{p3}#{p4}"
    end

    # Asteroids::dailyTimeCommitmentRatioOrNull(asteroid)
    def self.dailyTimeCommitmentRatioOrNull(asteroid)
        return nil if (asteroid["orbital"]["type"] != "daily-time-commitment-e1180643-fc7e-42bb-a2")
        commitmentInHours = asteroid["orbital"]["time-commitment-in-hours"]
        BankExtended::recoveredDailyTimeInHours(asteroid["uuid"]).to_f/commitmentInHours
    end

    # Asteroids::toStringXpDailyTimeCommitmentUIListing(asteroid)
    def self.toStringXpDailyTimeCommitmentUIListing(asteroid)
        uuid = asteroid["uuid"]
        isRunning = Runner::isRunning?(uuid)
        p1 = "[asteroid]"
        p2 = " #{Asteroids::asteroidOrbitalAsUserFriendlyString(asteroid["orbital"])}"
        p3 = " #{Asteroids::asteroidDescription(asteroid)}"
        p4 =
            if isRunning then
                " (running for #{(Runner::runTimeInSecondsOrNull(uuid).to_f/3600).round(2)} hours)"
            else
                ""
            end

        ratio = Asteroids::dailyTimeCommitmentRatioOrNull(asteroid)
        p6 = " [#{"%.2f" % asteroid["orbital"]["time-commitment-in-hours"]} hours, #{"%6.2f" % (100*ratio).round(2)} % completed]"

        ["#{p1}#{p2}#{p6}#{p3}#{p4}", ratio]
    end

    # Asteroids::asteroidDailyTimeCommitmentNumbers(asteroid)
    def self.asteroidDailyTimeCommitmentNumbers(asteroid)
        return "" if asteroid["orbital"]["type"] != "daily-time-commitment-e1180643-fc7e-42bb-a2"
        commitmentInHours = asteroid["orbital"]["time-commitment-in-hours"]
        ratio = BankExtended::recoveredDailyTimeInHours(asteroid["uuid"]).to_f/commitmentInHours
        return " (#{asteroid["orbital"]["time-commitment-in-hours"]} hours, #{(100*ratio).round(2)} % completed)"
    end

    # Asteroids::naturalOrdinalShift(asteroid)
    def self.naturalOrdinalShift(asteroid)
        bounds = JSON.parse(KeyValueStore::getOrNull(nil, "af59dd5d-135d-46c1-ab9a-65f54582266d"))
        ( asteroid["unixtime"]-bounds["lower"] ).to_f/( bounds["upper"] - bounds["lower"] )
    end

    # Asteroids::asteroidsDailyTimeCommitments()
    def self.asteroidsDailyTimeCommitments()
        Asteroids::asteroids()
            .select{|asteroid| asteroid["orbital"]["type"] == "daily-time-commitment-e1180643-fc7e-42bb-a2" }
    end

    # Asteroids::selectOneDailyTimeCommitmentOrNull()
    def self.selectOneDailyTimeCommitmentOrNull()
        asteroids = Asteroids::asteroidsDailyTimeCommitments()
        LucilleCore::selectEntityFromListOfEntitiesOrNull("asteroid", asteroids, lambda{|asteroid| Asteroids::toString(asteroid) })
    end

    # Asteroids::selectOneTargetOfThisAsteroidOrNull(asteroid)
    def self.selectOneTargetOfThisAsteroidOrNull(asteroid)
        LucilleCore::selectEntityFromListOfEntitiesOrNull("target", Asteroids::getAsteroidTargetsInOrdinalOrder(asteroid), lambda{|t| Patricia::toString(t) })
    end

    # Asteroids::selectZeroOrMoreTargetsFromThisAsteroid(asteroid)
    def self.selectZeroOrMoreTargetsFromThisAsteroid(asteroid)
        selected, _ = LucilleCore::selectZeroOrMore("target", [], Asteroids::getAsteroidTargetsInOrdinalOrder(asteroid), lambda{|t| Patricia::toString(t) })
        selected
    end

    # Asteroids::selectOneParentOfThisAsteroidOrNull(asteroid)
    def self.selectOneParentOfThisAsteroidOrNull(asteroid)
        LucilleCore::selectEntityFromListOfEntitiesOrNull("target", Arrows::getSourcesForTarget(asteroid), lambda{|t| Patricia::toString(t) })
    end

    # -------------------------------------------------------------------
    # Catalyst Objects

    # Asteroids::metric(asteroid)
    def self.metric(asteroid)

        if asteroid["orbital"]["type"] == "inbox-cb1e2cb7-4264-4c66-acef-687846e4ff860" then
            return 0.70 - 0.01*Asteroids::naturalOrdinalShift(asteroid)
        end

        if asteroid["orbital"]["type"] == "daily-time-commitment-e1180643-fc7e-42bb-a2" then
            if BankExtended::recoveredDailyTimeInHours(asteroid["uuid"]).to_f < asteroid["orbital"]["time-commitment-in-hours"] then
                return 0.65 - 0.05*BankExtended::recoveredDailyTimeInHours(asteroid["uuid"]).to_f/asteroid["orbital"]["time-commitment-in-hours"]
            end
            return 0
        end

        if asteroid["orbital"]["type"] == "burner-5d333e86-230d-4fab-aaee-a5548ec4b955" then
            return 0 if BankExtended::recoveredDailyTimeInHours("burner-5d333e86-230d-4fab-aaee-a5548ec4b955") > 1
            return 0.50 - 0.10*BankExtended::recoveredDailyTimeInHours("burner-5d333e86-230d-4fab-aaee-a5548ec4b955") - 0.001*Asteroids::naturalOrdinalShift(asteroid)
        end

        if asteroid["orbital"]["type"] == "single-execution-context-ceb9f3cf-fa19-41d1" then
            return SingleExecutionContext::metric(asteroid["uuid"])
        end

        if asteroid["orbital"]["type"] == "stream-78680b9b-a450-4b7f-8e15-d61b2a6c5f7c" then
            if asteroid["x-stream-index"].nil? then
                # This never happens during a regular Asteroids::catalystObjects() call, but can happen if this function is manually called on an asteroid
                return 0
            end
            return 0 if BankExtended::recoveredDailyTimeInHours("stream-78680b9b-a450-4b7f-8e15-d61b2a6c5f7c") > 1
            return 0.40 - 0.10*BankExtended::recoveredDailyTimeInHours("stream-78680b9b-a450-4b7f-8e15-d61b2a6c5f7c") - 0.001*asteroid["x-stream-index"]
        end

        puts asteroid
        raise "[Asteroids] error: 46b84bdb"
    end

    # Asteroids::asteroidToCalalystObjects(asteroid)
    def self.asteroidToCalalystObjects(asteroid)

        return [] if !DoNotShowUntil::isVisible(asteroid["uuid"])

        if asteroid["activeDays"] and !asteroid["activeDays"].include?(Time.new.wday) then
            return []
        end

        if Asteroids::dailyTimeCommitmentRatioOrNull(asteroid) and Asteroids::dailyTimeCommitmentRatioOrNull(asteroid) > 1 then
            return []
        end

        makeBody = lambda {|asteroid, target|
            if Asteroids::toString(asteroid).include?(Patricia::toString(target)) then
                return Asteroids::toString(asteroid)
            end
            "#{Asteroids::toString(asteroid)} ; #{Patricia::toString(target)}"
        }

        asteroidmetric = Asteroids::metric(asteroid)


        targets = Asteroids::getAsteroidTargetsInOrdinalOrder(asteroid)
                    .select{|target|
                        uuid = "#{asteroid["uuid"]}-#{target["uuid"]}"
                        DoNotShowUntil::isVisible(uuid)
                    }
                    .first(3)

        if asteroid["orbital"]["type"] == "daily-time-commitment-e1180643-fc7e-42bb-a2" and Asteroids::getAsteroidTargetsInOrdinalOrder(asteroid).size == 0 and ProgrammableBooleans::trueNoMoreOftenThanEveryNSeconds("dfd91b81-9cab-4cef-b90b-0a24cc88191c:#{asteroid["uuid"]}", 86400) then
            puts "Asteroid '#{Asteroids::toString(asteroid)}' has no targets"
            if LucilleCore::askQuestionAnswerAsBoolean("Destroy it ? : ", false) then
                Patricia::destroy(asteroid)
            end
        end

        targets
            .map{|target|
                asteroidTargetUUID = "#{asteroid["uuid"]}-#{target["uuid"]}"
                metric = asteroidmetric - 0.01*BankExtended::recoveredDailyTimeInHours(asteroidTargetUUID)
                isRunning = Runner::isRunning?(asteroidTargetUUID)
                metric = 1 if isRunning
                {
                    "uuid"             => asteroidTargetUUID,
                    "body"             => makeBody.call(asteroid, target),
                    "metric"           => metric,
                    "landing"          => lambda { Patricia::landing(target) },
                    "nextNaturalStep"  => lambda { Asteroids::asteroidTargetNaturalNextOperation(asteroid, target, asteroidTargetUUID) },
                    "done"             => lambda {
                        Asteroids::asteroidReceivesTime(asteroid, 60)
                        Patricia::destroy(target) 
                    },
                    "move"             => lambda { Asteroids::moveAsteroidTarget(asteroid, target) },
                    "isRunning"        => isRunning,
                    "isRunningForLong" => (lambda {
                        return false if !Runner::isRunning?(asteroidTargetUUID)
                        ( Runner::runTimeInSecondsOrNull(asteroidTargetUUID) || 0 ) > 3600
                    }).call(),
                    "x-asteroid"       => asteroid,
                }
            }
    end

    # Asteroids::catalystObjects()
    def self.catalystObjects()

        asteroids = Asteroids::asteroids()

        return [] if asteroids.empty?

        bounds = {
            "lower" => asteroids.map{|asteroid| asteroid["unixtime"] }.min,
            "upper" => asteroids.map{|asteroid| asteroid["unixtime"] }.max
        }

        KeyValueStore::set(nil, "af59dd5d-135d-46c1-ab9a-65f54582266d", JSON.generate(bounds))

        if ProgrammableBooleans::trueNoMoreOftenThanEveryNSeconds("2b8b3b77-86cd-448c-9c8c-951ab2578e7a", 3600) then

            # Removing the x-stream-index marks from the day before
            asteroids
                .select{|asteroid| asteroid["x-stream-index"] }
                .each{|asteroid|
                    asteroid.delete("x-stream-index")
                    NyxObjects2::put(asteroid)
                }

            # Marking 100 objects for today
            asteroids
                .select{|asteroid| asteroid["orbital"]["type"] == "stream-78680b9b-a450-4b7f-8e15-d61b2a6c5f7c" }
                .sort{|a1, a2| a1["unixtime"] <=> a2["unixtime"] }
                .first(20)
                .each_with_index{|asteroid, indx|
                    asteroid["x-stream-index"] = indx
                    NyxObjects2::put(asteroid)
                }

            KeyValueStore::setFlagTrue(nil, "a3bd01f1-5366-4543-83aa-04477ec5f068:#{Miscellaneous::today()}")

        end

        asteroids = asteroids
                        .select{|asteroid| 
                            b1 = (asteroid["orbital"]["type"] != "stream-78680b9b-a450-4b7f-8e15-d61b2a6c5f7c")
                            b2 = asteroid["x-stream-index"]
                            b1 or b2
                        }

        catalystObjects = asteroids
                            .map{|asteroid| Asteroids::asteroidToCalalystObjects(asteroid) }
                            .flatten
                            .sort{|o1, o2| o1["metric"]<=>o2["metric"] }
                            .reverse

        # Removing any first asteroid with no target
        if catalystObjects.size > 0 then
            if asteroid = catalystObjects[0]["x-asteroid"] then
                if Arrows::getTargetsForSource(asteroid).size == 0 then
                    NyxObjects2::destroy(asteroid)
                    return Asteroids::catalystObjects()
                end
            end
        end

        catalystObjects
    end

    # -------------------------------------------------------------------
    # Targets Ordinals

    # Asteroids::setTargetOrdinal(asteroid, target, ordinal)
    def self.setTargetOrdinal(asteroid, target, ordinal)
        KeyValueStore::set(nil, "60d47387-cdd4-44f1-a334-904c2b7c4b5c:#{asteroid["uuid"]}:#{target["uuid"]}", ordinal)
    end

    # Asteroids::getTargetOrdinal(asteroid, target)
    def self.getTargetOrdinal(asteroid, target)
        ordinal = KeyValueStore::getOrNull(nil, "60d47387-cdd4-44f1-a334-904c2b7c4b5c:#{asteroid["uuid"]}:#{target["uuid"]}")
        if ordinal then
            return ordinal.to_f
        end
        ordinals = Arrows::getTargetsForSource(asteroid)
                    .map{|t| KeyValueStore::getOrNull(nil, "60d47387-cdd4-44f1-a334-904c2b7c4b5c:#{asteroid["uuid"]}:#{t["uuid"]}") }
                    .compact
                    .map{|o| o.to_f }
        ordinal = ([0] + ordinals).max + 1
        KeyValueStore::set(nil, "60d47387-cdd4-44f1-a334-904c2b7c4b5c:#{asteroid["uuid"]}:#{target["uuid"]}", ordinal)
        ordinal
    end

    # Asteroids::getAsteroidTargetsInOrdinalOrder(asteroid)
    def self.getAsteroidTargetsInOrdinalOrder(asteroid)
        Arrows::getTargetsForSource(asteroid)
            .sort{|t1, t2| Asteroids::getTargetOrdinal(asteroid, t1) <=> Asteroids::getTargetOrdinal(asteroid, t2) }
    end

    # -------------------------------------------------------------------
    # Operations

    # Asteroids::reOrbitalOrNothing(asteroid)
    def self.reOrbitalOrNothing(asteroid)
        orbital = Asteroids::makeOrbitalInteractivelyOrNull()
        return if orbital.nil?
        asteroid["orbital"] = orbital
        puts JSON.pretty_generate(asteroid)
        NyxObjects2::put(asteroid)
    end

    # Asteroids::asteroidReceivesTime(asteroid, timespanInSeconds)
    def self.asteroidReceivesTime(asteroid, timespanInSeconds)
        puts "Adding #{timespanInSeconds} seconds to '#{Asteroids::toString(asteroid)}'"
        Bank::put(asteroid["uuid"], timespanInSeconds)
        puts "Adding #{timespanInSeconds} seconds to #{asteroid["orbital"]["type"]}"
        Bank::put(asteroid["orbital"]["type"], timespanInSeconds)
        if asteroid["orbital"]["type"] == "single-execution-context-ceb9f3cf-fa19-41d1" then
            puts "Adding #{timespanInSeconds} seconds to SingleExecutionContext-ECBED390-DE32-496D-BAA1-4418B6FD64C2"
            Bank::put("SingleExecutionContext-ECBED390-DE32-496D-BAA1-4418B6FD64C2", timespanInSeconds)
        end
    end

    # Asteroids::startAsteroidIfNotRunning(asteroid)
    def self.startAsteroidIfNotRunning(asteroid)
        return if Runner::isRunning?(asteroid["uuid"])
        puts "start asteroid: #{Asteroids::toString(asteroid)}"
        Runner::start(asteroid["uuid"])
    end

    # Asteroids::stopAsteroidIfRunning(asteroid)
    def self.stopAsteroidIfRunning(asteroid)
        return if !Runner::isRunning?(asteroid["uuid"])
        timespan = Runner::stop(asteroid["uuid"])
        return if timespan.nil?
        timespan = [timespan, 3600*2].min # To avoid problems after leaving things running
        Asteroids::asteroidReceivesTime(asteroid, timespan)
    end

    # Asteroids::diveAsteroidOrbitalType(orbitalType)
    def self.diveAsteroidOrbitalType(orbitalType)
        loop {
            system("clear")
            asteroids = Asteroids::asteroids().select{|asteroid| asteroid["orbital"]["type"] == orbitalType }
            asteroid = LucilleCore::selectEntityFromListOfEntitiesOrNull("asteroid", asteroids, lambda{|asteroid| Asteroids::toString(asteroid) })
            break if asteroid.nil?
            Asteroids::landing(asteroid)
        }
    end

    # Asteroids::getAsteroidTargetDestinationOrNull(asteroid)
    def self.getAsteroidTargetDestinationOrNull(asteroid)
        recipient = nil
        option = LucilleCore::selectEntityFromListOfEntitiesOrNull("option", ["move to a target", "move to a parent", "move to a Patricia selected element"]) 
        return nil if option.nil?
        if option == "move to a target" then
            recipient = Asteroids::selectOneTargetOfThisAsteroidOrNull(asteroid)
        end
        if option == "move to a parent" then
            recipient = Asteroids::selectOneParentOfThisAsteroidOrNull(asteroid)
        end
        if option == "move to a Patricia selected element" then
            recipient = Patricia::architect()
        end
        recipient
    end

    # Asteroids::moveAsteroidTarget(asteroid, target)
    def self.moveAsteroidTarget(asteroid, target)
        puts "moving: #{Patricia::toString(target)}"
        if Patricia::isQuark(target) and target["type"] == "aion-location" and target["description"].nil? then
            description = LucilleCore::askQuestionAnswerAsString("target description: ")
            if description.size > 0 then
                Quarks::setDescription(target, description)
            end
        end
        if Patricia::isNGX15(target) and target["type"] == "aion-location" and target["description"].nil? then
            description = LucilleCore::askQuestionAnswerAsString("target description: ")
            if description.size > 0 then
                target["description"] = description
                NyxObjects2::put(target)
            end
        end
        destination = Asteroids::getAsteroidTargetDestinationOrNull(asteroid)
        return if destination.nil?
        return if destination["uuid"] == asteroid["uuid"]
        Arrows::issueOrException(destination, target)
        Arrows::unlink(asteroid, target)
        Patricia::landing(target)
    end


    # Asteroids::moveSelectedAsteroidTargets(asteroid)
    def self.moveSelectedAsteroidTargets(asteroid)
        selected = Asteroids::selectZeroOrMoreTargetsFromThisAsteroid(asteroid)
        return if selected.size == 0
        destination = Asteroids::getAsteroidTargetDestinationOrNull(asteroid)
        return if destination.nil?
        return if destination["uuid"] == asteroid["uuid"]
        selected.each{|target|
            Arrows::issueOrException(destination, target)
            Arrows::unlink(asteroid, target)
        }
    end

    # Asteroids::asteroidTargetNaturalNextOperation(asteroid, target, asteroidTargetUUID)
    def self.asteroidTargetNaturalNextOperation(asteroid, target, asteroidTargetUUID)
        addTime = lambda {|asteroid, asteroidTargetUUID, timespan|
            puts "Adding #{timespan} seconds to asteroid/target runId '#{asteroidTargetUUID}'"
            Bank::put(asteroidTargetUUID, timespan)
            Asteroids::asteroidReceivesTime(asteroid, timespan)
        }
        if !Runner::isRunning?(asteroidTargetUUID) then
            # Is not running
            Runner::start(asteroidTargetUUID)
            Patricia::open1(target)
            menuitems = LCoreMenuItemsNX1.new()
            menuitems.item("keep running".yellow, lambda {})
            menuitems.item("stop".yellow, lambda { 
                timespan = Runner::stop(asteroidTargetUUID)
                timespan = [timespan, 3600*2].min # To avoid problems after leaving things running
                addTime.call(asteroid, asteroidTargetUUID, timespan)
            })
            menuitems.item("stop ; hide for n days".yellow, lambda { 
                timespan = Runner::stop(asteroidTargetUUID)
                timespan = [timespan, 3600*2].min # To avoid problems after leaving things running
                addTime.call(asteroid, asteroidTargetUUID, timespan)
                n = LucilleCore::askQuestionAnswerAsString("hide duration in days: ").to_f
                DoNotShowUntil::setUnixtime(asteroidTargetUUID, Time.new.to_i + n*86400)
            })
            menuitems.item("target landing".yellow, lambda { 
                Patricia::landing(target)
            })
            menuitems.item("stop ; move target".yellow, lambda { 
                timespan = Runner::stop(asteroidTargetUUID)
                timespan = [timespan, 3600*2].min # To avoid problems after leaving things running
                addTime.call(asteroid, asteroidTargetUUID, timespan)
                Asteroids::moveAsteroidTarget(asteroid, target)
            })
            menuitems.item("stop ; destroy target".yellow,lambda {
                timespan = Runner::stop(asteroidTargetUUID)
                timespan = [timespan, 3600*2].min # To avoid problems after leaving things running
                addTime.call(asteroid, asteroidTargetUUID, timespan)
                Patricia::destroy(target)
            })
            menuitems.item("stop ; re-orbital asteroid".yellow, lambda { 
                Asteroids::reOrbitalOrNothing(asteroid)
            })
            status = menuitems.promptAndRunSandbox()
        else
            # Is running
            menuitems = LCoreMenuItemsNX1.new()
            menuitems.item("stop".yellow, lambda {
                timespan = Runner::stop(asteroidTargetUUID)
                timespan = [timespan, 3600*2].min # To avoid problems after leaving things running
                addTime.call(asteroid, asteroidTargetUUID, timespan)
            })
            menuitems.item("stop ; hide for n days".yellow, lambda { 
                timespan = Runner::stop(asteroidTargetUUID)
                timespan = [timespan, 3600*2].min # To avoid problems after leaving things running
                addTime.call(asteroid, asteroidTargetUUID, timespan)
                n = LucilleCore::askQuestionAnswerAsString("hide duration in days: ").to_f
                DoNotShowUntil::setUnixtime(asteroidTargetUUID, Time.new.to_i + n*86400)
            })
            menuitems.item("stop ; move target".yellow, lambda {
                timespan = Runner::stop(asteroidTargetUUID)
                timespan = [timespan, 3600*2].min # To avoid problems after leaving things running
                addTime.call(asteroid, asteroidTargetUUID, timespan)
                Asteroids::moveAsteroidTarget(asteroid, target)
            })
            menuitems.item("stop ; destroy target".yellow, lambda {
                timespan = Runner::stop(asteroidTargetUUID)
                timespan = [timespan, 3600*2].min # To avoid problems after leaving things running
                addTime.call(asteroid, asteroidTargetUUID, timespan)
                Patricia::destroy(target)
            })
            menuitems.item("stop ; re-orbital asteroid".yellow, lambda { 
                Asteroids::reOrbitalOrNothing(asteroid)
            })
            menuitems.item("target landing".yellow, lambda { 
                Patricia::landing(target)
            })
            status = menuitems.promptAndRunSandbox()
        end
    end



    # Asteroids::landing(asteroid)
    def self.landing(asteroid)
        loop {

            asteroid = Asteroids::getAsteroidOrNull(asteroid["uuid"])
            return if asteroid.nil?

            system("clear")

            menuitems = LCoreMenuItemsNX1.new()

            Miscellaneous::horizontalRule()

            puts Asteroids::toString(asteroid)

            puts "uuid: #{asteroid["uuid"]}".yellow
            puts "orbital: #{JSON.generate(asteroid["orbital"])}".yellow
            puts "activeDays: #{JSON.generate(asteroid["activeDays"])}".yellow
            puts "bank value: #{Bank::value(asteroid["uuid"])}".yellow
            puts "BankExtended::recoveredDailyTimeInHours: #{BankExtended::recoveredDailyTimeInHours(asteroid["uuid"])}".yellow
            puts "metric: #{Asteroids::metric(asteroid)}".yellow
            puts "x-stream-index: #{asteroid["x-stream-index"]}".yellow

            unixtime = DoNotShowUntil::getUnixtimeOrNull(asteroid["uuid"])
            if unixtime and (Time.new.to_i < unixtime) then
                puts "DoNotShowUntil: #{Time.at(unixtime).to_s}".yellow
            end

            puts ""

            Asteroids::getAsteroidTargetsInOrdinalOrder(asteroid)
            .each{|target|
                menuitems.item(
                    "target ( #{"%6.3f" % Asteroids::getTargetOrdinal(asteroid, target)} ) : #{Patricia::toString(target)}",
                    lambda { Patricia::landing(target) }
                )
            }

            puts ""

            menuitems.item(
                "update asteroid description".yellow,
                lambda { 
                    description = LucilleCore::askQuestionAnswerAsString("description: ")
                    return if description == ""
                    asteroid["description"] = description
                    NyxObjects2::put(asteroid)
                    KeyValueStore::destroy(nil, "f16f78bd-c5a1-490e-8f28-9df73f43733d:#{asteroid["uuid"]}")
                }
            )

            puts ""

            menuitems.item(
                "re-orbital".yellow,
                lambda { Asteroids::reOrbitalOrNothing(asteroid) }
            )

            menuitems.item(
                "show json".yellow,
                lambda {
                    puts JSON.pretty_generate(asteroid)
                    LucilleCore::pressEnterToContinue()
                }
            )

            menuitems.item("stop ; hide for n days".yellow, lambda { 
                Asteroids::stopAsteroidIfRunning(asteroid)
                n = LucilleCore::askQuestionAnswerAsString("hide duration in days: ").to_f
                DoNotShowUntil::setUnixtime(asteroid["uuid"], Time.new.to_i + n*86400)
            })

            menuitems.item(
                "add time".yellow,
                lambda {
                    timeInHours = LucilleCore::askQuestionAnswerAsString("time in hours: ").to_f
                    Asteroids::asteroidReceivesTime(asteroid, timeInHours*3600)
                }
            )

            puts ""

            menuitems.item("update target's ordinal".yellow, lambda { 
                target = LucilleCore::selectEntityFromListOfEntitiesOrNull("target", Asteroids::getAsteroidTargetsInOrdinalOrder(asteroid), lambda{|t| Patricia::toString(t) })
                return if target.nil?
                ordinal = LucilleCore::askQuestionAnswerAsString("ordinal: ").to_f
                Asteroids::setTargetOrdinal(asteroid, target, ordinal)
            })

            menuitems.item(
                "add new target at ordinal".yellow,
                lambda { 
                    o1 = Patricia::architect()
                    return if o1.nil?
                    Arrows::issueOrException(asteroid, o1)
                    ordinal = LucilleCore::askQuestionAnswerAsString("ordinal: ").to_f
                    Asteroids::setTargetOrdinal(asteroid, o1, ordinal)
                }
            )

            puts ""

            menuitems.item(
                "select targets ; move them".yellow,
                lambda {
                    Asteroids::moveSelectedAsteroidTargets(asteroid)
                }
            )

            menuitems.item(
                "select and destroy target".yellow,
                lambda {
                    target = Patricia::selectOneTargetOrNullDefaultToSingletonWithConfirmation(asteroid)
                    return if target.nil?
                    Patricia::destroy(target)
                }
            )

            puts ""

            status = menuitems.promptAndRunSandbox()
            break if !status

        }

        SelectionLookupDataset::updateLookupForAsteroid(asteroid)
    end

    # Asteroids::main()
    def self.main()
        loop {
            system("clear")
            options = [
                "make new asteroid",
                "dive asteroids"
            ]
            option = LucilleCore::selectEntityFromListOfEntitiesOrNull("operation", options)
            break if option.nil?
            if option == "make new asteroid" then
                asteroid = Asteroids::issueAsteroidInteractivelyOrNull()
                next if asteroid.nil?
                puts JSON.pretty_generate(asteroid)
                Asteroids::landing(asteroid)
            end
            if option == "dive asteroids" then
                loop {
                    system("clear")
                    orbitalType = LucilleCore::selectEntityFromListOfEntitiesOrNull("asteroid", Asteroids::asteroidOrbitalTypes())
                    break if orbitalType.nil?
                    Asteroids::diveAsteroidOrbitalType(orbitalType)
                }
            end
        }
    end

    # ------------------------------------------------------------------
end

