# encoding: UTF-8

class NxLinks

    # NxLinks::link(uuid1, uuid2)
    def self.link(uuid1, uuid2)
        return if uuid1 == uuid2
        return if NxNodes::getOrNull(uuid1).nil?
        return if NxNodes::getOrNull(uuid2).nil?
        dir1 = "#{Config::pathToNyx()}/Network/#{uuid1}"
        if !File.exist?(dir1) then
            FileUtils::mkdir(dir1)
        end
        filepath1 = "#{dir1}/#{uuid2}.link"
        if !File.exist?(filepath1) then
            FileUtils.touch(filepath1)
        end

        dir2 = "#{Config::pathToNyx()}/Network/#{uuid2}"
        if !File.exist?(dir2) then
            FileUtils::mkdir(dir2)
        end
        filepath2 = "#{dir2}/#{uuid1}.link"
        if !File.exist?(filepath2) then
            FileUtils.touch(filepath2)
        end
    end

    # NxLinks::unlink(uuid1, uuid2)
    def self.unlink(uuid1, uuid2)
        dir1 = "#{Config::pathToNyx()}/Network/#{uuid1}"
        filepath1 = "#{dir1}/#{uuid2}.link"
        if File.exist?(filepath1) then
            FileUtils.rm(filepath1)
        end

        dir2 = "#{Config::pathToNyx()}/Network/#{uuid2}"
        filepath2 = "#{dir2}/#{uuid1}.link"
        if File.exist?(filepath2) then
            FileUtils.rm(filepath2)
        end
    end

    # NxLinks::linkeduuids(uuid)
    def self.linkeduuids(uuid)
        dir = "#{Config::pathToNyx()}/Network/#{uuid}"
        return [] if !File.exist?(dir)
        LucilleCore::locationsAtFolder(dir)
            .map{|filepath| File.basename(filepath).gsub(".link", "") }
    end

    # NxLinks::linkednodes(uuid)
    def self.linkednodes(uuid)
        NxLinks::linkeduuids(uuid)
            .map{|linkeduuid| NxNodes::getOrNull(linkeduuid) }
            .compact
    end
end