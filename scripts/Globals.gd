extends Node

enum SUITS { SUN, MOON, SHIP, ALIEN }
# enum LOCATION { UNKNOWN, PILE, DISCARD, PICKUP }

var card_scaling = Vector2(0.7, 0.7)

var selected_card = null

var suit_names = [ "Sun", "Moon", "Ship", "Alien" ]

func clear_selected():
	selected_card = null
	
func choose_selected(card):
	if card == null:
		return
		
	if selected_card != null:
		if selected_card.row < card.row:
			selected_card = card
	else:
		selected_card = card