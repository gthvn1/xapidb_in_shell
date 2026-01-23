module XapiDb = Xapidb_lib.Xapidb.XapiDb

let shrink str =
  (* Keep the first 8 chars *)
  let keep = 8 in
  if String.length str < keep + 1 then str else String.sub str 0 keep

let print_attributes db ref =
  let l = XapiDb.get_attrs db ~ref in
  if List.length l = 0 then Printf.printf "OpaqueRef <%s> not found\n" ref
  else (
    Printf.printf "OpaqueRef %s:\n" ref;
    List.iter (fun e -> Printf.printf "  %s\n" (XapiDb.elt_to_string e)) l)
