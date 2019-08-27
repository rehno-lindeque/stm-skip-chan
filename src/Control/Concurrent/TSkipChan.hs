module Control.Concurrent.TSkipChan where

import Control.Concurrent.STM (STM)
import Control.Concurrent.STM.TVar (TVar, newTVar, stateTVar)
import Control.Concurrent.STM.TMVar (TMVar, newTMVar, takeTMVar, putTMVar)
import Data.Foldable (for_)

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

{-# inline dupTSkipChan #-}
dupTSkipChan :: TSkipChan a -> STM (TSkipChan a)
dupTSkipChan (TSkipChan main _) = do
  sem <- newTMVar ()
  return (TSkipChan main sem)

