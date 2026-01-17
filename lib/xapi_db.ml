module type Db = sig
  type t

  val ping : unit -> string
  (** [ping] is just use for testing *)

  val from_file : string -> t
  (** [from_file fname] reads XML from [fname] and build a relational database *)
end

module XapiDb : Db = struct
  type elts = (string * string) list

  type t = (string, elts) Hashtbl.t

  let ping () = "pong"

  let table_name (attr : Xmlm.attribute list) : string =
    if List.length attr <> 1 then (
      Printf.eprintf "For table only one attribute name is expected, got %d\n"
        (List.length attr) ;
      exit 1 ) ;
    let (_, local), table_name = List.hd attr in
    assert (local = "name") ;
    table_name

  let row_elements (attr : Xmlm.attribute list) : elts =
    let rec loop acc = function
      | [] ->
          acc
      | x :: xs ->
          let (_uri, local), name = x in
          Printf.printf "row_elements: <%s> <%s>\n" local name ;
          loop ((local, name) :: acc) xs
    in
    loop [] attr

  (** [extract_ref elements] return the string that corresponds to "ref" or "_ref".
      It raises an expection if ref is not found. *)
  let extract_ref (elements : elts) : string =
    let _, opaqueref =
      List.find (fun (s, _) -> s = "ref" || s == "_ref") elements
    in
    (* Just keep the UUID *)
    let s = String.split_on_char ':' opaqueref in
    assert (List.hd s = "OpaqueRef") ;
    assert (List.length s = 2) ;
    List.(tl s |> hd)

  let from_file fname =
    let htable : (string, elts) Hashtbl.t = Hashtbl.create 128 in
    Printf.printf "Trying to read %s\n" fname ;
    let ic = open_in fname in
    let input = Xmlm.make_input (`Channel ic) in
    (* The goal of the loop is to fill the Hashtbl where the key is the OpaqueRef
       of an element. An element is basically the row but we will see as we go. *)
    let rec read_loop (stack : string list) =
      try
        (* input as a side effect *)
        let new_stack =
          match Xmlm.input input with
          | `Dtd _ ->
              stack (* can be safely ignored *)
          | `El_start (tag_name, tag_attr_lst) -> (
              let _, local = tag_name in
              match local with
              | "database" | "manifest" | "pair" ->
                  stack (* can be skipped *)
              | "table" ->
                  let tname = table_name tag_attr_lst in
                  tname :: stack
              | "row" ->
                  (* Row is always part of a table and we are not expecting nested table *)
                  assert (List.length stack = 1) ;
                  let tbname = List.hd stack in
                  let elements = row_elements tag_attr_lst in
                  let ref = extract_ref elements in
                  (* We can now insert the element, we should not have duplicated ref *)
                  let () =
                    match Hashtbl.find_opt htable ref with
                    | None ->
                        Hashtbl.add htable ref (("table", tbname) :: elements)
                    | Some _ ->
                        Printf.eprintf "Ref %s is duplicated" ref
                  in
                  (* We need to add the row because when reaching `El_end we will remove
                     it, and we will have the table on top. It works because we don't have
                     nested element. *)
                  local :: stack
              | _ ->
                  failwith (Printf.sprintf "%s is not handled" local) )
          | `El_end ->
              if List.is_empty stack then (
                Printf.printf "List is empty\n" ;
                stack )
              else List.tl stack
          | `Data _ ->
              Printf.printf "Data found\n" ;
              stack
        in
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
