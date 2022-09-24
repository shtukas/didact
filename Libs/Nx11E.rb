# encoding: UTF-8

class Nx11EGroupsUtils

    # Nx11EGroupsUtils::groups()
    def self.groups()
        NxTodos::items()
            .map{|item|
                if item["nx11e"]["type"] == "Ax39Group" then
                    item["nx11e"]["group"]
                else
                    nil
                end
            }
            .compact
            .reduce([]){|groups, group|
                groupIds = groups.map{|group| group["id"] }
                if groupIds.include?(group["id"]) then
                    groups
                else
                    groups + [group]
                end
            }
    end

    # Nx11EGroupsUtils::interactivelySelectGroupOrNull()
    def self.interactivelySelectGroupOrNull()
        groups = Nx11EGroupsUtils::groups()
        LucilleCore::selectEntityFromListOfEntitiesOrNull("group", groups, lambda{|group| group["name"] })
    end

    # Nx11EGroupsUtils::makeNewGroupOrNull()
    def self.makeNewGroupOrNull()
        name1 = LucilleCore::askQuestionAnswerAsString("name: ")
        return nil if name1 == ""
        ax39 = Ax39::interactivelyCreateNewAxOrNull()
        {
            "id"       => SecureRandom.uuid,
            "mikuType" => "Ax39Group",
            "name"     => name1,
            "ax39"     => ax39,
            "account"  => SecureRandom.hex
        }
    end

    # Nx11EGroupsUtils::architectGroupOrNull()
    def self.architectGroupOrNull()
        puts "Select a group and if nothing you will get a chance to create a new one"
        group = Nx11EGroupsUtils::interactivelySelectGroupOrNull()
        return group if group
        if LucilleCore::askQuestionAnswerAsBoolean("Would you like to create a new group ? ", true) then
            return Nx11EGroupsUtils::makeNewGroupOrNull()
        end
        nil
    end

    # Nx11EGroupsUtils::interactivelyDecidePositionInThisGroup(group)
    def self.interactivelyDecidePositionInThisGroup(group)
        LucilleCore::askQuestionAnswerAsString("position: ").to_f
    end

    # Nx11EGroupsUtils::interactivelyMakeNewNx11EGroupOrNull()
    def self.interactivelyMakeNewNx11EGroupOrNull()
        group = Nx11EGroupsUtils::makeNewGroupOrNull()
        position = Nx11EGroupsUtils::interactivelyDecidePositionInThisGroup(group)
        return {
            "mikuType" => "Nx11E",
            "type"     => "Ax39Group",
            "group"    => group,
            "position" => position
        }
    end

end

class Nx11E

    # Nx11E::types()
    def self.types()
        ["hot", "ordinal", "ondate", "Ax39Group", "Ax39Engine", "standard"]
    end

    # Makers

    # Nx11E::interactivelySelectTypeOrNull()
    def self.interactivelySelectTypeOrNull()
        LucilleCore::selectEntityFromListOfEntitiesOrNull("type (none to abort):", Nx11E::types())
    end

    # Nx11E::interactivelyCreateNewNx11EOrNull(itemuuid)
    def self.interactivelyCreateNewNx11EOrNull(itemuuid)
        type = Nx11E::interactivelySelectTypeOrNull()
        return nil if type.nil?
        if type == "hot" then
            return {
                "mikuType" => "Nx11E",
                "type"     => "hot",
                "unixtime" => Time.new.to_f
            }
        end
        if type == "ordinal" then
            ordinal = LucilleCore::askQuestionAnswerAsString("ordinal (empty to abort): ")
            return nil if ordinal == ""
            return {
                "mikuType" => "Nx11E",
                "type"     => "ordinal",
                "ordinal"  => ordinal
            }
        end
        if type == "ondate" then
            datetime = CommonUtils::interactivelySelectDateTimeIso8601OrNullUsingDateCode()
            return nil if datetime.nil?
            return {
                "mikuType" => "Nx11E",
                "type"     => "ondate",
                "datetime" => datetime
            }
        end
        if type == "Ax39Group" then
            return Nx11EGroupsUtils::interactivelyMakeNewNx11EGroupOrNull()
        end
        if type == "Ax39Engine" then
            ax39 = Ax39::interactivelyCreateNewAxOrNull()
            return nil if ax39.nil?
            return {
                "mikuType" => "Nx11E",
                "type"     => "Ax39Engine",
                "ax39"     => ax39,
                "itemuuid" => itemuuid
            }
        end
        if type == "standard" then
            return {
                "mikuType" => "Nx11E",
                "type"     => "standard",
                "unixtime" => Time.new.to_f
            }
        end
    end

    # Nx11E::makeOndate(datetime)
    def self.makeOndate(datetime)
        {
            "mikuType" => "Nx11E",
            "type"     => "ondate",
            "datetime" => datetime
        }
    end

    # Nx11E::interactivelySetANewEngineForItemOrNothing(item)
    def self.interactivelySetANewEngineForItemOrNothing(item)
        engine = Nx11E::interactivelyCreateNewNx11EOrNull(item["uuid"])
        return if engine.nil?
        ItemsEventsLog::setAttribute2(item["uuid"], "nx11e", engine)
    end

    # Functions

    # Nx11E::toString(nx11e)
    def self.toString(nx11e)
        if nx11e["mikuType"] != "Nx11E" then
            raise "(error: a06d321f-d66c-4909-bfb9-00a6787c0311) This function only takes Nx11Es, nx11e: #{nx11e}"
        end

        if nx11e["type"] == "hot" then
            return "(hot)"
        end

        if nx11e["type"] == "ordinal" then
            return "(ordinal: #{"%.2f" % nx11e["ordinal"]})"
        end

        if nx11e["type"] == "ondate" then
            return "(ondate: #{nx11e["datetime"][0, 10]})"
        end

        if nx11e["type"] == "Ax39Group" then

            group    = nx11e["group"]
            return "(ax39 group: #{group["name"]})"
        end

        if nx11e["type"] == "Ax39Engine" then
            return "(ax39)"
        end

        if nx11e["type"] == "standard" then
            return "(standard)"
        end

        raise "(error: b8adb3e1-eaee-4d06-afb4-bc0f3db0142b) nx11e: #{nx11e}"
    end

    # Nx11E::priority(item)
    def self.priority(item)

        shiftForUnixtimeOrdering = lambda {|unixtime|
            Math.atan(Time.new.to_f - unixtime).to_f/100
        }

        if item["mikuType"] != "Nx11E" then
            raise "(error: a99fb12c-53a6-465a-8b87-14a85c58463b) This function only takes Nx11Es, item: #{item}"
        end

        if item["type"] == "hot" then
            unixtime = item["unixtime"] || 0 # TODO: the first one created was missing it
            return 0.90 + shiftForUnixtimeOrdering.call(unixtime)
        end

        if item["type"] == "ordinal" then
            return 0.85 -  Math.atan(item["ordinal"]).to_f/100
        end

        if item["type"] == "ondate" then
            return 0.70 + Math.atan(Time.new.to_f - DateTime.parse(item["datetime"]).to_time.to_f).to_f/100
        end

        if item["type"] == "Ax39Group" then

            group    = item["group"]
            ax39     = group["ax39"]
            account  = group["account"]

            position = item["position"]

            cr = Ax39Extensions::completionRatio(ax39, account)

            return -1 if cr > 1

            return 0.60 + (1 - cr).to_f/100 - Math.atan(position).to_f/100
        end

        if item["type"] == "Ax39Engine" then
            cr = Ax39Extensions::completionRatio(item["ax39"], item["itemuuid"])
            return -1 if cr > 1
            return 0.50 + 0.2*(1-cr)
        end

        if item["type"] == "standard" then
            unixtime = item["unixtime"]
            return 0.40 + shiftForUnixtimeOrdering.call(unixtime)
        end

        raise "(error: 188c8d4b-1a79-4659-bd93-6d8e3ddfe4d1) item: #{item}"
    end
end