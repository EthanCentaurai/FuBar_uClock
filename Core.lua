
local db, localTime, realmTime, utcTime, displayedTime

uClock = AceLibrary("AceAddon-2.0"):new("AceDB-2.0", "AceEvent-2.0", "FuBarPlugin-2.0")
uClock.hasIcon = "Interface\\Icons\\INV_Misc_PocketWatch_02"
uClock.blizzardTooltip = true
uClock.cannotHideText = true

uClock:RegisterDB("uClockDB")
uClock:RegisterDefaults('profile', { showLocal = true, showRealm = false, showUTC = false, twentyFour = true, showSeconds = false, r = 1, g = 1, b = 1 })


function uClock:OnEnable()
	db = self.db.profile

	self:ScheduleRepeatingEvent(self.UpdateTimeStrings, 1, self)
	self.OnMenuRequest = {
		type = 'group',
		args = {
			localTime = {
				name = "Show Local Time",
				desc = "Show local time on the FuBar.",
				type = "toggle", order = 1,
				get = function() return db.showLocal end,
				set = function() db.showLocal = not db.showLocal self:UpdateTimeStrings() end,
			},
			realmTime = {
				name = "Show Realm Time",
				desc = "Show server time on the FuBar.",
				type = "toggle", order = 2,
				get = function() return db.showRealm end,
				set = function() db.showRealm = not db.showRealm self:UpdateTimeStrings() end,
			},
			utcTime = {
				name = "Show UTC Time",
				desc = "Show UTC time on the FuBar.",
				type = "toggle", order = 3,
				get = function() return db.showUTC end,
				set = function() db.showUTC = not db.showUTC self:UpdateTimeStrings() end,
			},
			empty = { type = "header", order = 4 },
			twentyFour = {
				name = "24 Hour Mode",
				desc = "Choose whether to have the time shown in 12-hour or 24-hour format.",
				type = "toggle", order = 5,
				get = function() return db.twentyFour end,
				set = function() db.twentyFour = not db.twentyFour self:UpdateTimeStrings() end,
			},
			showSeconds = {
				name = "Show Seconds",
				desc = "Choose whether to show seconds.",
				type = "toggle", order = 6,
				get = function() return db.showSeconds end,
				set = function() db.showSeconds = not db.showSeconds self:UpdateTimeStrings() end,
			},
			colourOfText = {
				name = "Colour of Text",
				desc = "Choose the colour of the text.",
				type = "color", order = 7,
				get = function() return db.r, db.g, db.b end,
				set = function(r, g, b) db.r, db.g, db.b = r, g, b self:UpdateTimeStrings() end,
			},
		},
	}
end


function uClock:OnTooltipUpdate()
	GameTooltip:AddDoubleLine("Today's Date", date("%A, %B %d, %Y"))
	GameTooltip:AddDoubleLine("Local Time", localTime)
	GameTooltip:AddDoubleLine("Server Time", realmTime)
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine("|cffeda55fClick|r to toggle the Time Manager.", 0.2, 1, 0.2)
	GameTooltip:AddLine("|cffeda55fShift-Click|r to toggle the Calendar.", 0.2, 1, 0.2)
	GameTooltip:AddLine("|cffeda55fRight-Click|r for options.", 0.2, 1, 0.2)
end

function uClock:OnClick(button)
	if button == "LeftButton" then
		if IsShiftKeyDown() then
			if IsAddOnLoaded("GroupCalendar5") then -- Version 5
				if GroupCalendar.UI.Window:IsShown() then
					GroupCalendar.UI.Window:Hide()
				else
					GroupCalendar.UI.Window:Show()
				end
			elseif IsAddOnLoaded("GroupCalendar") then -- Version 4
				GroupCalendar.ToggleCalendarDisplay()
			else
				ToggleCalendar()
			end
		else
			ToggleTimeManager()
		end
	end
end


function uClock:UpdateTimeStrings()
	local lHour, lMinute = date("%H"), date("%M")
	local sHour, sMinute = GetGameTime()
	local uHour, uMinute = date("!%H"), date("!%M")
	local seconds = date("%S")

	local lPM, sPM, uPM

	if not db.twentyFour then
		lPM = floor(lHour / 12) == 1
		lHour = mod(lHour, 12)

		sPM = floor(sHour / 12) == 1
		sHour = mod(sHour, 12)

		uPM = floor(uHour / 12) == 1
		uHour = mod(uHour, 12)

		if lHour == 0 then lHour = 12 end
		if sHour == 0 then sHour = 12 end
		if uHour == 0 then uHour = 12 end
	end

	if db.showSeconds then
		localTime = ("%d:%02d:%02d"):format(lHour, lMinute, seconds)
		realmTime = ("%d:%02d:%02d"):format(sHour, sMinute, seconds)
		utcTime   = ("%d:%02d:%02d"):format(uHour, uMinute, seconds)
	else
		localTime = ("%d:%02d"):format(lHour, lMinute)
		realmTime = ("%d:%02d"):format(sHour, sMinute)
		utcTime   = ("%d:%02d"):format(uHour, uMinute)
	end

	if not db.twentyFour then
		localTime = localTime..(lPM and " PM" or " AM")
		realmTime = realmTime..(sPM and " PM" or " AM")
		utcTime   = utcTime .. (uPM and " PM" or " AM")
	end

	displayedTime = ""

	if db.showLocal then displayedTime = displayedTime..localTime.." | " end
	if db.showRealm then displayedTime = displayedTime..realmTime.." | " end
	if db.showUTC then displayedTime = displayedTime..utcTime end

	displayedTime = displayedTime:gsub(" | $", "") -- remove trailing seperator

	self:SetText(("|cff%02x%02x%02x%s|r"):format(db.r*255, db.g*255, db.b*255, displayedTime))
end
