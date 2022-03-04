(import-macros {: gfx-at : req : imp : -= } :m)
(local v (require :v))
(req {: iter} :f)
(imp assets)
(local {: view} (require :fennel))
(local vectron (require :game.vectron))
(req dbg :game.debug)
(local gfx love.graphics)

(fn draw [me]
  (gfx.origin)
  (each [{: text : font : color :pos [x y]} (iter me.text)]
    (gfx.setColor color)
    (gfx.setFont font)
    (gfx.print text x y))
  (each [{: vectr : pos } (iter me.vectors)]
    (gfx-at pos
    (vectron.draw vectr.shapes)))

  (gfx.setColor [0 1 0])
  (gfx.setFont assets.small-font)
  (gfx.print (.. "TAP " me.tap-times " TIMES(S) TO CONTINUE") 30 650)

  )

(fn update [me dt]
  (when love.mouse.isJustPressed
    (-= me.tap-times 1))

  (when (<= me.tap-times 0)
    (set me.next me.once-done))
  )

(fn make [next-scene text vectors]

  {
   :tap-times 3
   :once-done next-scene 
   :next false
   : update
   : draw
   :text (or text [])
   :vectors (or vectors [])
   }
  )

{: make}
