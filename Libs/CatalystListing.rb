# encoding: UTF-8

class CatalystListing

    # CatalystListing::listingItems()
    def self.listingItems()
        items = [
            JSON.parse(`#{Config::userHomeDirectory()}/Galaxy/Binaries/fitness ns16s`),
            Anniversaries::listingItems(),
            Waves::listingItems(true),
            TxTimeCommitments::listingItems(),
            Waves::listingItems(false),
            TxDateds::listingItems(),
            NxTasks::listingItems(),
        ]
            .flatten
            .select{|item| DoNotShowUntil::isVisible(item["uuid"]) or NxBallsService::isPresent(item["uuid"]) }
            .select{|item| InternetStatus::itemShouldShow(item["uuid"]) or NxBallsService::isPresent(item["uuid"]) }
            .select{|item| !TimeCommitmentMapping::isOwned(item["uuid"]) or NxBallsService::isPresent(item["uuid"]) }

        its1, its2 = items.partition{|item| NxBallsService::isPresent(item["uuid"]) }
        its1 + its2.sort{|i1, i2| PolyFunctions::listingPriority(i1) <=> PolyFunctions::listingPriority(i2) }.reverse
    end

    # CatalystListing::program()
    def self.program()

        initialCodeTrace = CommonUtils::generalCodeTrace()

        SystemEvents::processCommsLine(true)

        loop {

            #puts "(code trace)"
            if CommonUtils::generalCodeTrace() != initialCodeTrace then
                puts "Code change detected"
                break
            end

            $commline_semaphore.synchronize {
                SystemEvents::processCommsLine(true)
                SystemEvents::flushChannel1()
            }

            LucilleCore::locationsAtFolder("#{ENV['HOME']}/Desktop/NxTasks")
                .each{|location|
                    next if File.basename(location).start_with?(".")
                    item = NxTasks::issueUsingLocation(location)
                    puts "Picked up from NxTasks: #{JSON.pretty_generate(item)}"
                    LucilleCore::removeFileSystemLocation(location)
                }

            if ProgrammableBooleans::trueNoMoreOftenThanEveryNSeconds("79ff9488-403e-43e4-b972-dd6e87b4e8d9", 86400) then
                TheIndex::updateIndexReadingDxF1s()
            end

            PolyPrograms::catalystMainListing()
        }
    end

    # CatalystListing::getContextOrNull()
    # context: a time commitment
    def self.getContextOrNull()
        uuid = XCache::getOrNull("7390a691-c8c4-4798-9214-704c5282f5e3")
        return nil if uuid.nil?
        TheIndex::getItemOrNull(uuid)
    end

    # CatalystListing::setContext(uuid)
    def self.setContext(uuid)
        XCache::set("7390a691-c8c4-4798-9214-704c5282f5e3", uuid)
    end

    # CatalystListing::emptyContext()
    def self.emptyContext()
        XCache::destroy("7390a691-c8c4-4798-9214-704c5282f5e3")
    end
end