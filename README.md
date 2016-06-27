RL-Dice
=======

A module to be used with conventional Roguelike dice.

Dice Index
----------

({x}d{y}+{s}{z}^+{s}{r})x{v}

x - Number of dice  
y - Faces of the dice	 
z - Bonus value to be added to the last roll result (can be negative)	 
r - Rerolls, if + then remove lowest rolls, if - then remove highest rolls  
s - If double sign (++ or --) adds {z} value to ALL dice rolls and/or {r} rerolls to all dice rolls  
v - Sets of dice used
	
Examples:
	
  	      1d6 = Roll 1 six sided die
		  3d4 = Roll 3 dice with four sides
	    2d4+1 = Roll 2 dice with four sides, add +1 to last roll
	   3d3++1 = Roll 3 dice with three sides, add +1 to all rolls
	   3d3--1 = Roll 3 dice with three sides, add -1 to all rolls
	   2d6^+2 = Roll 4 dice with six sides, remove the two lowest rolls
	  2d4^++1 = Roll 4 dice with four sides, remove the two lowest rolls
	 3d4-2^-1 = Roll 3 dice with four sides, remove the highest roll, add -1 to last roll
	  (1d6)x1 = Roll 1 six sided die (one set)
	  (1d6)x3 = Roll 1 six sided die (three sets)
	  
	  The difference between 3d6 and (1d6)x3 is {3d3} vs {1d6, 1d6, 1d6}
	  Sets return MULTIPLE results where number of dice only returns a SINGLE result or...
	  You could use both!
	  
	  (3d3)x3 = Roll 3 six sided die (three sets)  {3d3, 3d3, 3d3}

Usage
-----

First load the module:

    local dice = require('rl-dice/dice')

Then to use, it is really simple:

    print(dice.roll(8))                                             -- 2 (ie. math.random(1, num))
    print(dice.roll({sets=5,faces=3})                               -- 3, 1, 1, 2, 3
    print(dice.roll('3d6'))                                         -- 12
    print(dice.getString({num=3, faces=6}))                         -- '3d6'    
    print(dice.getDice('3d6'))                                      -- {num=3, faces=6}    
    print(dice.roll(Dice.getDice(dice.getString({set=3, faces=6}))) -- 2,6,1
    print(dice.roll(Dice.getString(dice.getDice('(1d6)x3'))))       -- 2,6,1
    print(dice.chance(.72))                                         -- true  (math.random() rolled .27)
    print(dice.chance(.13))                                         -- false (math.random() rolled .51)
There are also additional dice roll methods not normally seen in roguelikes, such as applying bonuses to all dice and the ability to reroll dice.

Methods
-------

dice.roll(num/string/dice_tbl) or dice:roll()

    returns set1, set2, set3, etc.

dice.chance(decimal)

    returns decimal >= math.random()

dice.getString(dice_tbl) or dice:getString()

    returns "formatted dice string"

dice.getDice(str)

    returns {formatted dice table}
    
dice.setMin(minimum)

    sets the lowest possible roll minimum for class default (if nil allows negative results to be rolled)   


Dice Table
----------

    dice = {
    	num = (+)number, 
    	faces = (+)number, 
    	sets = (+)number,	       -- optional
    	bonus = (+ or -)number,    -- optional
    	double_b = binary,         -- optional (requires bonus)
    	rerolls = (+ or -)number   -- optional
    	double_r = binary,         -- optional (requires rerolls) 
    	minimum = number/nil 	   -- optional (nil results in class default (if any) )
    }

Classes & Metamethods
---------------------

dice:new(num/string/dice_tbl, minimum) [returns roll obj]

    weapon = dice:new('1d6')                      -- '1d6'

dice.__add [modify bonus]

    weapon = weapon + 4                           -- '1d6+4'
    
dice.__sub [modify bonus]

    weapon = weapon - 2                           -- '1d6+2'

dice.__mul [modify number of dice]

    weapon = weapon * 2                           -- '3d6+2'
    
dice.__div [modify dice faces]

    weapon = weapon / -2                          -- '3d4+2'
    
dice.__pow [modify dice rerolls]

    weapon = weapon ^ 1                           -- '3d4+2^+1'
    
dice.__mod [modify dice sets]

    weapon = weapon % 2	                          -- '(3d4+1^+1)x3'

dice.__concat [modify double sign (for bonus or rerolls)]

    weapon = weapon .. '++^^'                     -- '(3d4++2^++1)x3'
    weapon = weapon .. '+^'                       -- '(3d4+2^+1)x3'
    -- '++' or '--' to enable double sign for bonus, '^^' to enable double sign for rerolls
    -- '+' or '-' to enable single sign for bonus, '^' to enable single sign for rerolls

dice.__tostring [returns dice str]

    print(weapon)                                 -- '(3d4+2^+1)x3'

Minimums
--------

You can set minimums for the dice result for either the entire class, a single dice instance, or nil. (nil allows negative roll results)

To set the class minimum:

    dice.setMin(0) 				   -- Dice minimum for ALL results is now 0
    
To set a dice instance minimum: (the second argument in dice:new(dice_str, minimum))

    dice:new('1d5', 1)				   -- Dice minimum for ONLY this dice instance is 1

A dice instance minimum overrides a class minimum.  Therefore,

    dice.setMin(0)                                  -- dice class min is 0
    dice_INST = dice:new('1d3-10', 1)               -- dice inst min is 1
    print(dice_INST:roll())                         -- 1

    dice.setMin(nil)                                -- dice class min is nil (can roll negative results)
    dice_INST = dice:new('1d3-5')                   -- dice inst min is nil as well 
    print(dice_INST:roll())                         -- -3

Dice Strings
------------

The dice must follow a certain string format when creating a new dice object or it will raise an error.

    dice_str = '1d5'			     	-- valid
    dice_str = '3d5'			     	-- valid
    dice_str = '(1d3)x1'		     	-- valid
    dice_str = '1d2+1'			     	-- valid
    dice_str = '1d10^+1'		  	    -- valid
    dice_str = '1d5+1^-2'	        	-- valid
    dice_str = '(1d3+8^+3)x3'		    -- valid
    dice_str = ' 1d5'			     	-- not valid (space in front of string)
    dice_str = '+10d5'			     	-- not valid
    dice_str = '5d+5'			     	-- not valid
    dice_str = '3d4+^1'			     	-- not valid
    dice_str = '(1d3)x1+5'		     	-- not valid (bonuses and rerolls have to be inside the sets parenthesis!)
    dice_str = '3d4^3'			     	-- not valid (reroll needs a + or - sign in front of it)
	 
Remember!
---------

* Error message will result if dice are incorrectly formatted.
* You must put a pos or neg sign in front of the bonus or reroll! (if you are going to use them)
* Double sign, bonus value, sets, and rerolls are optional, but number of dice and dice faces are NOT!
* When using dice.roll(), if dice result is 0 or neg, it will default to 1. (unless dice.minimum is set to another value)
