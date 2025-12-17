let () =
  let db = Xdb_core.Database.of_file "sample.xml" in
  Xdb_core.Database.print db
