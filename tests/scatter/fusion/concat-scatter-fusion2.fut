-- If both the indexes and values come from a concatenation of arrays
-- of the same size, that concatenation should be fused away.
-- ==
-- input { [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0] [0, 5, 10] }
-- output { [1, 2, 3, 4, 0, 1, 2, 3, 4, 0, 1, 2, 3, 4, 0, 0] }
-- structure { Concat 0 Scatter 1 }

let main (arr: *[]i32) (xs: []i32) =
  let (is0, vs0, is1, vs1, is2, is3, vs2, vs3) = unzip8 (map (\x -> (x,1,x+1,2,x+2,x+3,3,4)) xs)
  in scatter arr (is0 ++ is1 ++ is2 ++ is3) (vs0 ++ vs1 ++ vs2 ++ vs3)
