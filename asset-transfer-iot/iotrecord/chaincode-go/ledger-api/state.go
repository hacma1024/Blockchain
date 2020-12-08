/*
 * SPDX-License-Identifier: Apache-2.0
 */

package ledgerapi

import (
	"bytes"
	"fmt"
	"strings"
)

// MapToJSONString convert map to string of Json format
func MapToJSONString(m map[string]interface{}) string {
	b := new(bytes.Buffer)
	fmt.Fprintf(b, "`{")
	for key, value := range m {
		fmt.Fprintf(b, "\"%v\":\"%v\" ,", key, value)
	}
	fmt.Fprintf(b, "}`")
	s := b.String()
	k := strings.LastIndex(s, ",")
	return s[:k] + s[k+1:]
}

// SplitKey splits a key on colon
func SplitKey(key string) []string {
	return strings.Split(key, ":")
}

// MakeKey joins key parts using colon
func MakeKey(keyParts ...string) string {
	return strings.Join(keyParts, ":")
}

// StateInterface interface states must implement
// for use in a list
type StateInterface interface {
	// GetKey return components that combine to form the key
	GetKey() string
	Serialize() ([]byte, error)
}
