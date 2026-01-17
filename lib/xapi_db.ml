module type Db = sig
  type t

  val ping : unit -> string
  (** [ping] is just use for testing *)

  val from_file : string -> t
  (** [from_file fname] reads XML from [fname] and build a relational database *)
end

module XapiDb : Db = struct
  type elt = unit

  type t = (string, elt) Hashtbl.t

  let ping () = "pong"

  let from_file fname =
    let htable : (string, elt) Hashtbl.t = Hashtbl.create 128 in
    Printf.printf "Trying to read %s\n" fname ;
    let ic = open_in fname in
    let input = Xmlm.make_input (`Channel ic) in
    (* The goal of the loop is to fill the Hashtbl where the key is the OpaqueRef
       of an element. An element is basically the row but we will see as we go. *)
    let rec read_loop stack =
      try
        (* input as a side effect *)
        let new_stack =
          match Xmlm.input input with
          | `Dtd _ ->
              stack (* can be safely ignored *)
          | `El_start (tag_name, _tag_attr_lst) ->
              let _, local = tag_name in
              local :: stack
          | `El_end ->
              if List.is_empty stack then (
                Printf.printf "List is empty\n" ;
                stack )
              else List.tl stack
          | `Data _ ->
              Printf.printf "Data found\n" ;
              stack
        in
        if not (List.is_empty stack) then
          Printf.printf "Current head is %s\n" (List.hd stack) ;
        read_loop new_stack
      with Xmlm.Error ((line, col), err) ->
        if Xmlm.eoi input then print_endline "EOF reached"
        else (
          Printf.eprintf "[%d, %d]: Got exception: %s" line col
            (Xmlm.error_message err) ;
          exit 1 )
    in
    read_loop [] ; In_channel.close ic ; htable
end
