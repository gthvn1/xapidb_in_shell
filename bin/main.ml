module XapiDb = Xapi_db.XapiDb

let find_ref db ref =
  let l = XapiDb.get_ref db ~ref in
  Printf.printf "----------------------------------------\n" ;
  if List.length l = 0 then Printf.printf "OpaqueRef <%s> not found\n" ref
  else (
    Printf.printf "OpaqueRef %s:\n" ref ;
    List.iter (fun (k, v) -> Printf.printf "  %-20s\t%s\n" k v) l )

let () =
  XapiDb.ping () |> print_endline ;
  (* We are expecting an XML file as input *)
  if Array.length Sys.argv <> 2 then (
    print_endline "Usage: xapi_db file.xml" ;
    exit 1 ) ;
  let db = XapiDb.from_file Sys.argv.(1) in
  Printf.printf "Found %d entries in DB\n" (XapiDb.size db) ;
  (* Let's try to find an ref in sample *)
  let ref_sample = "082d1948-c3f7-91ae-8793-568c9e888810" in
  find_ref db ref_sample ;
  (* Let's try to find a ref that is valid in state *)
  let ref_state = "0c847c7c-955f-5635-e5c3-d6fa97621627" in
  find_ref db ref_state
