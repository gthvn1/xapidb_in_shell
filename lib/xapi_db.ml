module type Db = sig
  type t

  val ping : unit -> string
  (** [ping] is just use for testing *)

  val from_file : string -> t
  (** [from_file fname] reads XML from [fname] and build a relational database *)
end

module XapiDb : Db = struct
  type t = unit

  let ping () = "pong"

  let from_file fname =
    Printf.printf "Trying to read %s\n" fname ;
    let ic = open_in fname in
    let input = Xmlm.make_input (`Channel ic) in
    let rec read_loop () =
      try
        (* input as a side effect *)
        let () =
          match Xmlm.input input with
          | `Dtd name -> (
            match name with
            | None ->
                print_endline "Dtd found"
            | Some n ->
                Printf.printf "Dtd %s found" n )
          | `El_start (tag_name, _tag_attr_lst) ->
              let uri, local = tag_name in
              Printf.printf "Start uri: <%s>, local: <%s>\n" uri local
          | `El_end ->
              print_endline "End found"
          | `Data data ->
              Printf.printf "Data <%s> found\n" (data |> String.trim)
        in
        read_loop ()
      with Xmlm.Error ((line, col), err) ->
        if Xmlm.eoi input then print_endline "EOF reached"
        else (
          Printf.eprintf "[%d, %d]: Got exception: %s" line col
            (Xmlm.error_message err) ;
          exit 1 )
    in
    read_loop () ; In_channel.close ic
end
