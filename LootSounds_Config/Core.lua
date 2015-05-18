local ADDON_ID = "LootSounds_Config"
LootSounds_Config = LootSounds:NewModule(ADDON_ID)
LootSounds_Config.ADDON_ID = ADDON_ID

-- Used for holding a reference to an AceLocale locale.
local L

-- Used for separating sound groups from sound names when displayed.
local groupDivider = ": "

function LootSounds_Config:OnInitialize()

  L = LibStub("AceLocale-3.0"):GetLocale(ADDON_ID)

  self.db = LibStub("AceDB-3.0"):New(ADDON_ID, { profile = LootSounds.defaultOptions }, true)
  self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
  self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
  self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
end

function LootSounds_Config:OnEnable()

  LibStub("AceConfig-3.0"):RegisterOptionsTable(LootSounds.ADDON_ID, self:GetOptionsTable(), {"lootsounds", "ls"})
  self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(LootSounds.ADDON_ID)
end

function LootSounds_Config:OnProfileChanged(event, database, newProfileKey)

  self.db.profile = database.profile
end

-- Builds the configuration options table for use with AceConfig.
function LootSounds_Config:GetOptionsTable()

  local options = {
    ["name"] = self.ADDON_ID,
    ["type"] = "group",
    ["handler"] = self,
    ["args"] = {
      ["general"] = {
        ["name"] = L["General"],
        ["type"] = "group",
        ["order"] = 1,
        ["args"] = {
          ["general_info"] = {
            ["name"] = L["Duration info"],
            ["type"] = "description",
          },
          ["ignoreDuration"] = {
            ["name"] = L["Ignore duration"],
            ["desc"] = L["Ignore duration description"],
            ["type"] = "toggle",
            ["width"] = "full",
            ["descStyle"] = "inline",
            ["set"] = function(info, val) self.db.profile.ignoreDuration = val end,
            ["get"] = function(info) return self.db.profile.ignoreDuration end,
          },
          ["minDuration"] = {
            ["name"] = L["Minimum duration"],
            ["desc"] = L["Minimum duration description"],
            ["type"] = "range",
            ["width"] = "full",
            ["min"] = 0,
            ["max"] = 120,
            ["softMin"] = 5,
            ["softMax"] = 60,
            ["bigStep"] = 5,
            ["set"] = function(info, val) self.db.profile.minDuration = val end,
            ["get"] = function(info) return self.db.profile.minDuration end,
          },
          ["minDurationDescription"] = {
            ["name"] = L["Minimum duration description"],
            ["type"] = "description",
          },
        }
      },
      ["items"] = {
        ["name"] = L["Item sound selections"],
        ["type"] = "group",
        ["order"] = 2,
        ["args"] = {},
      },
      ["currency"] = {
        ["name"] = L["Currency sound selections"],
        ["type"] = "group",
        ["order"] = 3,
        ["args"] = {},
      },
    }
  }

  local rarities = LootSounds:GetItemRarityNames() or {}
  options.args.items.args = self:BuildSoundDropdowns(rarities, L["Item sound rarity"], L["Item sound rarity description"])

  local currencies = LootSounds:GetCurrencies() or {}
  options.args.currency.args = self:BuildSoundDropdowns(currencies, L["Currency sound type"], L["Currency sound type description"])

  -- Add in profile selection so people can customize per character.
  options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)

  return options
end

-- Builds a table of dropdown options for use with the LSM30_Sound widget using
-- the values contained the given table.
function LootSounds_Config:BuildSoundDropdowns(table, label, desc)

  local args = {}
  for index, name in pairs(table) do

    args[name] = {
      ["name"] = string.format(label, name),
      ["desc"] = string.format(desc, name),
      ["type"] = "select",
      ["width"] = "double",
      ["style"] = "dropdown",
      ["dialogControl"] = "LSM30_Sound",
      ["values"] = "GetSoundOptions",
      ["set"] = "SetSoundSelection",
      ["get"] = "GetSoundSelection",
    }
  end

  return args
end

-- Sets the selected sound for the given option.
function LootSounds_Config:SetSoundSelection(info, val)

  local group, item = unpack(info)

  self.db.profile.sounds[group] = self.db.profile.sounds[group] or {}

  -- User has selected they do not want a sound.
  if val == L["None"] then

    self.db.profile.sounds[group][item] = nil
    return
  end

  -- Look for a sound based on the key returned by LSM30_Sound.
  local sound = self:SoundFromSoundOption(val)
  if sound then

    self.db.profile.sounds[group][item] = sound
  end
end

-- Gets the selected sound for the given option.
function LootSounds_Config:GetSoundSelection(info)

  local group, item = unpack(info)

  if self.db.profile.sounds[group][item] then

    -- We need to convert our stored value into something usable by LSM30_Sound.
    return self:SoundToSoundOption(self.db.profile.sounds[group][item])
  end
end

-- Builds a table of dropdown options for use with the LSM30_Sound widget.
function LootSounds_Config:GetSoundOptions(info)

  local sounds = {}
  sounds[L["None"]] = "none"

  -- Make sure we have a table to work with.
  local registeredSounds = LootSounds.Sounds or {}

  for groupName, group in pairs(registeredSounds) do

    for soundName, sound in pairs(group) do

      local key = self:SoundToSoundOption(sound)
      if key then sounds[key] = sound.path end
    end
  end

  return sounds
end

-- Gets a sound configuration option value from a Sound item.
function LootSounds_Config:SoundToSoundOption(sound)

  if sound.group and sound.name then

    return sound.group .. groupDivider .. sound.name
  end
end

-- Gets a Sound item when given a sound configuration option selection.
function LootSounds_Config:SoundFromSoundOption(soundOption)

  if type(soundOption) ~= "string" then return nil end

  -- Make sure we have a table to work with.
  local registeredSounds = LootSounds.Sounds or {}
  -- Only calculate the divider length once.
  local dividerLen = groupDivider:len()

  -- Loop over our sounds to compare the soundOption value.
  for groupName, group in pairs(registeredSounds) do

    local groupLen = groupName:len()
    local fullLen = groupLen + dividerLen

    -- Compare with divider to help prevent false positives.
    if soundOption:sub(1, fullLen) == (groupName .. groupDivider) then

      for soundName, sound in pairs(group) do

        -- string.sub() will return the string starting at fullLen, we want to
        -- start at the next one.
        if soundOption:sub(fullLen + 1) == soundName then return sound end
      end
    end
  end
end
