open Tyxml.Html

(* ---------- types ---------- *)
type value = string

type row = (string * value) list

type table = {name: string; rows: row list}

type t = table list

(* ---------- Helpers ---------- *)

(* Generate unique IDs for rows *)
let make_row_ids db =
  let counter = ref 0 in
  List.fold_left
    (fun acc table ->
      let rows_with_ids =
        List.map
          (fun row ->
            incr counter ;
            (Printf.sprintf "row-%d" !counter, row) )
          table.rows
      in
      (table.name, rows_with_ids) :: acc )
    [] db
  |> List.rev

(* Build a map from OpaqueRef -> row id *)
let build_ref_map db_with_ids =
  let tbl = Hashtbl.create 16 in
  List.iter
    (fun (_, rows) ->
      List.iter
        (fun (id, row) ->
          match List.assoc_opt "ref" row with
          | Some ref_val ->
              Hashtbl.add tbl ref_val id
          | None ->
              () )
        rows )
    db_with_ids ;
  tbl

(* Generate HTML for a single row *)
let row_to_li ref_map (row_id, row) =
  let cells =
    List.map
      (fun (k, v) ->
        let content =
          if String.starts_with ~prefix:"OpaqueRef:" v then
            match Hashtbl.find_opt ref_map v with
            | Some target_id ->
                a ~a:[a_href ("#" ^ target_id)] [txt v]
            | None ->
                txt v
          else txt v
        in
        li [b [txt (k ^ ": ")]; content] )
      row
  in
  (* wrap inner <li> cells in a <ul> *)
  li ~a:[a_id row_id] [ul cells]

(* Generate collapsible table *)
let table_to_div ref_map (table_name, rows) =
  let header = h3 ~a:[a_class ["table-header"]] [txt table_name] in
  let rows_ul =
    ul ~a:[a_class ["table-rows"]] (List.map (row_to_li ref_map) rows)
  in
  div [header; rows_ul]

(* Generate full page *)
let page db =
  let db_with_ids = make_row_ids db in
  let ref_map = build_ref_map db_with_ids in
  html
    (head
       (title (txt "DB Viewer"))
       [ style
           [ txt
               "\n\
               \          .table-rows { display: none; margin-left: 20px; }\n\
               \          .table-header { cursor: pointer; color: blue; }\n\
               \        " ]
         (* script [txt " *)
          (* document.addEventListener('DOMContentLoaded', () => { *)
            (* document.querySelectorAll('.table-header').forEach(h => { *)
              (* h.addEventListener('click', () => { *)
                (* const ul = h.nextElementSibling; *)
                (* if (ul.style.display === 'none') ul.style.display = 'block'; *)
                (* else ul.style.display = 'none'; *)
              (* }); *)
            (* }); *)
          (* }); *)
        (* "] *)
       ] )
    (body (List.map (table_to_div ref_map) db_with_ids))

(* ---------- Example usage ---------- *)

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

let () =
  let html_doc = page sample_db in
  let output = Format.asprintf "%a" (Tyxml.Html.pp ()) html_doc in
  (* Write to file *)
  let oc = open_out "db_viewer.html" in
  output_string oc output ; close_out oc

(* let () = *)
(* let db = Xdb_core.Database.of_file "sample.xml" in *)
(* Xdb_core.Database.print db *)
