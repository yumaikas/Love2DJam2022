(fn check [exp err]
  `(or ,exp (error ,err)))

(fn each-in [ident tbl ...]
  `(let [tbl# ,tbl]
     (for [i# 1 (length tbl#)]
       (local ,ident (. tbl# i#))
       ,...)))

(fn += [x expr] `(set ,x (+ ,x ,expr)))

(fn -= [x expr] `(set ,x (- ,x ,expr)))

(fn *= [x expr] `(set ,x (* ,x ,expr)))

(fn imp [name]
  `(local ,name (require ,(tostring name))))

(fn req [name path]
  `(local ,name (require ,path)))

(fn unless [pred ...]
  `(when (not ,pred)
       ,...))

{: check : each-in  : += : -= : *= : unless : imp : req}
