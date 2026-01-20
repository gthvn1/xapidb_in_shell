(lang dune 3.20)

(generate_opam_files true)

(package
 (name xapidb_in_shell)
 (synopsis "Parse xapi db, generate relational DB in memory and provides a shell")
 (depends xmlm linenoise))

