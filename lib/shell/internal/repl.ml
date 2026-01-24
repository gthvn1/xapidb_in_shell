module XapiDb = Xapidb_lib.Xapidb.XapiDb

let start (db : XapiDb.t) =
  Completion.init db;

  (* User input loop *)
  let rec loop (state : State.t) =
    let prompt =
      match state.root with
      | None -> "no ref  > "
      | Some ref -> Helpers.shrink ref ^ "> "
    in
    match LNoise.linenoise prompt with
    | None -> Printf.printf "Bye bye\n"
    | Some s -> (
        LNoise.history_add s |> ignore;
        match Commands.from_string s with
        | Error Commands.UnknownArgs ->
            Printf.eprintf "Unknown <%s>\n%!" s;
            loop state
        | Error Commands.MissingArgs ->
            Printf.eprintf "Argument is missing\n%!";
            loop state
        | Error Commands.Empty -> loop state
        | Ok Commands.Quit -> Printf.printf "Bye\n"
        | Ok c ->
            let new_state = Commands.handle db state c in
            flush_all ();
            loop new_state)
  in
  Printf.printf "XAPI DB 0.1, type 'help' for more information\n%!";
  let init_state : State.t = { root = None; path = [] } in
  loop init_state
