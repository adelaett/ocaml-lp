type bound = {name: string; lb: float; ub: float}

type section =
  | Sobj of Objective.t
  | Scnstr of Cnstr.t list
  | Sbound of bound list
  | Sgeneral of string list
  | Sbinary of string list

type t = section list

let trans_binary p name =
  let obj, cnstrs = p in
  let newobj = Objective.to_binary name obj in
  let newc = List.map (Cnstr.to_binary name) cnstrs in
  (newobj, newc)

let trans_general p name =
  let obj, cnstrs = p in
  let newobj = Objective.to_integer name obj in
  let newc = List.map (Cnstr.to_integer name) cnstrs in
  (newobj, newc)

let trans_bound p b =
  let obj, cnstrs = p in
  let newobj = Objective.trans_bound b.name b.lb b.ub obj in
  let newc = List.map (Cnstr.trans_bound b.name b.lb b.ub) cnstrs in
  (newobj, newc)

let rec trans_attrs problem = function
  | [] ->
      problem
  | Sbound bounds :: rest ->
      let newp = List.fold_left trans_bound problem bounds in
      trans_attrs newp rest
  | Sgeneral gen :: rest ->
      let newp = List.fold_left trans_general problem gen in
      trans_attrs newp rest
  | Sbinary bin :: rest ->
      let newp = List.fold_left trans_binary problem bin in
      trans_attrs newp rest
  | _ ->
      (* though parser will error in this pattern *)
      failwith "LP file is ill-formed (multiple obj or cnstr sections?)"

let emit = function
  | Sobj obj :: Scnstr cnstrs :: attrs ->
      trans_attrs (obj, cnstrs) attrs
  | _ ->
      failwith "LP file is ill-formed (no objective or constraint section ?)"
