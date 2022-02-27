(local f (require :f))
(local {: view} (require :fennel))
(local assets (require :assets))
(local gfx love.graphics)

(fn draw [me] 
  (each [_ d (ipairs me.elts)]
    (let [[x y] d.pos]
      (gfx.setFont assets.font)
      (gfx.setColor d.color)
      (gfx.print d.txt x y))))

(fn update [me dt] 
  (each [_ d (ipairs me.elts)]
    (set d.time (- d.time dt)))
  (f.filter.i! me.elts #(> $.time 0)))

(fn spawn [me txt pos time color]
  (table.insert me.elts 
    { : txt : pos : time : color }))

(fn make [] 
  {
   :elts []
   : update
   : draw
   : spawn
   }
  )

{: make}
