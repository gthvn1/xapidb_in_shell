(* I want to transform my xml: *)

let sample_xml : string =
  {|
<?xml version="1.0" encoding="UTF-8"?>
<database>
  <manifest><pair key="schema_major_vsn" value="5"/><pair key="schema_minor_vsn" value="792"/><pair key="generation_count" value="72945"/></manifest>
  <table name="Certificate">
    <row ref="OpaqueRef:2b3b5149-e164-25b8-3e5c-b3da1765d060"  host="OpaqueRef:3ec68fc0-3c60-ffa4-e499-6142c369ea39" name="" type="host" uuid="7e514750-435c-c6e8-0272-042f644260f2"/>
    <row ref="OpaqueRef:082d1948-c3f7-91ae-8793-568c9e888810"  host="OpaqueRef:3ec68fc0-3c60-ffa4-e499-6142c369ea39" name=""  type="host_internal" uuid="bd62e7eb-ab54-82df-9c76-bea4981bf48d"/>
  </table>
  <table name="Cluster"/>
  <table name="Cluster_host"/>
  <table name="host">
    <row ref="OpaqueRef:3ec68fc0-3c60-ffa4-e499-6142c369ea39" CERTIFICATEs="('OpaqueRef:2b3b5149-e164-25b8-3e5c-b3da1765d060'%.'OpaqueRef:082d1948-c3f7-91ae-8793-568c9e888810')" uuid="6ff4b261-3e37-47f8-ace1-53556da6fcf2" />
   </table>
  <table name="pool_update"/>
</database>
|}

(*
into a database that is
- a list of table.
- a table has a name and a list of rows (0 or more)
- and a row is a list of key*value pair
- the key is a string but the value can of different type.
*)

(* For now we will keep raw string *)
type value = string

type row = (string * value) list

type table = {name: string; rows: row list}

type t = table list

let empty_db : t = []

(* So from xml I want to ends with: *)
let sample_db : t =
  [ { name= "Certificate"
    ; rows=
        [ [ ("ref", "OpaqueRef:2b3b5149-e164-25b8-3e5c-b3da1765d060")
          ; ("host", "OpaqueRef:3ec68fc0-3c60-ffa4-e499-6142c369ea39")
          ; ("name", "")
          ; ("type", "host")
          ; ("uuid", "7e514750-435c-c6e8-0272-042f644260f2") ]
        ; [ ("ref", "OpaqueRef:082d1948-c3f7-91ae-8793-568c9e888810")
          ; ("host", "OpaqueRef:3ec68fc0-3c60-ffa4-e499-6142c369ea39")
          ; ("name", "")
          ; ("type", "host_internal")
          ; ("uuid", "bd62e7eb-ab54-82df-9c76-bea4981bf48d") ] ] }
  ; {name= "Cluster"; rows= []}
  ; {name= "Cluster_host"; rows= []}
  ; { name= "host"
    ; rows=
        [ [ ("ref", "OpaqueRef:3ec68fc0-3c60-ffa4-e499-6142c369ea39")
          ; ( "CERTIFICATEs"
            , "('OpaqueRef:2b3b5149-e164-25b8-3e5c-b3da1765d060'%.'OpaqueRef:082d1948-c3f7-91ae-8793-568c9e888810')"
            )
          ; ("uuid", "6ff4b261-3e37-47f8-ace1-53556da6fcf2") ] ] }
  ; {name= "pool_update"; rows= []} ]

(* https://erratique.ch/software/xmlm/doc/Xmlm/index.html *)
let build (input : Xmlm.input) : t =
  let rec aux input' db : t =
    if Xmlm.eoi input' then db
    else
      try
        match Xmlm.input input with
        | `Dtd _ ->
            aux input' db (* We don't have dtd so just ignore *)
        | `El_start (tag_name, _) ->
            let uri, local = tag_name in
            Printf.printf "start tag uri:%s local:%s\n" uri local ;
            aux input' db
        | `El_end | `Data _ ->
            aux input' db
      with _ -> print_endline "got error" ; aux input' db
  in
  (* TODO: currently we are doing nothing so we can pass sample_db but
           we need to build it from empty_db. *)
  aux input sample_db

let print (db : t) =
  List.iter
    (fun table ->
      Printf.printf "Table: %s\n" table.name ;
      List.iter
        (fun row ->
          List.iter (fun (k, _) -> Printf.printf "  %s -> ... \n" k) row )
        table.rows ;
      print_newline () )
    db

let of_file (filename : string) : t =
  let ic = open_in filename in
  let db = Xmlm.make_input (`Channel ic) |> build in
  close_in ic ; db
