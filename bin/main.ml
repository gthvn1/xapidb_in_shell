module XapiDb = Xapi_db.XapiDb

type args = { fname : string; ref : string option }

let usage =
  {|
Usage: xapi_db [OPTIONS] FILENAME [REF]

Open an XAPI database file and optionally inspect an object reference.

Arguments:
  FILENAME    Path to the XAPI database file
  REF         Opaque object reference (optional)

Behavior:
  If REF is not provided, xapi_db starts an interactive REPL.

Options:
  -h, --help  Show this help message and exit
|}

let get_args () =
  match Sys.argv with
  | [| _; "-h" |] | [| _; "--help" |] ->
      print_string usage;
      exit 0
  | [| _; fname |] -> { fname; ref = None }
  | [| _; fname; ref |] -> { fname; ref = Some ref }
  | _ ->
      print_string usage;
      exit 1

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
  (* We are expecting an XML file as input *)
  let ic = open_in args.fname in
  let db = XapiDb.from_channel ic in
  In_channel.close ic;
  Printf.printf "Found %d entries in DB\n" (XapiDb.size db);

  match args.ref with
  | None ->
      (* Let's try to find an ref in sample *)
      let ref_sample = "082d1948-c3f7-91ae-8793-568c9e888810" in
      find_ref db ref_sample;

      (* Let's try to find a ref that is valid in state *)
      let ref_state = "0c847c7c-955f-5635-e5c3-d6fa97621627" in
      find_ref db ref_state
  | Some ref -> find_ref db ref
