-- http://rosettacode.org/wiki/Averages/Root_mean_square
--
-- input { [1.0,2.0,3.0,1.0] }
-- output { 1.936f64 }

import "/futlib/math"

let main [n] (as: [n]f64): f64 =
  f64.sqrt ((reduce (+) 0.0 (map (**2.0) as)) / r64 n)
