local dice = {}

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

function dice.roll(dice)
	if type(dice) == 'string' then
		dice = dice.getDice(dice)
		return {determine(dice.num, dice.faces, dice.bonus, dice.double_b, dice.rerolls, dice.double_r)}
	elseif type(dice) == 'number' then
		return {math.random(1, dice)}
	elseif type(dice) == 'table' then
		return {determine(dice.num, dice.faces, dice.bonus, dice.double_b, dice.rerolls, dice.double_r)}      
	end	
end

-- percent must be a decimal (ie. .75 = 75%)
function dice.chance(percent) return percent >= math.random() end

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

        dice.double_r = str_r:sub(2,3) == '++' or str_b:sub(2,3) == '--' or nil  -- if ++ or --, then reroll all dice

	dice.rerolls = tonumber(str_r:match('[+-]%d+'))	
	return dice
end

function dice.getString(dice_tbl)
	local num_dice, dice_faces, bonus, double_sign_bonus, rerolls, double_sign_reroll = dice_tbl.num, dice_tbl.faces, dice_tbl.bonus, dice_tbl.double_b, dice_tbl.rerolls, dice_tbl.double_r
	if not num_dice or not dice_faces then return error('Dice string incorrectly formatted.  Missing num_dice or dice_faces.') 
	elseif double_sign_bonus and not bonus then return error('Dice string incorrectly formatted. Double_sign exists but missing bonus.') end

	local str = ''

	rerolls = rerolls and '^'..string.format('%+d', rerolls) or ''
        if double_sign_reroll then rerolls = (tonumber(rerolls) > 0 and '+'..rerolls) or (tonumber(bonus) < 0 and '-'..rerolls) end        
	
	bonus = bonus and string.format('%+d', bonus) or ''
	if double_sign_bonus then bonus = (tonumber(bonus) > 0 and '+'..bonus) or (tonumber(bonus) < 0 and '-'..bonus) end

	str = num_dice..'d'..dice_faces..bonus..rerolls
	return str
end

return dice
