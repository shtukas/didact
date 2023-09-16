
class Events

    # Events::publish(event)
    def self.publish(event)
        timefragment = "#{Time.new.strftime("%Y")}/#{Time.new.strftime("%Y-%m")}/#{Time.new.strftime("%Y-%m-%d")}"
        folder1 = LucilleCore::indexsubfolderpath("#{EventTimelineReader::eventsTimeline()}/#{timefragment}", 100)
        filepath1 = "#{folder1}/#{CommonUtils::timeStringL22()}.json"
        File.open(filepath1, "w"){|f| f.puts(JSON.pretty_generate(event)) }
        $trace68be8052a3bf = EventTimelineReader::timelineFilepathsReverseEnumerator().next()
    end

    # Events::makeDoNotShowUntil(item, unixtime)
    def self.makeDoNotShowUntil(item, unixtime)
        {
            "uuid"      => SecureRandom.uuid,
            "unixtime"  => Time.new.to_i,
            "eventType" => "DoNotShowUntil",
            "targetId"  => item["uuid"],
            "unixtime"  => unixtime
        }
    end

    # Events::publishDoNotShowUntil(item, unixtime)
    def self.publishDoNotShowUntil(item, unixtime)
        Events::publish(Events::makeDoNotShowUntil(item, unixtime))
    end

    # Events::makeItemAttributeUpdate(itemuuid, attname, attvalue)
    def self.makeItemAttributeUpdate(itemuuid, attname, attvalue)
        {
            "uuid"      => SecureRandom.uuid,
            "unixtime"  => Time.new.to_i,
            "eventType" => "ItemAttributeUpdate",
            "payload" => {
                "itemuuid" => itemuuid,
                "attname"  => attname,
                "attvalue" => attvalue
            }
        }
    end

    # Events::publishItemAttributeUpdate(itemuuid, attname, attvalue)
    def self.publishItemAttributeUpdate(itemuuid, attname, attvalue)
        Events::publish(Events::makeItemAttributeUpdate(itemuuid, attname, attvalue))
    end

    # Events::makeItemDestroy(itemuuid)
    def self.makeItemDestroy(itemuuid)
        {
            "uuid"      => SecureRandom.uuid,
            "unixtime"  => Time.new.to_i,
            "eventType" => "ItemAttributeUpdate",
            "itemuuid"  => itemuuid
        }
    end

    # Events::publishItemDestroy(itemuuid)
    def self.publishItemDestroy(itemuuid)
        Events::publish(Events::makeItemDestroy(itemuuid))
    end

    # Events::makeItemInit(uuid, mikuType)
    def self.makeItemInit(uuid, mikuType)
        {
            "uuid"      => SecureRandom.uuid,
            "unixtime"  => Time.new.to_i,
            "eventType" => "ItemInit",
            "payload" => {
                "uuid"     => uuid,
                "mikuType" => mikuType
            }
        }
    end

    # Events::publishItemInit(uuid, mikuType)
    def self.publishItemInit(uuid, mikuType)
        Events::publish(Events::makeItemInit(uuid, mikuType))
    end
end