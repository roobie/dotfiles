/**
 * Hash utility script using Bun's CryptoHasher.
 *
 * This script computes a hash of the provided input string using the specified algorithm
 * (default: sha256) and outputs the result in base64url format.
 *
 * Usage: bun hash.ts <value> [--algo <algorithm>]
 *
 * Examples:
 *   bun hash.ts "hello world"
 *   bun hash.ts "password" --algo sha512
 *
 * N.B.: This script is designed for Bun runtime and uses Bun-specific APIs.

 References
 https://bun.com/docs/guides/process/argv.md
 https://bun.com/docs/runtime/hashing.md

    ## `Bun.CryptoHasher`

    `Bun.CryptoHasher` is a general-purpose utility class that lets you incrementally compute a hash of string or binary data using a range of cryptographic hash algorithms. The following algorithms are supported:

    - `"blake2b256"`
    - `"blake2b512"`
    - `"md4"`
    - `"md5"`
    - `"ripemd160"`
    - `"sha1"`
    - `"sha224"`
    - `"sha256"`
    - `"sha384"`
    - `"sha512"`
    * `"sha512-224"`
    - `"sha512-256"`
    - `"sha3-224"`
    - `"sha3-256"`
    - `"sha3-384"`
    - `"sha3-512"`
    - `"shake128"`
    - `"shake256"`
====================================================================================================
*/

import { CryptoHasher } from "bun";
import { parseArgs } from "util";

const { values, positionals } = parseArgs({
  args: Bun.argv,
  options: {
    algo: {
      type: "string",
    },
  },
  strict: true,
  allowPositionals: true,
});

const input = positionals[2];
if (String(input || "").length < 1) {
  throw Error("missing arg 'value' (the value to apply the hash function to)");
}

const hasher = new CryptoHasher(values.algo ?? "sha256");
hasher.update(input);
const data = hasher.digest();
console.log(toBase64Url(data));

/**
 * Converts a Uint8Array to a base64url-encoded string.
 *
 * @param data - The byte array to encode.
 * @returns The base64url-encoded string.
 */
function toBase64Url(data: Uint8Array): string {
  const base64url = Buffer.from(data)
    .toString("base64")
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=/g, "");
  return base64url;
}
