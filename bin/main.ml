(* I want to transform my xml: *)

let _sample_xml : string =
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

module XapiDb = Xapi_db.XapiDb

let () = XapiDb.ping () |> print_endline
