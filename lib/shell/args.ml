type t = {
    fname : string
  ; refs : string list
  ; user : string option
  ; host : string option
}

let read () : t =
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
      ("-user", Arg.Set_string user, "Set username for remote access")
    ; ("-host", Arg.Set_string host, "Set hostname or IP for remote access")
    ]
  in

  Arg.parse speclist anon_fun usage;
  (* file is required *)
  if List.length !inputs = 0 then (
    print_endline "Error: file is missing";
    Arg.usage speclist usage;
    exit 1);

  (* anon_fun builds inputs in reverse order, file is the last position *)
  let inputs = List.rev !inputs in
  {
    fname = List.hd inputs
  ; refs = List.tl inputs
  ; user = (if String.length !user = 0 then None else Some !user)
  ; host = (if String.length !host = 0 then None else Some !host)
  }
