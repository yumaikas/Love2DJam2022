(local {: view } (require :fennel))
(local vectron (require :game.vectron))

(fn [fin-color]
(vectron.center-norm [
                      { :color fin-color :points [ 269 408 288 411 267 416 ] } 
                      { :color fin-color :points [ 306 419 301 426 ] } 
                      { :color fin-color :points [ 303 405 294 391 ] }
                      { :color [1 0.16 1] :points [ 302 402 313 411 306 420 288 412 304 403 ] } 
                      ])
)
