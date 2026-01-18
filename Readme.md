- The idea is to parse XAPI DB, generates a in memory relational database and
  offers a prompt to query about `OpaqueRef`.
- Run:
  - help: `dune exec xapi_db -- -help`
  - open a cli using local **sample.xml**: `dune exec xapi_db -- sample.xml`
  - search for a specific opaque ref in **sample.xml**: `dune exec xapi_db -- sample.xml 3ec68fc0-3c60-ffa4-e499-6142c369ea39`
  - can also use remote database: `dune exec xapi_db -- -host 10.1.38.11 /var/lib/xcp/state.db`
- Currently *CLI* is not available and a fake search is done. It is coming...

- Example:
```sh
❯ dune exec xapi_db sample.xml 3ec68fc0-3c60-ffa4-e499-6142c369ea39
Entering directory '/home/gthvn1/devel/ocaml/ocaml_sandkasten'
Leaving directory '/home/gthvn1/devel/ocaml/ocaml_sandkasten'
Found 3 entries in DB
----------------------------------------
OpaqueRef 3ec68fc0-3c60-ffa4-e499-6142c369ea39:
  table               	host
  uuid                	6ff4b261-3e37-47f8-ace1-53556da6fcf2
  CERTIFICATEs        	('OpaqueRef:2b3b5149-e164-25b8-3e5c-b3da1765d060'%.'OpaqueRef:082d1948-c3f7-91ae-8793-568c9e888810')
  ref                 	OpaqueRef:3ec68fc0-3c60-ffa4-e499-6142c369ea39
```
