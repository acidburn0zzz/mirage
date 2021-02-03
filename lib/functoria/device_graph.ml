(*
 * Copyright (c) 2013-2020 Thomas Gazagnaire <thomas@gazagnaire.org>
 * Copyright (c) 2013-2020 Anil Madhavapeddy <anil@recoil.org>
 * Copyright (c) 2015-2020 Gabriel Radanne <drupyog@zoho.com>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

(* {1 Graph engine} *)

type t = D : {
  dev : ('a, _) Device.t ;
  args : t list ;
  deps : t list ;
  id : int ;
} -> t
type dtree = t

module IdTbl = Hashtbl.Make(struct
    type t = dtree
    let hash (D t) = t.id
    let equal (D t1) (D t2) = Int.equal t1.id t2.id
  end)

(* We iter in *reversed* topological order. *)
let fold_dtree f t z =
  let tbl = IdTbl.create 50 in
  let state = ref z in
  let rec aux v =
    if IdTbl.mem tbl v then ()
    else
      let D { args; deps; _} = v in
      IdTbl.add tbl v ();
      List.iter aux deps;
      List.iter aux args;
      state := f v !state
  in
  aux t;
  !state

let impl_name (D { dev; args = _; deps = _ ; id }) =
  match Type.is_functor (Device.module_type dev) with
  | false -> Device.module_name dev
  | true ->
    let prefix = Astring.String.Ascii.capitalize (Device.nice_name dev) in
    Fmt.strf "%s__%d" prefix id

let var_name (D { dev; args = _; deps = _ ; id}) =
  let prefix = Device.nice_name dev in
  Fmt.strf "%s__%i" prefix id
