
# encoding: UTF-8

# -----------------------------------------------------------------------

class Utils

    # Utils::applyNextTransformationToFile(filepath)
    def self.applyNextTransformationToFile(filepath)
        text = IO.read(filepath).strip
        text = SectionsType0141::applyNextTransformationToText(text)
        File.open(filepath, "w"){|f| f.puts(text) }
    end

    # Utils::catalystDataCenterFolderpath()
    def self.catalystDataCenterFolderpath()
        "/Users/pascal/Galaxy/DataBank/Catalyst"
    end

    # Utils::codeToUnixtimeOrNull(code)
    def self.codeToUnixtimeOrNull(code)

        return nil if code.nil?
        return nil if code == ""

        # +<weekdayname>
        # +<integer>day(s)
        # +<integer>hour(s)
        # +YYYY-MM-DD
        # +1@12:34

        code = code[1,99].strip

        # <weekdayname>
        # <integer>day(s)
        # <integer>hour(s)
        # YYYY-MM-DD
        # 1@12:34

        localsuffix = Time.new.to_s[-5,5]
        morningShowTime = "07:00:00 #{localsuffix}"
        weekdayNames = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]

        if weekdayNames.include?(code) then
            # We have a week day
            weekdayName = code
            date = Utils::selectDateOfNextNonTodayWeekDay(weekdayName)
            datetime = "#{date} #{morningShowTime}"
            return DateTime.parse(datetime).to_time.to_i
        end

        if code.include?("hour") then
            return Time.new.to_i + code.to_f*3600
        end

        if code.include?("day") then
            return Time.new.to_i + code.to_f*86400
        end

        if code[4,1]=="-" and code[7,1]=="-" then
            return DateTime.parse("#{code} #{morningShowTime}").to_time.to_i
        end

        if code.include?('@') then
            p1, p2 = code.split('@') # 1 12:34
            return DateTime.parse("#{Utils::nDaysInTheFuture(p1.to_i)[0, 10]} #{p2}:00 #{localsuffix}").to_time.to_i
        end

        nil
    end

    # Utils::editTextSynchronously(text)
    def self.editTextSynchronously(text)
        filename = SecureRandom.uuid
        filepath = "/tmp/#{filename}"
        File.open(filepath, 'w') {|f| f.write(text)}
        system("open '#{filepath}'")
        print "> press enter when done: "
        input = STDIN.gets
        IO.read(filepath)
    end

    # Utils::importFromLucilleInbox()
    def self.importFromLucilleInbox()
        getNextLocationAtTheInboxOrNull = lambda {
            Dir.entries("/Users/pascal/Desktop/Inbox")
                .reject{|filename| filename[0, 1] == '.' }
                .map{|filename| "/Users/pascal/Desktop/Inbox/#{filename}" }
                .first
        }
        while (location = getNextLocationAtTheInboxOrNull.call()) do
            if File.basename(location).include?("'") then
                basename2 = File.basename(location).gsub("'", "-")
                location2 = "#{File.dirname(location)}/#{basename2}"
                FileUtils.mv(location, location2)
                next
            end

            filepath = "/Users/pascal/Galaxy/DataBank/Catalyst/Marbles/quarks/#{Quarks::computeLowL22()}.marble"

            marble = Marbles::issueNewEmptyMarble(filepath)

            marble.set("uuid", SecureRandom.uuid)
            marble.set("unixtime", Time.new.to_i)
            marble.set("domain", "quarks")
            marble.set("description", File.basename(location))

            marble.set("type", "AionPoint")
            payload = AionCore::commitLocationReturnHash(MarbleElizabeth.new(marble.filepath()), location)
            marble.set("payload", payload)

            LucilleCore::removeFileSystemLocation(location)
        end
    end

    # Utils::isInteger(str)
    def self.isInteger(str)
        str == str.to_i.to_s
    end

    # Utils::getNewValueEveryNSeconds(uuid, n)
    def self.getNewValueEveryNSeconds(uuid, n)
      Digest::SHA1.hexdigest("6bb2e4cf-f627-43b3-812d-57ff93012588:#{uuid}:#{(Time.new.to_f/n).to_i.to_s}")
    end

    # Utils::nDaysInTheFuture(n)
    def self.nDaysInTheFuture(n)
        (Time.now+86400*n).utc.iso8601[0,10]
    end

    # Utils::dateIsWeekEnd(date)
    def self.dateIsWeekEnd(date)
        [6, 0].include?(Date.parse(date).to_time.wday)
    end

    # Utils::stringDistance1(str1, str2)
    def self.stringDistance1(str1, str2)
        # This metric takes values between 0 and 1
        return 1 if str1.size == 0
        return 1 if str2.size == 0
        Utils::levenshteinDistance(str1, str2).to_f/[str1.size, str2.size].max
    end

    # Utils::openFilepath(filepath)
    def self.openFilepath(filepath)
        system("open '#{filepath}'")
    end

    # Utils::openFilepathWithInvite(filepath)
    def self.openFilepathWithInvite(filepath)
        system("open '#{filepath}'")
        LucilleCore::pressEnterToContinue()
    end

    # Utils::openUrl(url)
    def self.openUrl(url)
        system("open -a Safari '#{url}'")
    end

    # Utils::onScreenNotification(title, message)
    def self.onScreenNotification(title, message)
        title = title.gsub("'","")
        message = message.gsub("'","")
        message = message.gsub("[","|")
        message = message.gsub("]","|")
        command = "terminal-notifier -title '#{title}' -message '#{message}'"
        system(command)
    end

    # Utils::selectDateOfNextNonTodayWeekDay(weekday) #2
    def self.selectDateOfNextNonTodayWeekDay(weekday)
        weekDayIndexToStringRepresentation = lambda {|indx|
            weekdayNames = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]
            weekdayNames[indx]
        }
        (1..7).each{|indx|
            if weekDayIndexToStringRepresentation.call((Time.new+indx*86400).wday) == weekday then
                return (Time.new+indx*86400).to_s[0,10]
            end
        }
    end

    # Utils::screenHeight()
    def self.screenHeight()
        `/usr/bin/env tput lines`.to_i
    end

    # Utils::screenWidth()
    def self.screenWidth()
        `/usr/bin/env tput cols`.to_i
    end

    # Utils::today()
    def self.today()
        Time.new.to_s[0, 10]
    end

    # Utils::todayAsLowercaseEnglishWeekDayName()
    def self.todayAsLowercaseEnglishWeekDayName()
        ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"][Time.new.wday]
    end

    # Utils::verticalSize(displayStr)
    def self.verticalSize(displayStr)
        displayStr.lines.map{|line| line.size/Utils::screenWidth() + 1 }.inject(0, :+)
    end

    # ----------------------------------------------------

    # Utils::pecoStyleSelectionOrNull(lines)
    def self.pecoStyleSelectionOrNull(lines)
        lines  = [""] + lines
        line = `echo '#{lines.join("\n")}' | /usr/local/bin/peco`.strip
        return line if line.size > 0
        nil
    end

    # Utils::ncurseSelection1410(lambda1, lambda2)
    # lambda1: pattern: String -> Array[String]
    # lambda2: string:  String -> Object or null
    def self.ncurseSelection1410(lambda1, lambda2)

        windowUpdate = lambda { |win, strs|
            win.setpos(0,0)
            strs.each{|str|
                win.deleteln()
                win << (str + "\n")
            }
            win.refresh
        }

        Curses::init_screen
        # Initializes a standard screen. At this point the present state of our terminal is saved and the alternate screen buffer is turned on

        Curses::noecho
        # Disables characters typed by the user to be echoed by Curses.getch as they are typed.

        inputString = ""
        inputString_lastModificationUnixtime = nil
        currentLines = []

        win1 = Curses::Window.new(1, Utils::screenWidth(), 0, 0)
        win2 = Curses::Window.new(Utils::screenHeight()-1, Utils::screenWidth(), 1, 0)

        win1.refresh
        win2.refresh

        # windowUpdate.call(win1, ["line1"])
        # windowUpdate.call(win2, ["line3", "line4"])

        windowUpdate.call(win1, ["-> "])

        thread1 = Thread.new {
            lastSearchedForString = nil
            loop {
                if inputString_lastModificationUnixtime.nil? then
                    sleep 0.1
                    next
                end
                if (Time.new.to_f - inputString_lastModificationUnixtime) < 0.5 then
                    sleep 0.1
                    next
                end
                if inputString.length < 3 then
                    sleep 0.1
                    next
                end
                if !lastSearchedForString.nil? and lastSearchedForString == inputString then
                    sleep 0.1
                    next
                end
                lastSearchedForString = inputString
                currentLines = lambda1.call(inputString)
                windowUpdate.call(win2, currentLines)
                windowUpdate.call(win1, ["-> #{inputString}"])
            }
        }

        loop {
            char = win1.getch.to_s # Reads and return a character non blocking

            next if char.size == 0

            if char == '127' then
                # delete
                next if inputString.length == 0
                inputString = inputString[0, inputString.length-1]
                inputString_lastModificationUnixtime = Time.new.to_f
                windowUpdate.call(win1, ["-> #{inputString}"])
                next
            end

            if char == '10' then
                # enter
                break
            end

            inputString = inputString + char
            inputString_lastModificationUnixtime = Time.new.to_f
            windowUpdate.call(win1, ["-> #{inputString}"])
        }

        thread1.terminate

        win1.close
        win2.close

        Curses::close_screen # this method restore our terminal's settings

        # -----------------------------------------------------------------------

        line = LucilleCore::selectEntityFromListOfEntitiesOrNull("selection", lambda1.call(inputString))
        return nil if line.nil?
        lambda2.call(line) # this returns an object or null
    end

    # ----------------------------------------------------

    # Utils::levenshteinDistance(s, t)
    def self.levenshteinDistance(s, t)
      # https://stackoverflow.com/questions/16323571/measure-the-distance-between-two-strings-with-ruby
      m = s.length
      n = t.length
      return m if n == 0
      return n if m == 0
      d = Array.new(m+1) {Array.new(n+1)}

      (0..m).each {|i| d[i][0] = i}
      (0..n).each {|j| d[0][j] = j}
      (1..n).each do |j|
        (1..m).each do |i|
          d[i][j] = if s[i-1] == t[j-1] # adjust index into string
                      d[i-1][j-1]       # no operation required
                    else
                      [ d[i-1][j]+1,    # deletion
                        d[i][j-1]+1,    # insertion
                        d[i-1][j-1]+1,  # substitution
                      ].min
                    end
        end
      end
      d[m][n]
    end

    # Utils::stringDistance1(str1, str2)
    def self.stringDistance1(str1, str2)
        # This metric takes values between 0 and 1
        return 1 if str1.size == 0
        return 1 if str2.size == 0
        Utils::levenshteinDistance(str1, str2).to_f/[str1.size, str2.size].max
    end

    # Utils::stringDistance2(str1, str2)
    def self.stringDistance2(str1, str2)
        # We need the smallest string to come first
        if str1.size > str2.size then
            str1, str2 = str2, str1
        end
        diff = str2.size - str1.size
        (0..diff).map{|i| Utils::levenshteinDistance(str1, str2[i, str1.size]) }.min
    end

    # ----------------------------------------------------

    # Utils::selectLinesUsingInteractiveInterface(lines) : Array[String]
    def self.selectLinesUsingInteractiveInterface(lines)
        # Some lines break peco, so we need to be a bit clever here...
        linesX = lines.map{|line|
            {
                "line"     => line,
                "announce" => line.gsub("(", "").gsub(")", "").gsub("'", "").gsub('"', "") 
            }
        }
        announces = linesX.map{|i| i["announce"] } 
        selected = `echo '#{([""]+announces).join("\n")}' | /usr/local/bin/peco`.split("\n")
        selected.map{|announce| 
            linesX.select{|i| i["announce"] == announce }.map{|i| i["line"] }.first 
        }
        .compact
    end

    # Utils::selectLineOrNullUsingInteractiveInterface(lines) : String
    def self.selectLineOrNullUsingInteractiveInterface(lines)

        # Temporary measure to remove stress on Utils::selectLinesUsingInteractiveInterface / peco after 
        # we added the videos from video stream
        lines = lines.reject{|line| line.include?('.mkv') }
        
        lines = Utils::selectLinesUsingInteractiveInterface(lines)
        if lines.size == 0 then
            return nil
        end
        if lines.size == 1 then
            return lines[0]
        end
        LucilleCore::selectEntityFromListOfEntitiesOrNull("select", lines)
    end

    # Utils::selectOneObjectOrNullUsingInteractiveInterface(items, toString = lambda{|item| item })
    def self.selectOneObjectOrNullUsingInteractiveInterface(items, toString = lambda{|item| item })
        lines = items.map{|item| toString.call(item) }
        line = Utils::selectLineOrNullUsingInteractiveInterface(lines)
        return nil if line.nil?
        items
            .select{|item| toString.call(item) == line }
            .first
    end
end
