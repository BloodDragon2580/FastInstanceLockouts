local AceGUI = LibStub("AceGUI-3.0")

-- Lokalisierte Texte für verschiedene Sprachen
local localizedTexts = {
    enUS = {
        Links = "Click left to open the Fast Instance Lockouts Frame.",
        Rechts = "Hold right-click to move the Minimap button.",
    },
    deDE = {
        Links = "Zum Öffnen des Fast Instance Lockouts Frame links klicken.",
        Rechts = "Rechtsklick halten, um den Minikarten-Button zu verschieben.",
    },
    -- Weitere Sprachen können hier hinzugefügt werden
}

-- Bestimme die aktuelle Sprache
local locale = GetLocale()

-- Debug-Ausgaben für die Sprache
print("Current Locale:", locale)

-- Setze die Standardwerte, falls die Sprache nicht definiert ist
_G["linksText"] = localizedTexts[locale] and localizedTexts[locale].Links or "Click left to open the Fast Instance Lockouts Frame."
_G["rechtsText"] = localizedTexts[locale] and localizedTexts[locale].Rechts or "Hold right-click to move the Minimap button."

-- Debug-Ausgaben für die Textwerte
print("LinksText:", _G["linksText"])
print("RechtsText:", _G["rechtsText"])

FastInstanceLockouts_Settings = {
	MinimapPos = 45
}

function FastInstanceLockouts_MinimapButton_Reposition()
	FastInstanceLockouts_MinimapButton:SetPoint("TOPLEFT","Minimap","TOPLEFT",52-(80*cos(FastInstanceLockouts_Settings.MinimapPos)),(80*sin(FastInstanceLockouts_Settings.MinimapPos))-52)
end

function FastInstanceLockouts_MinimapButton_DraggingFrame_OnUpdate()

	local xpos,ypos = GetCursorPosition()
	local xmin,ymin = Minimap:GetLeft(), Minimap:GetBottom()

	xpos = xmin-xpos/UIParent:GetScale()+70
	ypos = ypos/UIParent:GetScale()-ymin-70

	FastInstanceLockouts_Settings.MinimapPos = math.deg(math.atan2(ypos,xpos))
	FastInstanceLockouts_MinimapButton_Reposition()
end

function FastInstanceLockouts_MinimapButton_OnClick()
	DEFAULT_CHAT_FRAME.editBox:SetText("/fastlockout") 
	ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
end
