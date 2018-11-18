extends PanelContainer

onready var music_slider = $Panel/Music/MusicSlider
onready var sfx_slider = $Panel/SFX/MusicSlider

func on_close_pressed():
	get_tree().change_scene("res://scenes/Welcome.tscn")

func on_music_pressed():
	Globals.music_mute = !Globals.music_mute

func on_sfx_pressed():
	Globals.sfx_mute = !Globals.sfx_mute

func on_music_changed():
	Globals.music_db = Globals.convert_gain_to_db(music_slider.value / 100.0)

func on_sfx_changed():
	Globals.sfx_db = Globals.convert_gain_to_db(sfx_slider.value / 100)
