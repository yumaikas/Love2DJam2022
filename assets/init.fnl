; Load in base assets here
(let [chars (..
              " abcdefghijklmnopqrstuvwxyz" 
              "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" 
              "123456789.,!?-+/():;%&`'*#=[]\"")]
  {
   :font (love.graphics.newFont "assets/BungeeHairline-Regular.ttf" 40 :mono 1)
   :big-font (love.graphics.newFont "assets/BungeeHairline-Regular.ttf" 80 :mono 1)
   :frame-color [1 1 1]
   })


