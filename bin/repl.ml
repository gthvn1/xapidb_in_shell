module XapiDb = Xapidb_lib.Xapidb.XapiDb

type repl_state = { root : string option; path : string list }

let help =
  {|<opaqueref>     : set `OpaqueRef` as the root
ls              : display all attributes of `OpaqueRef` as root
cd <opaqueref>  : navigate to an attribute `OpaqueRef`
cd ..           : return to the previous object
path            : show the current list of `OpaqueRef` we followed
help            : display available commands
quit            : quit the REPL
|}

module Cmd = struct
  type error = Empty | UnknownArgs | MissingArgs
  type t = Cd of string | Help | Ls | Path | Quit | Set of string

  (* use for autocompletion *)
  let commands = [ "cd"; "help"; "ls"; "path"; "quit"; "set" ]

  let from_string (s : string) : (t, error) result =
    let words s =
      let open String in
      let s = s |> trim |> lowercase_ascii |> split_on_char ' ' in
      List.filter (fun w -> w <> "") s
    in
    let is_digit c =
      Char.code '0' <= Char.code c && Char.code c <= Char.code '9'
    in
    match words s with
    | [] -> Error Empty
    | cmd :: args -> (
        match cmd with
        | "ls" -> Ok Ls
        | "cd" -> (
            match args with
            | [ ref ] -> Ok (Cd ref)
            | _ -> Error MissingArgs)
        | "path" -> Ok Path
        | "help" -> Ok Help
        | "exit" | "quit" -> Ok Quit
        | cmd when is_digit cmd.[0] -> Ok (Set cmd)
        | _ -> Error UnknownArgs)

  let handle (db : XapiDb.t) (state : repl_state) (cmd : t) : repl_state =
    match cmd with
    | Cd ref ->
        Printf.printf "TODO: follow %s\n%!" ref;
        state
    | Help ->
        print_string help;
        state
    | Ls ->
        let () =
          match state.root with
          | None -> Printf.printf "No opaqueref set\n%!"
          | Some ref -> Helpers.print_attributes db ref
        in
        state
    | Path ->
        let () =
          match state.path with
          | [] -> Printf.printf "Empty\n%!"
          | [ ref ] -> Printf.printf "%s%!" ref
          | ref :: xs ->
              List.fold_left (fun acc s -> acc ^ " -> " ^ s) ref xs
              |> Printf.printf "%s\n%!"
        in
        state
    | Set ref -> { root = Some ref; path = [] }
    | Quit -> state
end

let start (db : XapiDb.t) =
  LNoise.history_load ~filename:"history.txt" |> ignore;
  LNoise.history_set ~max_length:100 |> ignore;
  (* Set completions for commands *)
  LNoise.set_completion_callback (fun line comp ->
      List.iter
        (fun cmd ->
          if String.starts_with ~prefix:line cmd then
            LNoise.add_completion comp cmd)
        (Cmd.commands @ XapiDb.get_opaquerefs db));

  (* User input loop *)
  let rec loop state =
    let prompt =
      match state.root with
      | None -> "> "
      | Some ref -> ref ^ "> "
    in
    match LNoise.linenoise prompt with
    | None -> Printf.printf "Bye bye\n"
    | Some s -> (
        LNoise.history_add s |> ignore;
        match Cmd.from_string s with
        | Error UnknownArgs ->
            Printf.eprintf "Unknown <%s>\n%!" s;
            loop state
        | Error MissingArgs ->
            Printf.eprintf "Argument is missing\n%!";
            loop state
        | Error Empty -> loop state
        | Ok Cmd.Quit -> Printf.printf "Bye\n"
        | Ok c ->
            let new_state = Cmd.handle db state c in
            flush_all ();
            loop new_state)
  in
  Printf.printf "XAPI DB 0.1, type 'help' for more information\n%!";
  let init_state = { root = None; path = [] } in
  loop init_state
