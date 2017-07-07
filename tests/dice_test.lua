luaunit = require('luaunit')
package.path = package.path .. ";../dice.lua"
local dice = require('dice')

local margin_of_error = .3
local sample_n = 100000  -- hundred thousand

local function getRollSample(dice_INS)
  local x = 0
  for i=1, sample_n do 
    x = x + dice_INS:roll()
  end
  return x / sample_n
end

--[[
    TEST CACHING
    TEST EACH OF DICE METHODS
    TEST FOR  MEMORY LEAKS
    TEST FOR DELETING PROPERLY
    TEST MIN
    TEST ROLLS
    TEST 
--]]

function TestInstance()
  local d6_1st = dice:new(6)
  local d6_2nd = dice:new('1d6')
  local sample_dice_tbl = {
    bonus=0, faces=6, num=1, sets=1, rerolls=0,
    notation='1d6', is_bonus_plural=false, is_reroll_plural=false
  }
  luaunit.assertEquals(d6_1st, d6_2nd)
  luaunit.assertEquals(d6_1st, sample_dice_tbl)
end

function TestRoll()
  local d6_1st = dice:new(6)
  local d6_2nd = dice:new('1d6')
  local result_1 = getRollSample(d6_1st)
  local result_2 = getRollSample(d6_2nd)
  luaunit.assertAlmostEquals(result_1, 3.5, margin_of_error)
  luaunit.assertAlmostEquals(result_2, 3.5, margin_of_error)
  
  local result_3, result_4 = 0, 0
  for i=1, sample_n do 
    result_3 = result_3 + dice.roll(6)
    result_4 = result_4 + dice.roll('1d6')
  end
  result_3 = result_3 / sample_n  
  result_4 = result_4 / sample_n
  
  luaunit.assertAlmostEquals(result_3, 3.5, margin_of_error)
  luaunit.assertAlmostEquals(result_4, 3.5, margin_of_error)  
end

function TestAdd()
  local d6 = dice:new(6)
  d6 = d6 + 1
  luaunit.assertEquals(d6, dice:new('1d6+1'))
  
  local result_1 = getRollSample(d6)
  luaunit.assertAlmostEquals(result_1, 4.5, margin_of_error)
  
  d6 = d6 + (-1)
  luaunit.assertEquals(d6, dice:new('1d6'))  
  local result_2 = getRollSample(d6)
  luaunit.assertAlmostEquals(result_2, 3.5, margin_of_error)
end

function TestSub()
  local d6 = dice:new(6)
  d6 = d6 - 1
  luaunit.assertEquals(d6, dice:new('1d6-1'))
  local result_1 = getRollSample(d6)
  luaunit.assertAlmostEquals(result_1, 2.65, margin_of_error)
  
  d6 = d6 - (-1)
  luaunit.assertEquals(d6, dice:new('1d6'))  
  local result_2 = getRollSample(d6)
  luaunit.assertAlmostEquals(result_2, 3.5, margin_of_error)  
end

function TestMul()
  local monopoly_dice = dice:new('1d6')
  monopoly_dice = monopoly_dice * 1
  luaunit.assertEquals(monopoly_dice, dice:new('2d6'))
  
  local result_1 = getRollSample(monopoly_dice)
  luaunit.assertAlmostEquals(result_1, 7, margin_of_error)  
  
  monopoly_dice = monopoly_dice * -1
  luaunit.assertEquals(monopoly_dice, dice:new('1d6'))
  
  local result_2 = getRollSample(monopoly_dice)
  luaunit.assertAlmostEquals(result_2, 3.5, margin_of_error)    
end

function TestDiv()
  local die = dice:new('1d6')
  die = die / 2
  luaunit.assertEquals(die, dice:new('1d8'))
  
  local result_1 = getRollSample(die)
  luaunit.assertAlmostEquals(result_1, 4.5, margin_of_error)  
  
  die = die / -2
  luaunit.assertEquals(die, dice:new('1d6'))
  
  local result_2 = getRollSample(die)
  luaunit.assertAlmostEquals(result_2, 3.5, margin_of_error)      
end

function TestExp()
  local die = dice:new('1d6')
  die = die ^ 1
  luaunit.assertEquals(die, dice:new('1d6^+1'))
  
  local result_1 = getRollSample(die)
  luaunit.assertAlmostEquals(result_1, 4.5, margin_of_error)  
  
  die = die ^ -2
  luaunit.assertEquals(die, dice:new('1d6^-1'))
  
  local result_2 = getRollSample(die)
  luaunit.assertAlmostEquals(result_2, 2.5, margin_of_error)  
    
  die = die ^ 1
  luaunit.assertEquals(die, dice:new('1d6'))
  
  local result_3 = getRollSample(die)
  luaunit.assertAlmostEquals(result_3, 3.5, margin_of_error)     
end

function TestMod()
  local die = dice:new('1d6')
  die = die % 1
  luaunit.assertEquals(die, dice:new('(1d6)x2'))
  
  local result_1 = getRollSample(die)
  luaunit.assertAlmostEquals(result_1, 3.5, margin_of_error)  
  
  die = die % -1
  luaunit.assertEquals(die, dice:new('1d6'))
  
  local result_2 = getRollSample(die)
  luaunit.assertAlmostEquals(result_2, 3.5, margin_of_error)  
  
  die = die % 1
  local result_3, result_4 = die:roll()
  luaunit.assertNotNil(result_3)
  luaunit.assertNotNil(result_4)
end

function TestToString()
  local die = dice:new('1d6')
  luaunit.assertEquals(tostring(die), '1d6')
  die = die + 4
  luaunit.assertEquals(tostring(die), '1d6+4')
  die = die - 2
  luaunit.assertEquals(tostring(die), '1d6+2')
  die = die * 2
  luaunit.assertEquals(tostring(die), '3d6+2')
  die = die / -2
  luaunit.assertEquals(tostring(die), '3d4+2') 
  die = die ^ 1
  luaunit.assertEquals(tostring(die), '3d4+2^+1')
  die = die % 2
  luaunit.assertEquals(tostring(die), '(3d4+2^+1)x3')    
end

function TestConcat()
  local die = dice:new('3d1+2')
  die = die .. '++'
  luaunit.assertEquals(tostring(die), '3d1++2') 
  die = die .. '+'
  luaunit.assertEquals(tostring(die), '3d1+2')
  die = die .. '--'
  luaunit.assertEquals(tostring(die), '3d1++2')
  die = die .. '-'
  luaunit.assertEquals(tostring(die), '3d1+2')  
  
  die = die .. '^^'
  luaunit.assertEquals(tostring(die), '3d1+2')  
  die = die .. '^'
  luaunit.assertEquals(tostring(die), '3d1+2')   
  
  
  die = dice:new('2d6^+1')
  die = die .. '^^'
  luaunit.assertEquals(tostring(die), '2d6^++1')  
  die = die .. '^'
  luaunit.assertEquals(tostring(die), '2d6^+1')      
end

function TestMin()
  local d = dice:new('1d3', 3)
  luaunit.assertEquals(d:roll(), 3)
  d = dice:new('1d1-1', 0)
  luaunit.assertEquals(d:roll(), 0)
  
  dice.setClassMin(0)
  
  d = dice:new('1d1-2', nil)
  luaunit.assertEquals(d:roll(), 0)  
  
  dice.setClassMin(nil)
  luaunit.assertEquals(d:roll(), -1)    
  
  dice.setClassMin(1)  -- reset our class min to oringal value
end

function TestBoundry()
  local d = dice:new('3d6')
  d = d / -100
  d = d * -10  -- blaaaah
  d = d % -1
  
  luaunit.assertEquals(d:roll(), 1)
  luaunit.assertEquals(tostring(d), '1d1')
  luaunit.assertEquals(d:getFaces(), -94)  
  luaunit.assertEquals(d:getNum(), -7)
  luaunit.assertEquals(d:getSets(), 0)    
end

function TestValidNotation()
  luaunit.assertError(dice.new, dice, ' 1d5')
  luaunit.assertError(dice.new, dice, '+10d5')
  luaunit.assertError(dice.new, dice, '5d+5')
  luaunit.assertError(dice.new, dice, '3d4+^1')
  luaunit.assertError(dice.new, dice, '(1d3)x1+5')
  luaunit.assertError(dice.new, dice, '3d4^3')
end

function TestComplexPatterns()
  local d = dice:new('(0d0)x0')
  d = d * 1
  d = d / 2
  d = d + 3
  d = d ^ 4
  d = d % 5
  
  luaunit.assertEquals(tostring(d), '(1d2+3^+4)x5')
  luaunit.assertEquals(d:getNum(), 1)
  luaunit.assertEquals(d:getFaces(), 2)
  luaunit.assertEquals(d:getBonus(), 3)
  luaunit.assertEquals(d:getRerolls(), 4)
  luaunit.assertEquals(d:getSets(), 5)  
  
  d = d .. '^^'
  luaunit.assertEquals(tostring(d), '(1d2+3^++4)x5')  
  d = d .. '++'
  luaunit.assertEquals(tostring(d), '(1d2++3^++4)x5')    
  d = d .. '+'
  luaunit.assertEquals(tostring(d), '(1d2+3^++4)x5')
  d = d .. '^'
  luaunit.assertEquals(tostring(d), '(1d2+3^+4)x5')    
  
  d = d * -2
  d = d / -4
  d = d + -6
  d = d ^ -8
  d = d % -10
  
  luaunit.assertEquals(d:getNotation(), '(-1d-2-3^-4)x-5')
  luaunit.assertEquals(d:getNum(), -1)
  luaunit.assertEquals(d:getFaces(), -2)
  luaunit.assertEquals(d:getBonus(), -3)
  luaunit.assertEquals(d:getRerolls(), -4)
  luaunit.assertEquals(d:getSets(), -5)    
  
  luaunit.assertEquals(d:roll(), 1)
  
  d = d .. '--'
  luaunit.assertEquals(d:getNotation(), '(-1d-2--3^-4)x-5')    
  d = d .. '-'
  luaunit.assertEquals(d:getNotation(), '(-1d-2-3^-4)x-5')
  d = d .. '^^'
  luaunit.assertEquals(d:getNotation(), '(-1d-2-3^--4)x-5')    
  luaunit.assertEquals(tostring(d), '1d1-3^--4')
end

function TestCache()
  local d = dice:new('1d1')
  dice.resetCache()
  luaunit.assertEquals(next(dice._cache), nil)
  --for k,v in pairs(dice._cache) do print(k,v) end
end

os.exit(luaunit.LuaUnit.run())