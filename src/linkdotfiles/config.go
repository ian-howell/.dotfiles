package main

import (
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"gopkg.in/yaml.v3"
)

// Config represents the configuration for the program
type Config struct {
	// The Links is a list of links to create.
	Links []Link `yaml:"links"`
}

// A Link represents a symlink to be created
type Link struct {
	// The File is the absolute path to the file or directory to link to
	File string `yaml:"file"`

	// The Link is the absolute path where the link will be created
	Link string `yaml:"link"`
}

const defaultConfigPath = "~/.dotfiles/linkdotfiles.yaml"

func getConfig() (Config, error) {
	configPath := expandHome(defaultConfigPath)
	data, err := os.ReadFile(configPath)
	if err != nil {
		return Config{}, fmt.Errorf("failed to read config file at %s: %w", configPath, err)
	}

	var config Config
	if err := yaml.Unmarshal(data, &config); err != nil {
		return Config{}, fmt.Errorf("failed to parse config file at %s: %w", configPath, err)
	}

	if err := normalizeConfig(&config); err != nil {
		return Config{}, err
	}

	return config, nil
}

func normalizeConfig(config *Config) error {
	errs := []error{}

	for i, link := range config.Links {
		if strings.TrimSpace(link.File) == "" {
			errs = append(errs, fmt.Errorf("links[%d].file is required", i))
		}
		if strings.TrimSpace(link.Link) == "" {
			errs = append(errs, fmt.Errorf("links[%d].link is required", i))
		}

		link.File = expandHome(link.File)
		link.Link = expandHome(link.Link)
		config.Links[i] = link

		if link.File != "" && !filepath.IsAbs(link.File) {
			errs = append(errs, fmt.Errorf("links[%d].file must be an absolute path", i))
		}
		if link.Link != "" && !filepath.IsAbs(link.Link) {
			errs = append(errs, fmt.Errorf("links[%d].link must be an absolute path", i))
		}
	}

	return errors.Join(errs...)
}

func expandHome(path string) string {
	if !strings.Contains(path, "~") && !strings.Contains(path, "$HOME") {
		return path
	}

	homeDir, err := os.UserHomeDir()
	if err != nil {
		panic(fmt.Sprintf("failed to resolve home directory: %v", err))
	}

	path = strings.ReplaceAll(path, "$HOME", homeDir)
	path = strings.ReplaceAll(path, "~", homeDir)

	return path
}
