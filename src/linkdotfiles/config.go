package main

import (
	"fmt"
	"io/fs"
	"os"

	"github.com/goccy/go-yaml"
)

// Config represents the configuration for the program
type Config struct {
	// The SourceRoot is the directory where the files to be linked are
	// located. Defaults to the user's home directory.
	SourceRoot string `yaml:"sourceRoot"`

	// The TargetRoot is the directory where the links will be created.
	// Defaults to the user's home directory.
	TargetRoot string `yaml:"targetRoot"`

	// The Links is a list of links to create. Each link's Source and Target
	// will be prefixed with the SourceRoot and TargetRoot respectively.
	Links []Link `yaml:"links"`
}

// A Link represents a symlink to be created
type Link struct {
	// The Source is the path to the file to link to
	Source string `yaml:"source"`

	// The Target is the path where the link will be created
	Target string `yaml:"target"`
}

type Linker struct {
	fs.FS
}

func NewLinker(fs fs.FS) Linker {
	return Linker{fs}
}

func (l Linker) LinkFiles(config Config) error {
	for _, link := range config.Links {
		if err := os.Symlink(link.Source, link.Target); err != nil {
			return fmt.Errorf("failed to create symlink: %w", err)
		}
	}
	return nil
}

// loadConfig reads the config file at the given path and returns a Config
func loadConfig(configFilePath string) (Config, error) {
	configContent, err := os.ReadFile(configFilePath)
	if err != nil {
		return Config{}, fmt.Errorf("failed to read config file: %w", err)
	}

	var config Config
	if err := yaml.Unmarshal(configContent, &config); err != nil {
		return Config{}, fmt.Errorf("failed to decode config: %w", err)
	}

	return config, nil
}

func LinkFiles(config Config) error {
	for _, link := range config.Links {
		if err := os.Symlink(link.Source, link.Target); err != nil {
			return fmt.Errorf("failed to create symlink: %w", err)
		}
	}
	return nil
}
