
require 'digest/sha1'
# Digest::SHA1.hexdigest 'foo'
# Digest::SHA1.file(myFile).hexdigest
# Digest::SHA256.hexdigest 'message'  
# Digest::SHA256.file(myFile).hexdigest

require 'securerandom'
# SecureRandom.hex    #=> "eb693ec8252cd630102fd0d0fb7c3485"
# SecureRandom.hex(4) #=> "eb693123"
# SecureRandom.uuid   #=> "2d931510-d99f-494a-8c67-87feb05e1594"

require 'find'

require "/Users/pascal/Galaxy/LucilleOS/Libraries/Ruby-Libraries/XCache.rb"
=begin
    XCache::setFlagTrue(key)
    XCache::setFlagFalse(key)
    XCache::flagIsTrue(key)

    XCache::set(key, value)
    XCache::getOrNull(key)
    XCache::getOrDefaultValue(key, defaultValue)
    XCache::destroy(key)
=end

# ------------------------------------------------------------------------

class Librarian0Utils

    # Librarian0Utils::filepathToContentHash(filepath) # nhash
    def self.filepathToContentHash(filepath)
        "SHA256-#{Digest::SHA256.file(filepath).hexdigest}"
    end

    # Librarian0Utils::openUrlUsingSafari(url)
    def self.openUrlUsingSafari(url)
        system("open -a Safari '#{url}'")
    end

    # Librarian0Utils::editTextSynchronously(text)
    def self.editTextSynchronously(text)
        filename = "#{SecureRandom.uuid}.txt"
        filepath = "/tmp/#{filename}"
        File.open(filepath, 'w') {|f| f.write(text)}
        system("open '#{filepath}'")
        print "> press enter when done: "
        input = STDIN.gets
        IO.read(filepath)
    end

    # Librarian0Utils::timeStringL22()
    def self.timeStringL22()
        "#{Time.new.strftime("%Y%m%d-%H%M%S-%6N")}"
    end

    # Librarian0Utils::atlas(pattern)
    def self.atlas(pattern)
        location = `/Users/pascal/Galaxy/LucilleOS/Binaries/atlas '#{pattern}'`.strip
        (location != "") ? location : nil
    end

    # Librarian0Utils::interactivelySelectDesktopLocationOrNull() 
    def self.interactivelySelectDesktopLocationOrNull()
        entries = Dir.entries("/Users/pascal/Desktop").select{|filename| !filename.start_with?(".") }.sort
        locationNameOnDesktop = LucilleCore::selectEntityFromListOfEntitiesOrNull("locationname", entries)
        return nil if locationNameOnDesktop.nil?
        "/Users/pascal/Desktop/#{locationNameOnDesktop}"
    end

    # Librarian0Utils::moveFileToBinTimeline(location)
    def self.moveFileToBinTimeline(location)
        return if !File.exists?(location)
        directory = "/Users/pascal/x-space/bin-timeline/#{Time.new.strftime("%Y%m")}/#{Time.new.strftime("%Y%m%d-%H%M%S-%6N")}"
        FileUtils.mkpath(directory)
        FileUtils.mv(location, directory)
    end

    # Librarian0Utils::commitFileToXCacheReturnPartsHashs(filepath)
    def self.commitFileToXCacheReturnPartsHashs(filepath)
        raise "[a324c706-3867-4fbb-b0de-f8c2edd2d110, filepath: #{filepath}]" if !File.exists?(filepath)
        raise "[fba5194d-cad3-4766-953e-a994923925fe, filepath: #{filepath}]" if !File.file?(filepath)
        hashes = []
        partSizeInBytes = 1024*1024 # 1 MegaBytes
        f = File.open(filepath)
        while ( blob = f.read(partSizeInBytes) ) do
            hashes << Librarian2DatablobsXCache::putBlob(blob)
        end
        f.close()
        hashes
    end

    # Librarian0Utils::commitFileToXCacheReturnPartsHashsImproved(filepath, lambdaBlobCommitReturnNhash)
    def self.commitFileToXCacheReturnPartsHashsImproved(filepath, lambdaBlobCommitReturnNhash)
        raise "[a324c706-3867-4fbb-b0de-f8c2edd2d110, filepath: #{filepath}]" if !File.exists?(filepath)
        raise "[fba5194d-cad3-4766-953e-a994923925fe, filepath: #{filepath}]" if !File.file?(filepath)
        hashes = []
        partSizeInBytes = 1024*1024 # 1 MegaBytes
        f = File.open(filepath)
        while ( blob = f.read(partSizeInBytes) ) do
            hashes << lambdaBlobCommitReturnNhash.call(blob)
        end
        f.close()
        hashes
    end

    # Librarian0Utils::uniqueStringLocationUsingFileSystemSearchOrNull(uniquestring)
    def self.uniqueStringLocationUsingFileSystemSearchOrNull(uniquestring)
        roots = [
            "/Users/pascal/Desktop"
        ]
        roots.each{|root|
            Find.find(root) do |path|
                if File.basename(path).downcase.include?(uniquestring.downcase) then
                    return path
                end
            end
        }
        nil
    end
end

class Librarian2DatablobsXCache

    # Librarian2DatablobsXCache::putBlob(blob)
    def self.putBlob(blob)
        nhash = "SHA256-#{Digest::SHA256.hexdigest(blob)}"
        XCache::set("FAF57B05-2EF0-4F49-B1C8-9E73D03939DE:#{nhash}", blob)
        nhash
    end

    # Librarian2DatablobsXCache::getBlobOrNull(nhash)
    def self.getBlobOrNull(nhash)
        XCache::getOrNull("FAF57B05-2EF0-4F49-B1C8-9E73D03939DE:#{nhash}")
    end
end

class Librarian3ElizabethXCache

    def initialize()
    end

    def commitBlob(blob)
        Librarian2DatablobsXCache::putBlob(blob)
    end

    def filepathToContentHash(filepath)
        "SHA256-#{Digest::SHA256.file(filepath).hexdigest}"
    end

    def readBlobErrorIfNotFound(nhash)
        blob = Librarian2DatablobsXCache::getBlobOrNull(nhash)
        return blob if blob
        puts "(error: c052116a-dd92-47a8-88e4-22d7516863d1) could not find blob, nhash: #{nhash}"
        raise "(error: 521d8f17-a958-44ba-97c2-ffacbbca9724, nhash: #{nhash})" if blob.nil?
    end

    def datablobCheck(nhash)
        begin
            blob = readBlobErrorIfNotFound(nhash)
            status = ("SHA256-#{Digest::SHA256.hexdigest(blob)}" == nhash)
            if !status then
                puts "(error: 4a667893-8d05-4bae-8ea8-d415066ac443) incorrect blob, exists but doesn't have the right nhash: #{nhash}"
            end
            return status
        rescue
            false
        end
    end
end

class Librarian6ObjectsLocal

    # Librarian6ObjectsLocal::databaseFilepath()
    def self.databaseFilepath()
        "#{Config::pathToLocalDidact()}/objects.sqlite3"
    end

    # ------------------------------------------------------------------------
    # Below: Public Interface

    # Librarian6ObjectsLocal::objects()
    def self.objects()
        db = SQLite3::Database.new(Librarian6ObjectsLocal::databaseFilepath())
        db.busy_timeout = 117
        db.busy_handler { |count| true }
        db.results_as_hash = true
        answer = []
        db.execute("select * from _objects_ order by _ordinal_", []) do |row|
            answer << JSON.parse(row['_object_'])
        end
        db.close
        answer
    end

    # Librarian6ObjectsLocal::getObjectsByMikuType(mikuType)
    def self.getObjectsByMikuType(mikuType)
        db = SQLite3::Database.new(Librarian6ObjectsLocal::databaseFilepath())
        db.busy_timeout = 117
        db.busy_handler { |count| true }
        db.results_as_hash = true
        answer = []
        db.execute("select * from _objects_ where _mikuType_=? order by _ordinal_", [mikuType]) do |row|
            answer << JSON.parse(row['_object_'])
        end
        db.close
        answer
    end

    # Librarian6ObjectsLocal::getObjectsByMikuTypeLimitByOrdinal(mikuType, n)
    def self.getObjectsByMikuTypeLimitByOrdinal(mikuType, n)
        db = SQLite3::Database.new(Librarian6ObjectsLocal::databaseFilepath())
        db.busy_timeout = 117
        db.busy_handler { |count| true }
        db.results_as_hash = true
        answer = []
        db.execute("select * from _objects_ where _mikuType_=? order by _ordinal_ limit ?", [mikuType, n]) do |row|
            answer << JSON.parse(row['_object_'])
        end
        db.close
        answer
    end

    # Librarian6ObjectsLocal::commit(object)
    def self.commit(object)
        raise "(error: 8e53e63e-57fe-4621-a1c6-a7b4ad5d23a7, missing attribute uuid)" if object["uuid"].nil?
        raise "(error: 016668dd-cb66-4ba1-9546-2fe05ee62fc6, missing attribute mikuType)" if object["mikuType"].nil?

        ordinal = object["ordinal"] || 0

        db = SQLite3::Database.new(Librarian6ObjectsLocal::databaseFilepath())
        db.execute "delete from _objects_ where _objectuuid_=?", [object["uuid"]]
        db.execute "insert into _objects_ (_objectuuid_, _mikuType_, _object_, _ordinal_) values (?,?,?,?)", [object["uuid"], object["mikuType"], JSON.generate(object), ordinal]
        db.close
    end

    # Librarian6ObjectsLocal::getObjectByUUIDOrNull(uuid)
    def self.getObjectByUUIDOrNull(uuid)
        db = SQLite3::Database.new(Librarian6ObjectsLocal::databaseFilepath())
        db.busy_timeout = 117
        db.busy_handler { |count| true }
        db.results_as_hash = true
        answer = nil
        db.execute("select * from _objects_ where _objectuuid_=?", [uuid]) do |row|
            answer = JSON.parse(row['_object_'])
        end
        db.close
        answer
    end

    # Librarian6ObjectsLocal::destroy(uuid)
    def self.destroy(uuid)
        db = SQLite3::Database.new(Librarian6ObjectsLocal::databaseFilepath())
        db.busy_timeout = 117
        db.busy_handler { |count| true }
        db.execute "delete from _objects_ where _objectuuid_=?", [uuid]
        db.close
    end
end

class Librarian7ObjectsInfinity

    # Librarian7ObjectsInfinity::databaseFilepath()
    def self.databaseFilepath()
        "#{Config::pathToInfinityDidact()}/objects.sqlite3"
    end

    # ------------------------------------------------------------------------
    # Below: Public Interface

    # Librarian7ObjectsInfinity::objects()
    def self.objects()
        db = SQLite3::Database.new(Librarian7ObjectsInfinity::databaseFilepath())
        db.busy_timeout = 117
        db.busy_handler { |count| true }
        db.results_as_hash = true
        answer = []
        db.execute("select * from _objects_ order by _ordinal_", []) do |row|
            answer << JSON.parse(row['_object_'])
        end
        db.close
        answer
    end

    # Librarian7ObjectsInfinity::getObjectsByMikuType(mikuType)
    def self.getObjectsByMikuType(mikuType)
        db = SQLite3::Database.new(Librarian7ObjectsInfinity::databaseFilepath())
        db.busy_timeout = 117
        db.busy_handler { |count| true }
        db.results_as_hash = true
        answer = []
        db.execute("select * from _objects_ where _mikuType_=? order by _ordinal_", [mikuType]) do |row|
            answer << JSON.parse(row['_object_'])
        end
        db.close
        answer
    end

    # Librarian7ObjectsInfinity::getObjectsByMikuTypeLimitByOrdinal(mikuType, n)
    def self.getObjectsByMikuTypeLimitByOrdinal(mikuType, n)
        db = SQLite3::Database.new(Librarian7ObjectsInfinity::databaseFilepath())
        db.busy_timeout = 117
        db.busy_handler { |count| true }
        db.results_as_hash = true
        answer = []
        db.execute("select * from _objects_ where _mikuType_=? order by _ordinal_ limit ?", [mikuType, n]) do |row|
            answer << JSON.parse(row['_object_'])
        end
        db.close
        answer
    end

    # Librarian7ObjectsInfinity::commit(object)
    def self.commit(object)
        raise "(error: 8e53e63e-57fe-4621-a1c6-a7b4ad5d23a7, missing attribute uuid)" if object["uuid"].nil?
        raise "(error: 016668dd-cb66-4ba1-9546-2fe05ee62fc6, missing attribute mikuType)" if object["mikuType"].nil?

        ordinal = object["ordinal"] || 0

        db = SQLite3::Database.new(Librarian7ObjectsInfinity::databaseFilepath())
        db.execute "delete from _objects_ where _objectuuid_=?", [object["uuid"]]
        db.execute "insert into _objects_ (_objectuuid_, _mikuType_, _object_, _ordinal_) values (?,?,?,?)", [object["uuid"], object["mikuType"], JSON.generate(object), ordinal]
        db.close
    end

    # Librarian7ObjectsInfinity::getObjectByUUIDOrNull(uuid)
    def self.getObjectByUUIDOrNull(uuid)
        db = SQLite3::Database.new(Librarian7ObjectsInfinity::databaseFilepath())
        db.busy_timeout = 117
        db.busy_handler { |count| true }
        db.results_as_hash = true
        answer = nil
        db.execute("select * from _objects_ where _objectuuid_=?", [uuid]) do |row|
            answer = JSON.parse(row['_object_'])
        end
        db.close
        answer
    end

    # Librarian7ObjectsInfinity::destroy(uuid)
    def self.destroy(uuid)
        db = SQLite3::Database.new(Librarian7ObjectsInfinity::databaseFilepath())
        db.busy_timeout = 117
        db.busy_handler { |count| true }
        db.execute "delete from _objects_ where _objectuuid_=?", [uuid]
        db.close
    end
end

# ---------------------------------------------------------------------------
# 
# ---------------------------------------------------------------------------

class Librarian15BecauseReadWrite

    # Librarian15BecauseReadWrite::utils_getAllTheSubstrings(str)
    def self.utils_getAllTheSubstrings(str)
        indx1 = 0
        substrings = []
        loop {
            break if indx1 >= str.length
            length = 1
            loop {
                break if length > str.length
                substring = str[indx1, length]
                substrings << substring
                length = length + 1
            }
            indx1 = indx1 + 1
        }
        substrings.uniq
    end

    # Librarian15BecauseReadWrite::utils_getAllTheSubstringsOfSize8(str)
    def self.utils_getAllTheSubstringsOfSize8(str)
        Librarian15BecauseReadWrite::utils_getAllTheSubstrings(str)
            .select{|str| str.size == 8 }
    end

    # Librarian15BecauseReadWrite::getLocationForThisTx46IdentiferOrNull(identifier)
    def self.getLocationForThisTx46IdentiferOrNull(identifier)
        LucilleCore::locationsAtFolder("/Users/pascal/Desktop").each{|location|
            return location if location.include?(identifier)
        }
        nil
    end

    # Librarian15BecauseReadWrite::utils_getAllTheTx46IdsLocationPairsFromDesktop()
    def self.utils_getAllTheTx46IdsLocationPairsFromDesktop()
        answer = []
        LucilleCore::locationsAtFolder("/Users/pascal/Desktop").each{|location|
            substrings = Librarian15BecauseReadWrite::utils_getAllTheSubstringsOfSize8(File.basename(location))
            substring = substrings.select{|ss| XCache::getOrNull("fa2e7141-f1f2-4d2c-b9e9-f51cf6a0da9b:#{ss}") }.first
            if substring then
                pair = {
                    "identifier" => substring,
                    "location"   => location
                }
                answer << pair
            end
        }
        answer
    end

    # Librarian15BecauseReadWrite::extractTopName(operator, rootnhash)
    def self.extractTopName(operator, rootnhash)
        AionCore::getAionObjectByHash(operator, rootnhash)["name"]
    end

    # Librarian15BecauseReadWrite::utils_rewriteThisAionRootWithNewTopName(operator, rootnhash, name1)
    def self.utils_rewriteThisAionRootWithNewTopName(operator, rootnhash, name1)
        aionObject = AionCore::getAionObjectByHash(operator, rootnhash)
        name2 = aionObject["name"]
        # name1 : name we want
        # name2 : name we have, possibly with an .extension
        if File.extname(name2) then
            aionObject["name"] = "#{name1}#{File.extname(name2)}"
        else
            aionObject["name"] = name1
        end
        blob = JSON.generate(aionObject)
        operator.commitBlob(blob)
    end

    # The purpose of this class is to provide edition of objects that have been exported to the desktop

    # Tx46 {
    #     "identifier" : String # This is the fragment that was used as name for the export folder on the desktop
    #     "itemuuid"   : String # UUID of the main object
    # }   

    # When we export, we generate an identififer, put the Tx46 into XCache and let it be. 
    # If somebody wants to update the object, then depending on the type, they will know what to do

    # Librarian15BecauseReadWrite::issueTx46(item)
    def self.issueTx46(item)
        tx = {
            "identifier" => SecureRandom.hex[0, 8],
            "mikuType"   => "Tx46",
            "itemuuid"   => item["uuid"]
        }
        XCache::set("fa2e7141-f1f2-4d2c-b9e9-f51cf6a0da9b:#{tx["identifier"]}", JSON.generate(tx))
        tx
    end

    # Librarian15BecauseReadWrite::issueTx46ReturnIdentifier(item)
    def self.issueTx46ReturnIdentifier(item)
        Librarian15BecauseReadWrite::issueTx46(item)["identifier"]
    end

    # Librarian15BecauseReadWrite::pickupItem(tx46, item, location)
    def self.pickupItem(tx46, item, location)
        puts "> Librarian15BecauseReadWrite::pickupItem(item, location)"
        puts "item: #{JSON.pretty_generate(item)}"
        puts "location: #{location}"

        if !item["iam"] then
            raise "(error: 4f8aa915-0c22-43a8-99ca-81958ead8fa6) We have an expectation that #{item} would have a 'iam' attribute"
        end

        if item["iam"]["type"] == "aion-point" then
            operator = InfinityElizabeth_DriveWithLocalXCache.new()
            rootnhash1 = AionCore::commitLocationReturnHash(operator, location)
            puts "rootnhash1: #{rootnhash1}"
            rootnhash2 = Librarian15BecauseReadWrite::utils_rewriteThisAionRootWithNewTopName(operator, rootnhash1, item["description"])
            puts "rootnhash2: #{rootnhash2}"
            return if rootnhash1 == rootnhash2
            item["iam"]["rootnhash"] = rootnhash2
            Librarian6ObjectsLocal::commit(item)
            return
        end
        if item["iam"]["type"] == "primitive-file" then
            puts "We are not yet picking up modifications of primitive files (#{location})"
            return
        end
        if item["iam"]["type"] == "carrier-of-primitive-files" then
            # We scan the location and upload any file that wasn't there before

            locations = LucilleCore::locationsAtFolder(location)
            # We make a fiirst pass to ensure everything is a file
            status = locations.all?{|loc| File.file?(loc) }
            if !status then
                puts "The folder has elements that are not files!"
                LucilleCore::pressEnterToContinue()
                return
            end
            locations.each{|filepath|

                # So..... unlike a regular upload, some of the files in there can already be existing 
                # primitive files tht were exported.

                # The nice thing is that primitive files carry their own uuid as Nyx objects.
                # We can use that to know if the location is an existing primitive file and can be ignored

                id = File.basename(filepath)[0, "10202204-1516-1710-9579-87e475258c29".size]
                if Librarian6ObjectsLocal::getObjectByUUIDOrNull(id) then
                    puts "#{File.basename(filepath)} is already a node"
                    # Note that in this case we are not picking up possible modifications of the primitive files
                else
                    puts "#{File.basename(filepath)} is new and needs upload"
                    primitiveFileObject = Nx100s::issuePrimitiveFileFromLocationOrNull(filepath)
                    puts "Primitive file:"
                    puts JSON.pretty_generate(primitiveFileObject)
                    puts "Link: (owner: #{item["uuid"]}, file: #{primitiveFileObject["uuid"]})"
                    Nx60s::issueClaim(item["uuid"], primitiveFileObject["uuid"])

                    puts "Writing #{primitiveFileObject["uuid"]}"
                    dottedExtension = primitiveFileObject["iam"]["dottedExtension"]
                    nhash = primitiveFileObject["iam"]["nhash"]
                    parts = primitiveFileObject["iam"]["parts"]
                    Librarian17PrimitiveFilesAndCarriers::exportPrimitiveFileAtLocation(primitiveFileObject["uuid"], dottedExtension, parts, location)

                    puts "Removing #{filepath}"
                    FileUtils.rm(filepath)
                end
            }

            return
        end
        raise "(error: 68436fbf-745f-4a02-8912-a04279c122c1) I don't know how to pickup #{item["iam"]}"
    end

    # Librarian15BecauseReadWrite::desktopDataPickups()
    def self.desktopDataPickups()
        Librarian15BecauseReadWrite::utils_getAllTheTx46IdsLocationPairsFromDesktop()
            .each{|pair|
                identifier = pair["identifier"]
                location   = pair["location"]
                tx46       = XCache::getOrNull("fa2e7141-f1f2-4d2c-b9e9-f51cf6a0da9b:#{identifier}")
                # We will be asuming that tx46 is not null, otherwise this is too wierd and we deserve to crash
                tx46       = JSON.parse(tx46)
                puts JSON.pretty_generate(tx46)
                itemuuid   = tx46["itemuuid"]
                item       = Librarian6ObjectsLocal::getObjectByUUIDOrNull(itemuuid)
                if item then
                    Librarian15BecauseReadWrite::pickupItem(tx46, item, location)
                else
                    puts "I could not find a nyx node for itemuuid: #{itemuuid}, that is associated with location: #{location}. Is that expected ?"
                    LucilleCore::pressEnterToContinue()
                end
            }
    end

    # Librarian15BecauseReadWrite::pickupInteractiveInterface()
    def self.pickupInteractiveInterface()
        pairs = Librarian15BecauseReadWrite::utils_getAllTheTx46IdsLocationPairsFromDesktop()
        selected, _ = LucilleCore::selectZeroOrMore("pickups", [], pairs, lambda{ |pair| File.basename(pair["location"]) })
        selected.each{|pair|
            identifier = pair["identifier"]
            location   = pair["location"]
            tx46       = XCache::getOrNull("fa2e7141-f1f2-4d2c-b9e9-f51cf6a0da9b:#{identifier}")
            # We will be asuming that tx46 is not null, otherwise this is too wierd and we deserve to crash
            tx46       = JSON.parse(tx46)
            puts JSON.pretty_generate(tx46)
            itemuuid   = tx46["itemuuid"]
            item       = Librarian6ObjectsLocal::getObjectByUUIDOrNull(itemuuid)
            if item then
                Librarian15BecauseReadWrite::pickupItem(tx46, item, location)
                LucilleCore::removeFileSystemLocation(location)
            else
                puts "I could not find a nyx node for itemuuid: #{itemuuid}, that is associated with location: #{location}. Is that expected ?"
                LucilleCore::pressEnterToContinue()
            end
        }
    end
end

class Librarian17PrimitiveFilesAndCarriers

    # Librarian17PrimitiveFilesAndCarriers::readPrimitiveFileOrNull(filepath) # [dottedExtension, nhash, parts]
    def self.readPrimitiveFileOrNull(filepath)
        return nil if !File.exists?(filepath)
        return nil if !File.file?(filepath)
 
        dottedExtension = File.extname(filepath)
 
        nhash = Librarian0Utils::filepathToContentHash(filepath)
 
        lambdaBlobCommitReturnNhash = lambda {|blob|
            InfinityDatablobs_DriveWithLocalXCache::putBlob(blob)
        }
        parts = Librarian0Utils::commitFileToXCacheReturnPartsHashsImproved(filepath, lambdaBlobCommitReturnNhash)
 
        return [dottedExtension, nhash, parts]
    end

    # Librarian17PrimitiveFilesAndCarriers::exportPrimitiveFileAtLocation(someuuid, dottedExtension, parts, location) # targetFilepath
    def self.exportPrimitiveFileAtLocation(someuuid, dottedExtension, parts, location)
        targetFilepath = "#{location}/#{someuuid}#{dottedExtension}"
        File.open(targetFilepath, "w"){|f|  
            parts.each{|nhash|
                blob = InfinityDatablobs_DriveWithLocalXCache::getBlobOrNull(nhash)
                raise "(error: c3e18110-2d9a-42e6-9199-6f8564cf96d2)" if blob.nil?
                f.write(blob)
            }
        }
        targetFilepath
    end

    # Librarian17PrimitiveFilesAndCarriers::carrierContents(owneruuid)
    def self.carrierContents(owneruuid)
        Librarian6ObjectsLocal::getObjectsByMikuType("Nx60")
            .select{|claim| claim["owneruuid"] == owneruuid }
            .map{|claim| claim["targetuuid"] }
            .map{|uuid| Librarian6ObjectsLocal::getObjectByUUIDOrNull(uuid) }
            .compact
    end

    # Librarian17PrimitiveFilesAndCarriers::exportCarrier(item)
    def self.exportCarrier(item)
        tx46Id = Librarian15BecauseReadWrite::issueTx46ReturnIdentifier(item)
        exportFolderpath = "/Users/pascal/Desktop/#{item["description"]} (#{tx46Id})"
        FileUtils.mkdir(exportFolderpath)
        Librarian17PrimitiveFilesAndCarriers::carrierContents(item["uuid"])
            .each{|ix|
                dottedExtension = ix["iam"]["dottedExtension"]
                nhash = ix["iam"]["nhash"]
                parts = ix["iam"]["parts"]
                Librarian17PrimitiveFilesAndCarriers::exportPrimitiveFileAtLocation(ix["uuid"], dottedExtension, parts, exportFolderpath)
            }
    end

    # Librarian17PrimitiveFilesAndCarriers::uploadCarrierOrNothing(uuid)
    def self.uploadCarrierOrNothing(uuid)
        uploadFolder = LucilleCore::askQuestionAnswerAsString("upload folder: ")
        if !File.exists?(uploadFolder) then
            puts "This upload folder does not exists!"
            LucilleCore::pressEnterToContinue()
            return
        end
        locations = LucilleCore::locationsAtFolder(uploadFolder)
        # We make a fiirst pass to ensure everything is a file
        status = locations.all?{|location| File.file?(location) }
        if !status then
            puts "The upload folder has elements that are not files!"
            LucilleCore::pressEnterToContinue()
            return
        end
        locations.each{|filepath|
            primitiveFileObject = Nx100s::issuePrimitiveFileFromLocationOrNull(filepath)
            puts "Primitive file:"
            puts JSON.pretty_generate(primitiveFileObject)
            puts "Link: (owner: #{uuid}, file: #{primitiveFileObject["uuid"]})"
            Nx60s::issueClaim(uuid, primitiveFileObject["uuid"])
        }
        puts "Upload completed"
        LucilleCore::pressEnterToContinue()
    end
end

# ---------------------------------------------------------------------------
# 
# ---------------------------------------------------------------------------

class LibrarianCLI

    # LibrarianCLI::main()
    def self.main()

        if ARGV[0] == "alexandra-sync" then
            AlexandraDidactSynchronization::run()
            exit
        end

        if ARGV[0] == "alexandra-sync+fsck@infinity" then
            AlexandraDidactSynchronization::run()
            InfinityFileSystemCheck::fsckExitAtFirstFailure()
            exit
        end

        if ARGV[0] == "show-object-i" then
            uuid = LucilleCore::askQuestionAnswerAsString("uuid: ")
            object = Librarian6ObjectsLocal::getObjectByUUIDOrNull(uuid)
            if object then
                puts JSON.pretty_generate(object)
                LucilleCore::pressEnterToContinue()
            else
                puts "I could not find an object with this uuid"
                LucilleCore::pressEnterToContinue()
            end
            exit
        end

        if ARGV[0] == "edit-object-i" then
            uuid = LucilleCore::askQuestionAnswerAsString("uuid: ")
            object = Librarian6ObjectsLocal::getObjectByUUIDOrNull(uuid)
            if object then
                puts JSON.pretty_generate(object)
                LucilleCore::pressEnterToContinue()
            else
                puts "I could not find an object with this uuid"
                LucilleCore::pressEnterToContinue()
            end
            exit
        end

        if ARGV[0] == "destroy-object-by-uuid-i" then
            uuid = LucilleCore::askQuestionAnswerAsString("uuid: ")
            Librarian6ObjectsLocal::destroy(uuid)
            exit
        end

        if ARGV[0] == "prob-blob-i" then
            nhash = LucilleCore::askQuestionAnswerAsString("nhash: ")
            blob = InfinityDatablobs_DriveWithLocalXCache::getBlobOrNull(nhash)
            if blob then
                puts "Found a blob of size #{blob.size}"
                LucilleCore::pressEnterToContinue()
            else
                puts "I could not find a blob with nhash: #{nhash}"
                LucilleCore::pressEnterToContinue()
            end
            exit
        end

        if ARGV[0] == "echo-blob-i" then
            nhash = LucilleCore::askQuestionAnswerAsString("nhash: ")
            blob = InfinityDatablobs_DriveWithLocalXCache::getBlobOrNull(nhash)
            if blob then
                puts JSON.pretty_generate(JSON.parse(blob))
                LucilleCore::pressEnterToContinue()
            else
                puts "I could not find a blob with nhash: #{nhash}"
                LucilleCore::pressEnterToContinue()
            end
            exit
        end

        if ARGV[0] == "desktop-aion-export-pickup-i" then
            Librarian15BecauseReadWrite::pickupInteractiveInterface()
            exit
        end

        puts "usage:"
        puts "    librarian alexandra-sync"
        puts "    librarian alexandra-sync+fsck@infinity"
        puts "    librarian show-object-i"
        puts "    librarian edit-object-i"
        puts "    librarian destroy-object-by-uuid-i"
        puts "    librarian prob-blob-i"
        puts "    librarian echo-blob-i"
        puts "    librarian desktop-aion-export-pickup-i"
    end
end


