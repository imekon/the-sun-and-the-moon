extends Node2D

onready var label = $PanelContainer/Panel/RichTextLabel

func on_start_pressed():
	get_tree().change_scene("res://scenes/Main.tscn")

func on_credits_pressed():
	get_tree().change_scene("res://scenes/Credits.tscn")

func on_help_pressed():
	get_tree().change_scene("res://scenes/Help.tscn")

func on_label_meta_clicked(meta):
	OS.shell_open(meta)

func on_settings_pressed():
	get_tree().change_scene("res://scenes/Settings.tscn")
