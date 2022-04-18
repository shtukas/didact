
# encoding: UTF-8

class Nx111

    # Nx111::iamTypes()
    def self.iamTypes()
        [
            "navigation",
            "log",
            "description-only",
            "text",
            "url",
            "aion-point",
            "unique-string",
            "primitive-file",
            "carrier-of-primitive-files",
            "local-group-001",
            "local-group-002",
            "Dx8Unit"
        ]
    end

    # Nx111::iamTypesForManualMaking()
    def self.iamTypesForManualMaking()
        [
            "navigation",
            "log",
            "description-only",
            "text",
            "url",
            "aion-point",
            "unique-string",
            "primitive-file",
            "carrier-of-primitive-files",
            "Dx8Unit"
        ]
    end

    # Nx111::interactivelySelectIamTypeOrNull()
    def self.interactivelySelectIamTypeOrNull()
        types = Nx111::iamTypesForManualMaking()
        LucilleCore::selectEntityFromListOfEntitiesOrNull("iam type", types)
    end

    # Nx111::primitiveFileIamValueFromLocationOrNull(location)
    def self.primitiveFileIamValueFromLocationOrNull(location)
        data = Librarian17PrimitiveFilesAndCarriers::readPrimitiveFileOrNull(location)
        return nil if data.nil?
        dottedExtension, nhash, parts = data
        ["primitive-file", dottedExtension, nhash, parts]
    end

    # Nx111::interactivelyCreateNewIamValueOrNull()
    def self.interactivelyCreateNewIamValueOrNull()
        type = Nx111::interactivelySelectIamTypeOrNull()
        return nil if type.nil?
        if type == "navigation" then
            return ["navigation"]
        end
        if type == "log" then
            return ["log"]
        end
        if type == "description-only" then
            return ["description-only"]
        end
        if type == "text" then
            text = Librarian0Utils::editTextSynchronously("")
            nhash = Librarian12LocalBlobsService::putBlob(text)
            return ["text", nhash]
        end
        if type == "url" then
            url = LucilleCore::askQuestionAnswerAsString("url (empty to abort): ")
            return nil if url == ""
            return ["url", url]
        end
        if type == "aion-point" then
            location = Librarian0Utils::interactivelySelectDesktopLocationOrNull()
            return nil if location.nil?
            return nil if !File.exists?(location)
            rootnhash = AionCore::commitLocationReturnHash(Librarian14ElizabethLocalStandard.new(), location)
            return ["aion-point", rootnhash]
        end
        if type == "unique-string" then
            uniquestring = LucilleCore::askQuestionAnswerAsString("unique string (use 'Nx01-#{SecureRandom.hex(6)}' if need one): ")
            return nil if uniquestring == ""
            return ["unique-string", uniquestring]
        end
        if type == "primitive-file" then
            location = Librarian0Utils::interactivelySelectDesktopLocationOrNull()
            return nil if location.nil?
            return Nx111::primitiveFileIamValueFromLocationOrNull(location)
        end
        if type == "carrier-of-primitive-files" then
            return ["carrier-of-primitive-files"]
        end
        if type == "Dx8Unit" then
            unitId = Utils::nx45()
            location = Librarian0Utils::interactivelySelectDesktopLocationOrNull()
            return nil if location.nil?
            return nil if !File.exists?(location)
            rootnhash = AionCore::commitLocationReturnHash(Librarian24ElizabethForDx8Units.new(unitId), location)
            configuration = {
                "unitId"   => unitId,
                "status"   => "standard",
                "rootnhash" => rootnhash
            }
            return ["Dx8Unit", configuration]
        end
        raise "(error: aae1002c-2f78-4c2b-9455-bdd0b5c0ebd6): #{type}"
    end

    # Nx111::accessNx100PossibleStorageMutation(item)
    def self.accessNx100PossibleStorageMutation(item)
        iAmValue = item["iam"]
        if iAmValue[0] == "navigation" then
            puts "This is a navigation node"
            LucilleCore::pressEnterToContinue()
            return
        end
        if iAmValue[0] == "log" then
            puts "This is a log"
            LucilleCore::pressEnterToContinue()
            return
        end
        if iAmValue[0] == "description-only" then
            puts "This is a description-only"
            LucilleCore::pressEnterToContinue()
            return
        end
        if iAmValue[0] == "text" then
            nhash = iAmValue[1]
            text1 = Librarian12LocalBlobsService::getBlobOrNull(nhash)
            text2 = Librarian0Utils::editTextSynchronously(text1)
            if text1 != text2 then
                iAmValue[1] = Librarian12LocalBlobsService::putBlob(text2)
                item["iam"] = iAmValue
                Librarian6Objects::commit(item)
            end
            return
        end
        if iAmValue[0] == "url" then
            url = iAmValue[1]
            puts "url: #{url}"
            Librarian0Utils::openUrlUsingSafari(url)
            LucilleCore::pressEnterToContinue()
            return
        end
        if iAmValue[0] == "aion-point" then
            rootnhash = iAmValue[1]
            exportFolder = "/Users/pascal/Desktop/#{item["description"]} (#{SecureRandom.hex[0, 4]})"
            puts "export folder: #{exportFolder}"
            FileUtils.mkdir(exportFolder)
            AionCore::exportHashAtFolder(Librarian14ElizabethLocalStandard.new(), rootnhash, exportFolder)
            system("open '#{exportFolder}'")
            return
        end
        if iAmValue[0] == "unique-string" then
            uniquestring = iAmValue[1]
            Librarian5Atoms::findAndAccessUniqueString(uniquestring)
            return
        end
        if iAmValue[0] == "primitive-file" then
            _, dottedExtension, nhash, parts = iAmValue
            location = "/Users/pascal/Desktop"
            filepath = Librarian17PrimitiveFilesAndCarriers::exportPrimitiveFileAtLocation(item["uuid"], dottedExtension, parts, location)
            LucilleCore::pressEnterToContinue()
            if File.exists?(filepath) and LucilleCore::askQuestionAnswerAsBoolean("delete file on the desktop ? ") then
                FileUtils.rm(filepath)
            end
            return
        end
        if iAmValue[0] == "carrier-of-primitive-files" then
            Librarian17PrimitiveFilesAndCarriers::exportCarrier(item)
            return
        end
        if iAmValue[0] == "local-group-001" then
            puts JSON.pretty_generate(iAmValue)
            LucilleCore::pressEnterToContinue()
            return
        end
        if iAmValue[0] == "local-group-002" then
            puts JSON.pretty_generate(iAmValue)
            LucilleCore::pressEnterToContinue()
            return
        end
        if iAmValue[0] == "Dx8Unit" then
            configuration = iAmValue[1]

            if configuration["status"] == "standard" then
                unitId = configuration["unitId"]
                rootnhash = configuration["rootnhash"]
                exportFolder = "/Users/pascal/Desktop/#{item["description"]} (#{SecureRandom.hex[0, 4]})"
                puts "export folder: #{exportFolder}"
                FileUtils.mkdir(exportFolder)
                AionCore::exportHashAtFolder(Librarian24ElizabethForDx8Units.new(unitId), rootnhash, exportFolder)
                system("open '#{exportFolder}'")
                return
            end

            raise "(error: 3d84d2b9-56c3-4762-b6a8-8a50c66b9240): #{item}, #{iAmValue}"
        end
        raise "(error: 3cbb1e64-0d18-48c5-bd28-f4ba584659a3): #{item}"
    end
end
