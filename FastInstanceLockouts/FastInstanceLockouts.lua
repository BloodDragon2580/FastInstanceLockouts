-- Übersetzungen für verschiedene Sprachen
local translations = {
    ["enUS"] = {
        lockPosition = "Lock Position",
        frameTitle = "Fast Instance Lockouts",
        noLockouts = "No lockouts found."
    },
    ["deDE"] = {
        lockPosition = "Position sperren",
        frameTitle = "Fast Instance Lockouts",
        noLockouts = "Keine Sperren gefunden."
    },
    ["frFR"] = {
        lockPosition = "Verrouiller la position",
        frameTitle = "Fast Instance Lockouts",
        noLockouts = "Aucun verrou trouvé."
    },
    ["esES"] = {
        lockPosition = "Bloquear posición",
        frameTitle = "Fast Instance Lockouts",
        noLockouts = "No se encontraron bloqueos."
    },
    ["itIT"] = {
        lockPosition = "Blocca posizione",
        frameTitle = "Fast Instance Lockouts",
        noLockouts = "Nessun blocco trovato."
    }
}

-- Funktion zum Abrufen der aktuellen Sprache und Rückgabe der Übersetzungen
local function GetLocaleTranslation()
    local locale = GetLocale()  -- Holen Sie sich die aktuelle Lokalisierung
    return translations[locale] or translations["en"]  -- Rückfall auf Englisch, falls nicht unterstützt
end

-- Erstellen eines Frames für das Addon
local frame = CreateFrame("Frame", "FastInstanceLockoutsFrame", UIParent, "BackdropTemplate")
frame:SetSize(350, 250)
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:SetResizable(true)  -- Frame als resizable markieren
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function(self)
    if not FastInstanceLockoutsDB.isLocked then
        self:StartMoving()
    end
end)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:Hide()

-- Modernes Design mit abgerundeten Ecken und einem halbtransparenten Hintergrund
frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
frame:SetBackdropColor(0, 0, 0, 0.8)  -- Schwarzer, halbtransparenter Hintergrund
frame:SetBackdropBorderColor(1, 1, 1, 0.2)  -- Leichte, weiße Umrandung

-- Ermitteln der aktuellen Sprache
local locale = GetLocaleTranslation()

-- Titel für das Fenster
frame.title = frame:CreateFontString(nil, "OVERLAY")
frame.title:SetFontObject("GameFontNormalLarge")
frame.title:SetPoint("TOP", frame, "TOP", 0, -10)
frame.title:SetText(locale.frameTitle)

-- Textfeld für die Anzeige der Instanzsperren
frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
frame.text:SetJustifyH("LEFT")
frame.text:SetPoint("TOPLEFT", 15, -40)
frame.text:SetPoint("BOTTOMRIGHT", -15, 15)
frame.text:SetText(locale.noLockouts)

-- Erstellen einer modernen Schaltfläche zum Schließen
frame.closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
frame.closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)

-- Funktion zum Abrufen und Anzeigen der Instanzsperren
local function UpdateInstanceLockouts()
    local lockoutText = ""
    for i = 1, GetNumSavedInstances() do
        local name, id, reset, difficulty, locked = GetSavedInstanceInfo(i)
        if locked then
            lockoutText = lockoutText .. name .. " (ID: " .. id .. ", Reset in: " .. SecondsToTime(reset) .. ")\n"
        end
    end
    frame.text:SetText(lockoutText ~= "" and lockoutText or locale.noLockouts)
end

-- Resize Handle zum Anpassen der Größe
local resizeButton = CreateFrame("Button", nil, frame)
resizeButton:SetPoint("BOTTOMRIGHT")
resizeButton:SetSize(16, 16)

resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")

resizeButton:SetScript("OnMouseDown", function(self)
    frame:StartSizing("BOTTOMRIGHT")
end)

resizeButton:SetScript("OnMouseUp", function(self)
    frame:StopMovingOrSizing()
    
    -- Speichere die neue Größe in der Datenbank
    FastInstanceLockoutsDB.width = frame:GetWidth()
    FastInstanceLockoutsDB.height = frame:GetHeight()
end)

-- Checkbox zum Sperren/Verschieben des Frames
local lockCheckbox = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
lockCheckbox:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 10, 10)
lockCheckbox.text:SetText(locale.lockPosition)
lockCheckbox:SetChecked(false)

-- Funktion zum Sperren/Entsperren der Position
lockCheckbox:SetScript("OnClick", function(self)
    FastInstanceLockoutsDB.isLocked = self:GetChecked()
end)

-- Slash-Befehl zum Öffnen und Schließen des Frames
SLASH_FASTINSTANCELOCKOUTS1 = "/fastlockout"
SlashCmdList["FASTINSTANCELOCKOUTS"] = function()
    if frame:IsShown() then
        frame:Hide()
        FastInstanceLockoutsDB.isShown = false
    else
        UpdateInstanceLockouts()
        frame:Show()
        FastInstanceLockoutsDB.isShown = true
    end
end

-- Speichern der Frame-Position und des Sichtbarkeitsstatus
frame:SetScript("OnHide", function()
    local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
    FastInstanceLockoutsDB.point = point
    FastInstanceLockoutsDB.relativePoint = relativePoint
    FastInstanceLockoutsDB.xOfs = xOfs
    FastInstanceLockoutsDB.yOfs = yOfs
end)

-- Laden der Frame-Position und des Sichtbarkeitsstatus, wenn die UI vollständig geladen ist
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
    if not FastInstanceLockoutsDB then
        FastInstanceLockoutsDB = {
            point = "CENTER",
            relativePoint = "CENTER",
            xOfs = 0,
            yOfs = 0,
            isShown = true, -- Standardmäßig auf "true" setzen
            width = 350, -- Standardbreite
            height = 250, -- Standardhöhe
            isLocked = false -- Standardmäßig nicht gesperrt
        }
    end
    
    frame:ClearAllPoints()
    frame:SetPoint(FastInstanceLockoutsDB.point, UIParent, FastInstanceLockoutsDB.relativePoint, FastInstanceLockoutsDB.xOfs, FastInstanceLockoutsDB.yOfs)
    
    -- Verwende Standardwerte, falls width oder height noch nicht gesetzt sind
    local width = FastInstanceLockoutsDB.width or 350
    local height = FastInstanceLockoutsDB.height or 250
    
    frame:SetSize(width, height)
    
    -- Setze den Sperrstatus der Checkbox
    lockCheckbox:SetChecked(FastInstanceLockoutsDB.isLocked)
    
    if FastInstanceLockoutsDB.isShown then
        UpdateInstanceLockouts()
        frame:Show()
    end
end)
