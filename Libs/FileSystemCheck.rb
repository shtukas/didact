
# encoding: UTF-8

class FileSystemCheck

    # FileSystemCheck::exitIfMissingCanary()
    def self.exitIfMissingCanary()
        if !File.exists?("#{Config::userHomeDirectory()}/Desktop/Pascal.png") then # We use this file to interrupt long runs at a place where it would not corrupt any file system.
            puts "Interrupted after missing canary file.".green
            exit
        end
    end

    # FileSystemCheck::fsckItemErrorArFirstFailure(item, runhash)
    def self.fsckItemErrorArFirstFailure(item, runhash)
        repeatKey = "#{runhash}:#{item}"
        return if XCache::getFlag(repeatKey)

        puts "FileSystemCheck::fsckItemErrorArFirstFailure(#{item}, #{runhash})"

        if item["uuid"].nil? then
            puts JSON.pretty_generate(item)
            puts "Missing attribute: uuid"
            raise "FileSystemCheck::fsckItemErrorArFirstFailure(item, #{runhash})"
        end

        if item["mikuType"].nil? then
            puts JSON.pretty_generate(item)
            puts "Missing attribute: mikuType"
            raise "FileSystemCheck::fsckItemErrorArFirstFailure(item, #{runhash})"
        end

        if item["unixtime"].nil? then
            puts JSON.pretty_generate(item)
            puts "Missing attribute: unixtime"
            raise "FileSystemCheck::fsckItemErrorArFirstFailure(item, #{runhash})"
        end

        if item["datetime"].nil? then
            puts JSON.pretty_generate(item)
            puts "Missing attribute: datetime"
            if LucilleCore::askQuestionAnswerAsBoolean("Should I add it now ? ", true) then
                DxF1::setAttribute2(item["uuid"], "datetime", CommonUtils::now_iso8601())
                return FileSystemCheck::fsckObjectuuidErrorAtFirstFailure(item["uuid"], SecureRandom.hex)
            end
            raise "FileSystemCheck::fsckItemErrorArFirstFailure(item, #{runhash})"
        end

        ensureAttribute = lambda {|attname|
            return if item[attname]
            puts JSON.pretty_generate(item)
            puts "Missing attribute: #{attname}"
            raise "FileSystemCheck::fsckItemErrorArFirstFailure(item, #{runhash})"
        }

        ensureItemFileExists = lambda {|itemuuid|
            filepath = DxF1::filepathIfExistsOrNullNoSideEffect(itemuuid)
            if filepath.nil? then
                puts "DxF1::filepathIfExistsOrNullNoSideEffect(#{itemuuid})"
                puts "Missing file for itemuuid (v1): #{itemuuid}"
                raise "FileSystemCheck::fsckItemErrorArFirstFailure(item, #{runhash})"
            end
            if !File.exists?(filepath) then
                puts "DxF1::filepathIfExistsOrNullNoSideEffect(#{itemuuid})"
                puts "Missing file for itemuuid (v2): #{itemuuid}"
                raise "FileSystemCheck::fsckItemErrorArFirstFailure(item, #{runhash})"
            end
        }

        mikuType = item["mikuType"]

        if mikuType == "CxAionPoint" then
            ensureAttribute.call("owneruuid")
            ensureAttribute.call("rootnhash")
            operator  = DxF1ElizabethFsck.new(item["uuid"])
            rootnhash = item["rootnhash"]
            status    = AionFsck::structureCheckAionHash(operator, rootnhash)
            if !status then
                puts JSON.pretty_generate(item)
                raise "(error: 50daf867-0dab-47d9-ae79-d8e431650eab) aion structure fsck failed "
            end
        end

        if mikuType == "CxDx8Unit" then
            ensureAttribute.call("owneruuid")
            ensureAttribute.call("unitId")
        end

        if mikuType == "CxFile" then
            ensureAttribute.call("owneruuid")
            ensureAttribute.call("dottedExtension")
            ensureAttribute.call("nhash")
            ensureAttribute.call("parts")
            operator = DxF1ElizabethFsck.new(item["uuid"])
            dottedExtension = item["dottedExtension"]
            nhash = item["nhash"]
            parts = item["parts"]
            status = PrimitiveFiles::fsckPrimitiveFileDataRaiseAtFirstError(operator, dottedExtension, nhash, parts)
            if !status then
                puts JSON.pretty_generate(item)
                raise "(error: 3e428541-805b-455e-b6a2-c400a6519aef) primitive file fsck failed "
            end
        end

        if mikuType == "CxText" then
            ensureAttribute.call("owneruuid")
            ensureAttribute.call("text")
        end

        if mikuType == "CxUniqueString" then
            ensureAttribute.call("owneruuid")
            ensureAttribute.call("uniquestring")
        end

        if mikuType == "CxUrl" then
            ensureAttribute.call("owneruuid")
            ensureAttribute.call("url")
        end

        if mikuType == "DxAionPoint" then
            ensureAttribute.call("rootnhash")
            operator  = DxF1ElizabethFsck.new(item["uuid"])
            rootnhash = item["rootnhash"]
            status    = AionFsck::structureCheckAionHash(operator, rootnhash)
            if !status then
                puts JSON.pretty_generate(item)
                raise "(error: eca3b221-df0f-473d-9367-f2d12353266c) aion structure fsck failed "
            end
        end

        if mikuType == "DxFile" then
            ensureAttribute.call("dottedExtension")
            ensureAttribute.call("nhash")
            ensureAttribute.call("parts")
            operator = DxF1ElizabethFsck.new(item["uuid"])
            dottedExtension = item["dottedExtension"]
            nhash = item["nhash"]
            parts = item["parts"]
            status = PrimitiveFiles::fsckPrimitiveFileDataRaiseAtFirstError(operator, dottedExtension, nhash, parts)
            if !status then
                puts JSON.pretty_generate(item)
                raise "(error: eb78a1da-f7be-490d-94f7-2974d1af4c2f) primitive file fsck failed "
            end
        end

        if mikuType == "DxLine" then
            ensureAttribute.call("line")
        end

        if mikuType == "DxText" then
            ensureAttribute.call("description")
            ensureAttribute.call("text")
        end

        if mikuType == "DxUniqueString" then
            ensureAttribute.call("uniquestring")
        end

        if mikuType == "DxUrl" then
            ensureAttribute.call("url")
        end

        if mikuType == "NxAnniversary" then
            ensureAttribute.call("description")
            ensureAttribute.call("startdate")
            ensureAttribute.call("repeatType")
            ensureAttribute.call("lastCelebrationDate")
        end

        if mikuType == "NxEvent" then
            ensureAttribute.call("description")
            # ensureAttribute.call("nx112") # optional
            if item["nx112"] then
                ensureItemFileExists.call(item["nx112"])
            end
        end

        if mikuType == "NxCollection" then
            ensureAttribute.call("description")
        end

        if mikuType == "NxConcept" then
            ensureAttribute.call("description")
        end

        if mikuType == "NxEntity" then
            ensureAttribute.call("description")
        end

        if mikuType == "NxPerson" then
            ensureAttribute.call("name")
        end

        if mikuType == "NxTask" then
            ensureAttribute.call("description")
            # ensureAttribute.call("nx112") # optional
            if item["nx112"] then
                ensureItemFileExists.call(item["nx112"])
            end
        end

        if mikuType == "NxTimeline" then
            ensureAttribute.call("description")
        end

        if mikuType == "TxDated" then
            ensureAttribute.call("description")
            # ensureAttribute.call("nx112") # optional
            if item["nx112"] then
                ensureItemFileExists.call(item["nx112"])
            end
        end

        if mikuType == "TxTimeCommitment" then
            ensureAttribute.call("ax39")
        end

        if mikuType == "Wave" then
            ensureAttribute.call("description")
            ensureAttribute.call("nx46")
            ensureAttribute.call("lastDoneDateTime")
        end

        XCache::setFlag(repeatKey, true)
    end

    # FileSystemCheck::fsckObjectuuidErrorAtFirstFailure(objectuuid, runhash)
    def self.fsckObjectuuidErrorAtFirstFailure(objectuuid, runhash)
        filepath = DxF1::filepathIfExistsOrNullNoSideEffect(objectuuid)
        return if filepath.nil?

        repeatKey = "e5efa6c6-f950-4a29-b15f-aa25ba4c0d5e:#{filepath}:#{runhash}:#{File.mtime(filepath)}"
        return if XCache::getFlag(repeatKey)

        puts "FileSystemCheck::fsckObjectuuidErrorAtFirstFailure(#{objectuuid}, #{runhash})"

        filepath = DxF1::filepathIfExistsOrNullNoSideEffect(objectuuid)

        if filepath.nil? then
            puts JSON.pretty_generate(item)
            puts "Could not find item filepath on the disk: #{filepath}"
            raise "FileSystemCheck::fsckObjectuuidErrorAtFirstFailure(#{objectuuid}, #{runhash})"
        end

        item = DxF1::getProtoItemAtFilepathOrNull(filepath)

        if item.nil? then
            puts JSON.pretty_generate(item)
            puts "Could not recover item from the disk #{filepath}"
            raise "FileSystemCheck::fsckObjectuuidErrorAtFirstFailure(#{objectuuid}, #{runhash})"
        end

        FileSystemCheck::fsckItemErrorArFirstFailure(item, runhash)
        XCache::setFlag(repeatKey, true)
    end

    # FileSystemCheck::fsckDxF1FilepathErrorAtFirstFailure(filepath, runhash)
    def self.fsckDxF1FilepathErrorAtFirstFailure(filepath, runhash)
        repeatKey = "0dfca14a-252b-45fc-bd80-95179ad4ac6e:#{filepath}:#{runhash}:#{File.mtime(filepath)}"
        return if XCache::getFlag(repeatKey)
        puts "FileSystemCheck::fsckDxF1FilepathErrorAtFirstFailure(#{filepath}, #{runhash})"
        item = DxF1::getProtoItemAtFilepathOrNull(filepath)
        if item.nil? then
            puts "FileSystemCheck::fsckDxF1FilepathErrorAtFirstFailure(#{filepath}, #{runhash}), item was nil"
            puts "sql dump:"
            system("sqlite3 '#{filepath}' .dump")
            if LucilleCore::askQuestionAnswerAsBoolean("delete file ? ") then
                FileUtils.rm(filepath)
                return
            else
                puts "exiting"
                exit
            end
        end
        FileSystemCheck::fsckItemErrorArFirstFailure(item, runhash)
        XCache::setFlag(repeatKey, true)
    end

    # FileSystemCheck::fsckErrorAtFirstFailure(runhash)
    def self.fsckErrorAtFirstFailure(runhash)
        Find.find("#{ENV['HOME']}/Galaxy/DataBank/Stargate/DxF1s") do |path|
            FileSystemCheck::exitIfMissingCanary()
            next if File.basename(path)[-8, 8] != ".sqlite3"
            FileSystemCheck::fsckDxF1FilepathErrorAtFirstFailure(path, runhash)
        end
        puts "fsck completed successfully".green
    end
end
