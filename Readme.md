## Description

This tool parses a XAPI database XML file, builds an in-memory relational database,
and provides a prompt oriented interface to explore the database using `OpaqueRef`
identifiers

## Requirements

- `unix` : https://ocaml.org/manual/5.4/api/Unix.html
- `xmlm` : https://erratique.ch/software/xmlm
- `linenoise`: https://github.com/ocaml-community/ocaml-linenoise

## Usage

- Show help:
```sh
dune exec xapi_db -- -help
```
- Open a REPL using local **sample.xml** file:
```sh
dune exec xapi_db -- sample.xml
```
- Query a specific `OpaqueRef` from **sample.xml**:
```sh
dune exec xapi_db -- sample.xml 3ec68fc0-3c60-ffa4-e499-6142c369ea39
```
- Use a remote database:
```sh
dune exec xapi_db -- -host 10.1.38.11 /var/lib/xcp/state.db
```

## Status
⚠️ **Work in progress** ⚠️
- A full interactive REPL is not available yet.
- Currently, a basic lookup is performed when an `OpaqueRef` is provided.
- Local and remote database works.

## Planned REPL commands
- The goal is to provide an interactive shell with the following commands:
  - [ ] `show <opaqueref>`: display all fields of the given `OpaqueRef`
  - [ ] `follow <field>`: naviate to a referenced object
  - [ ] `back`: return to the previous object
  - [ ] `where`: show the current `OpaqueRef`
  - [ ] `help`: display available commands
  - [ ] `exit`: exit the REPL

## Examples

- With multiple `OpaqueRef`:
```sh
❯ dune exec xapi_db -- sample.xml 082d1948-c3f7-91ae-8793-568c9e888810 3ec68fc0-3c60-ffa4-e499-6142c369ea39
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

- Without `OpaqueRef` it start the REPL
```sh
❯ dune exec xapi_db -- sample.xml
Entering directory '/home/gthouvenin/devel/ocaml/ocaml_sandkasten'
Leaving directory '/home/gthouvenin/devel/ocaml/ocaml_sandkasten'
Found 3 entries in DB
Fatal error: exception Failure("TODO: repl time !!!")
```
