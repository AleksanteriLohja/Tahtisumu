extends Node
var wave : int
var difficulty : float
const DIFF_MULTIPLIER : float = 1.5 #kerroin sille kuinka nopeasti pelistä tulee vaikeampi, esim 1.5 kertaa vihollisten määrä seuraavaan aaltoon
var max_enemies: int
var lives : int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_game()
	$GameOver/NewGame.pressed.connect(new_game)

	
func new_game():
	wave = 1
	lives = 5
	difficulty = 4
	max_enemies = 4
	reset()
	
func reset():
	max_enemies = int(difficulty)
	$player.reset()
	get_tree().call_group("enemies", "queue_free")
	get_tree().call_group("bullet", "queue_free")
	get_tree().call_group("items", "queue_free")
	$Hud/LivesLable.text = "LIVES:"+ str(lives)
	$Hud/WaveLable.text = "WAVE:"+ str(wave)
	$Hud/EnemiesLable.text = "ENEMIES:"+ str(max_enemies)
	$GameOver.hide()
	get_tree().paused = false
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if is_wave_completed():
		wave += 1
		difficulty *= DIFF_MULTIPLIER
		get_tree().paused = true
		$WaveOverTimer.start()

#muuttaa pelaajan hp määrää kun vihollinen osuu pelaajaan
func _on_enemy_spawner_hit_p() -> void:
	lives -= 1
	$Hud/LivesLable.text = "X"+ str(lives)
	get_tree().paused = true
	if lives <= 0:
		$GameOver/WavesSurvivedLable.text = "WAVES SURVIVED: " + str(wave - 1)
		$GameOver.show()
	else:
		$WaveOverTimer.start()	

func _on_wave_over_timer_timeout() -> void:
	reset()

		
func is_wave_completed():
	var all_dead = true
	var enemies = get_tree().get_nodes_in_group("enemies")
	#katsotaan ovatko kaikki viholliset spawnanneet, määrä määritelty new game funktiossa
	if enemies.size() == max_enemies:
		for e in enemies:
			if e.alive:
				all_dead = false
		return all_dead
	else:
		return false
	
