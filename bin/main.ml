module XapiDb = Xapi_db.XapiDb

type args = {
  fname : string;
  refs : string list;
  user : string option;
  host : string option;
}

let get_args () =
  let progname = Filename.basename Sys.argv.(0) in
  let usage =
    Printf.sprintf
      "USAGE: %s [-user] [-host] <file> [<opaqueref1>] [<opaqueref2>] ... \n\n\
       DESCRIPTION\n\
       Open an XAPI database file and optionally inspect an object reference.\n\
       If <opaqueref> is not provided, %s starts an interactive REPL.\n\n\
       ARGUMENTS"
      progname progname
  in
  let inputs = ref [] in
  let user = ref "" in
  let host = ref "" in

  let anon_fun filename = inputs := filename :: !inputs in

  let speclist =
    [
      ("-user", Arg.Set_string user, "Set username for remote access");
      ("-host", Arg.Set_string host, "Set hostname or IP for remote access");
    ]
  in

  let () = Arg.parse speclist anon_fun usage in
  (* file is required *)
  if List.length !inputs = 0 then (
    print_endline "Error: file is missing";
    Arg.usage speclist usage;
    exit 1);

  (* anon_fun builds inputs in reverse order, file is the last position *)
  let inputs = List.rev !inputs in
  {
    fname = List.hd inputs;
    refs = List.tl inputs;
    user = (if String.length !user = 0 then None else Some !user);
    host = (if String.length !host = 0 then None else Some !host);
  }

(* TODO: allow user host and remote as parameters and so we will be able to 
         call the XapiDb.from_channel remotely *)
let _with_ssh_cat ~user ~host ~remote_db f =
  let cmd = Printf.sprintf "ssh %s@%s cat %s" user host remote_db in
  let ic = Unix.open_process_in cmd in
  Fun.protect
    ~finally:(fun () -> ignore (Unix.close_process_in ic))
    (fun () -> f ic)

let find_ref db ref =
  let l = XapiDb.get_ref db ~ref in
  Printf.printf "----------------------------------------\n";
  if List.length l = 0 then Printf.printf "OpaqueRef <%s> not found\n" ref
  else (
    Printf.printf "OpaqueRef %s:\n" ref;
    List.iter (fun (k, v) -> Printf.printf "  %-20s\t%s\n" k v) l)

let () =
  let args = get_args () in

  (* TODO: Manage remote connection with ssh cat *)
  let _ = args.host in
  let _ = args.user in

  (* We are expecting an XML file as input *)
  let ic = open_in args.fname in
  let db = XapiDb.from_channel ic in
  In_channel.close ic;
  Printf.printf "Found %d entries in DB\n" (XapiDb.size db);

  (* Todo: Read all refs *)
  match List.nth_opt args.refs 0 with
  | None ->
      (* Let's try to find an ref in sample *)
      let ref_sample = "082d1948-c3f7-91ae-8793-568c9e888810" in
      find_ref db ref_sample;

      (* Let's try to find a ref that is valid in state *)
      let ref_state = "0c847c7c-955f-5635-e5c3-d6fa97621627" in
      find_ref db ref_state
  | Some ref -> find_ref db ref
