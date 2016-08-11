{-# LANGUAGE ViewPatterns #-}

module Stage2 where
  import MapHelper
  import Cube
  import qualified Data.Map.Lazy as Map
  import qualified Data.Sequence as S
  import Control.Monad.Trans.State
  import Control.Monad
  import Control.Monad.IO.Class

  main :: IO ()
  main = generateTable2 >>= \t -> writeTable "Stage2.dat" t

  movesStage2 :: [Move]
  movesStage2 = [U, U', U2, L2, R2, D, D', D2, B, B', B2, F, F', F2]

  getMoveListCorner :: Table Orientation -> Cube -> (Cube,[Move])
  getMoveListCorner ma c = if cornerO c == fromList zero8
    then (c,[]) else let m = ma Map.! cornerO c
                         (a,b) = getMoveListCorner ma (apply [m] c)
                     in (a,m:b)

  generateTable2 :: IO (Table Orientation)
  generateTable2 = execStateT (bfs (S.singleton identity)) Map.empty where
    bfs :: S.Seq Cube -> StateT (Table Orientation) IO ()
    bfs (S.viewl -> S.EmptyL) = return ()
    bfs (S.viewl -> (x S.:< xs)) = do
      ys <- forM movesStage2 $ \m -> do
        let c = apply [m] x
        ma <- get
        if Map.member (cornerO c) ma
          then return []
          else modify ( Map.insert (cornerO c) (invert m)) >> return [c]
      let zs = xs S.>< S.fromList (concat ys)
      liftIO . putStrLn . show . length $ zs
      bfs (zs)
