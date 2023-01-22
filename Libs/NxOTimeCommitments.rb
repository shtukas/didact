
class NxOTimeCommitments

    # NxOTimeCommitments::filepath(uuid)
    def self.filepath(uuid)
        "#{Config::pathToDataCenter()}/NxOTimeCommitment/#{uuid}.json"
    end

    # NxOTimeCommitments::items()
    def self.items()
        LucilleCore::locationsAtFolder("#{Config::pathToDataCenter()}/NxOTimeCommitment")
            .select{|filepath| filepath[-5, 5] == ".json" }
            .map{|filepath| JSON.parse(IO.read(filepath)) }
    end

    # NxOTimeCommitments::commit(item)
    def self.commit(item)
        filepath = NxOTimeCommitments::filepath(item["uuid"])
        File.open(filepath, "w"){|f| f.puts(JSON.pretty_generate(item)) }
    end

    # NxOTimeCommitments::getOrNull(uuid)
    def self.getOrNull(uuid)
        filepath = NxOTimeCommitments::filepath(uuid)
        return nil if !File.exists?(filepath)
        JSON.parse(IO.read(filepath))
    end

    # NxOTimeCommitments::destroy(uuid)
    def self.destroy(uuid)
        filepath = NxOTimeCommitments::filepath(uuid)
        if File.exists?(filepath) then
            FileUtils.rm(filepath)
        end
    end

    # --------------------------------------------------
    # Makers

    # NxOTimeCommitments::interactivelyIssueNewOrNull()
    def self.interactivelyIssueNewOrNull()
        description = LucilleCore::askQuestionAnswerAsString("description (empty to abort): ")
        return nil if description == ""
        hours = LucilleCore::askQuestionAnswerAsString("hours: ").to_f
        tcId = NxWTimeCommitments::interactivelySelectItem()["uuid"]
        uuid  = SecureRandom.uuid
        item = {
            "uuid"        => uuid,
            "mikuType"    => "NxOTimeCommitment",
            "unixtime"    => Time.new.to_i,
            "description" => description,
            "hours"       => hours,
            "tcId"        => tcId
        }
        NxOTimeCommitments::commit(item)
        item
    end
    
    # NxOTimeCommitments::listingItems()
    def self.listingItems()
        NxOTimeCommitments::items()
            .sort{|i1, i2| i1["unixtime"] <=> i2["unixtime"] }
    end

    # --------------------------------------------------
    # Data

    # NxOTimeCommitments::toString(item)
    def self.toString(item)
        pending = [item["hours"]-NxBalls::itemRealisedAndUnrealsedTimeInSeconds(item).to_f/3600, 0].max
        "(otc) (pending: #{"%5.2f" % (pending.round(2))}) #{item["description"]} (done: #{(NxBalls::itemRealisedAndUnrealsedTimeInSeconds(item).to_f/3600).round(2)} hours of #{item["hours"]})"
    end

    # NxOTimeCommitments::runningItems()
    def self.runningItems()
        NxOTimeCommitments::items()
            .select{|otc| NxBalls::getNxBallForItemOrNull(otc) }
    end

    # NxOTimeCommitments::itemLiveTimeThatShouldBeDoneTodayInHours(item)
    def self.itemLiveTimeThatShouldBeDoneTodayInHours(item)
        [item["hours"]*3600 - NxBalls::itemRealisedAndUnrealsedTimeInSeconds(item), 0].max
    end

    # NxOTimeCommitments::liveNumbers(otc)
    def self.liveNumbers(otc)
        pendingTimeTodayInSeconds = NxOTimeCommitments::itemLiveTimeThatShouldBeDoneTodayInHours(otc)
        {
            "timeThatShouldBeDoneTodayInHours" => pendingTimeTodayInSeconds.to_f/3600
        }
    end

    # NxOTimeCommitments::typeLiveTimeThatShouldBeDoneTodayInHours()
    def self.typeLiveTimeThatShouldBeDoneTodayInHours()
        NxOTimeCommitments::items()
            .map{|item| NxOTimeCommitments::itemLiveTimeThatShouldBeDoneTodayInHours(item) }
            .inject(0, :+)
    end
end