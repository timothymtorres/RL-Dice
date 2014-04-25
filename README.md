RL-Dice
=======

A module to be used with conventional Roguelike dice.

Dice Index
----------

{x}d{y}+{s}{z}^+{s}{r}	

x - Number of dice  
y - Faces of the dice	 
z - Bonus value to be added to the last roll result (can be negative)	 
r - Rerolls, if + then remove lowest rolls, if - then remove highest rolls  
s - If double sign (++ or --) adds {z} value to ALL dice rolls and/or {r} rerolls to all dice rolls
	
Examples:
	
  	      1d6 = Roll 1 six sided die
		  3d4 = Roll 3 dice with four sides
	    2d4+1 = Roll 2 dice with four sides, add +1 to last roll
	   3d3++1 = Roll 3 dice with three sides, add +1 to all rolls
	   3d3--1 = Roll 3 dice with three sides, add -1 to all rolls
	   2d6^+2 = Roll 4 dice with six sides, remove the two lowest rolls
	  2d4^++1 = Roll 4 dice with four sides, remove the two lowest rolls
	 3d4-2^-1 = Roll 3 dice with four sides, remove the highest roll, add -1 to last roll

Dice Table
----------

    dice = {
    	num = (+)number, 
    	faces = (+)number, 
    	bonus = (+ or -)number,    -- optional
    	double_b = binary,         -- optional (requires bonus)
    	rerolls = (+ or -)number   -- optional
    	double_r = binary,         -- optional (requires rerolls) 
    }

Usage
-----

First load the module:

    local dice = require('rl-dice')

Then to use, it is really simple:

    print(dice.roll(8)                                              -- {2} (ie. math.random(1, num))
    print(dice.roll({num=5,faces=3})                                -- {3, 1, 1, 2, 3}
    print(dice.roll('3d6'))                                         -- {2,6,5}
    print(dice.getString({num=3, faces=6}))                         -- '3d6'    
    print(dice.getDice('3d6'))                                      -- {num=3, faces=6}    
    print(dice.roll(Dice.getDice(dice.getString({num=3, faces=6}))) -- {2,6,1}
    print(dice.roll(Dice.getString(dice.getDice('3d6'))))           -- {2,6,1}
    print(dice.chance(.72))                                         -- true  (math.random() rolled .27)
    print(dice.chance(.13))                                         -- false (math.random() rolled .51)
There are also additional dice roll methods not normally seen in roguelikes, such as applying bonuses to all dice and the ability to reroll dice.

Methods
-------

dice.roll(num/string/dice_tbl) or dice:roll()

    returns {table array with dice rolls starting at [1]}

dice.chance(decimal)

    returns decimal >= math.random()

dice.getString(dice_tbl) or dice:getString()

    returns "formatted dice string"

dice.getDice(str)

    returns {formatted dice table}


Classes & Metamethods
---------------------

dice:new(num/string/dice_tbl) [returns roll obj]

    weapon = dice:new('1d6')                      -- '1d6'

dice.__add [modify bonus]

    weapon = weapon + 2                           -- '1d6+2'

dice.__mul [modify number of dice]

    weapon = weapon * 3                           -- '3d6+2'
    
dice.__div [modify dice faces]

    weapon = weapon / -2                          -- '3d4+2'
    
dice.__pow [modify dice rerolls]

    weapon = weapon ^ 1                           -- '3d4+2^+1'

dice.__concat [modify double sign (for bonus or rerolls)]

    weapon = weapon .. '++^^'                     -- '3d4++2^++1'
    weapon = weapon .. '+^'                       -- '3d4+2^+1'
    -- '++' or '--' to enable double sign for bonus, '^^' to enable double sign for rerolls
    -- '+' or '-' to enable single sign for bonus, '^' to enable single sign for rerolls

dice.__tostring [returns dice str]

    print(weapon)                                 -- '3d4+2^+1'
    
	 
Probability
-----------

First load the module:

    local odds = require('dice_odds')

Next then all you do is,

    list = odds('1d6')
    list = odds(6)
    list = odds({num=1,faces=6})
    
All return the same table containing:
    
    list.low = (lowest possible roll)
    list.high = (highest possible roll)
    list.average = (average roll)
    
Starting at index [low] and ending at index [high] is chance to roll.

    for i=list.low, list.high do 
      list[i] = (possible roll percent)
    end  

	 
Remember!
---------

* Error message will result if dice are incorrectly formatted.
* You must put a pos or neg sign in front of the bonus or reroll! (if you are going to use them)
* Double sign, bonus value, and rerolls are optional, but number of dice and dice faces are NOT!
* When using dice.roll(), if dice faces or dice num is 0 or neg, it will default to 1.
* Determining probability with rerolls has been omitted and does not factor into the calculation.

Future Features
---------------

* Determine probability with rerolls
* Save probability results into some kind of temp table?
* ???
