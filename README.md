[![Build Status](https://app.travis-ci.com/timothymtorres/RL-Dice.svg)](https://app.travis-ci.com/timothymtorres/RL-Dice)
[![Coverage Status](https://coveralls.io/repos/github/timothymtorres/RL-Dice/badge.svg)](https://coveralls.io/github/timothymtorres/RL-Dice)
[![github](https://img.shields.io/github/license/timothymtorres/RL-Dice.svg)](https://choosealicense.com/licenses/mit/)
[![tags](https://img.shields.io/github/tag/timothymtorres/RL-dice.svg?label=version)](https://github.com/timothymtorres/RL-Dice/tags)
[![commit](https://img.shields.io/github/last-commit/timothymtorres/rl-dice.svg)](https://github.com/timothymtorres/RL-Dice/commits/master)

RL-Dice
=======

A robust module to roll and manipulate roguelike dice.  This has also been included in [rotLove](https://github.com/paulofmandown/rotLove) roguelike toolkit which I highly recommend if you plan on making a roguelike.

This library is compatible with:

* Lua 5.1
* Lua 5.2
* Luajit 2.0
* Luajit 2.1
* Love2D

Consult the [online documentation](https://timothymtorres.github.io/RL-Dice) for the API and usage examples.  

The dice module provides the following:

* Dice notation strings - used to create or roll dice instances
* Dice number/faces - can be increased or decreased
* Dice bonus - can be increased or decreased
* Dice rerolls - can reroll and filter out via highest or lowest results
* Dice sets - can return multiple results
* Dice pluralism - enable bonus or rerolls to individual dice or to all dice
* Dice caching - reuses dice tables for faster performance

Unit Testing
------------

A LuaUnit test is setup in the tests folder.  There are 15 different tests that check that the metamethods, new instances, dice cache, and notation are all functioning.  To run these tests simply navigate to the test folder on your shell, and execute the command `lua dice_test.lua -v` to see the results.  
