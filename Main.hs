module Main where

import Y2021.Day1

defaultYear = 2021

solutions = [
  (2021, 1) -> (Y2021.Day1.solve1, Y2021.Day1.solve2)
  ]

main = do
  args <- getArgs
  yearAndDay@(y, d) <- case args of
    [y, d] -> return (y, d)
    [d]    -> return (defaultYear, d)
    _      -> error "Provide one (day) or two (year, day) arguments"
  let Just (s1, s2) = lookup solutions yearAndDay 
  input <- readFile $ "Y" ++ (show y) ++ "/input/day-" ++ show d ++ ".txt" 
  print (s1 input)
  print (s2 input)

