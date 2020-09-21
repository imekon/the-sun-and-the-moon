extends Node

class_name Battle

var battle_matrix = []

# Scissors cuts paper => SHIP beats MOON
# Paper covers rock => MOON beats SUN
# Rock crushes lizard => SUN beats ALIEN
# Scissors decapitates lizard => SHIP beats ALIEN
# Lizard eats paper => ALIEN beats MOON
# Rock crushes scissors => SUN beats SHIP
#
# SUN  -> MOON  -> SHIP     -> ALIEN
# ROCK -> PAPER -> SCISSORS -> LIZARD
func initialise():
	var sun =   [  0, -1,  1,  1 ]
	var moon =  [  1,  0, -1, -1 ]
	var ship =  [ -1,  1,  0,  1 ]
	var alien = [ -1,  1, -1,  0 ]
	
	battle_matrix.append(sun)
	battle_matrix.append(moon)
	battle_matrix.append(ship)
	battle_matrix.append(alien)

func process_battle(active_suit, selected_suit):
	var battle = battle_matrix[active_suit][selected_suit]
	var result = { 
		credits = battle, 
		first = active_suit, 
		second = selected_suit 
		}
	return result
