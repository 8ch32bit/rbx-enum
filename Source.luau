--// Author: 8ch99
--// Date written: 19/01/2025
--// A module that merges all of roblox's enum instances into a custom and modifyable enum environment
--// This can be used for the smooth creation of custom enums, etc.

--[[

MIT License

Copyright (c) 2025 8ch99

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

]]

--!strict

local RobloxEnum = Enum --// because we are overriding it later

--// Typedefs

type Metatable = typeof(setmetatable({}, {}))
type RobloxEnum = Enum

export type Enum = Metatable & {
	Name: string,
	Value: number,
	EnumType: EnumType,
}

export type EnumType = Metatable & {
	[string]: Enum | RobloxEnum,
	
	AddEnumItem: (EnumType, Enum) -> (),
	GetEnumItems: (EnumType) -> { Enum },
}

--// @class Enum

local Enum = {}
Enum.__index = Enum
Enum.__meta = "Enum"

--[[
	@TODO Create a new Enum instance
	@param EnumType: The EnumType instance that this Enum should belong to
	@param Name: The name of the enum
	@param Value: The numerical value of the enum
	@returns Enum
]]
function Enum.new(EnumType: EnumType, Name: string, Value: number): Enum
	local self = setmetatable({} :: Enum, Enum)
	self.EnumType = EnumType
	self.Name = Name
	self.Value = Value or 0
	EnumType:AddEnumItem(self)
	return self
end

--// @class EnumType

local EnumType = {}
EnumType.__index = EnumType
EnumType.__meta = "EnumType"

--[[
	@TODO Create a new EnumType instance
	@returns EnumType
]]
function EnumType.new(): EnumType
	return setmetatable({} :: EnumType, EnumType)
end

--[[
	@TODO Adds an Enum to the EnumType
	@param Enum: The enum to be added
]]
function EnumType:AddEnumItem(Enum: Enum)
	self[Enum.Name] = Enum
end

--[[
	@TODO Gets an array of all Enum's within this EnumType
	@returns The enum items found
]]
function EnumType:GetEnumItems(): {}
	local EnumItems = {}
	for _, Enum in self do
		if Enum.__meta == "Enum" then
			table.insert(EnumItems, Enum)
		end
	end
	return EnumItems
end

--// @module Enums

local Enums = {}

--[[
	@TODO Creates a new Enum, if a custom/roblox one doesn't exist already, and adds it to an EnumType if it exists or creates the new EnumType if it doesn't exist
	@param GivenEnumType: The name of the enum type to add the new Enum to
	@param Name: The name of the enum
	@param Value: The numerical value of the enum
	@returns The new Enum
]]
function Enums:Create(GivenEnumType: string, Name: string, Value: number)
	if GivenEnumType == "Create" or GivenEnumType == "GetEnums" then
		return warn(`Cannot name enum type {GivenEnumType}!`)
	end
	
	local RealEnumType = self[GivenEnumType]
	if typeof(RealEnumType) == "Enum" then
		return warn(`Cannot add custom enum to Roblox EnumType! ({GivenEnumType})`)
	end
	
	if not RealEnumType then
		RealEnumType = EnumType.new()
	end
	
	if RealEnumType[Name] then
		return warn(`Enum '{Name}' already exists in '{GivenEnumType}'!`)
	end
	
	return Enum.new(RealEnumType, Name, Value)
end

--[[
	@TODO Fetches a list of every existing EnumType within the Enums module, including roblox enums
	@returns The compiled array of EnumTypes
]]
function Enums:GetEnums()
	local Enums = {}
	for _, EnumType in self do
		if typeof(EnumType) == "Enum" then
			table.insert(Enums, EnumType)
			continue
		end
		if EnumType.__meta == "EnumType" then
			table.insert(Enums, EnumType)
		end
	end
	return Enums
end

--// load in roblox enums
for _, RobloxEnumType in ipairs(RobloxEnum:GetEnums()) do
	Enums[tostring(RobloxEnumType)] = RobloxEnumType
end

return Enums :: typeof(Enums)
