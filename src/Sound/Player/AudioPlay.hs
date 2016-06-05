module Sound.Player.AudioPlay (
  play,
  pause,
  resume,
  stop
) where

import Control.Monad (void)
import Data.Maybe (fromJust)
import System.Process (ProcessHandle, StdStream(CreatePipe),
  CreateProcess(std_err), createProcess, proc, terminateProcess)
import System.Process.Internals (ProcessHandle__(OpenHandle, ClosedHandle),
  PHANDLE, withProcessHandle)


play :: FilePath -> IO ProcessHandle
play path = do
  (_, _, _, processHandle) <-
    -- TODO: update System.Process version to use NoStream
    createProcess (proc "afplay" [path]) {
        std_err = CreatePipe
      }
  return processHandle


pause :: ProcessHandle -> IO ()
pause ph = do
  mPid <- getPid ph
  void $ createProcess (proc "kill" ["-17", show $ fromJust mPid])


resume :: ProcessHandle -> IO ()
resume ph = do
  mPid <- getPid ph
  void $ createProcess (proc "kill" ["-19", show $ fromJust mPid])


stop :: ProcessHandle -> IO ()
stop = terminateProcess


-- See https://mail.haskell.org/pipermail/haskell-cafe/2012-October/104028.html
getPid :: ProcessHandle -> IO (Maybe PHANDLE)
getPid ph = withProcessHandle ph (return . go)
  where
    go (OpenHandle pid) = Just pid
    go (ClosedHandle _) = Nothing
