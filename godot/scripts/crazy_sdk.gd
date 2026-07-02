# CrazySDK: autoload bridge to the CrazyGames SDK (v3).
# No-ops on desktop; on a Web export it calls window.CrazyGames.SDK via
# JavaScriptBridge. Every call is wrapped in try/catch on the JS side and the
# SDK init is DEFERRED until after the engine has booted + rendered a frame, so
# it can never interfere with startup (avoids the black-screen-at-boot trap).
#
# Ads: `maybe_midgame(cb)` shows a break ad at most once per cooldown window;
# `rewarded(cb)` shows an opt-in rewarded ad. The master bus is muted while an
# ad plays (a CrazyGames requirement) and restored to the user's setting after.
# The callback always fires — cb.call(true) on a completed ad, cb.call(false)
# when the ad was skipped (cooldown / desktop / error), so game flow never stalls.
extends Node

const MIDGAME_COOLDOWN_MS := 180000  # at most one break ad per 3 minutes

var available := false
var _ad_callback := Callable()
var _js_ad_done: JavaScriptObject
var _js_ad_fail: JavaScriptObject
var _last_ad_ms := 0

func _ready() -> void:
	if OS.has_feature("web"):
		available = true
		# First midgame ad only after one full cooldown of play time.
		_last_ad_ms = Time.get_ticks_msec()
		# JS -> GDScript callbacks for the ad lifecycle (refs must stay alive).
		_js_ad_done = JavaScriptBridge.create_callback(_on_ad_done)
		_js_ad_fail = JavaScriptBridge.create_callback(_on_ad_fail)
		var win := JavaScriptBridge.get_interface("window")
		win.__cg_ad_done = _js_ad_done
		win.__cg_ad_fail = _js_ad_fail
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

# ---- ads ----
func ad_in_flight() -> bool:
	return _ad_callback.is_valid()

# Break ad between runs. Respects the cooldown; cb(false) fires immediately
# when no ad is shown so the caller can proceed either way.
func maybe_midgame(cb: Callable) -> void:
	if ad_in_flight():
		return  # ignore extra clicks while an ad is on screen
	if not available or Time.get_ticks_msec() - _last_ad_ms < MIDGAME_COOLDOWN_MS:
		cb.call(false)
		return
	_request_ad("midgame", cb)

# Opt-in rewarded ad (user clicked a clearly-labelled button).
func rewarded(cb: Callable) -> void:
	if ad_in_flight():
		return
	if not available:
		cb.call(false)
		return
	_request_ad("rewarded", cb)

func _request_ad(kind: String, cb: Callable) -> void:
	_ad_callback = cb
	_last_ad_ms = Time.get_ticks_msec()
	AudioServer.set_bus_mute(0, true)  # CrazyGames requires silence during ads
	_call("try{window.CrazyGames.SDK.ad.requestAd('%s',{adStarted:function(){},adFinished:function(){window.__cg_ad_done();},adError:function(e){window.__cg_ad_fail();}});}catch(e){window.__cg_ad_fail&&window.__cg_ad_fail();}" % kind)

func _finish_ad(ok: bool) -> void:
	SaveData.apply_mute()  # back to the user's own sound setting
	var cb := _ad_callback
	_ad_callback = Callable()
	if cb.is_valid():
		cb.call(ok)

func _on_ad_done(_args: Array) -> void:
	_finish_ad(true)

func _on_ad_fail(_args: Array) -> void:
	_finish_ad(false)
