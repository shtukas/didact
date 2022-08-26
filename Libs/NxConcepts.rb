
# encoding: UTF-8

class NxConcepts

    # ----------------------------------------------------------------------
    # IO

    # NxConcepts::items()
    def self.items()
        Fx256WithCache::mikuTypeToItems("NxConcept")
    end

    # NxConcepts::destroy(uuid)
    def self.destroy(uuid)
        Fx256::deleteObjectLogically(uuid)
    end

    # ----------------------------------------------------------------------
    # Objects Makers

    # NxConcepts::interactivelyIssueNewItemOrNull()
    def self.interactivelyIssueNewItemOrNull()
        description = LucilleCore::askQuestionAnswerAsString("description (empty to abort): ")
        return nil if description == ""
        unixtime   = Time.new.to_i
        datetime   = Time.new.utc.iso8601
        uuid = SecureRandom.uuid
        DxF1s::setJsonEncoded(uuid, "uuid",        uuid)
        DxF1s::setJsonEncoded(uuid, "mikuType",    "NxConcept")
        DxF1s::setJsonEncoded(uuid, "unixtime",    Time.new.to_i)
        DxF1s::setJsonEncoded(uuid, "datetime",    datetime)
        DxF1s::setJsonEncoded(uuid, "description", description)
        FileSystemCheck::fsckObjectuuidErrorAtFirstFailure(uuid)
        Fx256::broadcastObjectEvents(uuid)
        item = Fx256::getProtoItemOrNull(uuid)
        if item.nil? then
            raise "(error: 01666ee3-d5b4-4fd1-9615-981ac7949ae9) How did that happen ? 🤨"
        end
        item
    end

    # ----------------------------------------------------------------------
    # Data

    # NxConcepts::toString(item)
    def self.toString(item)
        "(concept) #{item["description"]}"
    end
end
