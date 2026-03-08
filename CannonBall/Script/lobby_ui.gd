extends Control
class_name LobbyUI

@onready var scFriendList: ScrollContainer = $Steam/SCC_FriendList
@onready var vbcFirendList: VBoxContainer = $Steam/SCC_FriendList/VBC_FirendList
@onready var btInvite: Button = $Steam/BT_Invite
@onready var btHost: Button = $Steam/BT_Host
@onready var btJoin: Button = $Steam/BT_Join

@onready var scPublicList: ScrollContainer =  $Public/SCC_PublicList
@onready var vbcPublicList: VBoxContainer = $Public/SCC_PublicList/VBC_PublicList
@onready var btHostPublic: Button = $Public/BT_HostPublic
@onready var btFindPublic: Button = $Public/BT_FindPublic
@onready var btJoinPublic: Button = $Public/BT_JoinPublic

@onready var credit: Panel = $Creddit

## 튜토리얼
@onready var tutorial: Panel = $Tutorial
@onready var tutorial_title: Label = $Tutorial/TutorialTitle
@onready var t1: Control = $Tutorial/T1_KeySetting
@onready var t2: Control = $Tutorial/T2_Rules
@onready var t3: Control = $Tutorial/T3_Shell
@onready var t4: Control = $Tutorial/T4_Field

@onready var bt_prev: Button = $Tutorial/BT_Prev
@onready var bt_next: Button = $Tutorial/BT_Next
@onready var chapter1: ColorRect = $Tutorial/Chapter1
@onready var tutorial_videos: Array[VideoStreamPlayer] = [$Tutorial/T2_Rules/VSP_Tutorial_1, $Tutorial/T2_Rules/VSP_Tutorial_2, $Tutorial/T3_Shell/VSP_Tutorial_3, $Tutorial/T3_Shell/VSP_Tutorial_4, $Tutorial/T3_Shell/VSP_Tutorial_5, $Tutorial/T4_Field/VSP_Tutorial_6, $Tutorial/T4_Field/VSP_Tutorial_7, $Tutorial/T4_Field/VSP_Tutorial_8, $Tutorial/T4_Field/VSP_Tutorial_9, $Tutorial/T4_Field/VSP_Tutorial_10]

@onready var invite_btn: Button = $Steam/BT_Invite

var tutorial_page: int = 0
var tutorial_titles = ["Keys", "Rules", "Shells", "Field"]


var uiMgr: UIManager = null
var lobby: Lobby = null

func _enter_tree() -> void:
	uiMgr = get_parent() as UIManager
	lobby = uiMgr.root.sceneMgr.currentScene as Lobby

func _ready() -> void:
	if uiMgr.root.invite_steam_id:
		uiMgr.root.invite_steam_name =  Steam.getFriendPersonaName(uiMgr.root.invite_steam_id)
		scFriendList.visible = false
		btInvite.text = uiMgr.root.invite_steam_name
		btHost.disabled = false

	for i in range(0, 10, 1):
		tutorial_videos[i].volume = 0
			
	set_tutorial_page(tutorial_page)

func _process(delta: float) -> void:
	if uiMgr.root.my_steam_id:
		btInvite.disabled = false
	else:
		btInvite.disabled = true
		invite_btn.text = "Please run and login Steam client\nand restart the game."


# Multiplay Menu - Public
func _on_bt_host_public_pressed() -> void:
	uiMgr.root.invite_steam_id = 0
	lobby.host_lobby()

func _on_bt_find_public_pressed() -> void:
	if scPublicList.visible:
		scPublicList.visible = false
	else:
		lobby.refresh_public_list()
		scPublicList.visible = true

func _on_bt_join_public_pressed() -> void:
	lobby.join_lobby(lobby.selected_public_lobby_id)

# Multiplay Menu - Private

func _on_bt_invite_pressed() -> void:
	if scFriendList.visible:
		scFriendList.visible = false
	else:
		lobby.refresh_firend_list()
		scFriendList.visible = true

func _on_bt_host_pressed() -> void:
	lobby.host_lobby()

func _on_bt_join_pressed() -> void:
	lobby.join_lobby(uiMgr.root.steam_lobby_id)
	

# quit button

func _on_bt_quit_pressed() -> void:
	get_tree().quit(0)

# Credit button

func _on_bt_credit_pressed() -> void:
	credit.visible = true

func _on_bt_close_credit_pressed() -> void:
	credit.visible = false

##  Tutorial Buttons

func _on_bt_tutorial_pressed() -> void:
	tutorial.visible = true
	tutorial_page = 0
	set_tutorial_page(tutorial_page)

func _on_bt_close_tutorial_pressed() -> void:
	tutorial.visible = false

func _on_bt_prev_pressed() -> void:
	tutorial_page = clamp(tutorial_page - 1, 0, 3)
		
	set_tutorial_page(tutorial_page)

func _on_bt_next_pressed() -> void:
	tutorial_page = clamp(tutorial_page + 1, 0, 3)

	set_tutorial_page(tutorial_page)
	
func set_tutorial_page(page: int) -> void:
	if tutorial_page in [1, 2]:
		bt_prev.disabled = false
		bt_next.disabled = false
	elif tutorial_page == 0:
		bt_prev.disabled = true
		bt_next.disabled = false
	elif tutorial_page == 3:
		bt_prev.disabled = false
		bt_next.disabled = true
		
	var pages: Array[Control] = [t1, t2, t3, t4]
	for p in pages:
		p.visible = false
	pages[page].visible = true
	
	var chapter: ColorRect = chapter1
	for i in range(0, 4, 1):
		if i == page:
			chapter.color = Color(0, 0, 0)
		else:
			chapter.color = Color(1, 1, 1)
		
		if chapter.get_child_count() > 0:
			chapter = chapter.get_child(0) as ColorRect
	
	tutorial_title.text = tutorial_titles[page]

	for i in range(0, 10, 1):
		tutorial_videos[i].stop()

	var video_nums: Array[int] = []
	match tutorial_page:
		1: video_nums = [0, 1]
		2: video_nums = [2, 3, 4]
		3: video_nums = [5, 6, 7, 8, 9]
	
	for i in video_nums:
		tutorial_videos[i].play()
