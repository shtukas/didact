j# encoding: UTF-8

class TxFloats

    # TxFloats::items()
    def self.items()
        Librarian20LocalObjectsStore::getObjectsByMikuType("TxFloat")
    end

    # TxFloats::destroy(uuid)
    def self.destroy(uuid)
        Librarian20LocalObjectsStore::logicaldelete(uuid)
    end

    # --------------------------------------------------
    # Makers

    # TxFloats::interactivelyCreateNewOrNull()
    def self.interactivelyCreateNewOrNull()
        description = LucilleCore::askQuestionAnswerAsString("description (empty to abort): ")
        return nil if description == ""

        nx111 = Nx111::interactivelyCreateNewIamValueOrNull(Nx111::iamTypesForManualMakingOfCatalystItems())
        return nil if nx111.nil?

        uuid     = SecureRandom.uuid
        unixtime = Time.new.to_i
        datetime = Time.new.utc.iso8601

        universe = Multiverse::interactivelySelectUniverse()

        item = {
          "uuid"        => uuid,
          "mikuType"    => "TxFloat",
          "description" => description,
          "unixtime"    => unixtime,
          "datetime"    => datetime,
          "iam"         => nx111,
          "universe"    => universe
        }
        Librarian20LocalObjectsStore::commit(item)
        item
    end

    # --------------------------------------------------
    # toString

    # TxFloats::toString(item)
    def self.toString(item)
        "(item) #{item["description"]} (#{item["iam"]["type"]})"
    end

    # TxFloats::toStringForNS19(item)
    def self.toStringForNS19(item)
        "(item) #{item["description"]}"
    end

    # --------------------------------------------------
    # Operations

    # TxFloats::complete(item)
    def self.complete(item)
        TxFloats::destroy(item["uuid"])
    end

    # TxFloats::landing(item)
    def self.landing(item)

        loop {

            system("clear")

            Sx01Snapshots::printSnapshotDeploymentStatusIfRelevant()

            uuid = item["uuid"]

            store = ItemStore.new()

            puts TxFloats::toString(item).green
            puts "uuid: #{uuid}".yellow
            puts "iam: #{item["iam"]}".yellow

            TxAttachments::itemsForOwner(uuid).each{|attachment|
                indx = store.register(attachment, false)
                puts "[#{indx.to_s.ljust(3)}] #{TxAttachments::toString(attachment)}" 
            }

            puts "access | <datecode> | description | iam| attachment | universe | transmute | show json | >nyx | destroy (gg) | exit (xx)".yellow

            command = LucilleCore::askQuestionAnswerAsString("> ")

            break if command == "exit"
            break if command == "xx"

            if (indx = Interpreting::readAsIntegerOrNull(command)) then
                entity = store.get(indx)
                next if entity.nil?
                LxAction::action("landing", entity)
            end

            if (unixtime = Utils::codeToUnixtimeOrNull(command.gsub(" ", ""))) then
                DoNotShowUntil::setUnixtime(uuid, unixtime)
                break
            end

            if Interpreting::match("access", command) then
                EditionDesk::exportItemToDeskIfNotAlreadyExportedAndAccess(item)
                next
            end

            if Interpreting::match("description", command) then
                description = Utils::editTextSynchronously(item["description"]).strip
                next if description == ""
                item["description"] = description
                Librarian20LocalObjectsStore::commit(item)
                next
            end

            if Interpreting::match("iam", command) then
                nx111 = Nx111::interactivelyCreateNewIamValueOrNull(Nx111::iamTypesForManualMakingOfCatalystItems())
                next if nx111.nil?
                puts JSON.pretty_generate(nx111)
                if LucilleCore::askQuestionAnswerAsBoolean("confirm change ? ") then
                    item["iam"] = nx111
                    Librarian20LocalObjectsStore::commit(item)
                end
            end

            if Interpreting::match("attachment", command) then
                ox = TxAttachments::interactivelyIssueNewOrNullForOwner(item["uuid"])
                puts JSON.pretty_generate(ox)
                next
            end

            if Interpreting::match("universe", command) then
                item["universe"] = Multiverse::interactivelySelectUniverse()
                Librarian20LocalObjectsStore::commit(item)
                break
            end

            if Interpreting::match("transmute", command) then
                Transmutation::transmutation2(item, "TxFloat")
                break
            end

            if Interpreting::match("show json", command) then
                puts JSON.pretty_generate(item)
                LucilleCore::pressEnterToContinue()
                break
            end

            if command == "destroy" then
                if LucilleCore::askQuestionAnswerAsBoolean("destroy '#{TxFloats::toString(item)}' ? ", true) then
                    TxFloats::complete(item)
                    break
                end
                next
            end

            if command == "gg" then
                if LucilleCore::askQuestionAnswerAsBoolean("destroy '#{TxFloats::toString(item)}' ? ", true) then
                    TxFloats::complete(item)
                    break
                end
                next
            end

            if command == ">nyx" then
                Transmutation::floatToNyx(item)
                break
            end
        }
    end

    # --------------------------------------------------
    # nx16s

    # TxFloats::ns16(item)
    def self.ns16(item)
        uuid = item["uuid"]
        {
            "uuid"     => uuid,
            "mikuType" => "NS16:TxFloat",
            "announce" => "#{item["description"]} (#{item["iam"]["type"]})",
            "TxFloat"  => item
        }
    end

    # TxFloats::ns16s(universe)
    def self.ns16s(universe)
        return [] if universe.nil?
        Librarian20LocalObjectsStore::getObjectsByMikuTypeAndUniverse("TxFloat", universe)
            .sort{|i1, i2| i1["unixtime"] <=> i2["unixtime"] }
            .map{|item| TxFloats::ns16(item) }
    end

    # --------------------------------------------------

    # TxFloats::nx20s()
    def self.nx20s()
        TxFloats::items().map{|item|
            {
                "announce" => TxFloats::toStringForNS19(item),
                "unixtime" => item["unixtime"],
                "payload"  => item
            }
        }
    end
end
