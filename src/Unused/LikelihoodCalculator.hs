module Unused.LikelihoodCalculator
    ( calculateLikelihood
    ) where

import Unused.Types
import Unused.ResponseFilter (railsSingleOkay, elixirSingleOkay, haskellSingleOkay)

calculateLikelihood :: TermResults -> TermResults
calculateLikelihood r =
    r { trRemoval = uncurry Removal newLikelihood }
  where
    baseScore = totalOccurrenceCount r
    totalScore = baseScore
    newLikelihood
        | railsSingleOkay r = (Low, "a class, module, or migration that often occurs in only one file")
        | elixirSingleOkay r = (Low, "a class, module, or migration that often occurs in only one file")
        | haskellSingleOkay r = (Low, "a module, function, or special case that often occurs in only one file")
        | singleNonTestUsage r && testsExist r = (High, "only the definition and corresponding tests exist")
        | doubleNonTestUsage r && testsExist r = (Medium, "only the definition and one other use, along with tests, exists")
        | totalScore < 2 = (High, "used once")
        | totalScore < 6 = (Medium, "used semi-frequently")
        | totalScore >= 6 = (Low, "used frequently")
        | otherwise = (Unknown, "could not determine likelihood")

singleNonTestUsage :: TermResults -> Bool
singleNonTestUsage = (1 ==) . oOccurrences . trAppOccurrences

doubleNonTestUsage :: TermResults -> Bool
doubleNonTestUsage = (2 ==) . oOccurrences . trAppOccurrences

testsExist :: TermResults -> Bool
testsExist = (> 0) . oOccurrences . trTestOccurrences
