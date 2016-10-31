--- A library used to roll and manipulate roguelike based dice
-- @classmod dice
-- @author Timothy Torres
-- @copyright 2013
-- @license MIT/X11

local dice = {
  _AUTHOR = 'Timothy Torres',
  _URL     = 'https://github.com/timothymtorres/RL-Dice',
  _DESCRIPTION = 'A robust module to roll and manipulate roguelike dice.',
  _LICENSE = [[
    MIT LICENSE
    Copyright (c) 2013 Timothy Torres
    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:
    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]]
}
dice.minimum = 1 -- class default lowest possible roll is 1  (can set to nil to allow negative rolls) 
local random, max, abs, sort, match, format = math.random, math.max, math.abs, table.sort, string.match, string.format

--- Creates a new dice instance
-- @tparam ?int|string dice_notation Can be either a dice string, or int
-- @tparam[opt] int minimum Sets dice instance roll's minimum result boundaries
-- @treturn dice
function dice:new(dice_notation, minimum)
  -- If dice_notation is a number, we must convert it into the proper dice string format
  if type(dice_notation) ==  'number' then dice_notation = '1d'..dice_notation end
  
  local dice_pattern = '[(]?%d+[d]%d+[+-]?[+-]?%d*[%^]?[+-]?[+-]?%d*[)]?[x]?%d*'
	assert(dice_notation == match(dice_notation, dice_pattern), "Dice string incorrectly formatted.") 

	local dice_INST = {}

	dice_INST.num = tonumber(match(dice_notation, '%d+'))
	dice_INST.faces = tonumber(match(dice_notation, '[d](%d+)'))

	local double_bonus = match(dice_notation, '[^%^+-]([+-]?[+-])%d+')
	local bonus = match(dice_notation, '[^%^+-][+-]?([+-]%d+)')
	dice_INST.is_bonus_plural = double_bonus == '++' or double_bonus == '--' 
	dice_INST.bonus = tonumber(bonus) or 0


	local double_reroll = match(dice_notation, '[%^]([+-]?[+-])%d+')
	local reroll = match(dice_notation, '[%^][+-]?([+-]%d+)')	
	dice_INST.is_reroll_plural = double_reroll == '++' or double_reroll == '--' 
	dice_INST.rerolls = tonumber(reroll) or 0	

	dice_INST.sets = tonumber(match(dice_notation, '[x](%d+)')) or 1

	dice_INST.minimum = minimum	

	self.__index = self
	return setmetatable(dice_INST, self)
end

--- Sets class global for dice minimum
--@tparam[opt] int value Sets dice class minimum result boundaries (if nil, no minimum result)
function dice:setMin(value) self.minimum = value end

--- Number of total dice
-- @treturn int 
function dice:getNum() return self.num end

--- Number of total faces on a dice
-- @treturn int
function dice:getFaces() return self.faces end

--- Bonus to be added to the dice total
-- @treturn int
function dice:getBonus() return self.bonus end

--- Rerolls to be added to the dice
-- @treturn int
function dice:getRerolls() return self.rerolls end

--- Number of total dice sets
-- @treturn int
function dice:getSets() return self.sets end

--- Bonus to be added to all dice (if double bonus enabled) otherwise regular bonus
-- @treturn int
function dice:getTotalBonus() return (self.is_bonus_plural and self.bonus*self.num) or self.bonus end

--- Rerolls to be added to all dice (if double reroll enabled) otherwise regular reroll
-- @treturn int
function dice:getTotalRerolls() return (self.is_reroll_plural and self.rerolls*self.num) or self.rerolls end

--- Determines if all dice are to be rerolled together or individually
-- @treturn bool
function dice:isDoubleReroll() return self.is_reroll_plural end

--- Determines if all dice are to apply a bonus together or individually
-- @treturn bool
function dice:isDoubleBonus() return self.is_bonus_plural end

--- Modifies bonus
-- @tparam int value
-- @treturn dice dice
function dice:__add(value) self.bonus = self.bonus + value return self end

--- Modifies bonus
-- @tparam int value
-- @treturn dice
function dice:__sub(value) self.bonus = self.bonus - value return self end

--- Modifies number of dice
-- @tparam int value
-- @treturn dice
function dice:__mul(value) self.num = self.num + value return self end

--- Modifies amount of dice faces
-- @tparam int value
-- @treturn dice
function dice:__div(value) self.faces = self.faces + value return self end

--- Modifies rerolls
-- @tparam int value
-- @treturn dice
function dice:__pow(value) self.rerolls = self.rerolls + value return self end

--- Modifies dice sets
-- @tparam int value
-- @treturn dice
function dice:__mod(value) self.sets = self.sets + value return self end

--- Gets a formatted dice string in roguelike notation
-- @treturn string
function dice:__tostring()
	local num_dice, dice_faces, bonus, is_bonus_plural, rerolls, is_reroll_plural, sets = self.num, self.faces, self.bonus, self.is_bonus_plural, self.rerolls, self.is_reroll_plural, self.sets
  
	-- num_dice & dice_faces default to 1 if negative or 0!  
	sets, num_dice, dice_faces = max(sets, 1), max(num_dice, 1), max(dice_faces, 1)
  
	local double_bonus = is_bonus_plural and (bonus >= 0 and '+' or '-') or ''
	bonus = (bonus ~= 0 and double_bonus..format('%+d', bonus)) or ''  
    
	local double_reroll = is_reroll_plural and (rerolls >= 0 and '+' or '-') or ''    
	rerolls = (rerolls ~= 0 and '^'..double_reroll..format('%+d', rerolls)) or ''  
  
  if sets > 1 then return '('..num_dice..'d'..dice_faces..bonus..rerolls..')x'..sets 
  else return num_dice..'d'..dice_faces..bonus..rerolls
  end  
end

--- Modifies whether reroll or bonus applies to individual dice or all of them
-- @tparam str pluralism_notation String must be one of the following operators `- + ^` The operator may be double signed to indicate pluralism.  
-- @treturn dice
function dice:__concat(pluralism_notation)
	local str_b = match(pluralism_notation, '[+-][+-]?') or ''  
	local bonus = ((str_b == '++' or str_b == '--') and 'double') or ((str_b == '+' or str_b == '-') and 'single') or nil

	local str_r = match(pluralism_notation, '[%^][%^]?') or ''
	local reroll = (str_r == '^^' and 'double') or (str_r == '^' and 'single') or nil
  
	if bonus == 'double' then self.is_bonus_plural = true
	elseif bonus == 'single' then self.is_bonus_plural = false end
  
	if reroll == 'double' then self.is_reroll_plural = true
	elseif reroll == 'single' then self.is_reroll_plural = false end
	return self
end

--- Rolls the dice 
-- @tparam ?int|dice|str self
-- @tparam[opt] int minimum
function dice.roll(self, minimum)
  if type(self) ~= 'table' then self = dice:new(self, minimum) end
  local num_dice, dice_faces = self.num, self.faces 
  local bonus, rerolls = self.bonus, self.rerolls
  local is_bonus_plural, is_reroll_plural = self.is_bonus_plural, self.is_reroll_plural 
  local sets, minimum = self.sets, self.minimum  
  
  sets = max(sets, 1)  -- Minimum of 1 needed 
  local set_rolls = {}
  
  local bonus_all = is_bonus_plural and bonus or 0
  rerolls = is_reroll_plural and rerolls*num_dice or rerolls

  -- num_dice & dice_faces CANNOT be negative!
  num_dice, dice_faces = max(num_dice, 1), max(dice_faces, 1)
  
  for i=1, sets do
    local rolls = {}
    for ii=1, num_dice + abs(rerolls) do
      rolls[ii] = random(1, dice_faces) + bonus_all  -- if is_bonus_plural then bonus_all gets added to every roll, otherwise bonus_all = 0  
    end

    if rerolls ~= 0 then
      -- sort and if reroll is + then remove lowest rolls, if reroll is - then remove highest rolls
      if rerolls > 0 then sort(rolls, function(a,b) return a>b end) else sort(rolls) end
      for index=num_dice + 1, #rolls do rolls[index] = nil end
    end

    -- bonus gets added to the last roll if it is not plural
    if not is_bonus_plural then rolls[#rolls] = rolls[#rolls] + bonus end
    
    local total = 0
    for _, number in ipairs(rolls) do total = total + number end
    set_rolls[i] = total    
  end

  -- if minimum is empty then use dice class default min
  if minimum == nil then minimum = dice.minimum end

  if minimum then
    for i=1, sets do
      set_rolls[i] = max(set_rolls[i], minimum)
    end
  end  
  
  return unpack(set_rolls)  
end

return dice