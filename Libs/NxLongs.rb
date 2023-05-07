
class NxLongs

    # NxLongs::items()
    def self.items()
        BladeAdaptation::mikuTypeItems("NxLong")
    end

    # NxLongs::commit(item)
    def self.commit(item)
        BladeAdaptation::commitItem(item)
    end

    # NxLongs::destroy(uuid)
    def self.destroy(uuid)
        Blades::destroy(uuid)
    end

    # NxLongs::interactivelyIssueNewOrNull()
    def self.interactivelyIssueNewOrNull()
        description = LucilleCore::askQuestionAnswerAsString("description (empty to abort): ")
        return nil if description == ""
        uuid = SecureRandom.uuid
        coredataref = CoreData::interactivelyMakeNewReferenceStringOrNull(uuid)
        active = LucilleCore::askQuestionAnswerAsBoolean("is active ? : ")
        Blades::init("NxLong", uuid)
        Blades::setAttribute2(uuid, "unixtime", Time.new.to_i)
        Blades::setAttribute2(uuid, "datetime", Time.new.utc.iso8601)
        Blades::setAttribute2(uuid, "description", description)
        Blades::setAttribute2(uuid, "field11", coredataref)
        Blades::setAttribute2(uuid, "active", active)
        BladeAdaptation::getItemOrNull(uuid)
    end

    # NxLongs::toString(item)
    def self.toString(item)
        "(⛵️) #{item["active"] ? "(active)" : "(sleeping)"} #{item["description"]}#{CoreData::referenceStringToSuffixString(item["field11"])}"
    end

    # NxLongs::program1()
    def self.program1()
        loop {

            system("clear")

            puts ""

            spacecontrol = SpaceControl.new(CommonUtils::screenHeight() - 4)

            store = ItemStore.new()

            puts "active projects:"
            NxLongs::items().select{|item| item["active"] }
                .sort_by{|item| TxEngines::completionRatio(item["engine"]) }
                .each{|item|
                    store.register(item, Listing::canBeDefault(item)) 
                    status = spacecontrol.putsline(Listing::itemToListingLine(store: store, item: item))
                    break if !status
                }

            puts ""

            puts "sleeping projects:"
            NxLongs::items().select{|item| !item["active"] }
                .sort_by{|item| item["unixtime"] }
                .each{|item|
                    store.register(item, Listing::canBeDefault(item)) 
                    status = spacecontrol.putsline(Listing::itemToListingLine(store: store, item: item))
                    break if !status
                }

            puts ""
            input = LucilleCore::askQuestionAnswerAsString("> ")
            return if input == ""

            Listing::listingCommandInterpreter(input, store, nil)
        }
    end

    # NxLongs::interactivelySelectOneOrNull()
    def self.interactivelySelectOneOrNull()
        items = NxLongs::items().select{|item| !item["active"] }
        LucilleCore::selectEntityFromListOfEntitiesOrNull("board", items, lambda{|item| NxLongs::toString(item) })
    end

    # NxLongs::dataMaintenance()
    def self.dataMaintenance()
        # We scan the tasks and any boardless task with more than 2 hours in the bank is automatically turned into a long running project
        NxTasksBoardless::items()
            .sort_by{|item| item["position"] }
            .first(100)
            .each{|item|
                next if Bank::getValue(item["uuid"]) < 3600*2
                puts "transmuting task: #{item["description"]} into a long running project"
                active = LucilleCore::askQuestionAnswerAsBoolean("active ? : ")
                item["mikuType"] = "NxLong"
                item["active"] = active
                BladeAdaptation::commitItem(item)
            }

        if NxLongs::items().size > 0 and NxLongs::items().none?{|item| item["active"] } then
            puts "We do not currently have active long running projects"
            puts "Please select one or more:"
            loop {
                item = NxLongs::interactivelySelectOneOrNull()
                break if item.nil?
                item["active"] = true
                BladeAdaptation::commitItem(item)
                break if !LucilleCore::askQuestionAnswerAsBoolean("more ? ")
            }
        end
    end
end