// This example parses an LLVM IR assembly file and pretty-prints the data types
// of the parsed module to standard output.
package main

import (
	"log"

	"github.com/kr/pretty"
	"github.com/llir/llvm/asm"
)

func main() {
	// Parse the LLVM IR assembly file `main.ll`.
	mod, err := asm.ParseFile("llvm/main.ll")
	if err != nil {
		log.Fatalf("%+v", err)
	}
	// Pretty-print the data types of the parsed LLVM IR module.
	pretty.Println(mod)
}
