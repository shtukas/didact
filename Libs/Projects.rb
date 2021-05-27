# encoding: UTF-8

class Projects

    # Projects::repositoryFolderPath()
    def self.repositoryFolderPath()
        "#{Utils::catalystDataCenterFolderpath()}/Projects"
    end

    # Projects::toString(project)
    def self.toString(project)
        "[project] #{project["description"]}"
    end

    # Projects::interactivelyCreateNewProject()
    def self.interactivelyCreateNewProject()

        uuid = SecureRandom.uuid

        description = LucilleCore::askQuestionAnswerAsString("description (empty for abort): ")
        if description == "" then
            return nil
        end

        timeCommitmentInHoursPerWeek = LucilleCore::askQuestionAnswerAsString("timeCommitmentInHoursPerWeek (empty for abort): ")
        if timeCommitmentInHoursPerWeek == "" then
            return nil
        end

        timeCommitmentInHoursPerWeek = [timeCommitmentInHoursPerWeek.to_f, 0.5].max # at least 30 mins

        directoryFilename = LucilleCore::timeStringL22()

        folderpath = "#{Projects::repositoryFolderPath()}/#{directoryFilename}"
        FileUtils.mkdir(folderpath)

        project = {}
        project["uuid"]              = uuid
        project["schema"]            = "project"
        project["unixtime"]          = Time.new.to_i
        project["description"]       = description
        project["directoryFilename"] = directoryFilename
        project["timeCommitmentInHoursPerWeek"] = timeCommitmentInHoursPerWeek

        CoreDataTx::commit(project)

        if LucilleCore::askQuestionAnswerAsBoolean("access the folder ? ") then
            system("open '#{folderpath}'")
        end
    end

    # Projects::access(project)
    def self.access(project)
        startUnixtime = Time.new.to_f

        uuid = project["uuid"]

        folderpath = "#{Projects::repositoryFolderPath()}/#{project["directoryFilename"]}"

        system("open '#{folderpath}'")

        loop {

            puts Projects::toString(project).green

            puts "access | <datecode> | completed".yellow

            command = LucilleCore::askQuestionAnswerAsString("> ")

            break if command == ""

            if (unixtime = Utils::codeToUnixtimeOrNull(command.gsub(" ", ""))) then
                DoNotShowUntil::setUnixtime(uuid, unixtime)
                break
            end

            if Interpreting::match("access", command) then
                system("open '#{folderpath}'")
                next
            end

            if Interpreting::match("completed", command) then
                if LucilleCore::askQuestionAnswerAsBoolean("destroy project object and project folder ? ") then
                    CoreDataTx::delete(project["uuid"])
                    LucilleCore::removeFileSystemLocation(folderpath)
                end
            end
        }

        timespan = Time.new.to_f - startUnixtime

        puts "Time since start: #{timespan}"

        timespan = [timespan, 3600*2].min

        puts "putting #{timespan} seconds to project #{Projects::toString(project)} (uuid: #{uuid})"
        Bank::put(uuid, timespan)

        $counterx.registerTimeInSeconds(timespan)
    end

    # Projects::projectToNS16(project)
    def self.projectToNS16(project)
        uuid = project["uuid"]
        folderpath = "#{Projects::repositoryFolderPath()}/#{project["directoryFilename"]}"
        recoveryTime = BankExtended::stdRecoveredDailyTimeInHours(uuid)

        level = 
            if Bank::valueOverTimespan(uuid, 86400*7) < project["timeCommitmentInHoursPerWeek"]*3600 then
                "ns:important"
            else
                "ns:zero"
            end

        {
            "uuid"         => uuid,
            "metric"       => [level, recoveryTime, nil],
            "announce"     => Projects::toString(project),
            "access"       => lambda { Projects::access(project) },
            "done"         => lambda { 
                if LucilleCore::askQuestionAnswerAsBoolean("destroy project object and project folder ? ") then
                    CoreDataTx::delete(project["uuid"])
                    LucilleCore::removeFileSystemLocation(folderpath)
                end
            }
        }
    end

    # Projects::ns16s()
    def self.ns16s()
         CoreDataTx::getObjectsBySchema("project")
            .map{|project| Projects::projectToNS16(project) }
    end
end
