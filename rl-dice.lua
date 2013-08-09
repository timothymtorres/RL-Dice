local Dice = {}

--[[-- DICE INDEX -----
  {x}d{y}+{s}{z}^{r}
	x - number of dice being rolled
	y - faces of the dice
	z - a value to be added to the result (can be negative)
	r - rerolls, if + then remove lowest rolls, if - then remove highest rolls
	s - if double sign (++ or --) adds {z} value to all dice rolls (default is last roll) 
	
	Examples:
	
		  1d6 = Roll 1 six sided die
		  3d4 = Roll 3 dice with four sides
	    2d4+1 = Roll 2 dice with four sides, add +1 to last roll
	   3d3++1 = Roll 3 dice with three sides, add +1 to all rolls
	   3d3--1 = Roll 3 dice with three sides, add -1 to all rolls
	   2d6^+2 = Roll 4 dice with six sides, remove the two lowest rolls
	 3d4-2^-1 = Roll 3 dice with four sides, remove the highest roll, add -1 to last roll
------   FINISH  --]]--

function Dice.roll(str)
	if type(str) ~= 'string' or not str:match('%d+[d]%d+') then return error("dice string expected") end
	
	local num_dice = tonumber(str:sub(1, 1)) or 0  -- 1st character is always # of dice used
	if not (num_dice > 0) then return false end  -- if no dice then exit
	
	local dice_faces = tonumber(str:sub(3, 3)) or 0  -- 3rd character is always # of sides on dice
	
	local str_b = str:match('[^%^+-][+-][+-]?%d+') or '' 
	local double_sign = str_b:sub(2,3) == '++' or str_b:sub(2,3) == '--' or nil -- if ++ or --, then bonus to all dice
	local bonus = tonumber(str_b:match('[+-]%d+'))
	
	local str_r = str:match('[%^][+-]%d+') or ''
	local rerolls = tonumber(str_r:match('[+-]%d+'))
	
	return Dice.determine(num_dice, dice_faces, bonus, double_sign, rerolls)	-- time to roll the dice 	
end

function Dice.shuffle(tab)
  local len = #tab
  local r
  for i = 1, len do
    r = math.random(i, len)
    tab[i], tab[r] = tab[r], tab[i]
  end
end

function Dice.determine(num_dice, dice_faces, bonus, double_sign, rerolls)	
	local rolls = {}
	local rerolls = rerolls or 0
	local bonus_all = double_sign and bonus or 0
	
	for i=1, num_dice + math.abs(rerolls) do
		rolls[i] = math.random(1, dice_faces) + bonus_all
	end
	
	if rerolls ~= 0 then
		-- sort and if reroll is + then remove lowest rolls, if reroll is - then remove highest rolls 
		if rerolls > 0 then table.sort(rolls, function(a,b) return a>b end) else table.sort(rolls) end
		for i=num_dice + 1, #rolls do rolls[i] = nil end
		Dice.shuffle(rolls) -- to make the rolls random and out of order
	end
	
	
	if not double_sign and bonus then
		rolls[#rolls] = rolls[#rolls] + bonus  -- adds bonus to last roll by default
	end
	
	return unpack(rolls)
end

return Dice

