import BasePrelude
import Data.ByteString (ByteString)
import qualified Data.ByteString as BS
import Data.Attoparsec.ByteString
import Data.List (words)

readByte :: String -> Word8
readByte = foldl step 0
  where
    step byte char = consumeBit char (shiftL byte 1)
    consumeBit '0' = id
    consumeBit '1' = (.|. 1)

readBytes :: [String] -> ByteString
readBytes = BS.pack . fmap readByte

test :: [String] -> IO ()
test = print . parseUtf8 . readBytes

main :: IO ()
main = do
  test [ "01101110", "01100001"             -- na
       , "01101001", "11001100", "10001000" -- ï
       , "01110110", "01100101", "01110100" -- vet
       , "11000011", "10101001"             -- é
       ]
  test ["11000000", "10000001"] -- overlong
  test ["11000000"] -- not enough continuation bits
  test ["10010010"] -- leading continuation bit
  test ["11010111", "10000000", "10001010"] -- too many continuation bits

parseUtf8 :: ByteString -> Either String [Word32]
parseUtf8 = parseOnly utf8Parser

utf8Parser :: Parser [Word32]
utf8Parser = manyTill' codePointParser endOfInput

codePointParser :: Parser Word32
codePointParser =
  byteSequence ["0xxxxxxx"] <|>
  overlong 0x7F (multibyte "110xxxxx" 1) <|>
  overlong 0x7FF (multibyte "1110xxxx" 2) <|>
  checkedParser (overlong 0xFFFF (multibyte "11110xxx" 3))
                (< 0x110000)
                "illegal codepoint over 0x10FFFF"
  where
    multibyte leader num = byteSequence (leader : replicate num "10xxxxxx")

overlong :: Word32 -> Parser Word32 -> Parser Word32
overlong m parser = checkedParser parser (> m) "illegal overlong codepoint!"

byteSequence :: [String] -> Parser Word32
byteSequence patterns = do
  subBytes <- sequence (bytePattern <$> patterns)
  return (foldl mergeSubByte 0 subBytes)

mergeSubByte :: Word32 -> SubByte -> Word32
mergeSubByte whole (SubByte byte bits) =
  shiftL whole bits .|. fromIntegral byte

data SubByte = SubByte Word8 Int deriving (Show, Eq)

subZero :: SubByte
subZero = SubByte 0 0

pushBit :: Bool -> SubByte -> SubByte
pushBit True (SubByte b n) = SubByte (setBit (shiftL b 1) 0) (n + 1)
pushBit False (SubByte b n) = SubByte (shiftL b 1) (n + 1)

bytePattern :: String -> Parser SubByte
bytePattern pattern = satisfyMaybe (matchByte pattern)

matchByte :: String -> Word8 -> Maybe SubByte
matchByte pattern byte = foldM (flip check) subZero (zip pattern bits)
  where
    check ('1', True)  = Just
    check ('0', False) = Just
    check ('x', bit)   = Just . pushBit bit
    check _            = const Nothing
    bits = testBit byte <$> [7, 6 .. 0]

satisfyMaybe :: (Word8 -> Maybe a) -> Parser a
satisfyMaybe f = do
  byte <- anyWord8
  maybe (fail "maybe not satisfied") return (f byte)

checkedParser :: Parser a -> (a -> Bool) -> String -> Parser a
checkedParser parser predicate msg = do
  word <- parser
  unless (predicate word) (fail msg)
  return word
