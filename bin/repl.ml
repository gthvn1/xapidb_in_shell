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
  type error = Empty | UnknownArgs | MissingArgs
  type cmd = Show of string | Follow of string | Back | Where | Help | Quit

  let from_string (s : string) : (cmd, error) result =
    let words s =
      let open String in
      let s = s |> trim |> lowercase_ascii |> split_on_char ' ' in
      List.filter (fun w -> w <> "") s
    in
    match words s with
    | [] -> Error Empty
    | cmd :: args -> (
        match cmd with
        | "show" -> (
            (* TODO: in fact we can probably take a list of refs and not only one *)
            match args with
            | [ ref ] -> Ok (Show ref)
            | _ -> Error MissingArgs)
        | "follow" -> (
            match args with
            | [ ref ] -> Ok (Follow ref)
            | _ -> Error MissingArgs)
        | "back" -> Ok Back
        | "where" -> Ok Where
        | "help" -> Ok Help
        | "exit" | "quit" -> Ok Quit
        | _ -> Error UnknownArgs)

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
      try
        match line_so_far.[0] with
        | 's' -> LNoise.add_completion comp "show"
        | 'f' -> LNoise.add_completion comp "follow"
        | 'b' -> LNoise.add_completion comp "back"
        | 'w' -> LNoise.add_completion comp "where"
        | 'h' -> LNoise.add_completion comp "help"
        | 'q' -> LNoise.add_completion comp "quit"
        | _ -> ()
      with _ -> ());
  let rec loop () =
    match LNoise.linenoise "xapi_db> " with
    | None -> Printf.printf "Bye bye\n"
    | Some s -> (
        LNoise.history_add s |> ignore;
        match Cmd.from_string s with
        | Error UnknownArgs ->
            Printf.eprintf "Unknown <%s>\n%!" s;
            loop ()
        | Error MissingArgs ->
            Printf.eprintf "Argument is missing\n%!";
            loop ()
        | Error Empty -> loop ()
        | Ok Cmd.Quit -> Printf.printf "Bye\n"
        | Ok c ->
            Cmd.handle db c;
            flush_all ();
            loop ())
  in
  Printf.printf "%s%!" help;
  loop ()
