module XapiDb = Xapidb_lib.Xapidb.XapiDb
module XapiShell = Xapidb_shell.Shell

let with_ssh_cat ~user ~host ~remote_db f =
  let cmd =
    match user with
    | None -> Printf.sprintf "ssh %s cat %s" host remote_db
    | Some u -> Printf.sprintf "ssh %s@%s cat %s" u host remote_db
  in
  Printf.eprintf "Running %s\n" cmd;
  flush stderr;
  let ic = Unix.open_process_in cmd in
  Fun.protect
    ~finally:(fun () -> ignore (Unix.close_process_in ic))
    (fun () -> f ic)

let () =
  let args = Args.read () in

  (* Manage local file or remote connection *)
  let db =
    match args.host with
    | None ->
        let ic = open_in args.fname in
        let db = XapiDb.from_channel ic in
        In_channel.close ic;
        db
    | Some host ->
        with_ssh_cat ~user:args.user ~host ~remote_db:args.fname
          XapiDb.from_channel
  in
  Printf.printf "Found %d entries in DB\n" (XapiDb.size db);

  (* Todo: Read all refs, start a REPL if no refs are passed *)
  match List.nth_opt args.refs 0 with
  | None -> XapiShell.start db
  | Some _ ->
      List.iter
        (fun ref ->
          print_endline "---------";
          XapiShell.print_attributes db ref)
        args.refs
