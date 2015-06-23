module Main where

import Data.List
import Data.Char
import Data.Maybe(catMaybes, fromJust)

bestGenotype = encode [East, South, South]

myMap = Map 
    [
        replicate 15 Wall,
        [Exit, Open, Wall] ++ replicate 5 Open ++ replicate 3 Wall ++ replicate 3 Open ++ [Wall],
        Wall : replicate 7 Open ++ replicate 3 Wall ++ replicate 3 Open ++ [Wall],
        Wall : replicate 3 Open ++ replicate 3 Wall ++ [Open, Open, Wall] ++ replicate 4 Open ++ [Wall],
        Wall : replicate 3 Open ++ replicate 3 Wall ++ replicate 5 Open ++ [Wall, Open, Wall],
        [Wall, Wall, Open, Open] ++ replicate 3 Wall ++ replicate 5 Open ++ [Wall, Open, Wall],
        Wall : replicate 4 Open ++ [Wall] ++ replicate 4 Open ++ replicate 3 Wall ++ [Open, Wall],
        [Wall, Open, Wall, Wall] ++ replicate 3 Open ++ [Wall] ++ replicate 6 Open ++ [Entr],
        [Wall, Open, Wall, Wall] ++ replicate 3 Open ++ [Wall] ++ replicate 6 Open ++ [Wall],
        replicate 15 Wall        
    ]

-- Maybe version of (!!)
elemAt :: [a] -> Int -> Maybe a
elemAt xs i
    | i < 0 || i + 1 > length xs = Nothing
    | otherwise = Just $ xs !! i


-------- MAP --------

data Map = Map [[Square]]
instance Show Map where
    show (Map m) = intercalate "\n" $ map (foldl1 (++)) $ map (map show) m

showSqr :: Square -> String
showSqr Exit = "3"
showSqr Entr = "2"
showSqr Wall = "1"
showSqr Open = "0"

data Square = Exit | Entr | Open | Wall deriving (Eq)
instance Show Square where
    show Exit = "3"
    show Entr = "2"
    show Open = "0"
    show Wall = "1"

type Pos = (Int, Int)
data Direction = North | South | East | West deriving (Show, Eq)
type Route = [Direction]
 
move :: Direction -> Pos -> Map -> Pos
move d p (Map m) = if ((fromJust (m `elemAt` fst (add d p))) `elemAt` snd (add d p)) `elem` map Just [Open, Exit, Entr] then 
    (add d p) else p
        where 
            add North (r, c) = (r - 1, c)
            add South (r, c) = (r + 1, c)
            add East  (r, c) = (r, c + 1)
            add West  (r, c) = (r, c - 1)

startPos :: Map -> Pos
startPos (Map m) = (head $ catMaybes $ map (Entr `elemIndex`) (transpose m), 
                    head $ catMaybes $ map (Entr `elemIndex`) m)

exitPos :: Map -> Pos
exitPos (Map m) = (head $ catMaybes $ map (Exit `elemIndex`) (transpose m), 
                   head $ catMaybes $ map (Exit `elemIndex`) m)

distance :: Pos -> Pos -> Int
distance (r1, c1) (r2, c2) = abs (r1 - r2 + c1 - c2)

evaluate :: Route -> Pos -> Map -> Pos
evaluate [] p m = p
evaluate (d:ds) p m = evaluate ds (move d p m) m

-------- GENETICS --------

type Genotype = [Allele]
type Allele = (Bool, Bool)
type Fitness = Int

encode :: Route -> Genotype
encode [] = []
encode (North:xs) = (False, False) : encode xs
encode (South:xs) = (False, True) : encode xs
encode (East:xs) = (True, False) : encode xs
encode (West:xs) = (True, True) : encode xs

decode :: Genotype -> Route
decode [] = []
decode ((False, False):xs) = (North : (decode xs))
decode ((False, True):xs) = (South : (decode xs))
decode ((True, False):xs) = (East : (decode xs))
decode ((True, True):xs) = (West : (decode xs))

determineFitness :: Pos -> Map -> Fitness
determineFitness p (Map m)
    | distance p (exitPos (Map m)) == 0 = 2 * (distance (startPos (Map m)) (exitPos (Map m)))
    | otherwise = (distance (startPos (Map m)) (exitPos (Map m))) `div` 
                  (distance p (exitPos (Map m)))

testGenotype :: Genotype -> Map -> Fitness
testGenotype g (Map m) = determineFitness (evaluate (decode g) (startPos (Map m)) (Map m)) (Map m)

------- IO -------

main = do
    putStrLn $ show $ testGenotype bestGenotype $ myMap
