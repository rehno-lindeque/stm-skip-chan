# stm-skip-chan

STM-based implementation of skip channels extended with a combined read function.

Similar to the SkipChan implementation described in the [Concurrent Haskell](https://www.microsoft.com/en-us/research/wp-content/uploads/1996/01/concurrent-haskell.pdf) paper.

## Combined read

The combined read function `takeMergedTSkipChan` blocks until any one of N channels is updated and then reads the newest value from all of them simultaneously.

This affords you the ability to simultaneously subscribe to and block on multiple events without pulling in more a complex FRP / LSP / streaming dependency.

Keep in mind that a skip channel is designed to drop events that occur faster than what the reader is able to handle.

## Future work

An alternative implementation might split the reader and writer into two types, similar to broadcast-chan and chan-split packages.

It may be possible to implement a reader with a nicer applicative instance such that.

```
forever $ do
  (x,y,z) <- atomically $ takeTSkipChan ((,,) <$> reader1 <*> reader2 <*> reader3)
  -- make use of x, y, z
```
