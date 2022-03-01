; Load in base assets here
(let [chars (..
              " abcdefghijklmnopqrstuvwxyz" 
              "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" 
              "123456789.,!?-+/():;%&`'*#=[]\"")]
  {
   :font (love.graphics.newFont "assets/BungeeHairline-Regular.ttf" 40 :mono 1)
   :small-font (love.graphics.newFont "assets/BungeeHairline-Regular.ttf" 25 :mono 1)
   :big-font (love.graphics.newFont "assets/BungeeHairline-Regular.ttf" 80 :mono 1)
   :pre-intro (love.audio.newSource "assets/sounds/pre-intro.wav" :static)
   :battle-song 
   (let [snd (love.audio.newSource "assets/sounds/battle-song.ogg" :static)]
     (snd:setVolume 0.2)
     snd)
   :voice (love.audio.newSource "assets/sounds/voice.wav" :static)
   :zap (love.audio.newSource "assets/sounds/zap.wav" :static)
   :missile-ping
   (love.audio.newSource "assets/sounds/ping.wav" :static)
   :ping 
   (love.audio.newSource "assets/sounds/greet1.wav" :static)
   :wave
   (let [snd (love.audio.newSource "assets/sounds/wave.wav" :static)]
     (snd:setVolume 0.05)
     snd)
   :ground-hit 
   (love.audio.newSource "assets/sounds/missile-hit-ground.wav" :static)
   :water-hits [
                (love.audio.newSource "assets/sounds/missile-hit-water.wav" :static)
                (love.audio.newSource "assets/sounds/missile-hit-water2.wav" :static)
                (love.audio.newSource "assets/sounds/missile-hit-water3.wav" :static)
                ]
   :engine (let  [snd 
                  (love.audio.newSource "assets/sounds/engine.ogg" :static)]
             (snd:setVolume 0.05)
             (snd:setLooping true)  
             snd)

   :frame-color [1 1 1]
   })


