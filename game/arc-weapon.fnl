(fn draw [me]
  ; Arc is drawn based on simplex noise offsets from a straight line
  ; Arc is shown for .25 seconds
  )

(fn update [me dt]
  ; TODO: Charge when player has moved
  ; Fire if player is stopped and there is a valid target
  ; Discharge slowly if stopped and no valid targets
  )


(fn make [player charge-pos] 
  {
   : update
   : draw 

   :charge 0
   :max-charge 3
   :drain-speed 0.3
   : player
   }
  )
