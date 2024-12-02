package main

import (
	"fmt"
	"os"
)

func main() {
	cfg := getConfig()
	if err := run(cfg); err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}
}

func run(cfg Config) error {
	if err := linkFiles(cfg); err != nil {
		return fmt.Errorf("failed to link files: %w", err)
	}

	return nil
}
