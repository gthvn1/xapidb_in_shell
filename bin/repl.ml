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
  type cmd = Show of string | Follow of string | Back | Where | Help | Quit

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
    | [ "where" ] -> Some Where
    | [ "help" ] -> Some Help
    | [ "exit" ] | [ "quit" ] -> Some Quit
    | _ -> None

  let handle db cmd =
    match cmd with
    | Show ref -> Helpers.print_ref db ref
    | Follow ref -> Printf.printf "TODO: follow %s\n" ref
    | Back -> Printf.printf "TODO: back\n"
    | Where -> Printf.printf "TODO: where\n"
    | Help -> print_string help
    | Quit -> ()
end

let start (db : XapiDb.t) =
  LNoise.history_load ~filename:"history.txt" |> ignore;
  LNoise.history_set ~max_length:100 |> ignore;
  (* Set completions for commands *)
  LNoise.set_completion_callback (fun line_so_far comp ->
      if line_so_far <> "" then
        match line_so_far.[0] with
        | 's' -> LNoise.add_completion comp "show"
        | 'f' -> LNoise.add_completion comp "follow"
        | 'b' -> LNoise.add_completion comp "back"
        | 'w' -> LNoise.add_completion comp "where"
        | 'h' -> LNoise.add_completion comp "help"
        | 'q' -> LNoise.add_completion comp "quit"
        | _ -> ());
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
