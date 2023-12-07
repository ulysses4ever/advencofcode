module Main where

import Data.List (sort, group)

import AoC
import Data.Char (isDigit, ord)
import Data.List (sortOn)

data C =
    C2 | C3 | C4 | C5 | C6 | C7 | C8 | C9 | T | J | Q | K | A
    deriving (Eq, Ord, Bounded, Enum, Show, Read)

readCard :: Char -> C
readCard c
  | isDigit c = iterate succ C2 !! (ord c - ord '2')
  | otherwise = read [c]

solve :: [String] -> Int -> Int
solve inp = \case
    1 -> part1
    2 -> part2
  where
    hsbs :: [([C], Int)]
    hsbs = map (words .> \[h, b] -> (map readCard h, read b)) inp
    part1 = pTraceShowCompact hsbs 0
    part2 = 0

data S =
    HH | P1 | P2 | K3 | FH | K4 | K5
    deriving (Eq, Ord, Bounded, Enum, Show, Read)

scoreHand :: [C] -> S
scoreHand h = case h |> sort .> group .> sortOn length of
    [a] -> K5
    [a,b] -> case length a of
      1 -> K4
      2 -> FH
    [a,b,c] -> case length c of
      3 -> K3
      2 -> P2
    [a,b,c,d] -> P1
    _ -> HH

main :: IO ()
main = defaultMain solve

{-
i = [
    ( [ C3, C2, T, C3, K ], 765 ),
    ( [ T, C5, C5, J, C5 ], 684 ),
    ( [ K, K, C6, C7, C7 ], 28 ),
    ( [ K, T, J, J, T ], 220 ),
    ( [ Q, Q, Q, J, A ], 483 )
    ]
-}
