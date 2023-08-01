## Godot Engine plugin for Telegram.
## Made by Delalex.
@icon("res://addons/godogram/icon.png")
extends Node
class_name GodoGram

@export var bot_token = '' ## Which bot will be used to execute tasks? Go to BotFather and see!
@export_enum('Yes','No') var show_debug = 'Yes' ## Sends output to console
@export_enum('Yes', 'No') var use_threading = 'No' ## Processing will be faster
@export_range(0,32) var max_redirects = 8 ## Processing can go further
var HTTPWork = HTTPRequest.new() ## HTTPRequest processing unit #1
var HTTPWork_busy = true ## HTTPRequest1 processing the request
var HTTPWork_last_message = HTTPRequest.new() ## HTTPRequest processing unit #2
var HTTPWork_last_message_busy = true ## HTTPRequest2 processing the request

## Emitted when GodoGram gets last message from bot
signal last_message_got 
## Emitted when GodoGram processes the request
signal request_processed

func _ready():
	HTTPWork.tree_entered.connect(_work_allowed)
	HTTPWork_last_message.tree_entered.connect(_work_allowed_last_message)
	HTTPWork.request_completed.connect(_request_done)
	HTTPWork_last_message.request_completed.connect(_request_done_for_last_message)
	configureWorkers()

#==================================FUNCS========================================

## Prepares HTTP workers before their use
func configureWorkers():
	if use_threading == 'Yes':
		HTTPWork.use_threads = true
		HTTPWork_last_message.use_threads = true
		HTTPWork.max_redirects = max_redirects
		HTTPWork_last_message.max_redirects = max_redirects
		add_child(HTTPWork)
		add_child(HTTPWork_last_message)
## Sends a message from bot to targeted user with id
func send_message(chat_id: String, text: String):
	if not HTTPWork_busy:
		var headers = []
		var url = "https://api.telegram.org/bot" + bot_token + "/sendMessage?chat_id=" + chat_id + "&text=" + text
		HTTPWork_busy = true
		HTTPWork.request(url, headers, HTTPClient.METHOD_GET)
	else:
		print('Request completed with code: ERR_WORKER_BUSY')
## Gets last message sended to bot
func get_last_message():
	HTTPWork_last_message_busy = true
	var headers = ["Content-Type: application/json",
				   "accept: application/json",
				   "User-Agent: Telegram Bot SDK - (https://github.com/irazasyed/telegram-bot-sdk)"]
	HTTPWork_last_message.request("https://api.telegram.org/bot" + bot_token + "/getUpdates?offset=-1?limit=1")

#================================SIGNALS========================================

func _work_allowed():
	if show_debug == 'Yes':
		print('Worker #1: Entered tree')
	HTTPWork_busy = false

func _work_allowed_last_message():
	if show_debug == 'Yes':
		print('Worker #2: Entered tree')
	HTTPWork_last_message_busy = false

func _request_done(result, response_code, headers, body):
	HTTPWork_busy = false
	emit_signal("request_processed", response_code, result)
	if show_debug == 'Yes':
		print('Request completed with code: ', response_code)
		print('Result: ', result)

func _request_done_for_last_message(result, response_code, headers, body):
	HTTPWork_last_message_busy = false
	if show_debug == 'Yes':
		print('Request completed with code: ', response_code)
		print('Result: ', result)
	if response_code == 200:
		var json = JSON.new()
		var message_arr = body.get_string_from_utf8()
		var resp = JSON.parse_string(message_arr).result
		if resp.size() > 0:
			var source = resp[resp.size()-1]
			var message_id = source['message']['message_id']
			var message_text = source['message']['text']
			emit_signal("last_message_got", message_id, message_text)
		else:
			if show_debug == 'Yes':
				print('ERROR: No last messages found')

