(local v (require :v))
(local f (require :f))
(local {: view } (require :fennel))
(local random love.math.random)
(local noise love.math.noise)
(local gfx love.graphics)
(local quit (require :game.quit))
(local start-txt (require :game.title.start-txt))
(local scenes (require :game.scenes))
(local player (require :game.player))
(local barrage (require :game.barrage))
(local decals (require :game.decals))

(fn do-fish-flee [me dt] 
  (set me.fish.fish 
       (f.filter.i me.fish.fish #(> $.retarget-timer 0))))

(fn start-fish-flee [fish] 
  (print (view fish.dims))
  (let [
        [w h] fish.dims
        inner-corner [-50 (+ h 300)]
        outer-corner (v.add fish.dims [50 600])
        ]
  (each [_ fish (ipairs fish.fish)]
    (set fish.velocity 15)
    (set fish.max-velocity 15)
    (fish:retarget inner-corner outer-corner 10))))

(fn draw [me dt]
  (gfx.push)
  (let [[px py] me.player.pos
        (w h) (love.graphics.getDimensions)
        target-x (f.clamp -1200 0 (+ (- px) (/ w 2))) ]
    (gfx.translate target-x 0))
  (each [_ c (ipairs me.children)] (c:draw))
  (gfx.pop))

(fn update [me dt] 
  (gfx.push)
  (let [[px py] me.player.pos
        (w h) (love.graphics.getDimensions)
        target-x (f.clamp -1200 0 (+ (- px) (/ w 2))) ]
    (gfx.translate target-x 0))
  (each [_ c (ipairs me.children)] (c:update dt))
  (do-fish-flee me dt)
  (gfx.pop))

(fn make [dims player surface floor fish decals] 
  (let [barr (barrage.make player surface floor)
        [px _] player.pos ]

    (start-fish-flee fish)
    (barr:launch [px -100])
    {
     : update
     : draw

     : dims

     : barr
     : surface
     : floor
     : fish
     : decals
     : player
     :children [player surface floor fish decals barr]
     :next false
     }))

{: make }
