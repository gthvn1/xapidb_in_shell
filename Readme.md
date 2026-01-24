## Description

This tool parses an XAPI database XML file, builds an in-memory relational database,
and provides a prompt-oriented interface to explore the database using `OpaqueRef`
identifiers.

## Requirements

- `unix` : https://ocaml.org/manual/5.4/api/Unix.html
- `xmlm` : https://erratique.ch/software/xmlm
- `linenoise`: https://github.com/ocaml-community/ocaml-linenoise

## Usage

- Show help:
```sh
dune exec xapidb_in_shell -- -help
```
- Open a REPL using local **sample.xml** file:
```sh
dune exec xapidb_in_shell -- sample.xml
```
- Query a specific `OpaqueRef` from **sample.xml**:
```sh
dune exec xapidb_in_shell -- sample.xml 3ec68fc0-3c60-ffa4-e499-6142c369ea39
```
- Use a remote database:
```sh
dune exec xapidb_in_shell -- -host 10.1.38.11 /var/lib/xcp/state.db
```

## Status
⚠️ **Work in progress** ⚠️
- A full interactive REPL is not available yet (See section below).
- Local and remote databases work.

## Planned REPL commands
- The goal is to provide an interactive shell with the following commands:
  - [x] `ls`: display all fields of the current `OpaqueRef` or tables if no `OpaqueRef` is selected
  - [ ] `ls <table>`: list all `OpaqueRef` of the given *table*
  - [x] `cd <opaqueref>`: open the `OpaqueRef`
  - [x] `cd ..`: navigate up
  - [x] `pwd`: show the path we followed
  - [x] `help`: display available commands
  - [x] `exit`: exit the REPL

## Examples

- With multiple `OpaqueRef`:
```sh
❯ dune exec xapidb_in_shell -- sample.xml 082d1948-c3f7-91ae-8793-568c9e888810 3ec68fc0-3c60-ffa4-e499-6142c369ea39
Entering directory '/home/gthouvenin/devel/ocaml/ocaml_sandkasten'
Leaving directory '/home/gthouvenin/devel/ocaml/ocaml_sandkasten'
Found 3 entries in DB
----------------------------------------
OpaqueRef 082d1948-c3f7-91ae-8793-568c9e888810:
  table                 Certificate
  uuid                  bd62e7eb-ab54-82df-9c76-bea4981bf48d
  type                  host_internal
  name
  host                  3ec68fc0-3c60-ffa4-e499-6142c369ea39
  ref                   082d1948-c3f7-91ae-8793-568c9e888810
----------------------------------------
OpaqueRef 3ec68fc0-3c60-ffa4-e499-6142c369ea39:
  table                 host
  uuid                  6ff4b261-3e37-47f8-ace1-53556da6fcf2
  CERTIFICATEs          ('OpaqueRef:2b3b5149-e164-25b8-3e5c-b3da1765d060'%.'OpaqueRef:082d1948-c3f7-91ae-8793-568c9e888810')
  ref                   3ec68fc0-3c60-ffa4-e499-6142c369ea39
```

- Without `OpaqueRef` it starts the REPL
```sh
❯ dune exec xapidb_in_shell sample.xml
Found 3 OpaqueRefs in DB
XAPI DB 0.1, type 'help' for more information
no ref  > ls
  Certificate
  Cluster
  Cluster_host
  host
  pool_update
  probe_result
  role
no ref  > cd 082d1948-c3f7-91ae-8793-568c9e888810
082d1948> ls
OpaqueRef 082d1948-c3f7-91ae-8793-568c9e888810:
  table               	Certificate
  uuid                	bd62e7eb-ab54-82df-9c76-bea4981bf48d
  type                	host_internal
  name                	
  host                	3ec68fc0-3c60-ffa4-e499-6142c369ea39
  ref                 	082d1948-c3f7-91ae-8793-568c9e888810
082d1948> quit
Bye
```
