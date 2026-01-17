module type Db = sig
        type t

        val ping :unit -> string
end

module XapiDb: Db = struct
        type t = unit

        let ping () = "pong"
end
