(var mult 1)

(var saved 0)

{
 :set (fn [val] (set mult val))
 :save (fn [] (set saved mult))
 :restore (fn [] (set mult saved))
 :get (fn [] mult)
}
