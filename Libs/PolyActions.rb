
# encoding: UTF-8

class PolyActions

    # function names in alphabetical order

    # PolyActions::access(item)
    def self.access(item)

        # types in alphabetical order

        if item["mikuType"] == "DeviceBackup" then
            puts item["announce"]
            LucilleCore::pressEnterToContinue()
            return
        end

        if item["mikuType"] == "LambdX1" then
            item["lambda"].call()
            return
        end

        if item["mikuType"] == "NxAnniversary" then
            Anniversaries::accessAndDone(item)
            return
        end

        if item["mikuType"] == "TxProject" then
            TxProjects::access(item)
            return
        end

        if item["mikuType"] == "TxDrop" then
            CoreData::access(item["field11"])
            return
        end

        if item["mikuType"] == "NxBoard" then
            NxBoards::programBoardListing(item)
            return
        end

        if item["mikuType"] == "NxOndate" then
            NxOndates::access(item)
            return
        end

        if item["mikuType"] == "NxFire" then
            CoreData::access(item["field11"])
            return
        end

        if item["mikuType"] == "NxBoard" then
            puts NxBoards::toString(item)
            actions = ["set hours", "access items"]
            action = LucilleCore::selectEntityFromListOfEntitiesOrNull("action: ", actions)
            return if action.nil?
            if action == "set hours" then
                puts "Not implemented yet"
                LucilleCore::pressEnterToContinue()
            end
            if action == "access items" then
                puts "Not implemented yet"
                LucilleCore::pressEnterToContinue()
            end
            return
        end

        if item["mikuType"] == "NxTask" then
            NxTasks::access(item)
            return
        end

        if item["mikuType"] == "PhysicalTarget" then
            PhysicalTargets::access(item)
            return
        end

        if item["mikuType"] == "Wave" then
            Waves::access(item)
            return
        end

        raise "(error: abb645e9-2575-458e-b505-f9c029f4ca69) I do not know how to access mikuType: #{item["mikuType"]}"
    end

    # PolyActions::done(item)
    def self.done(item)

        NxBalls::stop(item)
       
        # Removing park, if any.
        item["parking"] = nil
        item["skipped"] = false

        # order: alphabetical order

        if item["mikuType"] == "DeviceBackup" then
            if LucilleCore::askQuestionAnswerAsBoolean("done-ing '#{item["announce"].green} ? '", true) then
                DoNotShowUntil::setUnixtime(item, Time.new.to_i + item["instruction"]["period"] * 86400)
            end
            return
        end

        if item["mikuType"] == "LambdX1" then
            return
        end

        if item["mikuType"] == "TxProject" then
            # We cannot done a project that still has drops
            if TxDrops::projectDrops(item).size > 0 then
                puts "Project '#{PolyFunctions::toString(item).green}' still has #{TxDrops::projectDrops(item).size} items. You cannot destroy it."
                action = LucilleCore::selectEntityFromListOfEntitiesOrNull("action", ["program(project)", "exit"])
                return if action.nil?
                if action == "exit" then
                    return
                end
                if action == "program(project)" then
                    TxProjects::program1(item)
                    return
                end
            end
            if LucilleCore::askQuestionAnswerAsBoolean("destroy '#{PolyFunctions::toString(item).green}' ? ", true) then
                N3Objects::destroy(item["uuid"])
            end
            return
        end

        if item["mikuType"] == "TxDrop" then
            if LucilleCore::askQuestionAnswerAsBoolean("destroy '#{PolyFunctions::toString(item).green}' ? ", true) then
                N3Objects::destroy(item["uuid"])
            end
            return
        end

        if item["mikuType"] == "NxAnniversary" then
            Anniversaries::done(item["uuid"])
            return
        end

        if item["mikuType"] == "NxBoard" then
            puts "There is no done action on NxBoards. If it was running, I have stopped it."
            LucilleCore::pressEnterToContinue()
            return
        end

        if item["mikuType"] == "NxOndate" then
            if LucilleCore::askQuestionAnswerAsBoolean("destroy '#{PolyFunctions::toString(item).green}' ? ", true) then
                NxOndates::destroy(item["uuid"])
            end
            return
        end

        if item["mikuType"] == "NxFire" then
            if LucilleCore::askQuestionAnswerAsBoolean("destroy '#{PolyFunctions::toString(item).green}' ? ", true) then
                N3Objects::destroy(item["uuid"])
            end
            return
        end

        if item["mikuType"] == "NxOndate" then
            if LucilleCore::askQuestionAnswerAsBoolean("destroy '#{PolyFunctions::toString(item).green}' ? ", true) then
                NxOndates::destroy(item["uuid"])
            end
            return
        end

        if item["mikuType"] == "NxTask" then
            if LucilleCore::askQuestionAnswerAsBoolean("destroy '#{PolyFunctions::toString(item).green}' ? ", true) then
                NxTasks::destroy(item["uuid"])
                BankCore::put("34c37c3e-d9b8-41c7-a122-ddd1cb85ddbc", 3600)
            end
            return
        end

        if item["mikuType"] == "PhysicalTarget" then
            PhysicalTargets::performUpdate(item)
            return
        end

        if item["mikuType"] == "Wave" then
            if LucilleCore::askQuestionAnswerAsBoolean("done-ing '#{Waves::toString(item).green} ? '", true) then
                Waves::performWaveNx46WaveDone(item)
            end
            return
        end

        puts "I do not know how to PolyActions::done(#{JSON.pretty_generate(item)})"
        raise "(error: f278f3e4-3f49-4f79-89d2-e5d3b8f728e6)"
    end

    # PolyActions::destroy(item)
    def self.destroy(item)

        NxBalls::stop(item)

        if item["mikuType"] == "Wave" then
            if LucilleCore::askQuestionAnswerAsBoolean("destroy '#{PolyFunctions::toString(item).green}' ? ", true) then
                N3Objects::destroy(item["uuid"])
            end
            return
        end

        puts "I do not know how to PolyActions::destroy(#{JSON.pretty_generate(item)})"
        raise "(error: f7ac071e-f2bb-4921-a7f3-22f268b25be8)"
    end

    # PolyActions::doubleDot(item)
    def self.doubleDot(item)

        if item["mikuType"] == "DeviceBackup" then
            PolyActions::access(item)
            return
        end

        if item["mikuType"] == "TxDrop" then
            puts PolyFunctions::toString(item).green
            first_time = (BankCore::getValue(item["uuid"]) == 0)
            NxBalls::start(item)
            NxTasks::access(item)
            if first_time then
                if LucilleCore::askQuestionAnswerAsBoolean("done and destroy '#{PolyFunctions::toString(item).green} ? '", true) then
                    NxBalls::stop(item)
                    N3Objects::destroy(item["uuid"])
                end
            end
            return
        end

        if item["mikuType"] == "NxBoard" then
            PolyActions::access(item)
            return
        end

        if item["mikuType"] == "NxOndate" then
            if LucilleCore::askQuestionAnswerAsBoolean("destroy '#{PolyFunctions::toString(item).green}' ? ", true) then
                NxOndates::access(item)
            end
            return
        end

        if item["mikuType"] == "NxFire" then
            PolyFunctions::toString(item).green
            NxBalls::start(item)
            PolyActions::access(item)
            return
        end

        if item["mikuType"] == "NxTask" then
            puts PolyFunctions::toString(item).green
            first_time = (BankCore::getValue(item["uuid"]) == 0)
            NxBalls::start(item)
            NxTasks::access(item)
            if first_time then
                if LucilleCore::askQuestionAnswerAsBoolean("done and destroy '#{PolyFunctions::toString(item).green} ? '", true) then
                    NxBalls::stop(item)
                    NxTasks::destroy(item["uuid"])
                end
            end
            return
        end

        if item["mikuType"] == "PhysicalTarget" then
            PolyFunctions::toString(item).green
            PhysicalTargets::access(item)
            return
        end

        if item["mikuType"] == "TxProject" then
            PolyActions::access(item)
            return
        end

        if item["mikuType"] == "Wave" then
            PolyFunctions::toString(item).green
            NxBalls::start(item)
            PolyActions::access(item)
            if LucilleCore::askQuestionAnswerAsBoolean("done-ing '#{Waves::toString(item).green} ? '", true) then
                NxBalls::stop(item)
                Waves::performWaveNx46WaveDone(item)
            end
            return
        end

        puts "I don't know how to doubleDot '#{item["mikuType"]}'"
        LucilleCore::pressEnterToContinue()
    end

    # PolyActions::program(item)
    def self.program(item)

        if item["mikuType"] == "NxAnniversary" then
            Anniversaries::program1(item)
            return
        end

        if item["mikuType"] == "NxBoard" then
            PolyActions::access(item)
            return
        end

        if item["mikuType"] == "Wave" then
            Waves::program(item)
            return
        end

        if item["mikuType"] == "NxTask" then
            NxTasks::program1(item)
            return
        end

        puts "PolyActions::program has not yet been implemented for miku type #{item["mikuType"]}"
        LucilleCore::pressEnterToContinue()
    end

    # PolyActions::pursue(item)
    def self.pursue(item)
        NxBalls::pursue(item)
    end

    # PolyActions::start(item)
    def self.start(item)
        NxBalls::start(item)
    end

    # PolyActions::addTimeToItem(item, timeInSeconds)
    def self.addTimeToItem(item, timeInSeconds)
        PolyFunctions::itemsToBankingAccounts(item).each{|account|
            puts "Adding #{timeInSeconds} seconds to account: #{account["description"]}"
            BankCore::put(account["number"], timeInSeconds)
        }
    end

    # PolyActions::editDescription(item)
    def self.editDescription(item)

        if item["mikuType"] == "DeviceBackup" then
            puts "There is no description edit for DeviceBackups"
            LucilleCore::pressEnterToContinue()
            return
        end

        puts "edit description:"
        item["description"] = CommonUtils::editTextSynchronously(item["description"])
        N3Objects::commit(item)
    end
end
