module XapiDb = Xapi_db.XapiDb

let help =
  {|HELP
  - `show <opaqueref>`  : display all fields of the given `OpaqueRef`
  - `follow <opaqueref>`: navigate to a referenced object
  - `back`              : return to the previous object
  - `where`             : show the current `OpaqueRef`
  - `help`              : display available commands
  - `quit`              : quit the REPL
|}

module Cmd = struct
  type cmd = Show of string | Follow of string | Back | Help | Quit

  let from_string (s : string) : cmd option =
    let words s =
      let open String in
      let s = s |> trim |> lowercase_ascii |> split_on_char ' ' in
      List.filter (fun w -> w <> "") s
    in
    match words s with
    | [ "show"; ref ] -> Some (Show ref)
    | [ "follow"; ref ] -> Some (Follow ref)
    | [ "back" ] -> Some Back
    | [ "help" ] -> Some Help
    | [ "exit" ] | [ "quit" ] -> Some Quit
    | _ -> None

  let handle db cmd =
    match cmd with
    | Show ref -> Helpers.print_ref db ref
    | Follow ref -> Printf.printf "TODO: follow %s\n" ref
    | Back -> Printf.printf "TODO: back\n"
    | Help -> print_string help
    | Quit -> ()
end

let start (db : XapiDb.t) =
  LNoise.history_load ~filename:"history.txt" |> ignore;
  LNoise.history_set ~max_length:100 |> ignore;
  let rec loop () =
    match LNoise.linenoise "xapi_db> " with
    | None -> Printf.printf "Bye bye\n"
    | Some s -> (
        LNoise.history_add s |> ignore;
        match Cmd.from_string s with
        | Some Cmd.Quit -> Printf.printf "Bye\n"
        | Some c ->
            Cmd.handle db c;
            flush_all ();
            loop ()
        | None ->
            Printf.eprintf "Unknown <%s>\n%!" s;
            loop ())
  in
  Printf.printf "%s%!" help;
  loop ()
