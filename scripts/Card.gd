extends Sprite

onready var top_label = $TopLabel
onready var bottom_label = $BottomLabel
onready var tween = $Tween
onready var blob = $Blob

var card_suit = -1
var card_number = -1
var card_credits = 0
# var location = Globals.UNKNOWN
var row
var column

var tween_start = Vector2()
var tween_end = Vector2()

signal finished_moving

func set_details(number, credits):
	card_credits = credits
	match number:
		1:
			top_label.text = "A"
			bottom_label.text = "A"
		2, 3, 4, 5, 6, 7, 8, 9, 10:
			top_label.text = str(number)
			bottom_label.text = str(number)
		11:
			top_label.text = "J"
			bottom_label.text = "J"
		12:
			top_label.text = "Q"
			bottom_label.text = "Q"
		13:
			top_label.text = "K"
			bottom_label.text = "K"
			
	if credits > 0:
		blob.modulate = Color(1, 1, 0)
	else:
		blob.visible = false
			
func move_to(pos: Vector2):
	tween_start = position
	tween_end = pos
	tween.interpolate_method(self, "on_move", 0, 1, 0.6, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()

func on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed():
		Globals.choose_selected(self)

func on_move(value):
	var x = lerp(tween_start.x, tween_end.x, value)
	var y = lerp(tween_start.y, tween_end.y, value)
	position = Vector2(x, y)

func on_tween_completed(object, key):
	emit_signal("finished_moving")
