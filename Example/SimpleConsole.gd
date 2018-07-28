extends Control

const SERCOMM = preload("res://bin/GDsercomm.gdns")
onready var PORT = SERCOMM.new()

#helper node
onready var com=$Com 
#use it as node since script alone won't have the editor help

var port

func _ready():
	#adding the baudrates options
	$OptionButton.add_item("")
	for index in com.baud_list: #first use of com helper
		$OptionButton.add_item(str(index))

#_physics_process may lag with lots of characters, but is the simplest way
#for best speed, you can use a thread
#do not use _process due to fps being too high
func _physics_process(delta): 
	if PORT.get_available()>0:
		for i in range(PORT.get_available()):
			$RichTextLabel.add_text(PORT.read())

func _on_SendButton_pressed():
	send_text()

func _on_OptionButton_item_selected(ID):
	set_physics_process(false)
	PORT.close()
	if port!=null and ID!=0:
		PORT.open(port,int($OptionButton.get_item_text(ID)),1000)
	else:
		print("You must select a port first")
	set_physics_process(true)

func _on_UpdateButton_pressed(): #Updates the port list
	$PortList.clear()
	$PortList.add_item("Select Port")
	for index in PORT.list_ports():
		$PortList.add_item(str(index))

func _on_PortList_item_selected(ID):
	port=$PortList.get_item_text(ID)
	$OptionButton.select(0)

func _on_LineEdit_gui_input(ev):
	if ev is InputEventKey and ev.scancode==KEY_ENTER:
		if($LineEdit.text!=""): #due to is_echo not working for some reason
			send_text()

func send_text():
	#LineEdit does not recognize endline
	var text=$LineEdit.text.replace(("\\n"),com.endline)

	if $CheckBox.pressed: #if checkbox is active, add endline
		text+=com.endline

	PORT.write(text) #write function, please use only ascii
	$LineEdit.text=""