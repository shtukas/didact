
# encoding: UTF-8

$LibrarianInMemoryObjectsDB = nil

class Librarian

    # --------------------------------------------------
    # Fx12

    # Librarian::pathToFx12sRepository()
    def self.pathToFx12sRepository()
        "#{Config::pathToDataBankStargate()}/Fx12s"
    end

    # Librarian::getFx12Filepath(uuid)
    def self.getFx12Filepath(uuid)
        hash1 = Digest::SHA1.hexdigest(uuid)
        folderpath = "#{Librarian::pathToFx12sRepository()}/#{hash1[0, 2]}"
        if !File.exists?(folderpath) then
            FileUtils.mkpath(folderpath)
        end
        "#{folderpath}/#{uuid}.fx12"
    end

    # Librarian::commitObjectToFx12File(object)
    def self.commitObjectToFx12File(object)
        filepath = Librarian::getFx12Filepath(object["uuid"])
        Fx12s::setObject(filepath, object)
    end

    # Librarian::fx12Filepaths()
    def self.fx12Filepaths()
        filepaths = []
        Find.find(Librarian::pathToFx12sRepository()) do |path|
            next if !File.file?(path)
            next if File.basename(path)[-5, 5] != ".fx12"
            filepaths << path
        end
        filepaths
    end

    # ---------------------------------------------------
    # Objects Reading

    # Librarian::ensureInMemoryDatabase()
    def self.ensureInMemoryDatabase()
        if $LibrarianInMemoryObjectsDB.nil? then
            puts "Loading objects from Fx12 files"
            $LibrarianInMemoryObjectsDB = SQLite3::Database.new ":memory:"
            $LibrarianInMemoryObjectsDB.results_as_hash = true
            $LibrarianInMemoryObjectsDB.busy_timeout = 117
            $LibrarianInMemoryObjectsDB.busy_handler { |count| true }
            $LibrarianInMemoryObjectsDB.execute "CREATE TABLE _objects_ (_objectuuid_ text primary key, _mikuType_ text, _object_ text, _ordinal_ float, _universe_ text);", []
            
            objects = Librarian::fx12Filepaths()
                        .map{|filepath| Fx12s::getObject(filepath) }
                        .sort{|o1, o2| o1["ordinal"] <=> o2["ordinal"] }
            
            objects.each{|object|
                $LibrarianInMemoryObjectsDB.execute "delete from _objects_ where _objectuuid_=?", [object["uuid"]]
                $LibrarianInMemoryObjectsDB.execute "insert into _objects_ (_objectuuid_, _mikuType_, _object_, _ordinal_, _universe_) values (?,?,?,?,?)", [object["uuid"], object["mikuType"], JSON.generate(object), object["ordinal"], object["universe"]]
            }
            # $LibrarianInMemoryObjectsDB.close
        end
    end

    # Librarian::objects()
    def self.objects()
        Librarian::ensureInMemoryDatabase()
        objects = []
        $LibrarianInMemoryObjectsDB.execute("select * from _objects_ order by _ordinal_", []) do |row|
            objects << JSON.parse(row['_object_'])
        end
        objects
    end

    # Librarian::getObjectsByMikuType(mikuType)
    def self.getObjectsByMikuType(mikuType)
        Librarian::ensureInMemoryDatabase()
        objects = []
        $LibrarianInMemoryObjectsDB.execute("select * from _objects_ where _mikuType_=? order by _ordinal_", [mikuType]) do |row|
            objects << JSON.parse(row['_object_'])
        end
        objects
    end

    # Librarian::getObjectsByMikuTypeAndUniverse(mikuType, universe)
    def self.getObjectsByMikuTypeAndUniverse(mikuType, universe)
        Librarian::ensureInMemoryDatabase()
        objects = []
        $LibrarianInMemoryObjectsDB.execute("select * from _objects_ where _mikuType_=? and _universe_=? order by _ordinal_", [mikuType, universe]) do |row|
            objects << JSON.parse(row['_object_'])
        end
        objects
    end

    # Librarian::getObjectsByMikuTypeAndUniverseByOrdinalLimit(mikuType, universe, n)
    def self.getObjectsByMikuTypeAndUniverseByOrdinalLimit(mikuType, universe, n)
        objects = []
        $LibrarianInMemoryObjectsDB.execute("select * from _objects_ where _mikuType_=? and _universe_=? order by _ordinal_ limit ?", [mikuType, universe, n]) do |row|
            objects << JSON.parse(row['_object_'])
        end
        objects
    end

    # Librarian::getObjectByUUIDOrNull(uuid)
    def self.getObjectByUUIDOrNull(uuid)
        Librarian::ensureInMemoryDatabase()
        object = nil
        $LibrarianInMemoryObjectsDB.execute("select * from _objects_ where _objectuuid_=?", [uuid]) do |row|
            object = JSON.parse(row['_object_'])
        end
        object
    end

    # ---------------------------------------------------
    # Objects Writing

    # Librarian::commit(object)
    def self.commit(object)

        Librarian::ensureInMemoryDatabase()

        raise "(error: 8e53e63e-57fe-4621-a1c6-a7b4ad5d23a7, missing attribute uuid)" if object["uuid"].nil?
        raise "(error: 016668dd-cb66-4ba1-9546-2fe05ee62fc6, missing attribute mikuType)" if object["mikuType"].nil?

        if object["ordinal"].nil? then
            object["ordinal"] = 0
        end

        if object["universe"].nil? then
            object["universe"] = "backlog"
        end

        if object["lxHistory"].nil? then
            object["lxHistory"] = []
        end

        object["lxHistory"] << SecureRandom.uuid

        Librarian::commitObjectToFx12File(object)

        $LibrarianInMemoryObjectsDB.execute "delete from _objects_ where _objectuuid_=?", [object["uuid"]]
        $LibrarianInMemoryObjectsDB.execute "insert into _objects_ (_objectuuid_, _mikuType_, _object_, _ordinal_, _universe_) values (?,?,?,?,?)", [object["uuid"], object["mikuType"], JSON.generate(object), object["ordinal"], object["universe"]]
    end

    # Librarian::commitWithoutUpdates(object)
    def self.commitWithoutUpdates(object)
        Librarian::ensureInMemoryDatabase()

        raise "(error: 8e53e63e-57fe-4621-a1c6-a7b4ad5d23a7, missing attribute uuid)" if object["uuid"].nil?
        raise "(error: 016668dd-cb66-4ba1-9546-2fe05ee62fc6, missing attribute mikuType)" if object["mikuType"].nil?

        raise "(error: 7fb476dc-94ce-4ef9-8253-04776dd550fb, missing attribute ordinal)" if object["ordinal"].nil?
        raise "(error: bcc0e0f0-b4cf-4815-ae70-0c4cf834bf8f, missing attribute universe)" if object["universe"].nil?
        raise "(error: 9fd3f77b-25a5-4fc1-b481-074f4d5444ce, missing attribute lxHistory)" if object["lxHistory"].nil?

        Librarian::commitObjectToFx12File(object)

        $LibrarianInMemoryObjectsDB.execute "delete from _objects_ where _objectuuid_=?", [object["uuid"]]
        $LibrarianInMemoryObjectsDB.execute "insert into _objects_ (_objectuuid_, _mikuType_, _object_, _ordinal_, _universe_) values (?,?,?,?,?)", [object["uuid"], object["mikuType"], JSON.generate(object), object["ordinal"], object["universe"]]
    end

    # Librarian::objectIsAboutToBeDestroyed(object)
    def self.objectIsAboutToBeDestroyed(object)
        if object["i1as"] then
            object["i1as"].each{|nx111|
                if nx111["type"] == "Dx8Unit" then
                    unitId = nx111["unitId"]
                    location = Dx8UnitsUtils::dx8UnitFolder(unitId)
                    puts "removing Dx8Unit folder: #{location}"
                    LucilleCore::removeFileSystemLocation(location)
                end
            }
        end
    end

    # Librarian::destroy(uuid)
    def self.destroy(uuid)

        Librarian::ensureInMemoryDatabase()

        if object = Librarian::getObjectByUUIDOrNull(uuid) then
            Librarian::objectIsAboutToBeDestroyed(object)
        end

        filepath = Librarian::getFx12Filepath(uuid)
        if File.exists?(filepath) then
            puts "removing file: #{filepath}"
            FileUtils.rm(filepath)
        end

        $LibrarianInMemoryObjectsDB.execute "delete from _objects_ where _objectuuid_=?", [uuid]
    end
end
