# encoding: UTF-8

# require "/Users/pascal/Galaxy/LucilleOS/Applications/Catalyst/Catalyst/DataIntegrityOfficer.rb"

# This variable contains the objects of the current display.
# We use it to speed up display after some operations

require 'digest/sha1'
# Digest::SHA1.hexdigest 'foo'
# Digest::SHA1.file(myFile).hexdigest

require "/Users/pascal/Galaxy/LucilleOS/Libraries/Ruby-Libraries/KeyValueStore.rb"
=begin
    KeyValueStore::setFlagTrue(repositorylocation or nil, key)
    KeyValueStore::setFlagFalse(repositorylocation or nil, key)
    KeyValueStore::flagIsTrue(repositorylocation or nil, key)

    KeyValueStore::set(repositorylocation or nil, key, value)
    KeyValueStore::getOrNull(repositorylocation or nil, key)
    KeyValueStore::getOrDefaultValue(repositorylocation or nil, key, defaultValue)
    KeyValueStore::destroy(repositorylocation or nil, key)
=end

require "/Users/pascal/Galaxy/LucilleOS/Applications/Catalyst/Catalyst/A10495.rb"
require "/Users/pascal/Galaxy/LucilleOS/Applications/Catalyst/Catalyst/Cliques.rb"
require "/Users/pascal/Galaxy/LucilleOS/Applications/Catalyst/Catalyst/GlobalNavigationNetwork.rb"

# ------------------------------------------------------------------------

class DataIntegrityOfficer

    # DataIntegrityOfficer::startSurvey()
    def self.startSurvey()
        # Ensure that each node not the root has a parent
        GlobalNavigationNetworkNodes::nodes()
            .each{|node|
                next if node["uuid"] == "3b5b7dbe-442b-4b5b-b681-f61ab598fd63" # root node
                next if !GlobalNavigationNetworkPaths::getParents(node).empty?
                puts "[DataIntegrityOfficer] Global Navigation Network Node '#{node["name"]}' doesn't have a parent, please make and/or select one".green
                puts JSON.pretty_generate(node)
                parent = GlobalNavigationNetworkMakeAndOrSelectNodeQuest::makeAndOrSelectNodeOrNull()
                next if parent.nil?
                next if node["uuid"] == parent["uuid"]
                object = GlobalNavigationNetworkPaths::issuePathFromFirstNodeToSecondNodeOrNull(parent, node)
                next if object.nil?
                puts JSON.pretty_generate(object)
            }
    end

    # DataIntegrityOfficer::interfaceLoopOperations()
    def self.interfaceLoopOperations()
        # Make sure that every Clique is on a node
        Cliques::cliques()
            .each{|clique|
                next if !GlobalNavigationNetworkContents::getNodesForEntity(clique).empty?

                if clique["tags"].include?("Pascal Address Book Archives") then
                    node = GlobalNavigationNetworkNodes::getOrNull("2ec5eda3-7d52-4b5f-8622-df3494280fd9") # Pascal Address Book Archives
                    if node.nil? then
                        puts "error: a6301551"
                        exit
                    end
                    GlobalNavigationNetworkContents::issueClaimGivenNodeAndEntity(node, clique)
                    return
                end

                system("clear")
                puts "[DataIntegrityOfficer] Clique '#{clique["description"]}' doesn't have a Global Navigation Network parent, please make and/or select one".green
                puts "First I am going to show it to you and then you will add it to a node"

                Cliques::cliqueDive(clique)

                # By now it could have been destroyed
                next if Cliques::getOrNull(clique["uuid"]).nil?
                # By now it also can have a parent node (since we dove)
                next if !GlobalNavigationNetworkContents::getNodesForEntity(clique).empty?

                node = GlobalNavigationNetworkMakeAndOrSelectNodeQuest::makeAndOrSelectNodeOrNull()
                next if node.nil?
                GlobalNavigationNetworkContents::issueClaimGivenNodeAndEntity(node, clique)
                return
            }
    end
end


