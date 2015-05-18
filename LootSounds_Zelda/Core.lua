local ADDON_ID = "LootSounds_Zelda"
LootSounds_Zelda = LibStub("AceAddon-3.0"):NewAddon(ADDON_ID)

function LootSounds_Zelda:OnInitialize()

  LootSounds:RegisterSound("Zelda: ALTTP", "Uncommon", self:GetSoundPath("ALTTP", "Small item catch"), 5)
  LootSounds:RegisterSound("Zelda: ALTTP", "Rare", self:GetSoundPath("ALTTP", "Item catch"), 5)
  LootSounds:RegisterSound("Zelda: ALTTP", "Epic", self:GetSoundPath("ALTTP", "Heart container get"), 5)
  LootSounds:RegisterSound("Zelda: ALTTP", "Legendary", self:GetSoundPath("ALTTP", "Spiritual stone get"), 16)
  LootSounds:RegisterSound("Zelda: ALTTP", "Archaeological", self:GetSoundPath("ALTTP", "Secret"), 1)

  LootSounds:RegisterSound("Zelda: OOT", "Uncommon", self:GetSoundPath("OOT", "Small item catch"), 3)
  LootSounds:RegisterSound("Zelda: OOT", "Rare", self:GetSoundPath("OOT", "Item catch"), 2)
  LootSounds:RegisterSound("Zelda: OOT", "Epic", self:GetSoundPath("OOT", "Heart container get"), 4)
  LootSounds:RegisterSound("Zelda: OOT", "Legendary", self:GetSoundPath("OOT", "Spiritual stone get"), 15)

  LootSounds:RegisterSound("Zelda: TP", "Uncommon", self:GetSoundPath("TP", "Small item catch"), 3)
  LootSounds:RegisterSound("Zelda: TP", "Rare", self:GetSoundPath("TP", "Item catch"), 3)
  LootSounds:RegisterSound("Zelda: TP", "Epic", self:GetSoundPath("TP", "Heart container get"), 3)
  LootSounds:RegisterSound("Zelda: TP", "Legendary", self:GetSoundPath("TP", "Treasure chest"), 6)
  LootSounds:RegisterSound("Zelda: TP", "Legendary Long", self:GetSoundPath("TP", "Reveal music"), 19)
  LootSounds:RegisterSound("Zelda: TP", "Archaeological", self:GetSoundPath("TP", "Secret"), 2)
end

function LootSounds_Zelda:GetSoundPath(group, name)

  return string.format("Interface\\AddOns\\LootSounds\\%s\\Sounds\\%s\\%s.ogg", ADDON_ID, group, name)
end
