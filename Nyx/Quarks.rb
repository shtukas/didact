
# encoding: UTF-8

# require "/Users/pascal/Galaxy/LucilleOS/Applications/Catalyst/Nyx/Quarks.rb"

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

require "/Users/pascal/Galaxy/LucilleOS/Libraries/Ruby-Libraries/AtlasCore.rb"

require "/Users/pascal/Galaxy/LucilleOS/Applications/Catalyst/Catalyst/Common.rb"

require "/Users/pascal/Galaxy/LucilleOS/Applications/Catalyst/Nyx/Bosons.rb"
require "/Users/pascal/Galaxy/LucilleOS/Applications/Catalyst/Nyx/NyxDataCarriers.rb"
require "/Users/pascal/Galaxy/LucilleOS/Applications/Catalyst/Nyx/NyxIO.rb"

require_relative "Librarian.rb"

# -----------------------------------------------------------------

class QuarksIssuers

    # QuarksIssuers::selectOneFilepathOnTheDesktopOrNull()
    def self.selectOneFilepathOnTheDesktopOrNull()
        desktopLocations = LucilleCore::locationsAtFolder("/Users/pascal/Desktop")
                            .select{|filepath| filepath[0,1] != '.' }
                            .select{|filepath| File.file?(filepath) }
                            .select{|filepath| File.basename(filepath) != 'pascal.png' }
                            .sort
        LucilleCore::selectEntityFromListOfEntitiesOrNull("filepath", desktopLocations, lambda{ |location| File.basename(location) })
    end

    # QuarksIssuers::selectOneFolderpathOnTheDesktopOrNull()
    def self.selectOneFolderpathOnTheDesktopOrNull()
        desktopLocations = LucilleCore::locationsAtFolder("/Users/pascal/Desktop")
                            .select{|filepath| filepath[0,1] != '.' }
                            .select{|filepath| File.directory?(filepath) }
                            .select{|filepath| File.basename(filepath) != 'Todo-Inbox' }
                            .sort
        LucilleCore::selectEntityFromListOfEntitiesOrNull("folderpath", desktopLocations, lambda{ |location| File.basename(location) })
    end

    # QuarksIssuers::issueQuarkLineInteractively()
    def self.issueQuarkLineInteractively()
        line = LucilleCore::askQuestionAnswerAsString("line: ")
        quark = {
            "uuid"             => SecureRandom.uuid,
            "nyxType"          => "quark-6af2c9d7-67b5-4d16-8913-c5980b0453f2",
            "creationUnixtime" => Time.new.to_f,
            "description"      => line,
            "type"             => "line",
            "line"             => line
        }
        NyxIO::commitToDisk(quark)
        quark
    end

    # QuarksIssuers::issueQuarkUrlInteractively()
    def self.issueQuarkUrlInteractively()
        url = LucilleCore::askQuestionAnswerAsString("url: ")
        description = LucilleCore::askQuestionAnswerAsString("quark description: ")
        quark = {
            "uuid"             => SecureRandom.uuid,
            "nyxType"          => "quark-6af2c9d7-67b5-4d16-8913-c5980b0453f2",
            "creationUnixtime" => Time.new.to_f,
            "description"      => description,
            "type"             => "url",
            "url"              => url
        }
        NyxIO::commitToDisk(quark)
        quark
    end

    # QuarksIssuers::issueQuarkFileInteractivelyOrNull()
    def self.issueQuarkFileInteractivelyOrNull()
        filepath1 = QuarksIssuers::selectOneFilepathOnTheDesktopOrNull()
        return nil if filepath1.nil?
        filename1 = File.basename(filepath1)
        filename2 = "#{CatalystCommon::l22()}-#{filename1}"
        filepath2 = "#{File.dirname(filepath1)}/#{filename2}"
        FileUtils.mv(filepath1, filepath2)
        LibrarianFile::copyFileToRepository(filepath2)
        description = LucilleCore::askQuestionAnswerAsString("quark description: ")
        quark = {
            "uuid"             => SecureRandom.uuid,
            "nyxType"          => "quark-6af2c9d7-67b5-4d16-8913-c5980b0453f2",
            "creationUnixtime" => Time.new.to_f,
            "description"      => description,
            "type"             => "file",
            "filename"         => filename2
        }
        NyxIO::commitToDisk(quark)
        quark
    end

    # QuarksIssuers::issueQuarkFile(filepath)
    def self.issueQuarkFile(filepath1)
        filename2 = "#{CatalystCommon::l22()}-#{File.basename(filepath1)}"
        filepath2 = "#{File.dirname(filepath1)}/#{filename2}"
        FileUtils.mv(filepath1, filepath2)
        LibrarianFile::copyFileToRepository(filepath2)
        quark = {
            "uuid"             => SecureRandom.uuid,
            "nyxType"          => "quark-6af2c9d7-67b5-4d16-8913-c5980b0453f2",
            "creationUnixtime" => Time.new.to_f,
            "type"             => "file",
            "filename"         => filename2
        }
        NyxIO::commitToDisk(quark)
        quark
    end

    # QuarksIssuers::issueQuarkFromText(text)
    def self.issueQuarkFromText(text)
        filename = LibrarianFile::textToFilename(text)
        quark = {
            "uuid"             => SecureRandom.uuid,
            "nyxType"          => "quark-6af2c9d7-67b5-4d16-8913-c5980b0453f2",
            "creationUnixtime" => Time.new.to_f,
            "description"      => description,
            "type"             => "file",
            "filename"         => filename
        }
        NyxIO::commitToDisk(quark)
        quark
    end

    # QuarksIssuers::issueQuarkFolderInteractivelyOrNull()
    def self.issueQuarkFolderInteractivelyOrNull()
        folderpath1 = QuarksIssuers::selectOneFolderpathOnTheDesktopOrNull()
        return nil if folderpath1.nil?
        foldername1 = File.basename(folderpath1)
        foldername2 = "#{CatalystCommon::l22()}-#{foldername1}"
        folderpath2 = "#{File.dirname(folderpath1)}/#{foldername2}"
        FileUtils.mv(folderpath1, folderpath2)
        LibrarianDirectory::copyDirectoryToRepository(folderpath2)
        description = LucilleCore::askQuestionAnswerAsString("quark description: ")
        quark = {
            "uuid"             => SecureRandom.uuid,
            "nyxType"          => "quark-6af2c9d7-67b5-4d16-8913-c5980b0453f2",
            "creationUnixtime" => Time.new.to_f,
            "description"      => description,
            "type"             => "folder",
            "foldername"       => foldername2
        }
        NyxIO::commitToDisk(quark)
        quark
    end

    # QuarksIssuers::locationToFileOrFolderQuarkIssued(location)
    def self.locationToFileOrFolderQuarkIssued(location)
        raise "f8e3b314" if !File.exists?(location)
        if File.file?(location) then
            filepath1 = location
            filename1 = File.basename(filepath1)
            filename2 = "#{CatalystCommon::l22()}-#{filename1}"
            filepath2 = "#{File.dirname(filepath1)}/#{filename2}"
            FileUtils.mv(filepath1, filepath2)
            LibrarianFile::copyFileToRepository(filepath2)
            FileUtils.mv(filepath2, filepath1) # putting thing back so that the location doesn't disappear under the nose of the caller
            quark = {
                "uuid"             => SecureRandom.uuid,
                "nyxType"          => "quark-6af2c9d7-67b5-4d16-8913-c5980b0453f2",
                "creationUnixtime" => Time.new.to_f,
                "type"             => "file",
                "filename"         => filename2
            }
            NyxIO::commitToDisk(quark)
            quark
        else
            folderpath1 = location
            foldername1 = File.basename(folderpath1)
            foldername2 = "#{CatalystCommon::l22()}-#{foldername1}"
            folderpath2 = "#{File.dirname(foldername1)}/#{foldername2}"
            FileUtils.mv(folderpath1, folderpath2)
            LibrarianDirectory::copyDirectoryToRepository(folderpath2)
            FileUtils.mv(folderpath2, folderpath1) # putting thing back so that the location doesn't disappear under the nose of the caller
            quark = {
                "uuid"             => SecureRandom.uuid,
                "nyxType"          => "quark-6af2c9d7-67b5-4d16-8913-c5980b0453f2",
                "creationUnixtime" => Time.new.to_f,
                "type"             => "folder",
                "foldername"       => foldername2
            }
            NyxIO::commitToDisk(quark)
            quark
        end
    end

    # QuarksIssuers::issueQuarkUniqueNameInteractively()
    def self.issueQuarkUniqueNameInteractively()
        uniquename = LucilleCore::askQuestionAnswerAsString("unique name: ")
        description = LucilleCore::askQuestionAnswerAsString("quark description: ")
        quark = {
            "uuid"             => SecureRandom.uuid,
            "nyxType"          => "quark-6af2c9d7-67b5-4d16-8913-c5980b0453f2",
            "creationUnixtime" => Time.new.to_f,
            "description"      => description,
            "type"             => "unique-name",
            "name"             => uniquename
        }
        NyxIO::commitToDisk(quark)
        quark
    end

    # QuarksIssuers::issueQuarkDataPodInteractively()
    def self.issueQuarkDataPodInteractively()
        podname = LucilleCore::askQuestionAnswerAsString("podname: ")
        description = LucilleCore::askQuestionAnswerAsString("description: ")
        quark = {
            "uuid"             => SecureRandom.uuid,
            "nyxType"          => "quark-6af2c9d7-67b5-4d16-8913-c5980b0453f2",
            "creationUnixtime" => Time.new.to_f,
            "description"      => description,
            "type"             => "datapod",
            "podname"          => podname
        }
        NyxIO::commitToDisk(quark)
        quark
    end
end

class Quarks

    # Quarks::issueNewQuarkInteractivelyOrNull()
    def self.issueNewQuarkInteractivelyOrNull()
        puts "Making a new Quark..."
        types = ["line", "url", "file", "new text file", "folder", "unique-name", "datapod"]
        type = LucilleCore::selectEntityFromListOfEntitiesOrNull("type", types)
        return if type.nil?
        if type == "line" then
            return QuarksIssuers::issueQuarkLineInteractively()
        end
        if type == "url" then
            return QuarksIssuers::issueQuarkUrlInteractively()
        end
        if type == "file" then
            return QuarksIssuers::issueQuarkFileInteractivelyOrNull()
        end
        if type == "new text file" then
            filename = LibrarianFile::makeNewTextFileInteractivelyReturnLibrarianFilename()
            description = LucilleCore::askQuestionAnswerAsString("description: ")
            quark = {
                "uuid"             => SecureRandom.uuid,
                "nyxType"          => "quark-6af2c9d7-67b5-4d16-8913-c5980b0453f2",
                "creationUnixtime" => Time.new.to_f,
                "description"      => description,
                "type"             => "file",
                "filename"         => filename
            }
            NyxIO::commitToDisk(quark)
            return quark
        end
        if type == "folder" then
            return QuarksIssuers::issueQuarkFolderInteractivelyOrNull()
        end
        if type == "unique-name" then
            return QuarksIssuers::issueQuarkUniqueNameInteractively()
        end
        if type == "datapod" then
            return QuarksIssuers::issueQuarkDataPodInteractively()
        end
    end

    # Quarks::quarks()
    def self.quarks()
        NyxIO::objects("quark-6af2c9d7-67b5-4d16-8913-c5980b0453f2")
            .sort{|n1, n2| n1["creationUnixtime"] <=> n2["creationUnixtime"] }
    end

    # Quarks::destroyQuarkByUUID(uuid)
    def self.destroyQuarkByUUID(uuid)
        NyxIO::destroyAtType(uuid, "quark-6af2c9d7-67b5-4d16-8913-c5980b0453f2")
    end

    # Quarks::getQuarksOfTypeFolderByFoldername(foldername)
    def self.getQuarksOfTypeFolderByFoldername(foldername)
        Quarks::quarks()
            .select{|quark| quark["type"] == "folder" and quark["foldername"] == foldername }
    end

    # Quarks::getQuarksOfTypeFileByFilename(filename)
    def self.getQuarksOfTypeFileByFilename(filename)
        Quarks::quarks()
            .select{|quark| quark["type"] == "file" and quark["filename"] == filename }
    end

    # Quarks::quarkHasConnections(quark)
    def self.quarkHasConnections(quark)
        return true if Bosons::getLinkedObjects(quark).size > 0
        return true if NyxRoles::getRolesForTarget(quark["uuid"]).size > 0
        false
    end

    # Quarks::getOrNull(uuid)
    def self.getOrNull(uuid)
        NyxIO::getOrNull(uuid)
    end

    # Quarks::quarkToString(quark)
    def self.quarkToString(quark)
        if quark["description"] then
            if quark["type"] == "file" then
                return "[quark] [#{quark["uuid"][0, 4]}] [#{quark["type"]}#{File.extname(quark["filename"])}] #{quark["description"]}"
            else
                return "[quark] [#{quark["uuid"][0, 4]}] [#{quark["type"]}] #{quark["description"]}"
            end
        end
        if quark["type"] == "line" then
            return "[quark] [#{quark["uuid"][0, 4]}] [line] #{quark["line"]}"
        end
        if quark["type"] == "file" then
            return "[quark] [#{quark["uuid"][0, 4]}] [file] #{quark["filename"]}"
        end
        if quark["type"] == "url" then
            return "[quark] [#{quark["uuid"][0, 4]}] [url] #{quark["url"]}"
        end
        if quark["type"] == "folder" then
            return "[quark] [#{quark["uuid"][0, 4]}] [folder] #{quark["foldername"]}"
        end
        if quark["type"] == "unique-name" then
            return "[quark] [#{quark["uuid"][0, 4]}] [unique name] #{quark["name"]}"
        end
        if quark["type"] == "datapod" then
            return "[quark] [#{quark["uuid"][0, 4]}] [datapod] #{quark["podname"]}"
        end
        raise "Quark error 3c7968e4"
    end

    # Quarks::openQuark(quark)
    def self.openQuark(quark)
        if quark["type"] == "line" then
            puts quark["line"]
            LucilleCore::pressEnterToContinue()
            return
        end
        if quark["type"] == "file" then
            LibrarianFile::accessFile(quark["filename"])
            return
        end
        if quark["type"] == "url" then
            system("open '#{quark["url"]}'")
            return
        end
        if quark["type"] == "folder" then
            LibrarianDirectory::openFolder(quark["foldername"])
            return
        end
        if quark["type"] == "unique-name" then
            uniquename = quark["name"]
            location = AtlasCore::uniqueStringToLocationOrNull(uniquename)
            if location then
                puts "opening: #{location}"
                system("open '#{location}'")
            else
                puts "I could not determine the location of unique name: #{uniquename}"
                LucilleCore::pressEnterToContinue()
            end
            return
        end
        if quark["type"] == "datapod" then
            podname = quark["podname"]
            puts "#{podname}"
            puts "I do not yet know how to open/access/browse DataPods"
            LucilleCore::pressEnterToContinue()
            return
        end
        raise "Quark error 160050-490261"
    end

    # Quarks::quarkDive(quark)
    def self.quarkDive(quark)
        loop {

            quark = Quarks::getOrNull(quark["uuid"])

            return if quark.nil? # Could have been destroyed in the previous loop

            system("clear")
            puts Quarks::quarkToString(quark).green
            puts "uuid: #{quark["uuid"]}"

            items = []

            items << [
                "open", 
                lambda{ Quarks::openQuark(quark) }
            ]

            items << [
                "update description",
                lambda{
                    description = 
                        if ( quark["description"].nil? or quark["description"].size == 0 ) then
                            description = LucilleCore::askQuestionAnswerAsString("description: ")
                        else
                            description = CatalystCommon::editTextUsingTextmate(quark["description"]).strip
                        end
                    return if description == ""
                    quark["description"] = description
                    NyxIO::commitToDisk(quark)
                }
            ]

            items << [
                "add tag",
                lambda {
                    payload = LucilleCore::askQuestionAnswerAsString("tag payload: ")
                    tag = Tags::issueTag(payload)
                    Bosons::issueLink(quark, tag)
                }
            ]

            items << [
                "clique (link to)",
                lambda {
                    clique = Cliques::selectCliqueOrMakeNewOneOrNull()
                    return if clique.nil?
                    Bosons::issueLink(quark, clique)
                }
            ]

            items << [
                "make new quark + attach to this with gluon",
                lambda {
                    newquark = Quarks::issueNewQuarkInteractivelyOrNull()
                    return if newquark.nil?
                    Gluons::issueLink(quark, newquark)
                }
            ]

            items << [
                "select existing quark + attach to this with gluon",
                lambda {
                    quark2 = Quarks::selectQuarkFromExistingQuarksOrNull()
                    return if quark2.nil?
                    return if quark["uuid"] == quark2["uuid"]
                    Gluons::issueLink(quark, quark2)
                }
            ]

            items << [
                "opencycle (register as)", 
                lambda { OpenCycles::issueFromQuark(quark) }
            ]

            items << [
                "quark (destroy)", 
                lambda { 
                    if LucilleCore::askQuestionAnswerAsBoolean("Are you sure to want to destroy this quark ? ") then
                        NyxIO::destroy(quark["uuid"])
                    end
                }
            ]

            items << nil

            NyxRoles::getRolesForTarget(quark["uuid"])
                .each{|object| items << [NyxRoles::objectToString(object), lambda{ NyxRoles::objectDive(object) }] }

            items << nil

            Gluons::getLinkedQuarks(quark)
                .sort{|q1, q2| q1["creationUnixtime"] <=> q2["creationUnixtime"] }
                .each{|q|
                    items << [ Quarks::quarkToString(q), lambda{ Quarks::quarkDive(q) } ]
                }

            Cliques::getCliqueBosonLinkedObjects(quark)
                .sort{|o1, o2| NyxDataCarriers::objectLastActivityUnixtime(o1) <=> NyxDataCarriers::objectLastActivityUnixtime(o2) }
                .each{|object|
                    object = NyxDataCarriers::applyQuarkToCubeUpgradeIfRelevant(object)
                    items << [NyxDataCarriers::objectToString(object), lambda { NyxDataCarriers::objectDive(object) } ]
                }

            status = LucilleCore::menuItemsWithLambdas(items) # Boolean # Indicates whether an item was chosen
            break if !status
        }
    end

    # Quarks::quarksListingAndDive()
    def self.quarksListingAndDive()
        loop {
            items = []
            Quarks::quarks()
                .sort{|q1, q2| q1["creationUnixtime"]<=>q2["creationUnixtime"] }
                .each{|quark|
                    items << [ Quarks::quarkToString(quark), lambda{ Quarks::quarkDive(quark) }]
                }
            status = LucilleCore::menuItemsWithLambdas(items) # Boolean # Indicates whether an item was chosen
            break if !status
        }
    end

    # Quarks::selectQuarkFromExistingQuarksOrNull()
    def self.selectQuarkFromExistingQuarksOrNull()
        quarkstrings = Quarks::quarks().map{|quark| Quarks::quarkToString(quark) }
        quarkstring = CatalystCommon::chooseALinePecoStyle("quark:", [""]+quarkstrings)
        return nil if quarkstring == ""
        Quarks::quarks()
            .select{|quark| Quarks::quarkToString(quark) == quarkstring }
            .first
    end

    # Quarks::searchNx1630(pattern)
    def self.searchNx1630(pattern)
        Quarks::quarks()
            .select{|quark| 
                [
                    quark["uuid"].downcase.include?(pattern.downcase),
                    Quarks::quarkToString(quark).downcase.include?(pattern.downcase)
                ].any?
            }
            .map{|quark|
                {
                    "description"   => Quarks::quarkToString(quark),
                    "referencetime" => quark["creationUnixtime"],
                    "dive"          => lambda{ Quarks::quarkDive(quark) }
                }
            }
    end
end
