# CrazySDK: autoload bridge to the CrazyGames SDK (v3).
# No-ops on desktop; on a Web export it calls window.CrazyGames.SDK via
# JavaScriptBridge. Every call is wrapped in try/catch on the JS side and the
# SDK init is DEFERRED until after the engine has booted + rendered a frame, so
# it can never interfere with startup (avoids the black-screen-at-boot trap).
extends Node

var available := false

func _ready() -> void:
	if OS.has_feature("web"):
		available = true
		# Defer init: let the game render first, then talk to the SDK.
		var t := get_tree().create_timer(0.1)
		t.timeout.connect(_init_sdk)

func _init_sdk() -> void:
	# The SDK <script> is loaded async, so keep retrying until it's there.
	# init() is async — await it, THEN report loading finished (avoids a race).
	_call("(function __cgTry(){try{if(window.__cg_inited){return;}if(window.CrazyGames&&window.CrazyGames.SDK){window.__cg_inited=true;window.CrazyGames.SDK.init().then(function(){window.CrazyGames.SDK.game.loadingStop();}).catch(function(e){console.error('CG init',e);});}else{setTimeout(__cgTry,300);}}catch(e){console.error('CG',e);}})()")

func _call(js: String) -> void:
	if not available:
		return
	# JavaScriptBridge.eval never throws into GDScript; JS errors just log.
	JavaScriptBridge.eval(js, true)

func _sdk(call_expr: String) -> void:
	_call("try{if(window.CrazyGames&&window.CrazyGames.SDK){window.CrazyGames.SDK.%s;}}catch(e){}" % call_expr)

func loading_stop() -> void:
	_sdk("game.loadingStop()")

func gameplay_start() -> void:
	_sdk("game.gameplayStart()")

func gameplay_stop() -> void:
	_sdk("game.gameplayStop()")

# Call on a positive moment (e.g. unlocking a new car).
func happytime() -> void:
	_sdk("game.happytime()")
