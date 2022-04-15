j# encoding: UTF-8

class TxFloats

    # TxFloats::items()
    def self.items()
        Librarian6Objects::getObjectsByMikuType("TxFloat")
    end

    # TxFloats::destroy(uuid)
    def self.destroy(uuid)
        Librarian6Objects::destroy(uuid)
    end

    # --------------------------------------------------
    # Makers

    # TxFloats::interactivelyCreateNewOrNull()
    def self.interactivelyCreateNewOrNull()
        description = LucilleCore::askQuestionAnswerAsString("description (empty to abort): ")
        return nil if description == ""

        atom = Librarian5Atoms::interactivelyIssueNewAtomOrNull()
        return nil if atom.nil?

        uuid     = SecureRandom.uuid
        unixtime = Time.new.to_i
        datetime = Time.new.utc.iso8601

        item = {
          "uuid"        => uuid,
          "mikuType"    => "TxFloat",
          "description" => description,
          "unixtime"    => unixtime,
          "datetime"    => datetime,
          "atomuuid"    => atom["uuid"]
        }
        Librarian6Objects::commit(item)
        ObjectUniverseMapping::interactivelySetObjectUniverseMapping(uuid)
        item
    end

    # --------------------------------------------------
    # toString

    # TxFloats::toString(float)
    def self.toString(float)
        "(float) #{float["description"]}#{Libriarian16SpecialCircumstances::atomTypeForToStrings(" ", float["atomuuid"])}"
    end

    # TxFloats::toStringForNS19(float)
    def self.toStringForNS19(float)
        "(float) #{float["description"]}"
    end

    # --------------------------------------------------
    # Operations

    # TxFloats::complete(float)
    def self.complete(float)
        TxFloats::destroy(float["uuid"])
    end

    # TxFloats::landing(item)
    def self.landing(item)

        loop {

            system("clear")

            uuid = item["uuid"]

            store = ItemStore.new()

            puts TxFloats::toString(item).green
            puts "uuid: #{uuid}".yellow

            TxAttachments::itemsForOwner(uuid).each{|attachment|
                indx = store.register(attachment, false)
                puts "[#{indx.to_s.ljust(3)}] #{TxAttachments::toString(attachment)}" 
            }

            Libriarian16SpecialCircumstances::atomLandingPresentation(item["atomuuid"])

            puts "access | <datecode> | description | atom | attachment | universe | transmute | show json | >nyx |destroy (gg) | exit (xx)".yellow

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
                Libriarian16SpecialCircumstances::accessAtom(item["atomuuid"])
                next
            end

            if Interpreting::match("description", command) then
                description = Utils::editTextSynchronously(item["description"]).strip
                next if description == ""
                item["description"] = description
                Librarian6Objects::commit(item)
                next
            end

            if Interpreting::match("atom", command) then
                atom = Librarian5Atoms::interactivelyIssueNewAtomOrNull()
                next if atom.nil?
                item["atomuuid"] = atom["uuid"]
                Librarian6Objects::commit(item)
                next
            end

            if Interpreting::match("attachment", command) then
                TxAttachments::interactivelyCreateNewOrNullForOwner(item["uuid"])
                next
            end

            if Interpreting::match("universe", command) then
                ObjectUniverseMapping::interactivelySetObjectUniverseMapping(item["uuid"])
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
                NyxAdapter::floatToNyx(item)
                break
            end
        }
    end

    # --------------------------------------------------
    # nx16s

    # TxFloats::ns16(float)
    def self.ns16(float)
        uuid = float["uuid"]
        {
            "uuid"     => uuid,
            "mikuType" => "NS16:TxFloat",
            "announce" => "#{float["description"]}#{Libriarian16SpecialCircumstances::atomTypeForToStrings(" ", float["atomuuid"])}",
            "TxFloat"  => float
        }
    end

    # TxFloats::ns16s(universe)
    def self.ns16s(universe)
        return [] if universe.nil?
        TxFloats::items()
            .select{|item| 
                objuniverse = ObjectUniverseMapping::getObjectUniverseMappingOrNull(item["uuid"])
                universe.nil? or objuniverse.nil? or (objuniverse == universe)
            }
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
