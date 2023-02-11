# encoding: UTF-8

class NxHeads

    # NxHeads::items()
    def self.items()
        ObjectStore2::objects("NxHeads")
    end

    # NxHeads::commit(item)
    def self.commit(item)
        ObjectStore2::commit("NxHeads", item)
    end

    # NxHeads::getItemOfNull(uuid)
    def self.getItemOfNull(uuid)
        ObjectStore2::getOrNull("NxHeads", uuid)
    end

    # NxHeads::destroy(uuid)
    def self.destroy(uuid)
        ObjectStore2::destroy("NxHeads", uuid)
    end

    # --------------------------------------------------
    # Makers

    # NxHeads::interactivelyIssueNewOrNull()
    def self.interactivelyIssueNewOrNull()
        description = LucilleCore::askQuestionAnswerAsString("description (empty to abort): ")
        return nil if description == ""
        uuid  = SecureRandom.uuid
        coredataref = CoreData::interactivelyMakeNewReferenceStringOrNull(uuid)
        position = NxList::midposition()
        item = {
            "uuid"        => uuid,
            "mikuType"    => "NxHead",
            "unixtime"    => Time.new.to_i,
            "datetime"    => Time.new.utc.iso8601,
            "description" => description,
            "field11"     => coredataref,
            "position"    => position
        }
        NxHeads::commit(item)
        item
    end

    # --------------------------------------------------
    # Data

    # NxHeads::toString(item)
    def self.toString(item)
        rt = BankUtils::recoveredAverageHoursPerDay(item["uuid"])
        "(stream) (#{"%5.2f" % rt}) #{item["description"]} (pos: #{item["position"]})"
    end

    # NxHeads::endPosition()
    def self.endPosition()
        ([-4] + NxHeads::items().map{|item| item["position"] }).max
    end

    # NxHeads::listingItems()
    def self.listingItems()
        NxHeads::items()
            .sort{|i1, i2| i1["position"] <=> i2["position"] }
            .take(3)
            .map {|item|
                {
                    "item" => item,
                    "rt"   => BankUtils::recoveredAverageHoursPerDay(item["uuid"])
                }
            }
            .sort{|p1, p2| p1["rt"] <=> p2["rt"] }
            .map {|packet| packet["item"] }
    end

    # --------------------------------------------------
    # Operations

    # NxHeads::access(item)
    def self.access(item)
        CoreData::access(item["field11"])
    end
end