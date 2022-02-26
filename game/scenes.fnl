(local {: view } (require :fennel))
(local scenes {})

{:get (fn [name] (. scenes name))
 :set (fn [name val] (tset scenes name val))
 :debug (fn [] (print (view scenes)))
 }
