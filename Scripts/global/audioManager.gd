extends Control

onready var tween = $Tween
var musicChangers = []
var overworldBattleMusic = false

func set_overworld_battle_music(enabled):
	overworldBattleMusic = enabled

func get_audio_player_count():
	return $AudioPlayers.get_child_count()

func add_audio_player():
	var musicPlayer = AudioStreamPlayer.new()
	$AudioPlayers.add_child(musicPlayer)

func get_audio_player(id):
	if id >= $AudioPlayers.get_child_count():
		return null
	return $AudioPlayers.get_child(id)

func get_audio_player_from_song(song, excludedChanger = null):
	if song != "":
		if excludedChanger != null:
			for musicChanger in musicChangers:
				var audioPlayer = musicChanger.attachedPlayer
				if audioPlayer.stream == load("res://Audio/Music/" + song) and musicChanger != excludedChanger:
					return audioPlayer
		else :
			for audioPlayer in audioManager.get_audio_player_list():
				if audioPlayer.stream == load("res://Audio/Music/" + song):
					return audioPlayer
	return null
	

func get_audio_player_id(node):
	return get_audio_player_list().find(node)

func get_audio_player_list():
	return $AudioPlayers.get_children()

func remove_audio_player(id):
	if get_audio_player(id) != null:
		get_audio_player(id).queue_free()
		if not get_audio_player(id).is_connected("tree_exited", self, "add_at_zero"):
			get_audio_player(id).connect("tree_exited", self, "add_at_zero", [], CONNECT_ONESHOT)

func add_at_zero():
	if get_audio_player_count() == 0:
		add_audio_player()


func play_music(track, loop = "", musicPlayer = get_audio_player(0), start = 0.0):
	if musicPlayer != null:
		var path = ""
		if track == "":
			path = "res://Audio/Music/" + loop
		else :
			path = "res://Audio/Music/" + track
		var musicFile = load(path)
		musicPlayer.stream = musicFile
		musicPlayer.play(start)
		if musicPlayer.is_connected("finished", self, "play_music"):
			musicPlayer.disconnect("finished", self, "play_music")
		if loop != "" and not musicPlayer.is_connected("finished", self, "play_music"):
			musicPlayer.connect("finished", self, "play_music", ["", loop, musicPlayer, 0.0], CONNECT_DEFERRED)
		else :
			musicPlayer.connect("finished", self, "remove_audio_player", [get_audio_player_id(musicPlayer)], CONNECT_ONESHOT)


func play_music_from_id(track, loop = "", id = 0, start = 0.0):
	play_music(track, loop, get_audio_player(id), start)

func set_audio_player_bus(id, bus):
	if get_audio_player(id) != null:
		get_audio_player(id).bus = bus

func set_audio_pitch(speed):
	for soundEffect in $Sfx.get_children():
		soundEffect.pitch_scale = speed

func music_fadeout(id, duration = 1):
	if get_audio_player(id) != null:
		if get_audio_player(id).playing:
			var musicPlayer = get_audio_player(id)
			tween.remove(musicPlayer)
			tween.interpolate_property(musicPlayer, "volume_db", 
				musicPlayer.volume_db, - 80, duration, 
				tween.TRANS_QUART, tween.EASE_IN)
			tween.start()

func music_fadein(id, volume, duration = 1):
	if get_audio_player(id) != null:
		var musicPlayer = get_audio_player(id)
		tween.remove(musicPlayer)
		tween.interpolate_property(musicPlayer, "volume_db", 
		- 80, volume, duration, 
		tween.TRANS_QUART, tween.EASE_OUT)
		tween.start()

func music_fadeto(id, volume = 0, duration = 1):
	if get_audio_player(id) != null:
		var musicPlayer = get_audio_player(id)
		if musicPlayer.volume_db != volume:
			tween.remove(musicPlayer)
			tween.interpolate_property(musicPlayer, "volume_db", 
				musicPlayer.volume_db, volume, duration, 
				tween.TRANS_LINEAR, tween.EASE_IN_OUT)
			tween.start()

func set_audio_player_volume(id, volume):
	if get_audio_player(id) != null:
		var musicPlayer = get_audio_player(id)
		musicPlayer.volume_db = volume

func fadeout_all_music(duration):
	tween.remove_all()
	for i in get_audio_player_count():
		music_fadeout(i, duration)

func stop_audio_player(id):
	if get_audio_player(id) != null:
		var musicPlayer = get_audio_player(id)
		if musicPlayer.is_connected("finished", self, "play_music"):
			musicPlayer.disconnect("finished", self, "play_music")
		musicPlayer.playing = false

func stop_all_music():
	for musicPlayer in get_audio_player_list():
		musicPlayer.playing = false
	remove_all_unplaying()

func pause_all_music():
	if tween.is_active():
		tween.seek(tween.tell() + tween.get_runtime())
		yield (tween, "tween_all_completed")
		remove_all_unplaying()
	for musicPlayer in get_audio_player_list():
		musicPlayer.stream_paused = true

func resume_all_music():
	for musicPlayer in get_audio_player_list():
		musicPlayer.stream_paused = false

func remove_all_unplaying():
	for i in get_audio_player_count():
		var musicPlayer = get_audio_player(i)
		if not musicPlayer.playing or musicPlayer.volume_db == - 80:
			remove_audio_player(i)

func get_playing(song):
	var songPlaying = false
	if get_audio_player_from_song(song) != null:
		songPlaying = true
	return songPlaying
	

func play_sfx(stream, name)->AudioStreamPlayer:
	var sfx_node:AudioStreamPlayer = get_sfx(name)
	if not sfx_node:
		sfx_node = AudioStreamPlayer.new()
		sfx_node.name = name
		$Sfx.add_child(sfx_node)
	sfx_node.stream = stream
	sfx_node.play()
	return sfx_node

func get_sfx(name)->AudioStreamPlayer:
	return $Sfx.get_node_or_null(name) as AudioStreamPlayer

func _on_Tween_tween_completed(object, key):
	remove_all_unplaying()
