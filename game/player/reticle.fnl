(local vectron (require :game.vectron))
(let [data [  { :color [0 1 1] :points [ 50 50 47 57 38 60 47 63 49 72 52 64 62 61 53 58 49 52 ]} ]]
  (vectron.center-norm data))
