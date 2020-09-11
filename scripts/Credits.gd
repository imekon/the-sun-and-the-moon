extends Node2D

func on_back_pressed():
	get_tree().change_scene("res://scenes/Welcome.tscn")

func on_label_meta_clicked(meta):
	OS.shell_open(meta)
	
