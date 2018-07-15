#!/usr/bin/ruby

# encoding: UTF-8
require 'digest/sha1'
# Digest::SHA1.hexdigest 'foo'
# Digest::SHA1.file(myFile).hexdigest
require "/Galaxy/local-resources/Ruby-Libraries/LucilleCore.rb"
require_relative "Bob.rb"
# -------------------------------------------------------------------------------------

Bob::registerAgent(
    {
        "agent-name"      => "Projects",
        "agent-uid"       => "10f0ad1e-ff0e-4a8a-8c90-fe09de2342ab",
        "general-upgrade" => lambda { AgentProjects::generalFlockUpgrade() },
        "object-command-processor" => lambda{ |object, command| AgentProjects::processObjectAndCommand(object, command) },
        "interface"       => lambda{ AgentProjects::interface() }
    }
)

# AgentProjects::metric

class AgentProjects

    def self.agentuuid()
        "10f0ad1e-ff0e-4a8a-8c90-fe09de2342ab"
    end

    def self.interface()
    end

    def self.generalFlockUpgrade()
        TheFlock::removeObjectsFromAgent(self.agentuuid())
        ProjectsCore::updateLocalTimeStructures()
        ProjectsCore::localTimeStructuresDataFiles().each{|data|
            projectuuid = data["projectuuid"]
            referenceTimeStructure = data["reference-time-structure"]
            data["local-commitments"]
                .map{|item|
                    timestructure = {}
                    timestructure["time-unit-in-days"] = referenceTimeStructure["time-unit-in-days"]
                    timestructure["time-commitment-in-hours"] = referenceTimeStructure["time-commitment-in-hours"] * item["timeshare"]
                    timedoneInHours, timetodoInHours, ratio = TimeStructuresOperator::doneMetricsForTimeStructure(item["uuid"], timestructure)
                    announce = "project: #{ProjectsCore::projectUUID2NameOrNull(projectuuid)} / #{item["description"]} ( #{100*ratio.round(2)} % of #{timetodoInHours.round(2)} hours [today] )"
                    metric = MetricsOfTimeStructures::metric2(item["uuid"], 0.1, 0.5, 0.6, timestructure) + CommonsUtils::traceToMetricShift(item["uuid"])
                    if announce.include?("(main)") then
                        metric = metric*0.9
                    end
                    object              = {}
                    object["uuid"]      = item["uuid"]
                    object["agent-uid"] = self.agentuuid()
                    object["metric"]    = metric
                    object["announce"]  = announce
                    object["commands"]  = Chronos::isRunning(item["uuid"]) ? ["stop"] : ["start"]
                    object["default-expression"] = Chronos::isRunning(item["uuid"]) ? "stop" : "start"
                    object["is-running"] = Chronos::isRunning(item["uuid"])
                    object["item-data"] = {}
                    object["item-data"]["data"] = data
                    object
                }
                .each{|object| TheFlock::addOrUpdateObject(object) }
        }
    end

    def self.processObjectAndCommand(object, command)
        if command=="start" then
            Chronos::start(object["uuid"])
        end
        if command=="stop" then
            itemuuid = object["uuid"]
            timespanInSeconds = Chronos::stop(itemuuid)
            projectuuid = object["item-data"]["data"]["projectuuid"]
            ProjectsCore::addTimeInSecondsToProject(projectuuid, timespanInSeconds)
        end
    end
end
