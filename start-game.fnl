(local fennel (require :fennel))
(local f (require :f))
(local v (require :v))
(import-macros {: each-in : check} :m)
(local menu (require :ui.menu))
(local {:stack ui-stack } (require :ui.containers))
(local ui (require :ui))
(local assets (require :assets))
(local scenes (require :game.scenes))
(local gfx love.graphics)
(local title (require :game.title))

(var MODE {})

(set love.keys {})
(set love.keys.justPressed {})
(set love.keys.down {})

(fn get-window-size [] [(love.graphics.getWidth) (love.graphics.getHeight)])

(fn get-center [] (icollect [_ attr (ipairs (get-window-size))] (/ attr 2)))

(var total-time 0)

(fn love.mousepressed [x y button istouch presses]
  (set love.mouse.isJustPressed true))

(fn love.mousereleased [x y button istouch]
  (set love.mouse.isJustReleased true))

(fn love.mousemoved [x y dx dy] 
  (when (or (not= dx 0) (not= dy 0))
    (set love.mouse.delta [dx dy])))

(fn love.keypressed [_ scancode isrepeat] 
  (tset love.keys.down scancode true)
  (tset love.keys.justPressed scancode true))

(fn love.keyreleased [_ scancode] 
  (tset love.keys.down scancode nil))

(fn love.load [] 

  (each [_ [name req] (ipairs [[ :title :game.title] [:level1 :game.level1]])]
    (scenes.set name (require req)))

  (love.math.setRandomSeed (love.timer.getTime))
  ; Make these configurable?
  (gfx.setLineStyle :rough)
  ; TODO: Switch to none
  (gfx.setLineJoin :none)
  (gfx.setLineWidth 1)

  (love.mouse.setGrabbed true)
  (set MODE (title.make)))

(fn love.draw []
  (gfx.setFont assets.font)
  (MODE:draw)
  (ui.draw))

(fn love.update [dt]
  (MODE:update dt)
  (set love.mouse.isJustPressed false)
  (set love.mouse.isJustReleased false)
  (set love.mouse.delta nil)
  (each [k (pairs love.keys.justPressed)]
    (tset love.keys.justPressed k nil))
  (when MODE.next
    (set MODE MODE.next)))
