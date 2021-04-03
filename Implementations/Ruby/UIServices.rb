# encoding: UTF-8

class UIServices

    # UIServices::explore()
    def self.explore()
        loop {
            system("clear")
            typex = NyxNavigationPoints::interactivelySelectClassifierTypeXOrNull()
            break if typex.nil?
            loop {
                system("clear")
                classifiers = NyxNavigationPoints::getClassifierDeclarations()
                                .select{|classifier| classifier["type"] == typex["type"] }
                                .sort{|c1, c2| c1["unixtime"] <=> c2["unixtime"] }
                classifier = CatalystUtils::selectOneOrNull(classifiers, lambda{|classifier| NyxNavigationPoints::toString(classifier) })
                break if classifier.nil?
                NyxNavigationPoints::landing(classifier)
            }
        }
    end

    # UIServices::servicesFront()
    def self.servicesFront()
        loop {
            system("clear")

            ms = LCoreMenuItemsNX1.new()

            ms.item("Calendar", lambda { Calendar::main() })

            ms.item("Anniversaries", lambda { Anniversaries::main() })

            ms.item("Waves", lambda { Waves::main() })

            puts ""

            ms.item("new wave", lambda { Waves::issueNewWaveInteractivelyOrNull() })            

            ms.item("new quark", lambda { Quarks::getQuarkPossiblyArchitectedOrNull(nil, nil) })    

            puts ""

            ms.item("dangerously edit a TodoCoreData object by uuid", lambda { 
                uuid = LucilleCore::askQuestionAnswerAsString("uuid: ")
                return if uuid == ""
                object = TodoCoreData::getOrNull(uuid)
                return if object.nil?
                object = CatalystUtils::editTextSynchronously(JSON.pretty_generate(object))
                object = JSON.parse(object)
                TodoCoreData::put(object)
            })

            ms.item("dangerously delete a TodoCoreData object by uuid", lambda { 
                uuid = LucilleCore::askQuestionAnswerAsString("uuid: ")
                object = TodoCoreData::getOrNull(uuid)
                return if object.nil?
                puts JSON.pretty_generate(object)
                return if !LucilleCore::askQuestionAnswerAsBoolean("delete ? : ")
                TodoCoreData::destroy(object)
            })

            puts ""

            status = ms.promptAndRunSandbox()
            break if !status
        }
    end

    # UIServices::nyxMain()
    def self.nyxMain()
        loop {
            system("clear")
            puts "Nyx 🗺"
            ops = ["Search", "Explore", "Issue New"]
            operation = LucilleCore::selectEntityFromListOfEntitiesOrNull("operation", ops)
            break if operation.nil?
            if operation == "Search" then
                Patricia::generalSearchLoop()
            end
            if operation == "Explore" then
                UIServices::explore()
            end
            if operation == "Issue New" then
                node = Patricia::makeNewNodeOrNull()
                next if node.nil?
                Patricia::landing(node)
            end
        }
    end

    # UIServices::desktopFileNameToNS16(filename)
    def self.desktopFileNameToNS16(filename)
        announce = IO.read("/Users/pascal/Desktop/#{filename}")
                        .lines
                        .first(6)
                        .join()
                        .strip
        return [] if announce == ""

        ns16 = {
            "uuid"     => "e9e42746-0da1-4b81-b0f9-8ca0b159e280:#{filename}",
            "announce" => "~/Desktop/#{filename}",
            "lambda"   => lambda{ 

                system("clear")
                puts announce

                context = {}
                actions = [
                    ["[]", "[] Next transformation", lambda{|context, command|
                        CatalystUtils::applyNextTransformationToFile("/Users/pascal/Desktop/#{filename}")
                    }],
                    ["edit", "edit", lambda{|context, command|
                        system("open '/Users/pascal/Desktop/#{filename}'")
                    }],
                    ["++", "++ (postpone today by one hour)", lambda{|context, command|
                        DoNotShowUntil::setUnixtime("e9e42746-0da1-4b81-b0f9-8ca0b159e280", Time.new.to_i+3600)
                    }],
                ]

                returnvalue = Interpreting::interpreter(context, actions, {
                    "displayHelpInLineAtIntialization" => true
                })

            }
        }

        [ns16]
    end

    # UIServices::waveLikeNS16s()
    def self.waveLikeNS16s()
        Calendar::ns16s() + Anniversaries::ns16s() + Waves::ns16s()
    end

    # UIServices::catalystNS16s()
    def self.catalystNS16s()
        UIServices::waveLikeNS16s() + UIServices::desktopFileNameToNS16("Todo.txt") + Quarks::ns16s()
    end
end


