RL-Dice
=======

A module to be used with conventional Roguelike dice strings.

USAGE
-----

First load the module:

    local Dice = require 'rl-dice'

Then to use, it is really simple:

    print(Dice.roll('3d6')) -- 2,6,5

There are also additional methods not normally seen in roguelikes, like applying bonuses to all dice, or rerolls.

Dice Index
----------

{x}d{y}+{s}{z}^{r}	

x - Number of dice  
y - Faces of the dice	 
z - Bonus value to be added to the last roll result (can be negative)	 
r - Rerolls, if + then remove lowest rolls, if - then remove highest rolls  
s - If double sign (++ or --) adds {z} value to ALL dice rolls  
	
Examples:
	
  	      1d6 = Roll 1 six sided die
		  3d4 = Roll 3 dice with four sides
	    2d4+1 = Roll 2 dice with four sides, add +1 to last roll
	   3d3++1 = Roll 3 dice with three sides, add +1 to all rolls
	   3d3--1 = Roll 3 dice with three sides, add -1 to all rolls
	   2d6^+2 = Roll 4 dice with six sides, remove the two lowest rolls
	 3d4-2^-1 = Roll 3 dice with four sides, remove the highest roll, add -1 to last roll
	 
Remember!
---------

* The variable needs to be in string format!
* You must put a pos or neg sign in front of the bonus or reroll! (if you are going to use them)
* Double sign, bonus value, and rerolls are optional.

