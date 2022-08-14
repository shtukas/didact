
# encoding: UTF-8

class ItemToGroupMapping

    # ItemToGroupMapping::databaseFile()
    def self.databaseFile()
        "#{ENV['HOME']}/Galaxy/DataBank/Stargate/item-to-group-mapping.sqlite3"
    end

    # ItemToGroupMapping::insertRow(row)
    def self.insertRow(row)
        $item_to_group_mapping_database_semaphore.synchronize {
            db = SQLite3::Database.new(ItemToGroupMapping::databaseFile())
            db.busy_timeout = 117
            db.busy_handler { |count| true }
            db.execute "delete from _mapping_ where _eventuuid_=?", [row["_eventuuid_"]]
            db.execute "insert into _mapping_ (_eventuuid_, _eventTime_, _itemuuid_, _groupuuid_, _status_) values (?, ?, ?, ?, ?)", [row["_eventuuid_"], row["_eventTime_"], row["_itemuuid_"], row["_groupuuid_"], row["_status_"]]
            db.close
        }
    end

    # ItemToGroupMapping::issueNoEvents(groupuuid, itemuuid)
    def self.issueNoEvent(groupuuid, itemuuid)
        $item_to_group_mapping_database_semaphore.synchronize {
            db = SQLite3::Database.new(ItemToGroupMapping::databaseFile())
            db.busy_timeout = 117
            db.busy_handler { |count| true }
            db.execute "insert into _mapping_ (_eventuuid_, _eventTime_, _itemuuid_, _groupuuid_, _status_) values (?, ?, ?, ?, ?)", [SecureRandom.uuid, Time.new.to_f, itemuuid, groupuuid, "true"]
            db.close
        }
    end

    # ItemToGroupMapping::issue(groupuuid, itemuuid)
    def self.issue(groupuuid, itemuuid)
        ItemToGroupMapping::issueNoEvents(groupuuid, itemuuid)
        SystemEvents::broadcast({
          "mikuType"  => "ItemToGroupMapping",
          "groupuuid" => groupuuid,
          "itemuuid"  => itemuuid
        })
    end

    # ItemToGroupMapping::detach(groupuuid, itemuuid)
    def self.detach(groupuuid, itemuuid)
        $item_to_group_mapping_database_semaphore.synchronize {
            db = SQLite3::Database.new(ItemToGroupMapping::databaseFile())
            db.busy_timeout = 117
            db.busy_handler { |count| true }
            db.execute "insert into _mapping_ (_eventuuid_, _eventTime_, _itemuuid_, _groupuuid_, _status_) values (?, ?, ?, ?, ?)", [SecureRandom.uuid, Time.new.to_f, itemuuid, groupuuid, "false"]
            db.close
        }
    end

    # ItemToGroupMapping::groupuuidToItemuuids(groupuuid)
    def self.groupuuidToItemuuids(groupuuid)
        answer = []
        $item_to_group_mapping_database_semaphore.synchronize {
            db = SQLite3::Database.new(ItemToGroupMapping::databaseFile())
            db.busy_timeout = 117
            db.busy_handler { |count| true }
            db.results_as_hash = true
            db.execute("select * from _mapping_ where _groupuuid_=?", [groupuuid]) do |row|
                answer << row['_itemuuid_']
            end
            db.close
        }
        answer
    end

    # ItemToGroupMapping::trueIfItemIsInAGroup(itemuuid)
    def self.trueIfItemIsInAGroup(itemuuid)
        answer = false
        $item_to_group_mapping_database_semaphore.synchronize {
            db = SQLite3::Database.new(ItemToGroupMapping::databaseFile())
            db.busy_timeout = 117
            db.busy_handler { |count| true }
            db.results_as_hash = true
            db.execute("select * from _mapping_ where _itemuuid_=?", [itemuuid]) do |row|
                answer = true # This implementation is fundamentally incorrect because to be correct we would need to take account of the _status_, but for the time being items won't be removed from groups
                # TODO: fix it
            end
            db.close
        }
        answer
    end

    # ItemToGroupMapping::itemuuidToGroupuuids(itemuuid)
    def self.itemuuidToGroupuuids(itemuuid)
        answer = []
        $item_to_group_mapping_database_semaphore.synchronize {
            db = SQLite3::Database.new(ItemToGroupMapping::databaseFile())
            db.busy_timeout = 117
            db.busy_handler { |count| true }
            db.results_as_hash = true
            db.execute("select * from _mapping_ where _itemuuid_=?", [itemuuid]) do |row|
                answer << row['_groupuuid_']
            end
            db.close
        }
        answer
    end

    # ItemToGroupMapping::eventuuids()
    def self.eventuuids()
        answer = []
        $item_to_group_mapping_database_semaphore.synchronize {
            db = SQLite3::Database.new(ItemToGroupMapping::databaseFile())
            db.busy_timeout = 117
            db.busy_handler { |count| true }
            db.results_as_hash = true
            db.execute("select _eventuuid_ from _mapping_", []) do |row|
                answer << row['_eventuuid_']
            end
            db.close
        }
        answer
    end

    # ItemToGroupMapping::records()
    def self.records()
        answer = []
        $item_to_group_mapping_database_semaphore.synchronize {
            db = SQLite3::Database.new(ItemToGroupMapping::databaseFile())
            db.busy_timeout = 117
            db.busy_handler { |count| true }
            db.results_as_hash = true
            db.execute("select * from _mapping_", []) do |row|
                answer << row.clone
            end
            db.close
        }
        answer
    end

    # ItemToGroupMapping::processEvent(event)
    def self.processEvent(event)
        if event["mikuType"] == "ItemToGroupMapping" then
            groupuuid = event["groupuuid"]
            itemuuid  = event["itemuuid"]
            ItemToGroupMapping::issueNoEvent(groupuuid, itemuuid)
        end

        if event["mikuType"] == "ItemToGroupMapping-records" then
            eventuuids = ItemToGroupMapping::eventuuids()
            event["records"].each{|row|
                next if eventuuids.include?(row["_eventuuid_"])
                ItemToGroupMapping::insertRow(row)
            }
        end
    end
end