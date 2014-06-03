local dice = require('rl-dice/dice')
local total_dice, total_rerolls, total_bonus
local dice_num, dice_faces

local function conversion(roll)
  if type(roll) == 'string' then
    roll = dice:new(roll)
  elseif type(roll) == 'number' then
    roll = dice:new('1d'..roll)
  elseif type(roll) == 'table' then
    -- already table format
  end
  return roll	
end

local function table_copy(t)
  local t2 = {}
  for k,v in pairs(t) do t2[k] = v end
  return t2
end

local function trimReroll(roll_set)
  local sort_pattern = total_rerolls>0 and (function(a,b) return a>b end) or (function(a,b) return a<b end)   
  for set=1, #roll_set do     
    table.sort(roll_set[set], sort_pattern)     
    for i=dice_num+1, total_dice do roll_set[set][i] = nil end    
  end
  return roll_set
end


local function setupResults(low, high) 
  local results = {} 
  for i=low, high do results[i] = 0 end 
  return results 
end

local function tallyTotal(roll_set, odds_range)
  for i=1, #roll_set do
    local dice_sum = 0
    for _,value in ipairs(roll_set[i]) do dice_sum = dice_sum + value end
    dice_sum = dice_sum + total_bonus
    odds_range[dice_sum] = odds_range[dice_sum] + 1 
  end  
  return odds_range
end

local function diceLoop(roll_outcomes, set, sequence)   
  if sequence >= total_dice then 
    roll_outcomes[#roll_outcomes+1] = set
    return 
  end
  
  sequence = sequence + 1
  for i=1, dice_faces do
    if sequence == #set then set[#set] = i
    else set[#set+1] = i end  
    local next_set = table_copy(set)
    diceLoop(roll_outcomes, next_set, sequence) 
  end
  
  if sequence == 1 then return roll_outcomes end
end

local function tallyDice(dice, odds_range)
  local list, set, sequence = {}, {}, 0
  local roll_list = diceLoop(list, set, sequence)
  
  if total_rerolls ~= 0 then roll_list = trimReroll(roll_list) end  
  roll_list = tallyTotal(roll_list, odds_range)
  return roll_list
end

local function roundOdds(odds, denominator)
  for i=odds.low, odds.high do odds[i] = odds[i]/denominator end 
  return odds
end

local function getAverage(odds)
  local average = 0
  for i=odds.low, odds.high do average = average + i*odds[i] end
  return average
end

local function determine_odds(roll)
  local roll = conversion(roll)
  
  dice_num, dice_faces = roll:getNum(), roll:getFaces()
  total_rerolls, total_bonus = roll:getTotalRerolls(), roll:getTotalBonus()
  total_dice = dice_num + math.abs(total_rerolls)

  local max, min = dice_num*dice_faces + total_bonus, dice_num + total_bonus 
  
  local total_combinations = dice_faces^total_dice    
  local number_range = setupResults(min, max)  
  local odds = tallyDice(roll, number_range)
  
  odds.low, odds.high = min, max  
  odds = roundOdds(odds, total_combinations)  
  odds.average = getAverage(odds)
  return odds 
end 

local function printOdds(odds)
  local min, max, average = odds.low, odds.high, odds.average
  
  print()
  print('Dice Odds:')
  for i=min, max do
    print('['..i..'] = '..odds[i]..'%')
  end      
  
  print( 'min='..min..' ('..odds[min]..'%)', 'max='..max..' ('..odds[max]..'%)', 'average='..average) 
end

return determine_odds
