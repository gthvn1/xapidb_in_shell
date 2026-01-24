module XapiDb = Xapidb_lib.Xapidb.XapiDb

let help =
  {|cd <opaqueref> : open `OpaqueRef`
cd ..          : return to the previous `OpaqueRef` if any
ls             : display all attributes of `OpaqueRef` as root
pwd            : show the current patch to reach the current `OpaqueRef`
exit|quit      : quit the REPL
help           : display available commands
|}

type error = Empty | UnknownArgs | MissingArgs
type t = Cd of string | Help | Ls | Pwd | Quit | Set of string

(* use for autocompletion *)
let commands = [ "cd"; "exit"; "help"; "ls"; "pwd"; "quit"; "set" ]

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
      | "pwd" -> Ok Pwd
      | "help" -> Ok Help
      | "exit" | "quit" -> Ok Quit
      | cmd when is_digit cmd.[0] -> Ok (Set cmd)
      | _ -> Error UnknownArgs)

let handle (db : XapiDb.t) (state : State.t) (cmd : t) : State.t =
  match cmd with
  | Cd ref ->
      if XapiDb.is_opaqueref ~ref db then
        match state.root with
        | None -> { root = Some ref; path = [] }
        | Some r -> { root = Some ref; path = r :: state.path }
      else if ref = ".." then
        match state.root with
        | None -> state
        | Some _ ->
            if state.path = [] then { root = None; path = [] }
            else { root = Some (List.hd state.path); path = List.tl state.path }
      else (
        Printf.printf "%s is not a valid opaqueref\n%!" ref;
        state)
  | Help ->
      print_string help;
      state
  | Ls ->
      let () =
        match state.root with
        | None -> Printf.printf "no opaqueref set\n%!"
        | Some ref -> Helpers.print_attributes db ref
      in
      state
  | Pwd ->
      let () =
        match (state.root, state.path) with
        | None, [] -> Printf.printf "empty\n%!"
        | None, _ -> failwith "if there is no root then path must be empty"
        | Some root, [] -> Printf.printf "%s\n%!" (Helpers.shrink root)
        | Some root, path ->
            List.fold_left
              (fun acc s -> acc ^ " <- " ^ Helpers.shrink s)
              (Helpers.shrink root) path
            |> Printf.printf "%s\n%!"
      in
      state
  | Set ref -> { root = Some ref; path = [] }
  | Quit -> state
