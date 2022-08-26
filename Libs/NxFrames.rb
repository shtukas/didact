# encoding: UTF-8

class NxFrames

    # NxFrames::items()
    def self.items()
        TheIndex::mikuTypeToItems("NxFrame")
    end

    # NxFrames::destroy(uuid)
    def self.destroy(uuid)
        DxF1::deleteObjectLogically(uuid)
    end

    # --------------------------------------------------
    # Makers

    # NxFrames::interactivelyCreateNewOrNull()
    def self.interactivelyCreateNewOrNull()
        description = LucilleCore::askQuestionAnswerAsString("description (empty to abort): ")
        return nil if description == ""
        uuid = SecureRandom.uuid
        nx111 = Nx111::interactivelyCreateNewNx111OrNull(uuid)
        unixtime = Time.new.to_i
        datetime = Time.new.utc.iso8601
        DxF1::setJsonEncoded(uuid, "uuid",        uuid)
        DxF1::setJsonEncoded(uuid, "mikuType",    "NxFrame")
        DxF1::setJsonEncoded(uuid, "unixtime",    unixtime)
        DxF1::setJsonEncoded(uuid, "datetime",    datetime)
        DxF1::setJsonEncoded(uuid, "description", description)
        DxF1::setJsonEncoded(uuid, "nx111",       nx111)
        FileSystemCheck::fsckObjectuuidErrorAtFirstFailure(uuid)
        DxF1::broadcastObjectFile(uuid)
        item = DxF1::getProtoItemOrNull(uuid)
        if item.nil? then
            raise "(error: b63ae301-b0a1-47da-a445-8c53a457d0fe) How did that happen ? 🤨"
        end
        item
    end

    # --------------------------------------------------
    # Data

    # NxFrames::toString(item)
    def self.toString(item)
        nx111String = item["nx111"] ? " (#{Nx111::toStringShort(item["nx111"])})" : ""
        "(frame) #{item["description"]}#{nx111String}"
    end

    # NxFrames::toStringForSearch(item)
    def self.toStringForSearch(item)
        "(frame) #{item["description"]}"
    end

    # --------------------------------------------------
    # Operations

    # NxFrames::dive()
    def self.dive()
        loop {
            system("clear")
            items = NxFrames::items()
                        .sort{|i1, i2| i1["unixtime"] <=> i2["unixtime"]}
            item = LucilleCore::selectEntityFromListOfEntitiesOrNull("frame", items, lambda{|item| LxFunction::function("toString", item) })
            return if item.nil?
            Landing::landing(item, false)
        }
    end
end
