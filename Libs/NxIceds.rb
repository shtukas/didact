# encoding: UTF-8

class NxIceds

    # NxIceds::objectuuidToItemOrNull(objectuuid)
    def self.objectuuidToItemOrNull(objectuuid)
        return nil if !Fx18Utils::fileExists?(objectuuid)
        return nil if Fx18Attributes::getOrNull(objectuuid, "mikuType") != "NxIced"
        {
            "uuid"        => objectuuid,
            "mikuType"    => Fx18Attributes::getOrNull(objectuuid, "mikuType"),
            "unixtime"    => Fx18Attributes::getOrNull(objectuuid, "unixtime"),
            "datetime"    => Fx18Attributes::getOrNull(objectuuid, "datetime"),
            "description" => Fx18Attributes::getOrNull(objectuuid, "description"),
            "nx111"       => Fx18Utils::jsonParseIfNotNull(Fx18Attributes::getOrNull(objectuuid, "nx111")),
        }
    end

    # NxIceds::items()
    def self.items()
        Fx18Index1::mikuType2objectuuids("NxIced")
            .map{|objectuuid| NxIceds::objectuuidToItemOrNull(objectuuid)}
            .compact
    end

    # NxIceds::destroy(uuid)
    def self.destroy(uuid)
        Fx18Utils::destroyLocalFx18EmitEvents(uuid)
    end

    # --------------------------------------------------
    # Data

    # NxIceds::toString(item)
    def self.toString(item)
        builder = lambda{
            nx111String = item["nx111"] ? " (#{Nx111::toStringShort(item["nx111"])})" : ""
            "(iced) #{item["description"]}#{nx111String}"
        }
        builder.call()
    end

    # NxIceds::toStringForSearch(item)
    def self.toStringForSearch(item)
        "(iced) #{item["description"]}"
    end
end