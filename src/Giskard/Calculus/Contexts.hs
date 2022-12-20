
-----------------------------------------------------------
-- |
-- Module       : Giskard.Calculus.Contexts
-- Description  : Contexts and Telescopes of the Calculus
-----------------------------------------------------------
module Giskard.Calculus.Contexts
    ( Context (..)
    , Declaration (..)
    , emptyCtxt
    , ctxtToTele
    ) where

import Giskard.Calculus.Term


-- |
-- Contexts implemented using lists. These store assumptions, like telescopes,
-- but can also store local definitions.
--
data Context
    -- | A context with a generic name: @C@.
    = NamedContext Name
    -- | A context list: @(x : A), (y : B), ...@.
    | ContextList [Declaration]
    -- | Concatenated contexts: @C ; D@
    | ConcatContexts
        Context
        Context

data Declaration
    = Assume Name Type
    | Define Name Term Type

-- |
-- Initial empty context.
--
emptyCtxt :: Context
emptyCtxt = ContextList []

-- |
-- Convert a context list to a telescope term.
--
ctxtToTele :: Context -> Term
ctxtToTele = go Star where
    go tele = \case
        -- (C : *) -> *
        NamedContext name -> mkPi name Star tele

        ContextList xs
            -> foldr goDecl tele $ reverse xs where
                goDecl (Assume name   ty) tele1 = mkPi name ty tele1
                goDecl (Define name _ ty) tele1 = mkPi name ty tele1

        ConcatContexts ctxt1 ctxt2
            -> go (go tele ctxt2) ctxt1