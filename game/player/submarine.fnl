(local vectron (require :game.vectron))

(let [data 
[
 { :color [1 1 0] :points [ 54 53 86 52 86 62 101 61 99 71 86 76 56 76 48 70 47 56 53 52 ] }  { :color [1 1 0] :points [ 75 40 71 40 70 53 ] }  { :color [1 1 0] :points [ 48 46 47 81 37 78 36 50 46 45 ] }  { :color [0.58 0.58 1] :points [ 85 52 96 55 101 62 ] }  ]]
  (vectron.center-norm data))

