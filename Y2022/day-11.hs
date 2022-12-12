#!/usr/bin/env cabal
{- cabal:
build-depends: base, flow, extra, containers, ilist
-}
{-# language LambdaCase #-}
{-# language RecordWildCards #-}
{-# language BlockArguments #-}

import Flow ((.>), (|>))
import Data.List
import Data.List.Index
import Data.List.Extra
import qualified Data.Sequence as S
import Data.Sequence (Seq(..))

-- Solve part n (n is 1 or 2) of the problem: turn structured input into the result
part :: Int -> [Monkey] -> Integer
part n ms = map count ms' |> sortOn negate |> take 2 |> product
  where
    msCnt = length ms
    rounds 1 = 20
    rounds 2 = 1000
    ms' = foldl' (procMonkey n) ms [mId | _r <- [1..rounds n], mId <- [0..msCnt-1]]

procMonkey :: Int -> [Monkey] -> Int -> [Monkey]
procMonkey p ms mId = setAt mId m' ms'
  where
    M {..} = ms !! mId
    m' = M {items = S.empty, count = count + toInteger (S.length items), ..}
    ms' = foldl' procItem ms items
    procItem :: [Monkey] -> Integer -> [Monkey]
    procItem ms it = sendItem mId' it' ms
      where
        it' = (if p == 1 then (`div` 3) else id) $ op it
        mId' = if test it' then ifTrue else ifFalse

sendItem mId it = modifyAt mId (\M {..} -> M { items = items :|> it, ..})

-- Read a group of lines of problem's input into something more structured
parseMonkey :: [String] -> Monkey
parseMonkey
  i@[_head, itemsS, opS, testS, ifTrueS, ifFalseS] = m
  where
    m = M {
        items = case words itemsS of
                  "Starting" : "items:" : is ->
                    concat is |> split (== ',') |> map read |> S.fromList,
        op = case words opS of
              ["Operation:", "new", "=", "old", opSym, opd] ->
                let opP = parseOp opSym in
                  case opd of
                    "old" -> \old -> old `opP` old
                    _     -> opP (read opd),
        test = case words testS of
            ["Test:", "divisible", "by", opd] -> \n -> n `mod` read opd == 0
            _ -> error "unknown monkey test (not a \"divisible\"-test)",
        ifTrue = case words ifTrueS of
            ["If", "true:", "throw", "to", "monkey", opd] -> read opd,
        ifFalse = case words ifFalseS of
            ["If", "false:", "throw", "to", "monkey", opd] -> read opd
            _ -> error "unknown ifFalse",
        count = 0
     }

parseOp :: String -> Integer -> Integer -> Integer
parseOp = \case
  "+" -> (+)
  "*" -> (*)

data Monkey = M
  {
    items   :: Seq Integer,
    op      :: Integer -> Integer,
    test    :: Integer -> Bool,
    ifTrue  :: Int,
    ifFalse :: Int,
    count   :: Integer
  }


showMonkey M {..} = "items: " ++ show items


{--------------------------------------------------------
--
-- Below is somewhat standard stuff, which is moslty reused
-- from day to day.
--
--------------------------------------------------------}

-- Entry point: read stdin, solve the problem and print the result
main  = interact (solve .> show)

-- Solve both parts and return a list with two elements -- the results
-- Input: problem's full text
solve input = (part <$> [1,2]) <*> pure (parse input)

-- Turn problem's full text into something more structured
parse :: String -> [Monkey]
parse =  lines .> split (== "") .> map parseMonkey
