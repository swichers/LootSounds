local ADDON_ID = "LootSounds"
LootSounds = LibStub("AceAddon-3.0"):NewAddon(ADDON_ID, "AceConsole-3.0", "AceEvent-3.0")
LootSounds.ADDON_ID = ADDON_ID
LootSounds.Sounds = {}
LootSounds.nextAllowedPlay = 0

LootSounds.defaultOptions = {
  ["minDuration"] = 5,
  ["ignoreDuration"] = false,
  ["sounds"] = {
    ["items"] = {},
    ["currency"] = {},
  },
}

local LootSounds_Config
local L

function LootSounds:OnInitialize()

  L = LibStub("AceLocale-3.0"):GetLocale(ADDON_ID)
  self:RegisterSound(L["Default"], L["Default"], [[Sound\Character\EmoteBoredWhistle01.wav]], 5)
end

function LootSounds:OnEnable()

  LootSounds_Config = self:GetModule("LootSounds_Config")

  self:RegisterEvent("CHAT_MSG_LOOT")
  self:RegisterEvent("CHAT_MSG_CURRENCY")
  self:RegisterEvent("CHAT_MSG_SYSTEM")

  self:RegisterChatFunction(CURRENCY_GAINED_MULTIPLE, LootSounds_CurrencyGained)
  self:RegisterChatFunction(CURRENCY_GAINED_MULTIPLE_BONUS, LootSounds_CurrencyGained)

  self:RegisterChatFunction(LOOT_ITEM_SELF_MULTIPLE, LootSounds_ItemGained)
  self:RegisterChatFunction(LOOT_ITEM_PUSHED_SELF_MULTIPLE, LootSounds_ItemGained)
  self:RegisterChatFunction(LOOT_ITEM_BONUS_ROLL_SELF, LootSounds_ItemGained)
  self:RegisterChatFunction(LOOT_ITEM_BONUS_ROLL_SELF_MULTIPLE, LootSounds_ItemGained)
  self:RegisterChatFunction(LOOT_ITEM_CREATED_SELF_MULTIPLE, LootSounds_ItemGained)

  self:RegisterChatFunction(ERR_QUEST_REWARD_ITEM_MULT_IS, LootSounds_ItemGained)

  -- Tested, verified working
  self:RegisterChatFunction(CURRENCY_GAINED, LootSounds_CurrencyGained)
  self:RegisterChatFunction(LOOT_ITEM_SELF, LootSounds_ItemGained)
  self:RegisterChatFunction(LOOT_ITEM_CREATED_SELF, LootSounds_ItemGained)
  self:RegisterChatFunction(LOOT_ITEM_PUSHED_SELF, LootSounds_ItemGained)
  self:RegisterChatFunction(ERR_QUEST_REWARD_ITEM_S, LootSounds_ItemGained)
end

function LootSounds:OnDisable()

  self:UnregisterEvent("CHAT_MSG_LOOT")
  self:UnregisterEvent("CHAT_MSG_CURRENCY")
  self:UnregisterEvent("CHAT_MSG_SYSTEM")
end

function LootSounds:RegisterChatFunction(chatString, handler, endsWithLink)

  MarsMessageParser_RegisterFunction(ADDON_ID, chatString, handler, endsWithLink)
end

function LootSounds:CHAT_MSG_LOOT(event, message)

  MarsMessageParser_ParseMessage(ADDON_ID, message)
end

function LootSounds:CHAT_MSG_CURRENCY(event, message)

  MarsMessageParser_ParseMessage(ADDON_ID, message)
end

function LootSounds:CHAT_MSG_SYSTEM(event, message)

  MarsMessageParser_ParseMessage(ADDON_ID, message)
end

function LootSounds_ItemGained(itemText)

  local _, _, rarity = GetItemInfo(itemText)
  LootSounds:PlayItemSound(rarity)
end

function LootSounds_CurrencyGained(itemText)

  local name, _, quality = GetItemInfo(itemText)
  LootSounds:PlayCurrencySound(name)
end

function LootSounds:RegisterSound(group, name, path, duration)

  if type(group) ~= "string"
    or type(name) ~= "string"
    or type(path) ~= "string" then

    return false
  end

  self.Sounds[group] = self.Sounds[group] or {}
  self.Sounds[group][name] = {
    ["group"] = group,
    ["name"] = name,
    ["path"] = path,
    ["duration"] = duration or 5,
  }

  return true
end

function LootSounds:PlayItemSound(rarity)

  if not self:isValidRarity(rarity) then

    self:Print(string.format(L["Unsupported rarity"], rarity))
    return false
  end

  local rarityName = self:GetItemRarity(rarity)
  local sound = LootSounds_Config.db.profile.sounds.items[rarityName]

  return self:PlaySound(sound)
end

function LootSounds:PlayCurrencySound(currency)

  local sound = LootSounds_Config.db.profile.sounds.currency[currency]
  return self:PlaySound(sound)
end

function LootSounds:PlaySound(sound)

  if (self.nextAllowedPlay > time() or not sound) then

    return false
  end

  local default = self.Sounds[L["Default"]][L["Default"]]
  local has_played = PlaySoundFile(sound.path, "SFX")

  if not has_played and sound.path ~= default.path then

    self:Print(string.format(L["Sound not found"], sound.path))
    return self:PlaySound(default)
  elseif not has_played and sound.path == default.path then

    self:Print(string.format(L["Default sound not found"], default.path))
    return false
  end

  local duration = LootSounds_Config.db.profile.minDuration
  if sound.duration and not LootSounds_Config.db.profile.ignoreDuration then

    duration = sound.duration
  end

  self.nextAllowedPlay = time() + duration

  return true
end

function LootSounds:GetCurrencies()

  local maxSize = GetCurrencyListSize()
  local currencies = {}

  for i = 1, maxSize do

    local name, isHeader, _, isUnused = GetCurrencyListInfo(i)

    if (not isHeader and not isUnused) then

      table.insert(currencies, name)
    end
  end

  table.sort(currencies)

  return currencies
end

function LootSounds:GetItemRarities()

  local rarities = {}

  rarities[L["Poor"]] = 0
  rarities[L["Common"]] = 1
  rarities[L["Uncommon"]] = 2
  rarities[L["Rare"]] = 3
  rarities[L["Epic"]] = 4
  rarities[L["Legendary"]] = 5
  rarities[L["Artifact"]] = 6
  rarities[L["Heirloom"]] = 7

  return rarities
end

function LootSounds:GetItemRarityNames()

  local rarities = self:GetItemRarities()
  local result = {}

  for name, code in pairs(rarities) do

    table.insert(result, name)
  end

  return result
end

function LootSounds:GetItemRarity(rarity)

  local rarities = self:GetItemRarities()

  for name, code in pairs(rarities) do

    if code == rarity then return name
    elseif name == rarity then return code end
  end
end

function LootSounds:isValidRarity(rarity)

  return self:GetItemRarity(rarity) ~= nil
end


function LootSounds:Debug(item)
  self:Print(LibStub("AceSerializer-3.0"):Serialize(item))
end
