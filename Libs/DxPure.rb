
# encoding: UTF-8

class DxPureElizabeth

    def initialize(filepath)
        if !File.exists?(filepath) then
            raise "(error: 954c1f8d-bba8-4e5c-bd2f-0bed8406ec14)"
        end
        @filepath = filepath
    end

    def putBlob(blob)
        nhash = "SHA256-#{Digest::SHA256.hexdigest(blob)}"
        DxPure::insertIntoPure(@filepath, nhash, blob)
        nhash
    end

    def filepathToContentHash(filepath)
        "SHA256-#{Digest::SHA256.file(filepath).hexdigest}"
    end

    def getBlobOrNull(nhash)
        DxPure::readValueOrNull(@filepath, nhash)
    end

    def readBlobErrorIfNotFound(nhash)
        blob = getBlobOrNull(nhash)
        return blob if blob
        puts "(error: c93d866c-a09d-4d0c-a729-aa19014f9913) could not find blob, nhash: #{nhash}"
        raise "(error: d5f371f6-178d-4173-9421-9fa5f29c5f62, nhash: #{nhash})" if blob.nil?
    end

    def datablobCheck(nhash)
        begin
            blob = readBlobErrorIfNotFound(nhash)
            status = ("SHA256-#{Digest::SHA256.hexdigest(blob)}" == nhash)
            if !status then
                puts "(error: a9bfcd31-c4ef-4588-8c5b-9f04ac2255a8) incorrect blob, exists but doesn't have the right nhash: #{nhash}"
            end
            return status
        rescue
            false
        end
    end
end

class DxPureElizabethFsck1_Migration

    def initialize(filepath)
        if !File.exists?(filepath) then
            raise "(error: 954c1f8d-bba8-4e5c-bd2f-0bed8406ec14)"
        end
        @filepath = filepath
    end

    def putBlob(blob)
        nhash = "SHA256-#{Digest::SHA256.hexdigest(blob)}"
        DxPure::insertIntoPure(@filepath, nhash, blob)
        nhash
    end

    def filepathToContentHash(filepath)
        "SHA256-#{Digest::SHA256.file(filepath).hexdigest}"
    end

    def getBlobOrNull(nhash)
        blob = DxPure::readValueOrNull(@filepath, nhash)
        if blob then
            return blob
        end

        blob = ExData::getBlobOrNull(nhash)
        if blob then
            putBlob(blob)
            return blob
        end

        nil
    end

    def readBlobErrorIfNotFound(nhash)
        blob = getBlobOrNull(nhash)
        return blob if blob
        puts "(error: 76169e64-9c86-4b17-ae10-30f6b72f2f72) could not find blob, nhash: #{nhash}"
        raise "(error: 185c1263-b427-4409-9970-2902f0ade5d3, nhash: #{nhash})" if blob.nil?
    end

    def datablobCheck(nhash)
        begin
            blob = readBlobErrorIfNotFound(nhash)
            status = ("SHA256-#{Digest::SHA256.hexdigest(blob)}" == nhash)
            if !status then
                puts "(error: ff6d6934-a139-43f0-93ff-14123ba364a6) incorrect blob, exists but doesn't have the right nhash: #{nhash}"
            end
            return status
        rescue
            false
        end
    end
end

class DxPure

    # ------------------------------------------------------------
    # Basic IO (1)

    # DxPure::makeNewPureFile(filepath)
    def self.makeNewPureFile(filepath)
        db = SQLite3::Database.new(filepath)
        db.busy_timeout = 117
        db.busy_handler { |count| true }
        db.results_as_hash = true
        db.execute("create table _dx_ (_key_ text primary key, _value_ blob)", [])
        db.close
    end

    # DxPure::insertIntoPure(filepath, key, value)
    def self.insertIntoPure(filepath, key, value)
        db = SQLite3::Database.new(filepath)
        db.busy_timeout = 117
        db.busy_handler { |count| true }
        db.results_as_hash = true
        db.execute("delete from _dx_ where _key_=?", [key])
        db.execute("insert into _dx_ (_key_, _value_) values (?, ?)", [key, value])
        db.close
    end

    # DxPure::readValueOrNull(filepath, key)
    def self.readValueOrNull(filepath, key)
        db = SQLite3::Database.new(filepath)
        db.busy_timeout = 117
        db.busy_handler { |count| true }
        db.results_as_hash = true
        value = nil
        db.execute("select _value_ from _dx_ where _key_=?", [key]) do |row|
            value = row["_value_"]
        end
        db.close
        value
    end

    # DxPure::getMikuType(filepath)
    def self.getMikuType(filepath)
        # We are working with the assumption that we can't fail the look up of a mikutype from the file itself
        mikuType = DxPure::readValueOrNull(filepath, "mikuType")
        if mikuType.nil? then
            raise "(error: c0fb51dc-13d3-4abe-a628-06e0daa02d38) could not extract mikuType from file #{filepath}"
        end
        mikuType
    end

    # ------------------------------------------------------------
    # Basic IO (2)

    # DxPure::sha1ToLocalFilepath(sha1)
    def self.sha1ToLocalFilepath(sha1)
        filepath = "#{Config::pathToLocalDataBankStargate()}/DxPure/#{sha1[0, 2]}/#{sha1}.sqlite3"
        if !File.exists?(File.dirname(filepath)) then
            FileUtils.mkdir(File.dirname(filepath))
        end
        filepath
    end

    # DxPure::sha1ToEnergyGrid1Filepath(sha1)
    def self.sha1ToEnergyGrid1Filepath(sha1)
        filepath = "#{StargateCentral::pathToCentral()}/DxPure/#{sha1[0, 2]}/#{sha1}.sqlite3"
        if !File.exists?(File.dirname(filepath)) then
            FileUtils.mkdir(File.dirname(filepath))
        end
        filepath
    end


    # ------------------------------------------------------------
    # Basic Utils

    # DxPure::getMikuTypeOrNull(sha1)
    def self.getMikuTypeOrNull(sha1)
        filepath = DxPure::sha1ToLocalFilepath(sha1)
        return nil if !File.exists?(filepath)
        DxPure::getMikuType(filepath)
    end

    # ------------------------------------------------------------
    # Issues

    # DxPure::dxPureTypes()
    def self.dxPureTypes()
        ["aion-point"]
    end

    # DxPure::issueDxPureAionPoint(owner, location)
    def self.issueDxPureAionPoint(owner, location)
        if !File.exists?(location) then
            raise "(error: b0824d0c-f8bd-4312-a550-f2752d49b3db) location: #{location}"
        end

        randomValue  = SecureRandom.hex
        mikuType     = "DxPureAionPoint"
        unixtime     = Time.new.to_i
        datetime     = Time.new.utc.iso8601
        # owner
        # location

        filepath1 = "/tmp/#{SecureRandom.hex}.sqlite3"
        DxPure::makeNewPureFile(filepath1)

        operator = DxPureElizabeth.new(filepath1)
        rootnhash = AionCore::commitLocationReturnHash(operator, location)

        DxPure::insertIntoPure(filepath1, "randomValue", randomValue)
        DxPure::insertIntoPure(filepath1, "mikuType", mikuType)
        DxPure::insertIntoPure(filepath1, "unixtime", unixtime)
        DxPure::insertIntoPure(filepath1, "datetime", datetime)
        DxPure::insertIntoPure(filepath1, "owner", owner)
        DxPure::insertIntoPure(filepath1, "rootnhash", rootnhash)

        DxPure::fsckFileRaiseError(filepath1)

        sha1 = Digest::SHA1.file(filepath1).hexdigest

        filepath2 = DxPure::sha1ToLocalFilepath(sha1)

        FileUtils.mv(filepath1, filepath2)

        sha1
    end

    # DxPure::interactivelyIssueNewOrNull(owner) # null or sha1
    def self.interactivelyIssueNewOrNull(owner)
        type = LucilleCore::selectEntityFromListOfEntitiesOrNull("DxPure type", DxPure::dxPureTypes())
        return nil if type.nil?
        if type == "aion-point" then
            location = CommonUtils::interactivelySelectDesktopLocationOrNull()
            return nil if location.nil?
            return DxPure::issueDxPureAionPoint(owner, location)
        end
        raise "(error: af59a943-db42-4190-a79e-d313aafc4165) type: #{type}" 
    end

    # ------------------------------------------------------------
    # Data

    # DxPure::toString(sha1)
    def self.toString(sha1)
        filepath = DxPure::sha1ToLocalFilepath(sha1)
        if !File.exists?(filepath) then
            return "(error: I cannot see the file #{filepath} for DxPure::toString(#{sha1}))"
        end
        mikuType = DxPure::getMikuType(filepath)
        if mikuType == "DxPureAionPoint" then
            return "(DxPure: aion-point) #{File.basename(filepath)}"
        end
        raise "(error: 00809174-4b82-4138-8810-20be99eb1219) DxPure toString: unsupported mikuType: #{mikuType}"
    end

    # ------------------------------------------------------------
    # Operations

    # DxPure::access(sha1)
    def self.access(sha1)
        filepath = DxPure::sha1ToLocalFilepath(sha1)
        if !File.exists?(filepath) then
            puts "I cannot see the file #{filepath}. Operation access aborted."
            LucilleCore::pressEnterToContinue()
            return
        end
        mikuType = DxPure::getMikuType(filepath)
        if mikuType == "DxPureAionPoint" then
            puts "(82bdb0e4-7747-445c-bd2b-dbe97affdbab) DxPure::access, DxPureAionPoint, not implemented yet"
            exit
            return 
        end
        raise "(error: 9a06ba98-9ec5-4dd5-94c8-1a87dd566506) DxPure access: unsupported mikuType: #{mikuType}"
    end

    # ------------------------------------------------------------
    # Fsck

    # DxPure::fsckFileRaiseError(filepath)
    def self.fsckFileRaiseError(filepath)
        mikuType = DxPure::getMikuType(filepath)

        ensureAttributeExists = lambda {|filepath, attrname|
            if DxPure::readValueOrNull(filepath, attrname).nil? then
                raise "(error: 5d636d7d-0a9c-4ef9-8abc-0992c99dafde) filepath: #{filepath}, attrname: #{attrname}"
            end
        }

        if mikuType == "DxPureAionPoint" then
            ensureAttributeExists.call(filepath, "randomValue")
            ensureAttributeExists.call(filepath, "mikuType")
            ensureAttributeExists.call(filepath, "unixtime")
            ensureAttributeExists.call(filepath, "datetime")
            ensureAttributeExists.call(filepath, "owner")
            ensureAttributeExists.call(filepath, "rootnhash")
            return
        end

        raise "(error: fa74feac-37c6-4525-93ba-933f52d54321) DxPure fsck: unsupported mikuType: #{mikuType}"
    end

    # ------------------------------------------------------------
    # Collection Management

    # DxPure::localFilepathsEnumerator()
    def self.localFilepathsEnumerator()
        Enumerator.new do |filepaths|
            Find.find("#{Config::pathToLocalDataBankStargate()}/DxPure") do |path|
                next if path[-8, 8] != ".sqlite3"
                filepaths << path
            end
        end
    end
end
