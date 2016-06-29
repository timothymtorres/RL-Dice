dice = {}
dice.__index = dice
dice.minimum = 1 -- class default lowest possible roll is 1  (can set to nil to allow negative rolls)

local random, max, abs, sort, match, format = math.random, math.max, math.abs, table.sort, string.match, string.format

--[[-- DICE INDEX -----
{x}d{y}+{s}{z}^+{s}{r}x{v}
    x - number of dice being rolled
    y - faces of the dice
    z - a value to be added to the result (can be negative)
    r - rerolls, if + then remove lowest rolls, if - then remove highest rolls
    s - if double sign (++ or --) adds {z} value to all dice rolls (default is last roll) or {r} rerolls to all dice rolls
    v - sets of dice used
    
    Examples:
    
        1d6 = Roll 1 six sided die
        3d4 = Roll 3 dice with four sides
      2d4+1 = Roll 2 dice with four sides, add +1 to last roll
     3d3++1 = Roll 3 dice with three sides, add +1 to all rolls
     3d3--1 = Roll 3 dice with three sides, add -1 to all rolls
     2d6^+2 = Roll 4 dice with six sides, remove the two lowest rolls
    2d4^++1 = Roll 4 dice with four sides, remove the two lowest rolls
   3d4-2^-1 = Roll 3 dice with four sides, remove the highest roll, add -1 to last roll
------ FINISH --]]--    

local function determine(num_dice, dice_faces, bonus, double_sign_bonus, rerolls, double_sign_rerolls, sets, minimum)
  sets = max(sets, 1)  -- Minimum of 1 needed 
  local set_rolls = {}
  
  local bonus_all = double_sign_bonus and bonus or 0
  rerolls = rerolls or 0
  rerolls = double_sign_rerolls and rerolls*num_dice or rerolls

  -- num_dice & dice_faces CANNOT be negative!
  num_dice, dice_faces = max(num_dice, 1), max(dice_faces, 1)
  
  for i=1, sets do
    local rolls = {}
    for ii=1, num_dice + abs(rerolls) do
      rolls[ii] = random(1, dice_faces) + bonus_all
    end

    if rerolls ~= 0 then
      -- sort and if reroll is + then remove lowest rolls, if reroll is - then remove highest rolls
      if rerolls > 0 then sort(rolls, function(a,b) return a>b end) else sort(rolls) end
      for index=num_dice + 1, #rolls do rolls[index] = nil end
    end

    -- adds bonus to last roll by default
    if not double_sign_bonus and bonus then rolls[#rolls] = rolls[#rolls] + bonus end
    
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

--[[
  dice = {
      num = (+)number, 
      faces = (+)number, 
      sets = (+)number,          -- optional
      bonus = (+ or -)number,    -- optional
      double_b = binary,         -- optional (requires bonus)
      rerolls = (+ or -)number   -- optional
      double_r = binary,         -- optional (requires rerolls) 
      minimum = number/false/nil -- optional (set false for no minimum, set to nil to use dice class default)
  }
--]]

function dice:new(roll, minimum)
	roll = (type(roll) == 'table' and roll) or (type(roll) == 'string' and dice.getDice(roll)) or (type(roll) == 'number' and dice.getDice('1d'..roll))
	roll.minimum = minimum	
	self.__index = self
	return setmetatable(roll, self)
end

function dice:getNum() return self.num end
function dice:getFaces() return self.faces end
function dice:getBonus() return self.bonus end
function dice:getRerolls() return self.rerolls end
function dice:getSets() return self.sets end
function dice:getTotalBonus() return (self.double_b and self.bonus*self.num) or self.bonus end
function dice:getTotalRerolls() return (self.double_r and self.rerolls*self.num) or self.rerolls end
function dice:isDoubleReroll() return self.double_r end
function dice:isDoubleBonus() return self.double_b end

function dice.__add(roll, value) roll.bonus = roll:getBonus() + value return dice:new(roll) end

function dice.__sub(roll, value) roll.bonus = roll:getBonus() - value return dice:new(roll) end

function dice.__mul(roll, value) roll.num = roll:getNum() + value return dice:new(roll) end

function dice.__div(roll, value) roll.faces = roll:getFaces() + value return dice:new(roll) end

function dice.__pow(roll, value) roll.rerolls = roll:getRerolls() + value return dice:new(roll) end

function dice.__mod(roll, value) roll.sets = roll:getSets() + value return dice:new(roll) end

function dice.__tostring(self) return self:getString() end

function dice.__concat(roll, str)
	local str_b = match(str, '[+-][+-]?') or ''  
	local bonus = ((str_b == '++' or str_b == '--') and 'double') or ((str_b == '+' or str_b == '-') and 'single') or nil

	local str_r = match(str, '[%^][%^]?') or ''
	local reroll = (str_r == '^^' and 'double') or (str_r == '^' and 'single') or nil
  
	if bonus == 'double' then roll.double_b = true
	elseif bonus == 'single' then roll.double_b = false end
  
	if reroll == 'double' then roll.double_r = true
	elseif reroll == 'single' then roll.double_r = false end
	return dice:new(roll)
end

function dice:roll()
	if type(self) == 'string' then
		local roll = dice.getDice(self)
		return determine(roll.num, roll.faces, roll.bonus, roll.double_b, roll.rerolls, roll.double_r, roll.sets, roll.minimum)
	elseif type(self) == 'number' then
		return max(random(1, self), dice.minimum)
	elseif type(self) == 'table' then
		return determine(self.num, self.faces, self.bonus, self.double_b, self.rerolls, self.double_r, self.sets, self.minimum)      
	end
end

-- percent must be a decimal (ie. .75 = 75%)
function dice.chance(percent) return percent >= random() end

function dice.getDice(str)
  local dice_pattern = '[(]?%d+[d]%d+[+-]?[+-]?%d*[%^]?[+-]?[+-]?%d*[)]?[x]?%d*'
	if str ~= match(str, dice_pattern) then return error("Dice string incorrectly formatted.") end
	local dice = {}
  
	dice.num = tonumber(match(str, '%d+'))
	dice.faces = tonumber(match(str, '[d](%d+)'))

	local double_bonus, bonus = match(str, '[^%^+-]([+-][+-]?)(%d+)')
	dice.double_b = double_bonus == '++' or double_bonus == '--' 
	dice.bonus = tonumber(bonus) or 0

	local double_reroll, reroll = match(str, '[%^]([+-][+-]?)(%d+)')
	dice.double_r = double_reroll == '++' or double_reroll == '--' 
	dice.rerolls = tonumber(reroll) or 0	
  
  dice.sets = tonumber(match(str, '[x](%d+)')) or 1
	return dice
end

function dice:getString()
	local num_dice, dice_faces, bonus, double_sign_bonus, rerolls, double_sign_reroll, sets = self.num, self.faces, self.bonus, self.double_b, self.rerolls, self.double_r, self.sets
  
	-- num_dice & dice_faces default to 1 if negative or 0!  
	num_dice, dice_faces = max(num_dice, 1), max(dice_faces, 1)
  
	local double_b = double_sign_bonus and (bonus >= 0 and '+' or '-') or ''
	bonus = (bonus ~= 0 and double_b..format('%+d', bonus)) or ''  
    
	local double_r = double_sign_reroll and (rerolls >= 0 and '+' or '-') or ''    
	rerolls = (rerolls ~= 0 and '^'..double_r..format('%+d', rerolls)) or ''  
  
  if sets > 1 then 
    return '('..num_dice..'d'..dice_faces..bonus..rerolls..')x'..sets 
  else 
    return num_dice..'d'..dice_faces..bonus..rerolls
  end
end

function dice.setMin(value) dice.minimum = value end

return dice
