module XapiDb = Xapi_db.XapiDb

let () =
  XapiDb.ping () |> print_endline ;
  (* We are expecting an XML file as input *)
  if Array.length Sys.argv <> 2 then (
    print_endline "Usage: xapi_db file.xml" ;
    exit 1 ) ;
  let db = XapiDb.from_file Sys.argv.(1) in
  Printf.printf "Found %d entries in DB\n" (XapiDb.size db) ;
  Printf.printf "----------------------------------------\n" ;
  (* Let's try to find an ref in sample *)
  let ref_sample = "082d1948-c3f7-91ae-8793-568c9e888810" in
  let l = XapiDb.get_ref db ~ref:ref_sample in
  if List.length l = 0 then Printf.printf "Ref <%s> not found\n" ref_sample
  else List.iter (fun (k, v) -> Printf.printf "  %-20s\t%s\n" k v) l ;
  Printf.printf "----------------------------------------\n" ;
  (* Let's try to find a ref that is valid in state *)
  let ref_state = "0c847c7c-955f-5635-e5c3-d6fa97621627" in
  let l = XapiDb.get_ref db ~ref:ref_state in
  if List.length l = 0 then Printf.printf "Ref <%s> not found\n" ref_state
  else List.iter (fun (k, v) -> Printf.printf "  %-20s\t%s\n" k v) l
