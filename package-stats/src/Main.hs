{-# LANGUAGE OverloadedStrings, DeriveGeneric #-}
module Main (
    main
) where

import Network.HTTP.Conduit (responseBody)
import Data.Conduit (($$), (=$=), (.|))
import Data.Conduit.Binary (sinkFile)
import Data.Conduit.Zlib (ungzip)
import Control.Lens ((.>))
import Data.Text (Text)
import Data.CSV.Conduit (runResourceT, CSV(..), fromCSV, defCSVSettings)
import Data.CSV.Conduit.Conversion (getNamed, FromNamedRecord, ToNamedRecord)
import GHC.Generics (Generic)
import Network.HTTP.Simple (httpSource)
import Data.Conduit.List (consume)
import Control.Monad.IO.Class (MonadIO(..))
import qualified Data.Map as M
       (empty, unionWith, fromListWith, toList)
import Data.Time
       (fromGregorian, addDays, showGregorian, getCurrentTime, utctDay)
import Control.Monad (when, foldM_, forM_)
import Data.String (IsString(..))
import Data.Traversable (forM)
import Data.List (sortOn)
import qualified Data.Text as T (map, unlines, unpack)
import qualified Data.Text.IO as T (putStrLn)
import Data.Monoid ((<>))
import Control.DeepSeq (deepseq)

data LogRecord = LogRecord
    { package :: Text
    , version :: Text
    } deriving (Generic, Show)

instance FromNamedRecord LogRecord
instance ToNamedRecord LogRecord

main :: IO ()
main = do
    -- day <- utctDay <$> getCurrentTime
    let day = fromGregorian 2017 10 14
    list <- runResourceT $
        forM [-62 .. -2] (\n -> do
            let dayString = showGregorian (addDays n day)
            l <- M.fromListWith (+) . map (\lr -> (package $ getNamed lr, 1 :: Int)) <$>
                (httpSource (fromString $ "http://cran-logs.rstudio.com/" ++ take 4 dayString ++ "/" ++ dayString ++ ".csv.gz") responseBody
                    .| ungzip
                    .| intoCSV defCSVSettings
                    $$ consume)
            deepseq l $ return l)
    let sorted = sortOn (negate . snd) . M.toList $ foldl (M.unionWith (+)) M.empty list
        total = sum $ map snd sorted
        -- Replace totals with a running total
        runningTotal = zip (map fst sorted) . scanl1 (+) $ map snd sorted
        -- Most popular packages (make up 90% of downloads)
        top = map fst $ takeWhile (\t -> snd t * 100 `div` total < 90) runningTotal
        fixName = T.map (\c -> if c == '.' then '_' else c)
        commentOutBroken n | n `elem` broken = "# " <> n
                           | otherwise = n
        broken =
            [ "KoNLP", "Sejong" -- hash mismatch for Sejong
            , "installr" -- Windows only
            , "rpanel" -- bwidget tcl error checking
            , "carData", "spatstat_data", "asciiSetupReader", "HybridFS", "ggridges", "incgraph" -- new (R package not in nixpkgs yet)
            , "Rsymphony" -- Underlying native library is not in nixpkgs
            , "Seurat" -- SDMTools.so: undefined symbol: X
            , "tesseract" -- pkg-config seems to work, but we still get an anticonf error.
            ]
        fixedNames = map (commentOutBroken . fixName) top
    T.putStrLn $ T.unlines fixedNames
