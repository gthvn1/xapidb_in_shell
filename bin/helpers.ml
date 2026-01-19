module XapiDb = Xapi_db.XapiDb

let print_ref db ref =
  let l = XapiDb.get_ref db ~ref in
  if List.length l = 0 then Printf.printf "OpaqueRef <%s> not found\n" ref
  else (
    Printf.printf "OpaqueRef %s:\n" ref;
    List.iter (fun e -> Printf.printf "  %s\n" (XapiDb.elt_to_string e)) l)
