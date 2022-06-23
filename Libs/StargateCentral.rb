class StargateCentralDataBlobs

    # StargateCentralDataBlobs::pathToCentral()
    def self.pathToCentral()
        "/Volumes/Infinity/Data/Pascal/Stargate-Central"
    end

    # StargateCentralDataBlobs::propagateDatablobs(folderpath1, folderpath2)
    def self.propagateDatablobs(folderpath1, folderpath2)
        Find.find(folderpath1) do |path|
            next if File.basename(path)[-5, 5] != ".data"
            filename = File.basename(path)
            targetfolderpath = "#{folderpath2}/#{filename[7, 2]}"
            targetfilepath = "#{targetfolderpath}/#{filename}"
            next if File.exist?(targetfilepath)
            if !File.exists?(targetfolderpath) then
                FileUtils.mkdir(targetfolderpath)
            end
            puts "copying datablob: #{filename}"
            FileUtils.cp(path, targetfilepath)
        end
    end

    # StargateCentralDataBlobs::propagateDatablobsWithPrimaryDeletion(folderpath1, folderpath2)
    def self.propagateDatablobsWithPrimaryDeletion(folderpath1, folderpath2)
        Find.find(folderpath1) do |path|
            next if File.basename(path)[-5, 5] != ".data"
            filename = File.basename(path)
            targetfolderpath = "#{folderpath2}/#{filename[7, 2]}"
            targetfilepath = "#{targetfolderpath}/#{filename}"
            if File.exist?(targetfilepath) then
                FileUtils.rm(path)
                next
            end
            if !File.exists?(targetfolderpath) then
                FileUtils.mkdir(targetfolderpath)
            end
            puts "copying datablob: #{filename}"
            FileUtils.cp(path, targetfilepath)
            FileUtils.rm(path)
        end
    end
end

class StargateCentralObjects

    # StargateCentralObjects::pathToObjectsDatabase()
    def self.pathToObjectsDatabase()
        "#{StargateCentralDataBlobs::pathToCentral()}/objects.sqlite3"
    end

    # StargateCentralObjects::objects()
    def self.objects()
        db = SQLite3::Database.new(StargateCentralObjects::pathToObjectsDatabase())
        db.busy_timeout = 117
        db.busy_handler { |count| true }
        db.results_as_hash = true
        answer = []
        db.execute("select * from _objects_") do |row|
            answer << JSON.parse(row['_object_'])
        end
        db.close
        answer
    end

    # StargateCentralObjects::commit(object)
    def self.commit(object)
        raise "(error: ee5c0d42-685e-433a-9d5b-c043494f19ff, missing attribute uuid)" if object["uuid"].nil?
        raise "(error: a98ef432-f4f5-43e2-82ba-2edafa505a8d, missing attribute mikuType)" if object["mikuType"].nil?

        db = SQLite3::Database.new(StargateCentralObjects::pathToObjectsDatabase())
        db.execute "delete from _objects_ where _variant_=?", [object["variant"]]
        db.execute "insert into _objects_ (_uuid_, _variant_, _mikuType_, _object_) values (?, ?, ?, ?)", [object["uuid"], object["variant"], object["mikuType"], JSON.generate(object)]
        db.close

        Cliques::garbageCollectCentralClique(object["uuid"])
    end

    # StargateCentralObjects::getClique(uuid)
    def self.getClique(uuid) 
        db = SQLite3::Database.new(StargateCentralObjects::pathToObjectsDatabase())
        db.busy_timeout = 117
        db.busy_handler { |count| true }
        db.results_as_hash = true
        answer = []
        db.execute("select * from _objects_ where _uuid_=?", [uuid]) do |row|
            answer << JSON.parse(row['_object_'])
        end
        db.close
        answer
    end

    # StargateCentralObjects::destroyVariantNoEvent(variant)
    def self.destroyVariantNoEvent(variant)
        db = SQLite3::Database.new(StargateCentralObjects::pathToObjectsDatabase())
        db.execute "delete from _objects_ where _variant_=?", [variant]
        db.close
    end
end
