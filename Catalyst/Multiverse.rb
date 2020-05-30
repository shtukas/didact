# encoding: UTF-8

# require "/Users/pascal/Galaxy/LucilleOS/Applications/Catalyst/Catalyst/Multiverse.rb"

require 'fileutils'
# FileUtils.mkpath '/a/b/c'
# FileUtils.cp(src, dst)
# FileUtils.mv 'oldname', 'newname'
# FileUtils.rm(path_to_image)
# FileUtils.rm_rf('dir/to/remove')

require 'securerandom'
# SecureRandom.hex    #=> "eb693ec8252cd630102fd0d0fb7c3485"
# SecureRandom.hex(4) #=> "eb693123"
# SecureRandom.uuid   #=> "2d931510-d99f-494a-8c67-87feb05e1594"

require 'colorize'

require "/Users/pascal/Galaxy/LucilleOS/Applications/Catalyst/Catalyst/PrimaryNetwork.rb"

# -----------------------------------------------------------------

class Timelines

    # Timelines::path()
    def self.path()
        "/Users/pascal/Galaxy/DataBank/Catalyst/Multiverse/timelines"
    end

    # Timelines::save(node)
    def self.save(node)
        filepath = "#{Timelines::path()}/#{node["uuid"]}.json"
        File.open(filepath, "w") {|f| f.puts(JSON.pretty_generate(node)) }
    end

    # Timelines::getOrNull(uuid)
    def self.getOrNull(uuid)
        filepath = "#{Timelines::path()}/#{uuid}.json"
        return nil if !File.exists?(filepath)
        JSON.parse(IO.read(filepath))
    end

    # Timelines::timelines()
    # Nodes are given in increasing creation timestamp
    def self.timelines()
        Dir.entries(Timelines::path())
            .select{|filename| filename[-5, 5] == ".json" }
            .map{|filename| "#{Timelines::path()}/#{filename}" }
            .map{|filepath| JSON.parse(IO.read(filepath)) }
            .sort{|i1, i2| i1["creationTimestamp"]<=>i2["creationTimestamp"] }
    end

    # Timelines::makeTimelineInteractivelyOrNull()
    def self.makeTimelineInteractivelyOrNull()
        puts "Making a new Starlight node..."
        node = {
            "catalystType"      => "catalyst-type:timeline",
            "creationTimestamp" => Time.new.to_f,
            "uuid"              => SecureRandom.uuid,

            "name" => LucilleCore::askQuestionAnswerAsString("nodename: ")
        }
        Timelines::save(node)
        puts JSON.pretty_generate(node)
        node
    end

    # Timelines::timelineToString(node)
    def self.timelineToString(node)
        "[timeline] #{node["name"]} (#{node["uuid"][0, 4]})"
    end
end

class TimelineNetwork

    # TimelineNetwork::path()
    def self.path()
        "/Users/pascal/Galaxy/DataBank/Catalyst/Multiverse/paths"
    end

    # TimelineNetwork::save(path)
    def self.save(path)
        filepath = "#{TimelineNetwork::path()}/#{path["uuid"]}.json"
        File.open(filepath, "w") {|f| f.puts(JSON.pretty_generate(path)) }
    end

    # TimelineNetwork::getOrNull(uuid)
    def self.getOrNull(uuid)
        filepath = "#{TimelineNetwork::path()}/#{uuid}.json"
        return nil if !File.exists?(filepath)
        JSON.parse(IO.read(filepath))
    end

    # TimelineNetwork::paths()
    def self.paths()
        Dir.entries(TimelineNetwork::path())
            .select{|filename| filename[-5, 5] == ".json" }
            .map{|filename| "#{TimelineNetwork::path()}/#{filename}" }
            .map{|filepath| JSON.parse(IO.read(filepath)) }
            .sort{|i1, i2| i1["creationTimestamp"]<=>i2["creationTimestamp"] }
    end

    # TimelineNetwork::issuePathInteractivelyOrNull()
    def self.issuePathInteractivelyOrNull()
        path = {
            "catalystType"      => "catalyst-type:starlight-path",
            "creationTimestamp" => Time.new.to_f,
            "uuid"              => SecureRandom.uuid,

            "sourceuuid" => LucilleCore::askQuestionAnswerAsString("sourceuuid: "),
            "targetuuid" => LucilleCore::askQuestionAnswerAsString("targetuuid: ")
        }
        TimelineNetwork::save(path)
        path
    end

    # TimelineNetwork::issuePathFromFirstNodeToSecondNodeOrNull(timeline1, timeline2)
    def self.issuePathFromFirstNodeToSecondNodeOrNull(timeline1, timeline2)
        return nil if timeline1["uuid"] == timeline2["uuid"]
        path = {
            "catalystType"      => "catalyst-type:starlight-path",
            "creationTimestamp" => Time.new.to_f,
            "uuid"              => SecureRandom.uuid,
            "sourceuuid" => timeline1["uuid"],
            "targetuuid" => timeline2["uuid"]
        }
        TimelineNetwork::save(path)
        path
    end

    # TimelineNetwork::getPathsWithGivenTarget(targetuuid)
    def self.getPathsWithGivenTarget(targetuuid)
        TimelineNetwork::paths()
            .select{|path| path["targetuuid"] == targetuuid }
    end

    # TimelineNetwork::getPathsWithGivenSource(sourceuuid)
    def self.getPathsWithGivenSource(sourceuuid)
        TimelineNetwork::paths()
            .select{|path| path["sourceuuid"] == sourceuuid }
    end

    # TimelineNetwork::pathToString(path)
    def self.pathToString(path)
        "[stargate] #{path["sourceuuid"]} -> #{path["targetuuid"]}"
    end

    # TimelineNetwork::getParents(timeline)
    def self.getParents(timeline)
        TimelineNetwork::getPathsWithGivenTarget(timeline["uuid"])
            .map{|path| Timelines::getOrNull(path["sourceuuid"]) }
            .compact
    end

    # TimelineNetwork::getChildren(node)
    def self.getChildren(node)
        TimelineNetwork::getPathsWithGivenSource(node["uuid"])
            .map{|path| Timelines::getOrNull(path["targetuuid"]) }
            .compact
    end
end

class TimelineContent

    # TimelineContent::path()
    def self.path()
        "/Users/pascal/Galaxy/DataBank/Catalyst/Multiverse/ownershipclaims"
    end

    # TimelineContent::save(dataclaim)
    def self.save(dataclaim)
        filepath = "#{TimelineContent::path()}/#{dataclaim["uuid"]}.json"
        File.open(filepath, "w") {|f| f.puts(JSON.pretty_generate(dataclaim)) }
    end

    # TimelineContent::getOrNull(uuid)
    def self.getOrNull(uuid)
        filepath = "#{TimelineContent::path()}/#{uuid}.json"
        return nil if !File.exists?(filepath)
        JSON.parse(IO.read(filepath))
    end

    # TimelineContent::claims()
    def self.claims()
        Dir.entries(TimelineContent::path())
            .select{|filename| filename[-5, 5] == ".json" }
            .map{|filename| "#{TimelineContent::path()}/#{filename}" }
            .map{|filepath| JSON.parse(IO.read(filepath)) }
            .sort{|i1, i2| i1["creationTimestamp"]<=>i2["creationTimestamp"] }
    end

    # TimelineContent::issueClaimGivenTimelineAndEntity(node, target)
    def self.issueClaimGivenTimelineAndEntity(node, target)
        claim = {
            "catalystType"      => "catalyst-type:time-ownership-claim",
            "creationTimestamp" => Time.new.to_f,
            "uuid"              => SecureRandom.uuid,

            "nodeuuid"   => node["uuid"],
            "targetuuid" => target["uuid"]
        }
        TimelineContent::save(claim)
        claim
    end

    # TimelineContent::claimToString(dataclaim)
    def self.claimToString(dataclaim)
        "[starlight ownership claim] #{dataclaim["nodeuuid"]} -> #{dataclaim["targetuuid"]}"
    end

    # TimelineContent::getTimelineEntities(node)
    def self.getTimelineEntities(node)
        TimelineContent::claims()
            .select{|claim| claim["nodeuuid"] == node["uuid"] }
            .map{|claim| PrimaryNetwork::getSomethingByUuidOrNull(claim["targetuuid"]) }
            .compact
    end

    # TimelineContent::getTimelinesForEntity(clique)
    def self.getTimelinesForEntity(clique)
        TimelineContent::claims()
            .select{|claim| claim["targetuuid"] == clique["uuid"] }
            .map{|claim| Timelines::getOrNull(claim["nodeuuid"]) }
            .compact
    end
end

class Multiverse

    # Multiverse::openTimeline(timeline)
    def self.openTimeline(timeline)
        # Here there isn't much to open per say, so we default to visiting 
        Multiverse::visitTimeline(timeline)
    end

    # Multiverse::visitTimeline(timeline)
    def self.visitTimeline(timeline)
        loop {
            puts ""
            puts JSON.pretty_generate(timeline)
            puts "uuid: #{timeline["uuid"]}"
            puts Timelines::timelineToString(timeline).green
            items = []
            items << ["rename", lambda{ 
                timeline["name"] = CatalystCommon::editTextUsingTextmate(timeline["name"]).strip
                Timelines::save(timeline)
            }]

            TimelineNetwork::getParents(timeline)
                .sort{|n1, n2| n1["name"] <=> n2["name"] }
                .each{|n| items << ["[network parent] #{Timelines::timelineToString(n)}", lambda{ MultiverseNavigation::visit(n) }] }

            TimelineContent::getTimelineEntities(timeline)
                .sort{|p1, p2| p1["creationTimestamp"] <=> p2["creationTimestamp"] } # "creationTimestamp" is a common attribute of all data entities
                .each{|something| items << ["[something] #{PrimaryNetwork::somethingToString(something)}", lambda{ PrimaryNetworkNavigation::visit(something) }] }

            TimelineNetwork::getChildren(timeline)
                .sort{|n1, n2| n1["name"] <=> n2["name"] }
                .each{|n| items << ["[network child] #{Timelines::timelineToString(n)}", lambda{ MultiverseNavigation::visit(n) }] }

            items << ["add parent timeline", lambda{ 
                timeline0 = MultiverseMakeAndOrSelectQuest::makeAndOrSelectTimelineOrNull()
                path = TimelineNetwork::issuePathFromFirstNodeToSecondNodeOrNull(timeline0, timeline)
                puts JSON.pretty_generate(path)
                TimelineNetwork::save(path)
            }]

            items << ["add child timeline", lambda{ 
                timeline2 = MultiverseMakeAndOrSelectQuest::makeAndOrSelectTimelineOrNull()
                path = TimelineNetwork::issuePathFromFirstNodeToSecondNodeOrNull(timeline, timeline2)
                puts JSON.pretty_generate(path)
                TimelineNetwork::save(path)
            }]

            status = LucilleCore::menuItemsWithLambdas(items) # Boolean # Indicates whether an item was chosen
            break if !status
        }
    end

    # Multiverse::selectTimelineFromExistingTimelines()
    def self.selectTimelineFromExistingTimelines()
        nodestrings = Timelines::timelines().map{|node| Timelines::timelineToString(node) }
        nodestring = CatalystCommon::chooseALinePecoStyle("node:", [""]+nodestrings)
        node = Timelines::timelines()
                .select{|node| Timelines::timelineToString(node) == nodestring }
                .first
    end

    # Multiverse::selectTimelinePossiblyCreateOneOrNull()
    def self.selectTimelinePossiblyCreateOneOrNull()
        loop {
            puts "-> You are selecting a timeline (possibly will create one)"
            LucilleCore::pressEnterToContinue()

            # Version 1
            # LucilleCore::selectEntityFromListOfEntitiesOrNull("node", Timelines::timelines(), lambda {|node| Timelines::timelineToString(node) })

            # Version 2
            nodestrings = Timelines::timelines().map{|node| Timelines::timelineToString(node) }
            nodestring = CatalystCommon::chooseALinePecoStyle("node:", [""]+nodestrings)
            node = Timelines::timelines()
                    .select{|node| Timelines::timelineToString(node) == nodestring }
                    .first
            return node if node
            if LucilleCore::askQuestionAnswerAsBoolean("Multiverse: You are being selecting a timeline but did not select any of the existing ones. Would you like to make a new node and return it ? ") then
                return Timelines::makeTimelineInteractivelyOrNull()
            end
            if LucilleCore::askQuestionAnswerAsBoolean("Multiverse: There is no selection, would you like to return null ? ", true) then
                return nil
            end
        }
    end

    # Multiverse::management()
    def self.management()
        loop {
            system("clear")
            puts "Starlight Management (root)"
            operations = [
                "make timeline",
                "make starlight path"
            ]
            operation = LucilleCore::selectEntityFromListOfEntitiesOrNull("operation", operations)
            break if operation.nil?
            if operation == "make timeline" then
                node = Timelines::makeTimelineInteractivelyOrNull()
                puts JSON.pretty_generate(node)
                Timelines::save(node)
            end
            if operation == "make starlight path" then
                node1 = MultiverseMakeAndOrSelectQuest::makeAndOrSelectTimelineOrNull()
                next if node1.nil?
                node2 = MultiverseMakeAndOrSelectQuest::makeAndOrSelectTimelineOrNull()
                next if node2.nil?
                path = TimelineNetwork::issuePathFromFirstNodeToSecondNodeOrNull(node1, node2)
                puts JSON.pretty_generate(path)
                TimelineNetwork::save(path)
            end
        }
    end

end

class MultiverseNavigation

    # MultiverseNavigation::mainNavigation()
    def self.mainNavigation()
        timeline = Multiverse::selectTimelinePossiblyCreateOneOrNull()
        return if timeline.nil?
        MultiverseNavigation::visit(timeline)
    end

    # MultiverseNavigation::visit(timeline)
    def self.visit(timeline)
        Multiverse::visitTimeline(timeline)
    end
end

class MultiverseMakeAndOrSelectQuest

    # MultiverseMakeAndOrSelectQuest::makeAndOrSelectTimelineOrNull()
    def self.makeAndOrSelectTimelineOrNull()
        puts "-> You are on a selection Quest [selecting a timeline]"
        puts "-> I am going to make you select one from existing and if that doesn't work, I will make you create a new one [with extensions if you want]"
        LucilleCore::pressEnterToContinue()
        timeline = Multiverse::selectTimelineFromExistingTimelines()
        return timeline if timeline
        puts "-> You are on a selection Quest [selecting a timeline]"
        if LucilleCore::askQuestionAnswerAsBoolean("-> ...but did not select anything. Do you want to create one ? ") then
            timeline = Timelines::makeTimelineInteractivelyOrNull()
            return nil if timeline.nil?
            puts "-> You are on a selection Quest [selecting a timeline]"
            puts "-> You have created '#{timeline["name"]}'"
            option1 = "quest: return '#{timeline["name"]}' immediately"
            option2 = "quest: dive first"
            options = [ option1, option2 ]
            option = LucilleCore::selectEntityFromListOfEntitiesOrNull("options", options)
            if option == option1 then
                return timeline
            end
            if option == option2 then
                Multiverse::visitTimeline(timeline)
                return timeline
            end
        end
        nil
    end
end

