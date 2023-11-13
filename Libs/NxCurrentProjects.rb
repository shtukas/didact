
class NxCurrentProjects

    # NxCurrentProjects::interactivelyIssueNewOrNull()
    def self.interactivelyIssueNewOrNull()
        description = LucilleCore::askQuestionAnswerAsString("description (empty to abort): ")
        return nil if description == ""
        uuid = SecureRandom.uuid
        Updates::itemInit(uuid, "NxCurrentProject")
        coredataref = CoreDataRefStrings::interactivelyMakeNewReferenceStringOrNull(uuid)
        Updates::itemAttributeUpdate(uuid, "unixtime", Time.new.to_i)
        Updates::itemAttributeUpdate(uuid, "datetime", Time.new.utc.iso8601)
        Updates::itemAttributeUpdate(uuid, "description", description)
        Updates::itemAttributeUpdate(uuid, "field11", coredataref)
        Broadcasts::publishItem(uuid)
        Catalyst::itemOrNull(uuid)
    end

    # ------------------
    # Data

    # NxCurrentProjects::toString(item)
    def self.toString(item)
        "⚙️  #{TxEngines::prefix2(item)}#{item["description"]}#{CoreDataRefStrings::itemToSuffixString(item)}"
    end

    # NxCurrentProjects::listingItems()
    def self.listingItems()
        items = Catalyst::mikuType("NxCurrentProject")
        i1, i2 = items.partition{|item| item["engine-0916"] }
        [
            i1.select{|item| TxEngines::dailyRelativeCompletionRatio(item["engine-0916"]) < 1 },
            i2
        ].flatten
    end

    # ------------------
    # Ops

    # NxCurrentProjects::access(item)
    def self.access(item)
        CoreDataRefStrings::accessAndMaybeEdit(item["uuid"], item["field11"])
    end
end