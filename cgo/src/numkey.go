// Package numkey is a Go wrapper for the numkey C software library.
// 64 bit Encoding for Short Codes and E.164 LVN.
//
// @category   Libraries
// @author     Nicola Asuni <nicola.asuni@vonage.com>
// @copyright  2019-2020 Vonage
// @license    see LICENSE file
// @link       https://github.com/nexmoinc/numkey
package numkey

/*
#cgo CFLAGS: -O3 -pedantic -std=c99 -Wextra -Wno-strict-prototypes -Wcast-align -Wundef -Wformat-security -Wshadow
#include <stdlib.h>
#include <inttypes.h>
#include "../../c/src/numkey/hex.h"
#include "../../c/src/numkey/numkey.h"
*/
import "C"
import "unsafe"

// TNumKey contains the number components
type TNumKey struct {
	Country string `json:"country"`
	Number  string `json:"number"`
}

// castCNumKey convert C numkey_t to GO TNumKey.
func castCNumKey(nk C.numkey_t) TNumKey {
	return TNumKey{
		Country: C.GoString((*C.char)(unsafe.Pointer(&nk.country[0]))),
		Number:  C.GoString((*C.char)(unsafe.Pointer(&nk.number[0]))),
	}
}

// StringToNTBytesN convert a string to byte array allocating "size" bytes.
func StringToNTBytesN(s string, size int) []byte {
	b := make([]byte, size)
	copy(b[:], s)
	return b
}

// NumKey returns an encoded COUNTRY + NUMBER
// If the country or number are invalid this function returns 0
func NumKey(country, number string) uint64 {
	countrysize := len(country)
	numsize := len(number)
	if countrysize != 2 || numsize < 1 {
		return 0
	}
	bcountry := StringToNTBytesN(country, countrysize+1)
	bnumber := StringToNTBytesN(number, numsize+1)
	pcountry := unsafe.Pointer(&bcountry[0]) // #nosec
	pnumber := unsafe.Pointer(&bnumber[0])   // #nosec
	return uint64(C.numkey((*C.char)(pcountry), (*C.char)(pnumber), C.size_t(numsize)))
}

// DecodeNumKey parses a numkey string and returns the components as TNumKey structure.
func DecodeNumKey(nk uint64) TNumKey {
	if nk == 0 {
		return TNumKey{}
	}
	var data C.numkey_t
	C.decode_numkey(C.uint64_t(nk), &data)
	return castCNumKey(data)
}

// CompareNumKeyCountry compares two NumKeys by country only.
func CompareNumKeyCountry(nka, nkb uint64) int {
	return int(C.compare_numkey_country(C.uint64_t(nka), C.uint64_t(nkb)))
}

// Hex provides a 16 digits hexadecimal string representation of a 64bit unsigned number.
func Hex(v uint64) string {
	cstr := C.malloc(17)
	defer C.free(unsafe.Pointer(cstr)) // #nosec
	C.numkey_hex(C.uint64_t(v), (*C.char)(cstr))
	return C.GoStringN((*C.char)(cstr), C.int(16))
}

// ParseHex parses a 16 digit HEX string and returns the 64 bit unsigned number.
func ParseHex(s string) uint64 {
	b := StringToNTBytesN(s, len(s)+1)
	p := unsafe.Pointer(&b[0]) // #nosec
	return uint64(C.parse_numkey_hex((*C.char)(p)))
}
