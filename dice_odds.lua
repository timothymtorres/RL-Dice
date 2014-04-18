local dice = require('rl-dice')

local function conversion(roll)
  if type(roll) == 'string' then
    roll = dice.getDice(roll)
  elseif type(roll) == 'number' then
    roll = {num=1, faces = roll}
  elseif type(roll) == 'table' then
    -- already table format
  end
  return roll	
end

local function dice_loop(num, faces, tbl, count, stack)
  if stack >= num then
    tbl[count] = tbl[count] + 1
    return
  end

  local stack = stack + 1

  for i=1, faces do
    dice_loop(num, faces, tbl, count+i, stack)
  end
  return tbl
end 

local function determine_odds(roll)
  local roll = conversion(roll)
  local num, faces, double_b, double_r = roll.num, roll.faces,  roll.double_b, roll.double_r
  local bonus = roll.bonus or 0
  local rerolls = roll.rerolls or 0
  local max = num*faces + ((double_b and bonus*num) or bonus)
  local min = num + ((double_b and bonus*num) or bonus)
  local odds = {}

  local denominator = faces^num
  local result = 0
  
  local count,stack = 0,0

  for i=min,max do
    odds[i] = 0
  end

  odds = dice_loop(num, faces, odds, count, stack)

  for i=min,max do
    odds[i] = math.ceil(odds[i]/denominator*1000)*.001
  end  

  odds.low = min
  odds.high = max
  odds.average = (max-min)*.5
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
