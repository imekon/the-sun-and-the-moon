extends Node

enum SUITS { SUN, MOON, SHIP, ALIEN, SPECIAL }

var card_scaling = Vector2(0.7, 0.7)

var selected_card = null
var music_db = -6
var sfx_db = -6
var music_mute = false
var sfx_mute = false

var suit_names = [ "Sun", "Moon", "Ship", "Alien", "Special" ]

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
		
func convert_gain_to_db(gain):
	if gain < 0.0:
		return -90.0
	else:
		return 20.0 * log(gain) / log(10)
