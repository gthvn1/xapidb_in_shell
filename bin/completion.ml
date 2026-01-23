module XapiDb = Xapidb_lib.Xapidb.XapiDb

let init (db : XapiDb.t) =
  LNoise.history_load ~filename:"history.txt" |> ignore;
  LNoise.history_set ~max_length:100 |> ignore;

  (* Set completions for commands *)
  LNoise.set_completion_callback (fun line comp ->
      let line', patterns =
        (* Currently only "cd" command accepts opaqueref *)
        if String.starts_with ~prefix:"cd" line then
          (* TODO: If we add extra spaces between "cd" and the opaqueref it will
                 not match. It's because we are matching "cd <opaqueref>" and
                 not "cd  <opaqueref>". So we should allow extra spaces. *)
          let p = List.map (fun s -> "cd " ^ s) (XapiDb.get_opaquerefs db) in
          (line, p)
        else (line, Commands.commands)
      in
      List.iter
        (fun s ->
          if String.starts_with ~prefix:line' s then
            LNoise.add_completion comp s)
        patterns)
