

class Engined

    # Engined::muiItems()
    def self.muiItems()
        tasks = Cubes2::mikuType("NxTask").select{|item| item["engine-0020"] }
        (tasks + NxListings::topBlocks())
                .select{|item| NxListings::dayCompletionRatio(item) < 1 }
                .sort_by{|item| NxListings::dayCompletionRatio(item) }
    end
end
