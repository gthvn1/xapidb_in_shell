module XapiDb = Xapi_db.XapiDb

let () =
  XapiDb.ping () |> print_endline ;
  (* We are expecting an XML file as input *)
  if Array.length Sys.argv <> 2 then (
    print_endline "Usage: xapi_db file.xml" ;
    exit 1 ) ;
  let _ = XapiDb.from_file Sys.argv.(1) in
  print_endline "done"
