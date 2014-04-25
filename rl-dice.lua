local dice = {}
dice.__index = dice

--[[-- DICE INDEX -----
{x}d{y}+{s}{z}^+{s}{r}
    x - number of dice being rolled
    y - faces of the dice
    z - a value to be added to the result (can be negative)
    r - rerolls, if + then remove lowest rolls, if - then remove highest rolls
    s - if double sign (++ or --) adds {z} value to all dice rolls (default is last roll) or {r} rerolls to all dice rolls
    
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

local function shuffle(tab)
	local len = #tab
	local r
	for i = 1, len do
		r = math.random(i, len)
		tab[i], tab[r] = tab[r], tab[i]
	end
end

local function determine(num_dice, dice_faces, bonus, double_sign_bonus, rerolls, double_sign_rerolls)     
	local rolls = {}
	local rerolls_temp = rerolls or 0
	local bonus_all = double_sign_bonus and bonus or 0
  local rerolls = double_sign_rerolls and rerolls_temp*num_dice or rerolls_temp
  
  -- num_dice & dice_faces CANNOT be negative!
  local num_dice, dice_faces = math.max(num_dice, 1), math.max(dice_faces, 1)

	for i=1, num_dice + math.abs(rerolls) do
		rolls[i] = math.random(1, dice_faces) + bonus_all
	end

	if rerolls ~= 0 then
		-- sort and if reroll is + then remove lowest rolls, if reroll is - then remove highest rolls
		if rerolls > 0 then table.sort(rolls, function(a,b) return a>b end) else table.sort(rolls) end
		for i=num_dice + 1, #rolls do rolls[i] = nil end
		shuffle(rolls) -- to make the rolls random and out of order
	end


	if not double_sign_bonus and bonus then
		rolls[#rolls] = rolls[#rolls] + bonus -- adds bonus to last roll by default
	end

	return table.unpack(rolls)
end

--[[
  dice = {
      num = (+)number, 
      faces = (+)number, 
      bonus = (+ or -)number,    -- optional
      double_b = binary,         -- optional (requires bonus)
      rerolls = (+ or -)number   -- optional
      double_r = binary,         -- optional (requires rerolls) 
  }
--]]

function dice:new(roll)
  local roll = (type(roll) == 'table' and roll) or (type(roll) == 'string' and dice.getDice(roll)) or (type(roll) == 'number' and dice.getDice('1d'..roll))
  self.__index = self
  return setmetatable(roll, self)
end

function dice.__add(roll, value)
  roll.bonus = roll.bonus + value
  return dice:new(roll)
end

function dice.__mul(roll, value)
  roll.num = roll.num + value
  return dice:new(roll)  
end

function dice.__div(roll, value)
  roll.faces = roll.faces + value
  return dice:new(roll)  
end

function dice.__pow(roll, value)
  roll.rerolls = roll.rerolls + value
  return dice:new(roll)  
end

function dice.__concat(roll, str)
	local str_b = str:match('[+-][+-]?') or ''  
	local bonus = ((str_b == '++' or str_b == '--') and 'double') or ((str_b == '+' or str_b == '-') and 'single') or nil

	local str_r = str:match('[%^][%^]?') or ''
  local reroll = (str_r == '^^' and 'double') or (str_r == '^' and 'single') or nil
  
  if bonus == 'double' then
    roll.double_b = true
  elseif bonus == 'single' then
    roll.double_b = false
  end
  
  if reroll == 'double' then
    roll.double_r = true
  elseif reroll == 'single' then
    roll.double_r = false
  end
  return dice:new(roll)
end

function dice.__tostring(self)
  return self:getString()
end  

function dice:roll()
	if type(self) == 'string' then
		local roll = dice.getDice(self)
		return {determine(roll.num, roll.faces, roll.bonus, roll.double_b, roll.rerolls, roll.double_r)}
	elseif type(self) == 'number' then
		return {math.random(1, self)}
	elseif type(self) == 'table' then
		return {determine(self.num, self.faces, self.bonus, self.double_b, self.rerolls, self.double_r)}      
	end
end

function dice.chance(percent) -- percent must be a decimal (ie. .75 = 75%)
  return percent >= math.random()
end

function dice.getDice(str)
	if not str:match('%d+[d]%d+') then return error("Dice string incorrectly formatted.") end
	local dice = {}
	dice.num = tonumber(str:match('%d+')) or 0
	if not (dice.num > 0) then return error('No dice to roll?') end -- if no dice then exit

	local str_f = str:match('[d]%d+')
	dice.faces = tonumber(str_f:sub(2)) or 0

	local str_b = str:match('[^%^+-][+-][+-]?%d+') or ''
	dice.double_b = str_b:sub(2,3) == '++' or str_b:sub(2,3) == '--' or nil -- if ++ or --, then bonus to all dice
	dice.bonus = tonumber(str_b:match('[+-]%d+'))

	local str_r = str:match('[%^][+-][+-]?%d+') or ''

  dice.double_r = str_r:sub(2,3) == '++' or str_b:sub(2,3) == '--' or nil -- if ++ or --, then reroll all dice

	dice.rerolls = tonumber(str_r:match('[+-]%d+'))	
	return dice
end

function dice:getString()
	local num_dice, dice_faces, bonus, double_sign_bonus, rerolls, double_sign_reroll = self.num, self.faces, self.bonus, self.double_b, self.rerolls, self.double_r
  
  -- num_dice & dice_faces CANNOT be negative!  
  local num_dice, dice_faces = math.max(num_dice, 1), math.max(dice_faces, 1)
  
	if not num_dice or not dice_faces then return error('Dice string incorrectly formatted.  Missing num_dice or dice_faces.') 
	elseif double_sign_bonus and not bonus then return error('Dice string incorrectly formatted. Double_sign exists but missing bonus.') end   
  
  local double_b = double_sign_bonus and (bonus >= 0 and '+' or '-') or ''
  bonus = (bonus ~= 0 and double_b..string.format('%+d', bonus)) or ''  
    
  local double_r = double_sign_reroll and (rerolls >= 0 and '+' or '-') or ''    
  rerolls = (rerolls ~= 0 and '^'..double_r..string.format('%+d', rerolls)) or ''    

	return num_dice..'d'..dice_faces..bonus..rerolls
end

return dice
