
# extract bits and store the components seprately in a
# big-endian format (to be compatible with left-to-right
# reading coventions for numbers)
unpack_double <- function(x) {
  binary <- numToBits(x)  # little-endian binary representation
  structure(
    list(
      sign = binary[64],        # 1-bit sign
      exponent = binary[63:53], # 11-bit big-endian exponent
      mantissa = binary[52:1]   # 52-bit big-endian mantissa
    ),
    class = "unpacked_double"
  )
}

# pretty print method
print.unpacked_double <- function(x, ...) {
  binary_sign <- as.character(as.integer(x$sign))
  binary_exponent <- paste(as.character(as.integer(x$exponent)), collapse = "")
  binary_mantissa <- paste(as.character(as.integer(x$mantissa)), collapse = "")
  cat(binary_sign, binary_exponent, binary_mantissa, "\n")
  return(invisible(x))
}

# extractor functions to reconstitute the sign, mantissa
# and exponent from their binary representations
extract_sign <- function(x) {
  return(ifelse(as.integer(x$sign) == 0, 1, -1))
}
extract_mantissa <- function(x) {
  mantissa_bits <- as.integer(x$mantissa)
  bit_multipliers <- 2 ^ (-1:-52)
  mantissa <- 1 + sum(mantissa_bits * bit_multipliers)
  return(mantissa)
}
extract_exponent <- function(x) {
  exponent_bits <- as.integer(x$exponent)
  bit_multipliers <- 2 ^ (10:0)
  exponent <- 1 + sum(exponent_bits * bit_multipliers) - 2^10
  return(exponent)
}

# sanity check: repack_double(unpack_double(x)) should always return x
repack_double <- function(x) {
  sign <- extract_sign(x)
  exponent <- extract_exponent(x)
  mantissa <- extract_mantissa(x)
  return(sign * mantissa * 2 ^ exponent)
}
