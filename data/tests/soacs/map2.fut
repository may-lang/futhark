-- ==
-- input {
--   [1,2,3,4,5,6,7,8]
-- }
-- output {
--   [3, 4, 5, 6, 7, 8, 9, 10]
-- }
fun [int] main([int] a) = map(+2, a)