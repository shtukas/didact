
class Waves

    # --------------------------------------------------
    # IO

    # Waves::items()
    def self.items()
        Librarian6Objects::getObjectsByMikuType("Wave")
    end

    # Waves::destroy(uuid)
    def self.destroy(uuid)
        Librarian6Objects::destroy(uuid)
    end

    # --------------------------------------------------
    # Making

    # Waves::makeScheduleParametersInteractivelyOrNull() # [type, value]
    def self.makeScheduleParametersInteractivelyOrNull()

        scheduleTypes = ['sticky', 'repeat']
        scheduleType = LucilleCore::selectEntityFromListOfEntitiesOrNull("schedule type: ", scheduleTypes)

        return nil if scheduleType.nil?

        if scheduleType=='sticky' then
            fromHour = LucilleCore::askQuestionAnswerAsString("From hour (integer): ").to_i
            return ["sticky", fromHour]
        end

        if scheduleType=='repeat' then

            repeat_types = ['every-n-hours','every-n-days','every-this-day-of-the-week','every-this-day-of-the-month']
            type = LucilleCore::selectEntityFromListOfEntities_EnsureChoice("repeat type: ", repeat_types, lambda{|entity| entity })

            return nil if type.nil?

            if type=='every-n-hours' then
                print "period (in hours): "
                value = STDIN.gets().strip.to_f
                return [type, value]
            end
            if type=='every-n-days' then
                print "period (in days): "
                value = STDIN.gets().strip.to_f
                return [type, value]
            end
            if type=='every-this-day-of-the-month' then
                print "day number (String, length 2): "
                value = STDIN.gets().strip
                return [type, value]
            end
            if type=='every-this-day-of-the-week' then
                weekdays = ['monday','tuesday','wednesday','thursday','friday','saturday','sunday']
                value = LucilleCore::selectEntityFromListOfEntities_EnsureChoice("weekday: ", weekdays, lambda{|entity| entity })
                return [type, value]
            end
        end
        raise "e45c4622-4501-40e1-a44e-2948544df256"
    end

    # Waves::computeNextShowUp(item)
    def self.computeNextShowUp(item)
        if item["repeatType"] == 'sticky' then
            # unixtime1 is the time of the event happening today
            # It can still be ahead of us.
            unixtime1 = (Utils::unixtimeAtComingMidnightAtGivenTimeZone(Utils::getLocalTimeZone()) - 86400) + item["repeatValue"].to_i*3600
            if unixtime1 > Time.new.to_i then
                return unixtime1
            end
            # We return the event happening tomorrow
            return Utils::unixtimeAtComingMidnightAtGivenTimeZone(Utils::getLocalTimeZone()) + item["repeatValue"].to_i*3600
        end
        if item["repeatType"] == 'every-n-hours' then
            return Time.new.to_i+3600 * item["repeatValue"].to_f
        end
        if item["repeatType"] == 'every-n-days' then
            return Time.new.to_i+86400 * item["repeatValue"].to_f
        end
        if item["repeatType"] == 'every-this-day-of-the-month' then
            cursor = Time.new.to_i + 86400
            while Time.at(cursor).strftime("%d") != item["repeatValue"] do
                cursor = cursor + 3600
            end
           return cursor
        end
        if item["repeatType"] == 'every-this-day-of-the-week' then
            mapping = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday']
            cursor = Time.new.to_i + 86400
            while mapping[Time.at(cursor).wday] != item["repeatValue"] do
                cursor = cursor + 3600
            end
            return cursor
        end
    end

    # Waves::scheduleString(item)
    def self.scheduleString(item)
        if item["repeatType"] == 'sticky' then
            return "sticky, from: #{item["repeatValue"]}"
        end
        "#{item["repeatType"]}: #{item["repeatValue"]}"
    end

    # Waves::issueNewWaveInteractivelyOrNull()
    def self.issueNewWaveInteractivelyOrNull()

        description = LucilleCore::askQuestionAnswerAsString("description (empty to abort): ")
        return nil if description == ""

        iAmValue = Nx111::interactivelyCreateNewIamValueOrNull(Nx111::iamTypesForManualMakingOfCatalystItems())
        return nil if iAmValue.nil?

        schedule = Waves::makeScheduleParametersInteractivelyOrNull()
        return nil if schedule.nil?

        Librarian6Objects::commit(atom)

        wave = {
            "uuid"        => SecureRandom.uuid,
            "mikuType"    => "Wave",
            "unixtime"    => Time.new.to_f,
            "description" => description,
            "iam"         => iAmValue,
        }

        wave["repeatType"]       = schedule[0]
        wave["repeatValue"]      = schedule[1]
        wave["lastDoneDateTime"] = "#{Time.new.strftime("%Y")}-01-01T00:00:00Z"

        Librarian6Objects::commit(wave)
        wave
    end

    # -------------------------------------------------------------------------
    # Operations

    # Waves::toString(item)
    def self.toString(item)
        lastDoneDateTime = item["lastDoneDateTime"] || "#{Time.new.strftime("%Y")}-01-01T00:00:00Z"
        ago = "#{((Time.new.to_i - DateTime.parse(lastDoneDateTime).to_time.to_i).to_f/86400).round(2)} days ago"
        "[wave] #{item["description"]} (#{item["iam"][0]}) (#{Waves::scheduleString(item)}) (#{ago})"
    end

    # Waves::performDone(wave)
    def self.performDone(wave)
        if Waves::toString(wave).include?("[backup]") then
            logfile = "/Users/pascal/Galaxy/LucilleOS/Backups-Utils/logs/main.txt"
            File.open(logfile, "a"){|f| f.puts("#{Time.new.to_s} : #{wave["description"]}")}
        end

        puts "done-ing: #{Waves::toString(wave)}"
        wave["lastDoneDateTime"] = Time.now.utc.iso8601
        Librarian6Objects::commit(wave)

        unixtime = Waves::computeNextShowUp(wave)
        puts "Not shown until: #{Time.at(unixtime).to_s}"
        DoNotShowUntil::setUnixtime(wave["uuid"], unixtime)
    end

    # Waves::landing(item)
    def self.landing(item)
        uuid = item["uuid"]

        loop {

            system("clear")

            store = ItemStore.new()

            uuid = item["uuid"]

            puts "#{Waves::toString(item)}".green

            puts "uuid: #{item["uuid"]}".yellow
            puts "iam: #{item["iam"]}".yellow
            puts "schedule: #{Waves::scheduleString(item)}".yellow
            puts "last done: #{item["lastDoneDateTime"]}".yellow
            puts "DoNotShowUntil: #{DoNotShowUntil::getDateTimeOrNull(item["uuid"])}".yellow
            puts "universe: #{ObjectUniverseMapping::getObjectUniverseMappingOrNull(item["uuid"])}".yellow

            TxAttachments::itemsForOwner(uuid).each{|attachment|
                indx = store.register(attachment, false)
                puts "[#{indx.to_s.ljust(3)}] #{TxAttachments::toString(attachment)}" 
            }

            puts ""

            puts "access | done | <datecode> | description | iam | attachment | schedule | universe | destroy | exit (xx)".yellow

            command = LucilleCore::askQuestionAnswerAsString("> ")

            break if command == "exit"
            break if command == "xx"

            if (indx = Interpreting::readAsIntegerOrNull(command)) then
                entity = store.get(indx)
                next if entity.nil?
                LxAction::action("landing", entity)
            end

            if command == "access" then
                Nx111::accessIamCarrierPossibleStorageMutation(item)
                next
            end

            if command == "done" then
                Waves::performDone(item)
                break
            end

            if (unixtime = Utils::codeToUnixtimeOrNull(command.gsub(" ", ""))) then
                DoNotShowUntil::setUnixtime(uuid, unixtime)
                break
            end

            if Interpreting::match("description", command) then
                item["description"] = Utils::editTextSynchronously(item["description"])
                Waves::performDone(item)
                next
            end

            if Interpreting::match("iam", command) then
                iAmValue = Nx111::interactivelyCreateNewIamValueOrNull(Nx111::iamTypesForManualMakingOfCatalystItems())
                next if iAmValue.nil?
                puts JSON.pretty_generate(iAmValue)
                if LucilleCore::askQuestionAnswerAsBoolean("confirm change ? ") then
                    item["iam"] = iAmValue
                    Librarian6Objects::commit(item)
                end
            end

            if Interpreting::match("attachment", command) then
                TxAttachments::interactivelyCreateNewOrNullForOwner(item["uuid"])
                next
            end

            if Interpreting::match("schedule", command) then
                schedule = Waves::makeScheduleParametersInteractivelyOrNull()
                return if schedule.nil?
                item["repeatType"] = schedule[0]
                item["repeatValue"] = schedule[1]
                Librarian6Objects::commit(item)
                next
            end

            if Interpreting::match("universe", command) then
                ObjectUniverseMapping::interactivelySetObjectUniverseMapping(item["uuid"])
                next
            end

            if Interpreting::match("destroy", command) then
                if LucilleCore::askQuestionAnswerAsBoolean("Do you want to destroy this wave ? : ") then
                    Waves::destroy(item["uuid"])
                    break
                end
            end
        }
    end

    # -------------------------------------------------------------------------
    # Waves

    # Waves::selectWaveOrNull()
    def self.selectWaveOrNull()
        LucilleCore::selectEntityFromListOfEntitiesOrNull("wave", Waves::items().sort{|w1, w2| w1["lastDoneDateTime"] <=> w2["lastDoneDateTime"] }, lambda {|wave| Waves::toString(wave) })
    end

    # Waves::waves()
    def self.waves()
        loop {
            system("clear")
            wave = Waves::selectWaveOrNull()
            return if wave.nil?
            Waves::landing(wave)
        }
    end

    # -------------------------------------------------------------------------
    # NS16

    # Waves::access(item) # Code
    # "ebdc6546-8879" # Continue
    # "8a2aeb48-780d" # Close NxBall
    def self.access(item)
        system("clear")
        uuid = item["uuid"]
        puts Waves::toString(item)
        puts "Starting at #{Time.new.to_s}"

        Nx111::accessIamCarrierPossibleStorageMutation(item)

        loop {
            operation = LucilleCore::selectEntityFromListOfEntitiesOrNull("operation", ["done (default)", "stop and exit", "exit and continue", "landing and back", "delay"])

            if operation.nil? or operation == "done (default)" then
                Waves::performDone(item)
                NxBallsService::close(uuid, true)
                return "8a2aeb48-780d" # Close NxBall
            end
            if operation == "stop and exit" then
                NxBallsService::close(uuid, true)
                return "8a2aeb48-780d" # Close NxBall
            end
            if operation == "exit and continue" then
                return "ebdc6546-8879" # Continue
            end
            if operation == "landing and back" then
                Waves::landing(item)
                # The next line handle if the landing resulted in a destruction of the object
                if Librarian6Objects::getObjectByUUIDOrNull(item["uuid"]).nil? then
                    NxBallsService::close(uuid, true)
                    return "8a2aeb48-780d" # Close NxBall
                end
            end
            if operation == "delay" then
                unixtime = Utils::interactivelySelectUnixtimeOrNull()
                if unixtime then
                    DoNotShowUntil::setUnixtime(item["uuid"], unixtime)
                    NxBallsService::close(uuid, true)
                    return "8a2aeb48-780d" # Close NxBall
                end
            end
        }
    end

    # Waves::isPriorityWave(wave)
    def self.isPriorityWave(wave)
        return true if wave["repeatType"] == "sticky"
        return true if wave["repeatType"] == "every-this-day-of-the-month"
        return true if wave["repeatType"] == "every-this-day-of-the-week"
        false
    end

    # Waves::toNS16(wave)
    def self.toNS16(wave)
        uuid = wave["uuid"]
        {
            "uuid"     => uuid,
            "mikuType" => "NS16:Wave",
            "announce" => Waves::toString(wave),
            "wave"     => wave
        }
    end

    # Waves::ns16s(universe)
    def self.ns16s(universe)
        items1, items2 = Waves::items()
            .select{|item| 
                objuniverse = ObjectUniverseMapping::getObjectUniverseMappingOrNull(item["uuid"])
                universe.nil? or objuniverse.nil? or (objuniverse == universe) 
            }
            .partition{|wave| Waves::isPriorityWave(wave) }

        items2 = items2
                .sort{|w1, w2| w1["lastDoneDateTime"] <=> w2["lastDoneDateTime"] }

        (items1 + items2)
            .select{|wave| DoNotShowUntil::isVisible(wave["uuid"]) }
            .select{|wave| InternetStatus::ns16ShouldShow(wave["uuid"]) }
            .map{|wave| Waves::toNS16(wave) }
    end

    # Waves::nx20s()
    def self.nx20s()
        Waves::items().map{|item|
            {
                "announce" => Waves::toString(item),
                "unixtime" => item["unixtime"],
                "payload"  => item
            }
        }
    end
end
