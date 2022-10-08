
# encoding: UTF-8

class Config

    # Config::pathToLocalDataBankStargate()
    def self.pathToLocalDataBankStargate()
        "#{Config::userHomeDirectory()}/Galaxy/DataBank/Stargate"
    end

    # Config::get(key)
    def self.get(key)
        config = JSON.parse(IO.read("#{Config::userHomeDirectory()}/Galaxy/DataBank/Stargate-Config.json"))
        config[key]
    end

    # Config::userHomeDirectory()
    def self.userHomeDirectory()
        ENV['HOME']
    end
end

class StargateMultiInstanceShared
    # StargateMultiInstanceShared::sharedConfigGet(key)
    def self.sharedConfigGet(key)
        config = JSON.parse(IO.read("#{Config::userHomeDirectory()}/Galaxy/DataBank/Stargate-ActiveCommsLine/shared-config.json"))
        config[key]
    end
end