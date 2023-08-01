@tool
extends Control

var HTTPWork = HTTPRequest.new()

func _ready():
	HTTPWork.max_redirects = 12
	HTTPWork.use_threads = true
	$list/ping_test.pressed.connect(ping_test)

func ping_test():
	var bot_token = $list/bot_token.text
	var chat_id = $list/chat_id.text
	var text = 'Hello from GodoGram!'
	var headers = []
	var url = "https://api.telegram.org/bot" + bot_token + "/sendMessage?chat_id=" + chat_id + "&text=" + text
	$HTTPRequest.request(url, headers, HTTPClient.METHOD_GET)

func _on_http_request_request_completed(result, response_code, headers, body):
	print('Ping completed with code: ', response_code)

