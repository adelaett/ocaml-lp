type t = Max of Poly.t | Min of Poly.t

let maximize ?(eps = 10. *. epsilon_float) p = Max (Poly.simplify ~eps p)

let minimize ?(eps = 10. *. epsilon_float) p = Min (Poly.simplify ~eps p)

let take_vars = function Max p | Min p -> Poly.take_vars p

let to_string ?(short = false) o =
  let p_string p = Poly.to_string ~short (Poly.double_quad p) in
  match o with
  | Max p when Poly.degree p >= 2 ->
      "maximize\n " ^ p_string p ^ " / 2"
  | Max p ->
      "maximize\n " ^ p_string p
  | Min p when Poly.degree p >= 2 ->
      "minimize\n " ^ p_string p ^ " / 2"
  | Min p ->
      "minimize\n " ^ p_string p

let degree = function Max p | Min p -> Poly.degree p
