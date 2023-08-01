@tool
@icon("res://addons/godogram/icon.png")
extends EditorPlugin

var dock

func _enter_tree():
	print('GodoGram activated!')
	add_autoload_singleton('GodoGramAPI', "res://addons/godogram/godogram.gd")
	dock = preload("res://addons/godogram/dock.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_LEFT_UR, dock)
	add_custom_type("GodoGram", "HTTPRequest", preload("res://addons/godogram/godogram.gd"), preload("res://addons/godogram/icon.png"))


func _exit_tree():
	print('GodoGram deactivated!')
	remove_autoload_singleton('GodoGramAPI')
	remove_control_from_docks(dock)
	dock.free()
	remove_custom_type("GodoGram")
