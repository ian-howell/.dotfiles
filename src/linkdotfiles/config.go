package main

import (
	"fmt"
	"os"
	"path/filepath"
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

func getConfig() Config {
	homeDir, err := os.UserHomeDir()
	if err != nil {
		panic(fmt.Sprintf("failed to get user home directory: %v", err))
	}
	return Config{
		SourceRoot: filepath.Join(homeDir, ".dotfiles/links"),
		TargetRoot: homeDir,
		Links: []Link{
			{"azure/config", ".azure/config"},
			{"bin", ".bin"},
			{"fonts", ".fonts"},
			{"gitconfig", ".gitconfig"},
			{"global_gitignore", ".global_gitignore"},
			{"zprofile", ".zprofile"},
			{"tmux", ".config/tmux"},
			{"kitty", ".config/kitty"},
			{"nvim", ".config/nvim"},
			{"zsh", ".zsh"},
			{"zshenv", ".zshenv"},
			{"zshrc", ".zshrc"},
			{"lazygit.yml", ".config/lazygit/config.yml"},
			{"sesh", ".config/sesh"},
			{"shellcheckrc", ".shellcheckrc"},
			{"vscode-nvim", ".config/vscode-nvim"},
		},
	}
}

func linkFiles(config Config) error {
	for _, link := range config.Links {
		source := config.SourceRoot + "/" + link.Source
		target := config.TargetRoot + "/" + link.Target

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
	}
	return nil
}
