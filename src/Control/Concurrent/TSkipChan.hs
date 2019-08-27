module Control.Concurrent.TSkipChan where

import Control.Concurrent.STM (STM)
import Control.Concurrent.STM.TVar (TVar, newTVar, stateTVar)
import Control.Concurrent.STM.TMVar (TMVar, newTMVar, takeTMVar, tryTakeTMVar, putTMVar)
import Data.Foldable (for_, asum)
import Data.Traversable (for)
import Control.Applicative ((<|>))

data TSkipChan a = TSkipChan (TVar (a, [TMVar ()])) (TMVar ())

{-# inline newTSkipChan #-}
newTSkipChan :: a -> STM (TSkipChan a)
newTSkipChan a = do
  sem <- newTMVar ()
  main <- newTVar (a, [])
  return (TSkipChan main sem)

{-# inline putTSkipChan #-}
putTSkipChan :: TSkipChan a -> a -> STM ()
putTSkipChan (TSkipChan main _) a = do
  originalSems <- stateTVar main (\(_, sems) -> (sems, (a, [])))
  for_ originalSems $ \sem ->
    putTMVar sem ()

{-# inline takeTSkipChan #-}
takeTSkipChan :: TSkipChan a -> STM a
takeTSkipChan (TSkipChan main sem) = do
  takeTMVar sem
  a <- stateTVar main (\(a, sems) -> (a, (a, sem:sems)))
  return a

{-# inline takeMergedTSkipChan #-}
takeMergedTSkipChan :: [TSkipChan a] -> STM [a]
takeMergedTSkipChan chans = do
  case chans of
    [] -> return []
    _ -> do
      takeAnyAndEveryTMVar (map (\(TSkipChan _ sem) -> sem) chans)
      for chans $ \(TSkipChan main sem) ->
        stateTVar main (\(a, sems) -> (a, (a, sem:sems)))
  where
    takeAnyAndEveryTMVar [c] = takeTMVar c
    takeAnyAndEveryTMVar (c:cs) =
      (takeTMVar c >> mapM_ tryTakeTMVar cs)
        <|> takeAnyAndEveryTMVar cs

{-# inline dupTSkipChan #-}
dupTSkipChan :: TSkipChan a -> STM (TSkipChan a)
dupTSkipChan (TSkipChan main _) = do
  sem <- newTMVar ()
  return (TSkipChan main sem)

