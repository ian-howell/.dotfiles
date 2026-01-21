package main

import (
	"errors"
	"fmt"
	"os"
	"path/filepath"
)

func main() {
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}
}

func run() error {
	cfg, err := getConfig()
	if err != nil {
		return fmt.Errorf("failed to get config: %w", err)
	}
	if err := linkFiles(cfg); err != nil {
		return fmt.Errorf("failed to link files: %w", err)
	}

	return nil
}

func linkFiles(config Config) error {
	errs := []error{}
	for _, link := range config.Links {
		if err := linkFile(link); err != nil {
			errs = append(errs, fmt.Errorf("link %q -> %q: %w", link.File, link.Link, err))
		}
	}

	return errors.Join(errs...)
}

func linkFile(link Link) error {
	source := link.File
	target := link.Link

	// Create the parent directory if it doesn't exist
	if err := os.MkdirAll(filepath.Dir(target), 0755); err != nil {
		return fmt.Errorf("failed to create parent directory: %w", err)
	}

	// If the target already exists, remove it
	if _, err := os.Lstat(target); err == nil {
		if err := os.RemoveAll(target); err != nil {
			return fmt.Errorf("failed to remove existing target: %w", err)
		}
	}

	if err := os.Symlink(source, target); err != nil {
		return fmt.Errorf("failed to create symlink: %w", err)
	}

	return nil
}
