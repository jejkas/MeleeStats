MeleeStats_LastUpdate = GetTime();
function MeleeStats_OnUpdate()
	if MeleeStats_LastUpdate + 0.1 <= GetTime()
	then
		MeleeStats_UpdateString();
	end;
end




SLASH_MeleeStats1 = "/MeleeStats";


SlashCmdList["MeleeStats"] = function(args)
	MeleeStats_(args);
	if args == ""
	then
		MeleeStats_("/MeleeStats lock | hide")
	elseif args == "lock"
	then
		if MeleeStats_Frame:IsMovable()
		then
			MeleeStats_("Frame locked");
			MeleeStats_Settings["frameLocked"] = true;
			MeleeStats_Frame.texture:SetVertexColor(0,0,0,0)
			MeleeStats_Frame:SetMovable(false);
			MeleeStats_Frame:EnableMouse(false);
			MeleeStats_Frame:SetResizable(false);
		else
			MeleeStats_("Frame unlocked");
			MeleeStats_Settings["frameLocked"] = false;
			MeleeStats_Frame.texture:SetVertexColor(0,0,0,0.4)
			MeleeStats_Frame:SetMovable(true);
			MeleeStats_Frame:EnableMouse(true);
			MeleeStats_Frame:SetResizable(true);
		end
	elseif args == "hide"
	then
		if MeleeStats_Frame:IsVisible()
		then
			MeleeStats_Settings["frameShown"] = false;
			MeleeStats_Frame:Hide();
		else
			MeleeStats_Settings["frameShown"] = true;
			MeleeStats_Frame:Show();
		end;
	end
end;



MeleeStats_LastResponsSent = 0;

function MeleeStats_OnEvent()
	if event == "ADDON_LOADED" and arg1 == "MeleeStats"
	then
		if not MeleeStats_Settings
		then
			MeleeStats_Settings = {}
			MeleeStats_Settings["frameLocked"] = false;
			MeleeStats_Settings["frameShown"] = true;
 			MeleeStats_Settings["frameRelativePos"] = "TOPLEFT";
			MeleeStats_Settings["frameXPos"] = 0;
			MeleeStats_Settings["frameYPos"] = 0;
		end
		MeleeStats_MakeFrame();
	end
end
-- /script MeleeStats_UpdateString();
function MeleeStats_UpdateString()
	local tohit, crit, maxCrit, critLeft, miss, attackPower = MeleeStats_GetStats();
	MeleeStats_Frame_Font:SetText(attackPower.."ap h:".. tohit .. "% c:" .. crit .. "% cl:" .. critLeft .. "% m:" .. miss .. "%");
end;


function MeleeStats_GetCrit()
	local i = 1
	while true do
		local spell, rank = GetSpellName(i, BOOKTYPE_SPELL)
		if (not spell) then
			break
		end
	   
		if spell == "Attack"
		then
			MeleeStats_tooltip:SetSpell(i, BOOKTYPE_SPELL);
			local tmpText, text;
			local lines = MeleeStats_tooltip:NumLines();
			tmpText = getglobal("MeleeStats_tooltipTextLeft2");
			text = tmpText:GetText();
			local s = __strsplit("%", text);
			return s[1];
		end;
		i = i + 1
	end
	return 0;
end


-- /script MeleeStats_(MeleeStats_GetStats());
function MeleeStats_GetStats()
	local glance = 40;
	local dodge = 6.5;
	
	local mainSpeed, offSpeed = UnitAttackSpeed("Player");
	
	local miss = 27;
	
	if not offSpeed -- No offhand
	then
		miss = 8;
	end
	
	local tohit = BonusScanner:GetBonus("TOHIT");
	local playerClass, englishClass = UnitClass("player");
	
	-- Rogue checks
	if englishClass == "ROGUE"
	then
		nameTalent, icon, iconx, icony, currRank, maxRank= GetTalentInfo(2,6);
		tohit = tohit + currRank; -- Hit talent.
	end;
	local crit = MeleeStats_GetCrit();
	
	local maxCrit = 100-glance-dodge-miss+tohit;
	local critLeft = maxCrit-crit;
	
	
	-- /script 	local base, posBuff, negBuff = UnitAttackPower("player"); local attackPower = base + posBuff + negBuff; SendChatMessage("AP:"..attackPower)
	local base, posBuff, negBuff = UnitAttackPower("player");
	local attackPower = base + posBuff + negBuff;
	
	return tohit, crit, maxCrit, critLeft, miss-tohit, attackPower;
end;



function MeleeStats_LT()
	local numTabs = GetNumTalentTabs();
	for t=1, numTabs do
		DEFAULT_CHAT_FRAME:AddMessage(GetTalentTabInfo(t)..":");
		local numTalents = GetNumTalents(t);
		for i=1, numTalents do
			nameTalent, icon, iconx, icony, currRank, maxRank= GetTalentInfo(t,i);
			DEFAULT_CHAT_FRAME:AddMessage("- ("..t.." / "..i..")"..nameTalent..": "..currRank.."/"..maxRank);
		end
	end
end;





function MeleeStats_(str)
	local c = ChatFrame1;
	
	if str == nil
	then
		c:AddMessage('BigBrother: NIL'); --ChatFrame1
	elseif type(str) == "boolean"
	then
		if str == true
		then
			c:AddMessage('BigBrother: true');
		else
			c:AddMessage('BigBrother: false');
		end;
	elseif type(str) == "table"
	then
		c:AddMessage('BigBrother: array');
		MeleeStats_printArray(str);
	else
		c:AddMessage('BigBrother: '..str);
	end;
end;

function MeleeStats_printArray(arr, n)
	if n == nil
	then
		 n = "arr";
	end
	for key,value in pairs(arr)
	do
		if type(arr[key]) == "table"
		then
			MeleeStats_printArray(arr[key], n .. "[\"" .. key .. "\"]");
		else
			if type(arr[key]) == "string"
			then
				MeleeStats_(n .. "[\"" .. key .. "\"] = \"" .. arr[key] .."\"");
			elseif type(arr[key]) == "number" 
			then
				MeleeStats_(n .. "[\"" .. key .. "\"] = " .. arr[key]);
			elseif type(arr[key]) == "boolean" 
			then
				if arr[key]
				then
					MeleeStats_(n .. "[\"" .. key .. "\"] = true");
				else
					MeleeStats_(n .. "[\"" .. key .. "\"] = false");
				end;
			else
				MeleeStats_(n .. "[\"" .. key .. "\"] = " .. type(arr[key]));
				
			end;
		end;
	end
end;

function __strsplit(sep,str)
	if str == nil
	then
		return false;
	end;
	local arr = {}
	local tmp = "";
	
	--printDebug(string.len(str));
	local chr;
	for i = 1, string.len(str)
	do
		chr = string.sub(str, i, i);
		if chr == sep
		then
			table.insert(arr,tmp);
			tmp = "";
		else
			tmp = tmp..chr;
		end;
	end
	table.insert(arr,tmp);
	
	return arr
end

-- UI stuff, should be it's own file

function MeleeStats_UI_MoveFrameStart(arg1, frame)
	if not frame.isMoving
	then
		if arg1 == "LeftButton" and frame:IsMovable()
		then
			frame:StartMoving();
			frame.isMoving = true;
		end
	end;
end;

function MeleeStats_UI_MoveFrameStop(arg1, frame)
	if frame.isMoving
	then
		local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
		MeleeStats_Settings["frameRelativePos"] = relativePoint;
		MeleeStats_Settings["frameXPos"] = xOfs;
		MeleeStats_Settings["frameYPos"] = yOfs;
		frame:StopMovingOrSizing();
		frame.isMoving = false;
	end
end;

MeleeStats_Frame = "";
MeleeStats_Frame_Font = "";

function MeleeStats_MakeFrame()
	local f = MeleeStats_Frame;
	f.texture = f:CreateTexture(nil,"OVERLAY");
	f.texture:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background");
	f:SetWidth(500)
	f:SetHeight(30)
	f:SetPoint(MeleeStats_Settings["frameRelativePos"], MeleeStats_Settings["frameXPos"], MeleeStats_Settings["frameYPos"])
	f:SetFrameStrata("MEDIUM")
	
	if MeleeStats_Settings["frameLocked"]
	then
		f.texture:SetVertexColor(0,0,0,0)
	else
		f.texture:SetVertexColor(0,0,0,0.4)
	end
	
	f:SetMovable(not MeleeStats_Settings["frameLocked"]);
	f:EnableMouse(not MeleeStats_Settings["frameLocked"]);
	f:SetResizable(not MeleeStats_Settings["frameLocked"]);
	f.texture:SetAllPoints(f)

	f:SetScript("OnMouseDown", function() MeleeStats_UI_MoveFrameStart(arg1, this); end)
	f:SetScript("OnMouseUp", function() MeleeStats_UI_MoveFrameStop(arg1, this); end)

	MeleeStats_Frame_Font = MeleeStats_Frame:CreateFontString();
	MeleeStats_Frame_Font:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE", "");
	MeleeStats_Frame_Font:SetPoint("LEFT", MeleeStats_Frame, 0, 0)
	MeleeStats_Frame_Font:SetWidth(500);
	MeleeStats_Frame_Font:SetHeight(30);
	MeleeStats_Frame_Font:SetText("BACON");

	if MeleeStats_Settings["frameShown"]
	then
		MeleeStats_Frame:Show();
	end;
end

MeleeStats_Frame = CreateFrame("FRAME", "MeleeStats_Frame");
MeleeStats_Frame:RegisterEvent("ADDON_LOADED");
MeleeStats_Frame:RegisterEvent("PLAYER_LOGIN");
MeleeStats_Frame:RegisterEvent("CHAT_MSG_SYSTEM");
MeleeStats_Frame:RegisterEvent("CHAT_MSG_ADDON");
MeleeStats_Frame:SetScript("OnUpdate", MeleeStats_OnUpdate);
MeleeStats_Frame:SetScript("OnEvent", MeleeStats_OnEvent);