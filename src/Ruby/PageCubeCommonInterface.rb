
class PageCubeCommonInterface

    # PageCubeCommonInterface::objectIsType1(ns)
    def self.objectIsType1(ns)
        ns["nyxNxSet"] == "c18e8093-63d6-4072-8827-14f238975d04"
    end

    # PageCubeCommonInterface::objectIsType2(ns)
    def self.objectIsType2(ns)
        ns["nyxNxSet"] == "6b240037-8f5f-4f52-841d-12106658171f"
    end

    # PageCubeCommonInterface::toString(ns)
    def self.toString(ns)
        if PageCubeCommonInterface::objectIsType1(ns) then
            return NSDataType1::cubeToString(ns)
        end
        if PageCubeCommonInterface::objectIsType2(ns) then
            return NSDataType2::conceptToString(ns)
        end
        raise "[error: dd0dce2a]"
    end

    # PageCubeCommonInterface::navigationLambda(ns)
    def self.navigationLambda(ns)
        if PageCubeCommonInterface::objectIsType1(ns) then
            return lambda { NSDataType1::landing(ns) }
        end
        if PageCubeCommonInterface::objectIsType2(ns) then
            return lambda { NSDataType2::landing(ns) }
        end
        raise "[error: fd3c6cff]"
    end

    # PageCubeCommonInterface::getReferenceDateTime(ns)
    def self.getReferenceDateTime(ns)
        datetime = DateTimeZ::getLastDateTimeISO8601ForSourceOrNull(ns)
        return datetime if datetime
        Time.at(ns["unixtime"]).utc.iso8601
    end

    # PageCubeCommonInterface::getReferenceUnixtime(ns)
    def self.getReferenceUnixtime(ns)
        DateTime.parse(PageCubeCommonInterface::getReferenceDateTime(ns)).to_time.to_f
    end

    # PageCubeCommonInterface::getUpstreamPages(ns)
    def self.getUpstreamPages(ns)
        Arrows::getSourcesOfGivenSetsForTarget(ns, ["6b240037-8f5f-4f52-841d-12106658171f"])
    end

    # PageCubeCommonInterface::getDownstreamObjects(ns)
    def self.getDownstreamObjects(ns)
        Arrows::getTargetsOfGivenSetsForSource(ns, ["c18e8093-63d6-4072-8827-14f238975d04", "6b240037-8f5f-4f52-841d-12106658171f"])
    end

    # PageCubeCommonInterface::getDownstreamObjectsType1(ns)
    def self.getDownstreamObjectsType1(ns)
        Arrows::getTargetsOfGivenSetsForSource(ns, ["c18e8093-63d6-4072-8827-14f238975d04"])
    end

    # PageCubeCommonInterface::getDownstreamObjectsType2(ns)
    def self.getDownstreamObjectsType2(ns)
        Arrows::getTargetsOfGivenSetsForSource(ns, ["6b240037-8f5f-4f52-841d-12106658171f"])
    end
end
