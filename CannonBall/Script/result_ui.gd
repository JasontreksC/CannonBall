extends Control
class_name ResultUI

@onready var lbResult: Label = $Result
var uiMgr: UIManager = null

func _enter_tree() -> void:
	uiMgr = get_parent() as UIManager

func _ready() -> void:
	match uiMgr.root.sceneMgr.gameResult:
		0:
			lbResult.text = "Defeat"
		1:
			lbResult.text = "Vectory"

func _on_bt_quit_pressed() -> void:
	uiMgr.root.back_to_lobby()
