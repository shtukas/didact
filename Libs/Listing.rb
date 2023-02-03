# encoding: UTF-8

class Listing

    # Listing::listingCommands()
    def self.listingCommands()
        [
            "[all] .. | <datecode> | access (<n>) | do not show until <n> | done (<n>) | landing (<n>) | expose (<n>) | >> skip default | lock (<n>) | push | set time commitment |destroy",
            "[makers] anniversary | manual countdown | wave | today | ondate | todo | drop | top | capsule",
            "[divings] anniversaries | ondates | waves | todos | desktop",
            "[NxBalls] start | start * | stop | stop * | pause | pursue",
            "[NxTodo] redate",
            "[misc] search | speed | commands",
        ].join("\n")
    end

    # Listing::listingCommandInterpreter(input, store)
    def self.listingCommandInterpreter(input, store)

        if input.start_with?("+") and (unixtime = CommonUtils::codeToUnixtimeOrNull(input.gsub(" ", ""))) then
            if (item = store.getDefault()) then
                DoNotShowUntil::setUnixtime(item["uuid"], unixtime)
                return
            end
        end

        if Interpreting::match("..", input) then
            item = store.getDefault()
            return if item.nil?
            PolyActions::doubleDot(item)
            return
        end

        if Interpreting::match(".. *", input) then
            _, ordinal = Interpreting::tokenizer(input)
            item = store.get(ordinal.to_i)
            return if item.nil?
            PolyActions::doubleDot(item)
            return
        end

        if Interpreting::match(">>", input) then
            item = store.getDefault()
            return if item.nil?
            Skips::skip(item["uuid"], Time.new.to_f + 3600*1.5)
            return
        end

        if Interpreting::match("access", input) then
            item = store.getDefault()
            return if item.nil?
            PolyActions::access(item)
            return
        end

        if Interpreting::match("access *", input) then
            _, ordinal = Interpreting::tokenizer(input)
            item = store.get(ordinal.to_i)
            return if item.nil?
            PolyActions::access(item)
            return
        end

        if Interpreting::match("anniversary", input) then
            Anniversaries::issueNewAnniversaryOrNullInteractively()
            return
        end

        if Interpreting::match("anniversaries", input) then
            Anniversaries::dive()
            return
        end

        if Interpreting::match("commands", input) then
            puts Listing::listingCommands().yellow
            LucilleCore::pressEnterToContinue()
            return
        end

        if Interpreting::match("capsule", input) then
            hours = LucilleCore::askQuestionAnswerAsString("hours (algebraic, negative for done time): ").to_f
            tc = NxTimeCommitments::interactivelySelectOneOrNull()
            return if tc.nil?
            capsule = {
                "uuid"        => SecureRandom.uuid,
                "mikuType"    => "NxTimeCapsule",
                "unixtime"    => Time.new.to_i,
                "datetime"    => Time.new.utc.iso8601,
                "description" => tc["description"],
                "field1"      => hours,
                "field10"     => tc["uuid"]
            }
            ObjectStore1::commitObject(capsule)
            return
        end

        if Interpreting::match("description", input) then
            item = store.getDefault()
            return if item.nil?
            puts "edit description:"
            item["description"] = CommonUtils::editTextSynchronously(item["description"])
            ObjectStore1::commitItem(item)
            return
        end

        if Interpreting::match("description *", input) then
            _, ordinal = Interpreting::tokenizer(input)
            item = store.get(ordinal.to_i)
            return if item.nil?
            puts "edit description:"
            item["description"] = CommonUtils::editTextSynchronously(item["description"])
            ObjectStore1::commitItem(item)
            return
        end

        if Interpreting::match("desktop", input) then
            system("open '#{Desktop::desktopFolderPath()}'")
            return
        end

        if Interpreting::match("destroy", input) then
            item = store.getDefault()
            return if item.nil?
            if LucilleCore::askQuestionAnswerAsBoolean("confirm destruction of #{item["mikuType"]} '#{PolyFunctions::toString(item).green}' ") then
                ObjectStore1::destroy(item["uuid"])
            end
            return
        end

        if Interpreting::match("destroy *", input) then
            _, ordinal = Interpreting::tokenizer(input)
            item = store.get(ordinal.to_i)
            return if item.nil?
            if LucilleCore::askQuestionAnswerAsBoolean("confirm destruction of #{item["mikuType"]} '#{PolyFunctions::toString(item).green}' ") then
                ObjectStore1::destroy(item["uuid"])
            end
            return
        end

        if Interpreting::match("done", input) then
            item = store.getDefault()
            return if item.nil?
            PolyActions::done(item)
            return
        end

        if Interpreting::match("done *", input) then
            _, ordinal = Interpreting::tokenizer(input)
            item = store.get(ordinal.to_i)
            return if item.nil?
            PolyActions::done(item)
            return
        end

        if Interpreting::match("do not show until *", input) then
            _, _, _, _, ordinal = Interpreting::tokenizer(input)
            item = store.get(ordinal.to_i)
            return if item.nil?
            datecode = LucilleCore::askQuestionAnswerAsString("datecode: ")
            return if datecode == ""
            unixtime = CommonUtils::codeToUnixtimeOrNull(datecode.gsub(" ", ""))
            return if unixtime.nil?
            DoNotShowUntil::setUnixtime(item["uuid"], unixtime)
            return
        end

        if Interpreting::match("drop", input) then
            NxDrops::interactivelyIssueNewOrNull()
        end

        if Interpreting::match("exit", input) then
            exit
        end

        if Interpreting::match("expose", input) then
            item = store.getDefault()
            return if item.nil?
            puts JSON.pretty_generate(item)
            LucilleCore::pressEnterToContinue()
            return
        end

        if Interpreting::match("expose *", input) then
            _, ordinal = Interpreting::tokenizer(input)
            item = store.get(ordinal.to_i)
            return if item.nil?
            puts JSON.pretty_generate(item)
            LucilleCore::pressEnterToContinue()
            return
        end

        if Interpreting::match("landing", input) then
            item = store.getDefault()
            return if item.nil?
            PolyActions::landing(item)
            return
        end

        if Interpreting::match("landing *", input) then
            _, ordinal = Interpreting::tokenizer(input)
            item = store.get(ordinal.to_i)
            return if item.nil?
            PolyActions::landing(item)
            return
        end

        if Interpreting::match("lock", input) then
            item = store.getDefault()
            return if item.nil?
            domain = LucilleCore::askQuestionAnswerAsString("domain: ")
            Locks::lock(domain, item["uuid"])
            return
        end

        if Interpreting::match("manual countdown", input) then
            TxManualCountDowns::issueNewOrNull()
            return
        end

        if Interpreting::match("ondate", input) then
            item = NxTodos::interactivelyIssueNewOndateOrNull()
            return if item.nil?
            puts JSON.pretty_generate(item)
            return
        end

        if Interpreting::match("ondates", input) then
            NxTodos::ondateReport()
            return
        end

        if Interpreting::match("push", input) then
            item = store.getDefault()
            return if item.nil?
            trajectory = Engine::trajectory(Time.new.to_f + 3600*6, 24)
            ObjectStore1::set(item["uuid"], "field13", JSON.generate(trajectory))
            return
        end

        if Interpreting::match("pause", input) then
            item = store.getDefault()
            return if item.nil?
            PolyActions::pause(item)
            return
        end

        if Interpreting::match("pause *", input) then
            _, ordinal = Interpreting::tokenizer(input)
            item = store.get(ordinal.to_i)
            return if item.nil?
            PolyActions::pause(item)
            return
        end

        if Interpreting::match("pursue", input) then
            item = store.getDefault()
            return if item.nil?
            PolyActions::pursue(item)
            return
        end

        if Interpreting::match("pursue *", input) then
            _, ordinal = Interpreting::tokenizer(input)
            item = store.get(ordinal.to_i)
            return if item.nil?
            PolyActions::pursue(item)
            return
        end

        if Interpreting::match("redate", input) then
            item = store.getDefault()
            return if item.nil?
            if item["mikuType"] != "NxTodo" then
                puts "redate is reserved for NxTodos"
                LucilleCore::pressEnterToContinue()
                return
            end
            if item["field2"] != "ondate" then
                puts "redate is reserved for NxTodos with ondate"
                LucilleCore::pressEnterToContinue()
                return
            end
            unixtime = CommonUtils::interactivelySelectUnixtimeUsingDateCodeOrNull()
            item["doNotShowUntil"] = unixtime
            item["datetime"] = Time.at(unixtime).utc.iso8601
            ObjectStore1::commitItem(item)
            return
        end

        if Interpreting::match("set time commitment", input) then
            item = store.getDefault()
            return if item.nil?
            return if ["NxDrop", "NxTop"].include?(item["mikuType"])
            tc = NxTimeCommitments::interactivelySelectOneOrNull()
            return if tc.nil?
            item["field10"] = tc["uuid"]
            ObjectStore1::commitItem(item)
            return
        end

        if Interpreting::match("start", input) then
            item = store.getDefault()
            return if item.nil?
            PolyActions::start(item)
            return
        end

        if Interpreting::match("start *", input) then
            _, ordinal = Interpreting::tokenizer(input)
            item = store.get(ordinal.to_i)
            return if item.nil?
            PolyActions::start(item)
            return
        end

        if Interpreting::match("stop", input) then
            item = store.getDefault()
            return if item.nil?
            PolyActions::stop(item)
            return
        end

        if Interpreting::match("stop *", input) then
            _, ordinal = Interpreting::tokenizer(input)
            item = store.get(ordinal.to_i)
            return if item.nil?
            PolyActions::stop(item)
            return
        end

        if Interpreting::match("search", input) then
            SearchCatalyst::run()
            return
        end

        if Interpreting::match("top", input) then
            NxTops::interactivelyIssueNullOrNull()
        end

        if Interpreting::match("today", input) then
            item = NxTodos::interactivelyIssueNewTodayOrNull()
            return if item.nil?
            puts JSON.pretty_generate(item)
            return
        end

        if Interpreting::match("todo", input) then
            item = NxTodos::interactivelyIssueNewRegularOrNull()
            return if item.nil?
            puts JSON.pretty_generate(item)
            return
        end

        if input == "wave" then
            Waves::issueNewWaveInteractivelyOrNull()
            return
        end

        if input == "waves" then
            Waves::dive()
            return
        end

        if Interpreting::match("speed", input) then
            LucilleCore::pressEnterToContinue()
            return
        end
    end

    # Listing::isNxTimeCapsuleStoppedAndCompleted(item)
    def self.isNxTimeCapsuleStoppedAndCompleted(item)
        return false if item["mikuType"] != "NxTimeCapsule"
        return false if item["field2"]     # we are running
        return false if item["field1"] > 0 # we are still positive
        true
    end

    # Listing::isPriorityItem(item)
    def self.isPriorityItem(item)
        return true if PolyFunctions::toStringForListing(item).include?("sticky")
        return true if NxBalls::nxballSuffixStatus(item["field9"]).include?("nxball")
        return true if PolyFunctions::toStringForListing(item).include?("countdown")
        false
    end

    # Listing::mainProgram2Pure()
    def self.mainProgram2Pure()

        initialCodeTrace = CommonUtils::stargateTraceCode()

        $SyncConflictInterruptionFilepath = nil

        loop {

            if CommonUtils::stargateTraceCode() != initialCodeTrace then
                puts "Code change detected"
                break
            end

            if $SyncConflictInterruptionFilepath then
                puts "$SyncConflictInterruptionFilepath: #{$SyncConflictInterruptionFilepath}"
                exit
            end

            LucilleCore::locationsAtFolder("#{ENV['HOME']}/Galaxy/DataHub/NxTodos-BufferIn")
                .each{|location|
                    next if File.basename(location).start_with?(".")
                    item = NxTodos::bufferInImport(location)
                    puts "Picked up from NxTodos-BufferIn: #{JSON.pretty_generate(item)}"
                    LucilleCore::removeFileSystemLocation(location)
                }

            NxTimeCapsules::garbageCollection()

            if ProgrammableBooleans::trueNoMoreOftenThanEveryNSeconds("2bf15677-bac8-4467-b7cc-e313113df3a9", 3600) then
                puts "Engine::listingActivations()"
                Engine::listingActivations()
            end

            system("clear")
            store = ItemStore.new()
            vspaceleft = CommonUtils::screenHeight() - 4

            dskt = Desktop::contents()
            if dskt.size > 0 then
                puts ""
                puts "Desktop:".green
                vspaceleft = vspaceleft - 2
                puts dskt
                vspaceleft = vspaceleft - CommonUtils::verticalSize(dskt)
                puts ""
                vspaceleft = vspaceleft - 1
            end
            
            timecommitments = Engine::itemsForMikuType("NxTimeCommitment")
            vspaceleft = vspaceleft - timecommitments.size

            tops = Engine::itemsForMikuType("NxTop")
            if tops.size > 0 then
                tops.each{|item|
                    store.register(item, false)
                    line = "(#{store.prefixString()})         #{NxTops::toString(item)}#{NxBalls::nxballSuffixStatus(item["field9"])}"
                    if line. include?("running") then
                        line = line.green
                    end
                    puts line
                    vspaceleft = vspaceleft - 1
                }
            end

            trajectoryToNumber = lambda{|trajectory|
                return 0.8 if trajectory.nil?
                (Time.new.to_i - trajectory["activationunixtime"]).to_f/(trajectory["expectedTimeToCompletionInHours"]*3600)
            }

            puts ""
            vspaceleft = vspaceleft - 1

            items =
            Engine::listingItems()
                .select{|item| DoNotShowUntil::isVisible(item) }
                .map{|item|
                    item["listing:position"] = trajectoryToNumber.call(item["field13"])
                    item
                }
                .select{|item| item["listing:position"] > 0 }
                .sort{|i1, i2| i1["listing:position"] <=> i2["listing:position"] }
                .reverse

            CommonUtils::putFirst(items, lambda{|e| Listing::isPriorityItem(e) })
                .each{|item|
                    next if Listing::isNxTimeCapsuleStoppedAndCompleted(item)
                    store.register(item, !Skips::isSkipped(item) && !Locks::isLocked(item))
                    line = "(#{store.prefixString()}) (#{"%5.2f" % item["listing:position"]}) #{PolyFunctions::toStringForListing(item)}#{item["field10"] ? " (tc: #{NxTimeCommitments::uuidToDescription(item["field10"])})" : "" }#{NxBalls::nxballSuffixStatus(item["field9"])}"
                    if Locks::isLocked(item) then
                        line = "#{line} [lock: #{item["field8"]}]".yellow
                    end
                    if NxBalls::itemIsRunning(item) or NxBalls::itemIsPaused(item) then
                        line = line.green
                    end
                    puts line
                    vspaceleft = vspaceleft - CommonUtils::verticalSize(line)
                    break if vspaceleft <= 0
                }
            timecommitments
                .each{|item|
                    store.register(item, false)
                    puts "(#{store.prefixString()}) #{NxTimeCommitments::toStringForListing(item)}"
                }
            puts The99Percent::line()

            puts ""
            input = LucilleCore::askQuestionAnswerAsString("> ")
            next if input == ""

            Listing::listingCommandInterpreter(input, store)
        }
    end
end
