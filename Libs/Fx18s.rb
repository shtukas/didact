class Fx18s

    # Fx18s::makeNewFx18File(filepath)
    def self.makeNewFx18File(filepath)
        puts "Initiate Fx18: #{filepath}"
        folderpath = File.dirname(filepath)
        if !File.exists?(folderpath) then
            FileUtils.mkdir(folderpath)
        end
        db = SQLite3::Database.new(filepath)
        db.busy_timeout = 117
        db.busy_handler { |count| true }
        db.results_as_hash = true
        db.execute("create table _fx18_ (_objectuuid_ text, _eventuuid_ text primary key, _eventTime_ float, _eventData1_ blob, _eventData2_ blob, _eventData3_ blob, _eventData4_ blob, _eventData5_ blob)", [])
        db.close
    end

    # ------------------------------------------------------
    # Pure functions computing the filepaths

    # Fx18s::objectuuidToLocalFx18Filepath(objectuuid)
    def self.objectuuidToLocalFx18Filepath(objectuuid)
        sha1 = Digest::SHA1.hexdigest(objectuuid)
        "#{Config::pathToLocalDataBankStargate()}/Fx18s/#{sha1[0, 2]}/#{sha1}.sqlite3"
    end

    # Fx18s::objectuuidToEnergyGridFx18Filepath(objectuuid)
    def self.objectuuidToEnergyGridFx18Filepath(objectuuid)
        sha1 = Digest::SHA1.hexdigest(objectuuid)
        "#{StargateCentral::pathToCentral()}/Fx18s/#{sha1[0, 2]}/#{sha1}.sqlite3"
    end

    # ------------------------------------------------------
    # Making files given objectuuids

    # Fx18s::makeNewLocalFx18FileForObjectuuid(objectuuid)
    def self.makeNewLocalFx18FileForObjectuuid(objectuuid)
        filepath = Fx18s::objectuuidToLocalFx18Filepath(objectuuid)
        Fx18s::makeNewFx18File(filepath)
    end

    # ------------------------------------------------------
    # Get existing local files with error if not present, or ensure remote (sync)

    # Fx18s::getExistingLocalFx18FilepathForObjectuuid(objectuuid)
    def self.getExistingLocalFx18FilepathForObjectuuid(objectuuid)
        filepath = Fx18s::objectuuidToLocalFx18Filepath(objectuuid)
        if !File.exists?(filepath) then
            raise "(error: 7a6f4737-5030-4653-bf59-09f6d301b471) filepath: #{filepath}"
        end
        filepath
    end

    # Fx18s::ensureLocalFx18FilepathForObjectuuid(objectuuid)
    def self.ensureLocalFx18FilepathForObjectuuid(objectuuid)
        filepath = Fx18s::objectuuidToLocalFx18Filepath(objectuuid)
        if !File.exists?(filepath) then
            Fx18s::makeNewFx18File(filepath)
        end
        filepath
    end

    # Fx18s::ensureEnergyGridFx18FilepathForObjectuuid(objectuuid)
    def self.ensureEnergyGridFx18FilepathForObjectuuid(objectuuid)
        filepath = Fx18s::objectuuidToEnergyGridFx18Filepath(objectuuid)
        if !File.exists?(filepath) then
            Fx18s::makeNewFx18File(filepath)
        end
        filepath
    end

    # ------------------------------------------------------

    # Fx18s::commit(objectuuid, eventuuid, eventTime, eventData1, eventData2, eventData3, eventData4, eventData5)
    def self.commit(objectuuid, eventuuid, eventTime, eventData1, eventData2, eventData3, eventData4, eventData5)
        if objectuuid.nil? then
            raise "(error: a3202192-2d16-4f82-80e9-a86a18d407c8)"
        end
        if eventuuid.nil? then
            raise "(error: 1025633f-b0aa-42ed-9751-b5f87af23450)"
        end
        if eventTime.nil? then
            raise "(error: 9a6caf6b-fa31-4fda-b963-f0c04f4e50a2)"
        end
        db = SQLite3::Database.new(Fx18s::getExistingLocalFx18FilepathForObjectuuid(objectuuid))
        db.busy_timeout = 117
        db.busy_handler { |count| true }
        db.execute "delete from _fx18_ where _eventuuid_=?", [eventuuid]
        db.execute "insert into _fx18_ (_objectuuid_, _eventuuid_, _eventTime_, _eventData1_, _eventData2_, _eventData3_, _eventData4_, _eventData5_) values (?, ?, ?, ?, ?, ?, ?, ?)", [objectuuid, eventuuid, eventTime, eventData1, eventData2, eventData3, eventData4, eventData5]
        db.close
    end

    # Fx18s::deleteObjectLogicallyNoEvents(objectuuid)
    def self.deleteObjectLogicallyNoEvents(objectuuid)
        Fx18Attributes::setJsonEncodeUpdate(objectuuid, "isAlive", false)
    end

    # Fx18s::deleteObjectLogically(objectuuid)
    def self.deleteObjectLogically(objectuuid)
        Fx18s::deleteObjectLogicallyNoEvents(objectuuid)
        SystemEvents::broadcast({
            "mikuType"   => "NxDeleted",
            "objectuuid" => objectuuid,
        })
        SystemEvents::processEventInternally({
            "mikuType"   => "(object has been logically deleted)",
            "objectuuid" => objectuuid,
        })
    end

    # Fx18s::objectIsAlive(objectuuid)
    def self.objectIsAlive(objectuuid)
        value = Fx18Attributes::getJsonDecodeOrNull(objectuuid, "isAlive")
        return true if value.nil?
        value
    end

    # Fx18s::getItemOrNull(objectuuid)
    def self.getItemOrNull(objectuuid)
        filepath = Fx18s::objectuuidToLocalFx18Filepath(objectuuid)
        return nil if !File.exists?(filepath)
        item = {}
        db = SQLite3::Database.new(filepath)
        db.busy_timeout = 117
        db.busy_handler { |count| true }
        db.results_as_hash = true
        objectuuids = []
        db.execute("select * from _fx18_ where _objectuuid_=? order by _eventTime_", [objectuuid]) do |row|
            attrname = row["_eventData2_"]
            attvalue = JSON.parse(row["_eventData3_"])
            item[attrname] = attvalue
        end
        db.close
        item
    end

    # Fx18s::getAliveItemOrNull(objectuuid)
    def self.getAliveItemOrNull(objectuuid)
        item = Fx18s::getItemOrNull(objectuuid)
        return nil if item.nil?
        return nil if (!item["isAlive"].nil? and !item["isAlive"]) # Object is logically deleted
        item
    end

    # Fx18s::broadcastObjectEvents(objectuuid)
    def self.broadcastObjectEvents(objectuuid)
        item = {}
        db = SQLite3::Database.new(Fx18s::getExistingLocalFx18FilepathForObjectuuid(objectuuid))
        db.busy_timeout = 117
        db.busy_handler { |count| true }
        db.results_as_hash = true
        objectuuids = []
        db.execute("select * from _fx18_ order by _eventTime_", []) do |row|
            SystemEvents::broadcast({
                "mikuType"      => "Fx18 File Event",
                "Fx18FileEvent" => row
            })
        end
        db.close
    end

    # Fx18s::getFileRows(filepath)
    def self.getFileRows(filepath)
        db = SQLite3::Database.new(filepath)
        db.busy_timeout = 117
        db.busy_handler { |count| true }
        db.results_as_hash = true
        rows = []
        db.execute("select * from _fx18_ order by _eventTime_", []) do |row|
            rows << row.clone
        end
        db.close
        rows
    end

    # Fx18s::getAllRowsFromAllFiles()
    def self.getAllRowsFromAllFiles()
        Fx18s::localFx18sFilepathsEnumerator()
            .map{|filepath| Fx18s::getFileRows(filepath)}
            .flatten
    end

    # Fx18s::localFx18sFilepathsEnumerator()
    def self.localFx18sFilepathsEnumerator()
        Enumerator.new do |filepaths|
            Find.find("#{Config::pathToLocalDataBankStargate()}/Fx18s") do |path|
                next if path[-8, 8] != ".sqlite3"
                filepaths << path
            end
        end
    end

    # Fx18s::energyGrid1Fx18sFilepathsEnumerator()
    def self.energyGrid1Fx18sFilepathsEnumerator()
        Enumerator.new do |filepaths|
            Find.find("#{StargateCentral::pathToCentral()}/Fx18s") do |path|
                next if path[-8, 8] != ".sqlite3"
                filepaths << path
            end
        end
    end

    # Fx18s::objectuuidsUsingLocalFx18FileEnumerationIncludeLogicallyDeleted()
    def self.objectuuidsUsingLocalFx18FileEnumerationIncludeLogicallyDeleted()
        Enumerator.new do |objectuuids|
            Fx18s::localFx18sFilepathsEnumerator().each{|filepath|
                objectuuid = Fx18Attributes::getJsonDecodeOrNullUsingFilepath(filepath, "uuid")
                if objectuuid.nil? then
                    puts "(error: 03a7834f-5882-4519-9a29-3a40092e6eae) I could not determine uuid for file: #{filepath}"
                    puts "Exit."
                    exit
                end
                objectuuids << objectuuid
            }
        end
    end

    # Fx18s::processEventInternally(event)
    def self.processEventInternally(event)
        if event["mikuType"] == "Fx18 File Event" then
            eventi = event["Fx18FileEvent"]
            objectuuid = eventi["_objectuuid_"]
            return if !File.exists?(Fx18s::objectuuidToLocalFx18Filepath(objectuuid))
            Fx18s::commit(eventi["_objectuuid_"], eventi["_eventuuid_"], eventi["_eventTime_"], eventi["_eventData1_"], eventi["_eventData2_"], eventi["_eventData3_"], eventi["_eventData4_"], eventi["_eventData5_"])
            Lookup1::reconstructEntry(eventi["_objectuuid_"])
            return
        end
        if event["mikuType"] == "Fx18s-allFiles-allRows" then
            event["records"].each{|row|
                Fx18s::ensureLocalFx18FilepathForObjectuuid(row["_objectuuid_"])
                Fx18s::commit(row["_objectuuid_"], row["_eventuuid_"], row["_eventTime_"], row["_eventData1_"], row["_eventData2_"], row["_eventData3_"], row["_eventData4_"], row["_eventData5_"])
            }
            Stargate::resetCachePrefix()
        end
    end
end

class Fx18Attributes

    # Fx18Attributes::set1(objectuuid, eventuuid, eventTime, attname, attvalue)
    def self.set1(objectuuid, eventuuid, eventTime, attname, attvalue)
        puts "Fx18Attributes::set1(#{objectuuid}, #{eventuuid}, #{eventTime}, #{attname}, #{attvalue})"
        Fx18s::commit(objectuuid, eventuuid, eventTime, "attribute", attname, JSON.generate(attvalue), nil, nil)
    end

    # Fx18Attributes::setJsonEncodeObjectMaking(objectuuid, attname, attvalue)
    def self.setJsonEncodeObjectMaking(objectuuid, attname, attvalue)
        Fx18Attributes::set1(objectuuid, SecureRandom.uuid, Time.new.to_f, attname, attvalue)
    end

    # Fx18Attributes::setJsonEncodeUpdate(objectuuid, attname, attvalue)
    def self.setJsonEncodeUpdate(objectuuid, attname, attvalue)
        Fx18Attributes::set1(objectuuid, SecureRandom.uuid, Time.new.to_f, attname, attvalue)
        SystemEvents::processEventInternally({
            "mikuType"   => "(object has been updated)",
            "objectuuid" => objectuuid,
        })
    end

    # Fx18Attributes::getJsonDecodeOrNull(objectuuid, attname)
    def self.getJsonDecodeOrNull(objectuuid, attname)
        db = SQLite3::Database.new(Fx18s::getExistingLocalFx18FilepathForObjectuuid(objectuuid))
        db.busy_timeout = 117
        db.busy_handler { |count| true }
        db.results_as_hash = true
        attvalue = nil
        # It is of crutial importance that we `order by _eventTime_` to return the current (latest) value
        db.execute("select * from _fx18_ where _objectuuid_=? and _eventData1_=? and _eventData2_=? order by _eventTime_", [objectuuid, "attribute", attname]) do |row|
            attvalue = JSON.parse(row["_eventData3_"])
        end
        db.close
        attvalue
    end

    # Fx18Attributes::getJsonDecodeOrNullUsingFilepath(filepath, attname)
    def self.getJsonDecodeOrNullUsingFilepath(filepath, attname)
        db = SQLite3::Database.new(filepath)
        db.busy_timeout = 117
        db.busy_handler { |count| true }
        db.results_as_hash = true
        attvalue = nil
        # It is of crutial importance that we `order by _eventTime_` to return the current (latest) value
        db.execute("select * from _fx18_ where _eventData1_=? and _eventData2_=? order by _eventTime_", ["attribute", attname]) do |row|
            attvalue = JSON.parse(row["_eventData3_"])
        end
        db.close
        attvalue
    end
end

class Fx18sSynchronisation

    # Fx18sSynchronisation::getEventuuids(filepath)
    def self.getEventuuids(filepath)
        db = SQLite3::Database.new(filepath)
        db.busy_timeout = 117
        db.busy_handler { |count| true }
        db.results_as_hash = true
        uuids = []
        db.execute("select _eventuuid_ from _fx18_", []) do |row|
            uuids << row["_eventuuid_"]
        end
        db.close
        uuids
    end

    # Fx18sSynchronisation::getRecordOrNull(filepath, eventuuid)
    def self.getRecordOrNull(filepath, eventuuid)
        db = SQLite3::Database.new(filepath)
        db.busy_timeout = 117
        db.busy_handler { |count| true }
        db.results_as_hash = true
        record = nil
        db.execute("select * from _fx18_ where _eventuuid_=?", [eventuuid]) do |row|
            record = row
        end
        db.close
        record
    end

    # Fx18sSynchronisation::putRecord(filepath, record)
    def self.putRecord(filepath, record)
        db = SQLite3::Database.new(filepath)
        db.busy_timeout = 117
        db.busy_handler { |count| true }
        db.execute "delete from _fx18_ where _eventuuid_=?", [record["_eventuuid_"]]
        db.execute "insert into _fx18_ (_objectuuid_, _eventuuid_, _eventTime_, _eventData1_, _eventData2_, _eventData3_, _eventData4_, _eventData5_) values (?, ?, ?, ?, ?, ?, ?, ?)", [record["_objectuuid_"], record["_eventuuid_"], record["_eventTime_"], record["_eventData1_"], record["_eventData2_"], record["_eventData3_"], record["_eventData4_"], record["_eventData5_"]]
        db.close
    end

    # Fx18sSynchronisation::propagateFileData(filepath1, filepath2)
    def self.propagateFileData(filepath1, filepath2)
        raise "(error: d5e6f2d3-9eab-484a-bde8-d7e6d479b04f)" if !File.exists?(filepath1)
        raise "(error: 5d24c60a-db47-4643-a618-bb2057daafd2)" if !File.exists?(filepath2)

        eventuuids1 = Fx18sSynchronisation::getEventuuids(filepath1)
        eventuuids2 = Fx18sSynchronisation::getEventuuids(filepath2)

        (eventuuids1 - eventuuids2).each{|eventuuid|

            record1 = Fx18sSynchronisation::getRecordOrNull(filepath1, eventuuid)
            if record1.nil? then
                puts "filepath1: #{filepath1}"
                puts "filepath2: #{filepath2}"
                puts "eventuuid: #{eventuuid}"
                raise "(error: e0f0d25c-48da-44b2-8304-832c3aa14421)"
            end

            objectuuid = record1["_objectuuid_"]

            puts "Fx18sSynchronisation::propagateFileData, filepath1: #{filepath1}, objectuuid: #{record1["_objectuuid_"]}, eventuuid: #{eventuuid}"

            Fx18sSynchronisation::putRecord(filepath2, record1)

            # Checks
            record2 = Fx18sSynchronisation::getRecordOrNull(filepath2, eventuuid)
            if record2.nil? then
                puts "filepath1: #{filepath1}"
                puts "filepath2: #{filepath2}"
                puts "eventuuid: #{eventuuid}"
                raise "(error: 9ad32d45-bbe4-4121-ab08-ff60a644ece4)"
            end
            [
                "_objectuuid_", 
                "_eventuuid_", 
                "_eventTime_", 
                "_eventData1_",
                "_eventData2_",
                "_eventData3_",
                "_eventData4_",
                "_eventData5_"
            ].each{|key|
                if record1[key] != record2[key] then
                    puts "filepath1: #{filepath1}"
                    puts "filepath2: #{filepath2}"
                    puts "eventuuid: #{eventuuid}"
                    puts "key: #{key}"
                    raise "(error: 5c04dc70-9024-414c-bab6-a9f9dee871ce)"
                end
            }
        }
    end

    # Fx18sSynchronisation::sync()
    def self.sync()

        LucilleCore::locationsAtFolder("#{Config::pathToLocalDataBankStargate()}/Datablobs").each{|filepath|
            next if filepath[-5, 5] != ".data"
            puts "Fx18sSynchronisation::sync(): transferring blob: #{filepath}"
            blob = IO.read(filepath)
            ExData::putBlobOnEnergyGrid1(blob)
            FileUtils.rm(filepath)
        }

        DxPure::localFilepathsEnumerator().each{|dxLocalFilepath|
            sha1 = File.basename(dxLocalFilepath).gsub(".sqlite3", "")
            eGridFilepath = DxPure::sha1ToEnergyGrid1Filepath(sha1)
            next if File.exists?(eGridFilepath)
            FileUtils.cp(dxLocalFilepath, eGridFilepath)
        }

        Fx18s::localFx18sFilepathsEnumerator().each{|filepath1|
            puts "filepath1: #{filepath1}"
            objectuuid = Fx18Attributes::getJsonDecodeOrNullUsingFilepath(filepath1, "uuid")
            if objectuuid.nil? then
                puts "I could not extract the uuid from Fx18 file #{filepath1}"
                raise "(error: 77a8fbbc-105f-4119-920b-3d73c66c6185)"
            end
            filepath2 = Fx18s::objectuuidToEnergyGridFx18Filepath(objectuuid)
            if File.exists?(filepath2) then
                Fx18sSynchronisation::propagateFileData(filepath1, filepath2) # uplink
            else
                puts "Copying:"
                puts "    #{filepath1}"
                puts "    #{filepath2}"
                folderpath2 = File.dirname(filepath2)
                if !File.exists?(folderpath2) then
                    FileUtils.mkdir(folderpath2)
                end
                FileUtils.cp(filepath1, filepath2)
            end
        }

        Fx18s::energyGrid1Fx18sFilepathsEnumerator().each{|filepath1|
            puts "filepath1: #{filepath1}"
            objectuuid = Fx18Attributes::getJsonDecodeOrNullUsingFilepath(filepath1, "uuid")
            if objectuuid.nil? then
                puts "I could not extract the uuid from Fx18 file #{filepath1}"
                raise "(error: 85d69faf-0db7-4ee5-a463-eaa0ad90eb83) How did that happen ? 🤔"
            end
            filepath2 = Fx18s::objectuuidToLocalFx18Filepath(objectuuid)
            if File.exists?(filepath2) then
                Fx18sSynchronisation::propagateFileData(filepath1, filepath2) # downlink
            else
                puts "Copying:"
                puts "    #{filepath1}"
                puts "    #{filepath2}"
                folderpath2 = File.dirname(filepath2)
                if !File.exists?(folderpath2) then
                    FileUtils.mkdir(folderpath2)
                end
                FileUtils.cp(filepath1, filepath2)
            end
        }
    end
end
