-- Not OK, because the module type specifies a more liberal type than
-- defined by the module.
-- ==
-- error: module type

module m = { type t 'a = a } : { type t '^a }
