module Main where

import Test.HUnit
import System.IO

data Expr = N   Int
          | Var String Int Int
          | Add [Expr]
          | Mul [Expr]
          deriving (Show, Eq)

eval (N x ) = x
eval (Add xs) = sum [eval x | x <- xs]
eval (Mul xs) = product [eval x | x <- xs]

isneg (N n)       | n < 0 = True
isneg (Var _ a _) | a < 0 = True
isneg _                   = False

str (N x) = show x
str (Add [])       = ""
str (Add [Add xs]) = "(" ++ str (Add xs) ++ ")"
str (Add [x])      = str x
str (Add (x:y:zs))
    | isneg y      = str (Add [x])        ++ str (Add (y:zs))
str (Add (x:xs))   = str (Add [x]) ++ "+" ++ str (Add xs)
str (Mul [])       = ""
str (Mul [Add xs]) = "(" ++ str (Add xs) ++ ")"
str (Mul [Mul xs]) = "(" ++ str (Mul xs) ++ ")"
str (Mul [x])      = str x
str (Mul (x:xs))   = str (Mul [x]) ++ "*" ++ str (Mul xs)
str (Var x  1 1) = x
str (Var x(-1)1) = "-" ++ x
str (Var x  a 1) = show a ++ x
str (Var x  a n) = str (Var x a 1) ++ "^" ++ show n
x a n = Var "x" a n

tests = TestList
        [ "eval 1" ~: eval (Add[N 1,N 1 ]) ~?= 1+1
        , "eval 2" ~: eval (Add[N 2,N 3 ]) ~?= 2+3
        , "eval 3" ~: eval (Add[N 5,N(-3)]) ~?= 5-3
        , "eval 4" ~: eval (Mul[N 3,N 4 ]) ~?= 3*4
        , "eval 5" ~: eval (Add[N 1,Mul[N 2,N 3]]) ~?= 1+2*3
        , "eval 6" ~: eval (Mul[Add[N 1,N 2],N 3]) ~?= (1+2)*3
        , "str 1" ~: str (Add[N 1,N 2 ,N 3 ]) ~?= "1+2+3"
        , "str 2" ~: str (Add[N 1,N(-2),N(-3)]) ~?= "1-2-3"
        , "str 3" ~: str (Mul[N 1,N 2 ,N 3 ]) ~?= "1*2*3"
        , "str 4" ~: str (Add[N 1,Mul[N 2,N 3]]) ~?= "1+2*3"
        , "str 5" ~: str (Add[Add[N 1,N 2],N 3]) ~?= "(1+2)+3"
        , "str 6" ~: str (Mul[Add[N 1,N 2],N 3]) ~?= "(1+2)*3"
        , "str 7" ~: str (Mul[Mul[N 1,N 2],N 3]) ~?= "(1*2)*3"
        , "equal" ~: Add[N 1,N 2] ~?= Add[N 1,N 2]
        -- , "x 1" ~: str (Add [x 1,N 1]) ~?= "x+1"
        -- , "x 2" ~: str (Add [x 2,x 1,N 1]) ~?= "x^2+x+1"
        , "x 1" ~: str (Add [1`x`1,N 1]) ~?= "x+1"
        , "x 2" ~: str (Add [1`x`3,(-1)`x`2,(-2)`x`1,N 1]) ~?= "x^3-x^2-2x+1"
        ]

main = do
    runTestText (putTextToHandle stderr False) tests
-- main = do
--     let f = Mul[Add[N 1,N 2],N 3]
--     print $ f
--     print $ str f
