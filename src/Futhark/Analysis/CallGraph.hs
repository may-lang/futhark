-- | This module exports functionality for generating a call graph of
-- an Futhark program.
module Futhark.Analysis.CallGraph
  ( CallGraph
  , buildCallGraph
  )
  where

import Control.Monad.Writer.Strict
import qualified Data.Map.Strict as M
import qualified Data.Set as S
import Data.Maybe (isJust)
import Data.List

import Futhark.Representation.SOACS

type FunctionTable = M.Map Name FunDef

buildFunctionTable :: Prog -> FunctionTable
buildFunctionTable = foldl expand M.empty . progFunctions
  where expand ftab f = M.insert (funDefName f) f ftab

-- | The call graph is just a mapping from a function name, i.e., the
-- caller, to a list of the names of functions called by the function.
-- The order of this list is not significant.
type CallGraph = M.Map Name (S.Set Name)

-- | @buildCallGraph prog@ build the program's Call Graph. The representation
-- is a hashtable that maps function names to a list of callee names.
buildCallGraph :: Prog -> CallGraph
buildCallGraph prog = foldl' (buildCGfun ftable) M.empty entry_points
  where entry_points = map funDefName $ filter (isJust . funDefEntryPoint) $ progFunctions prog
        ftable = buildFunctionTable prog

-- | @buildCallGraph ftable cg fname@ updates Call Graph @cg@ with the
-- contributions of function @fname@, and recursively, with the
-- contributions of the callees of @fname@.
buildCGfun :: FunctionTable -> CallGraph -> Name -> CallGraph
buildCGfun ftable cg fname  =
  -- Check if function is a non-builtin that we have not already
  -- processed.
  case M.lookup fname ftable of
    Just f | Nothing <- M.lookup fname cg -> do
               let callees = buildCGbody $ funDefBody f
                   cg' = M.insert fname callees cg
               -- recursively build the callees
               foldl' (buildCGfun ftable) cg' callees
    _ -> cg

buildCGbody :: Body -> S.Set Name
buildCGbody = mconcat . map (buildCGexp . stmExp) . stmsToList . bodyStms

buildCGexp :: Exp -> S.Set Name
buildCGexp (Apply fname _ _ _) = S.singleton fname
buildCGexp (Op op) = execWriter $ mapSOACM folder op
  where folder = identitySOACMapper {
          mapOnSOACLambda = \lam -> do tell $ buildCGbody $ lambdaBody lam
                                       return lam
          }
buildCGexp e = execWriter $ mapExpM folder e
  where folder = identityMapper {
          mapOnBody = \_ body -> do tell $ buildCGbody body
                                    return body
          }
