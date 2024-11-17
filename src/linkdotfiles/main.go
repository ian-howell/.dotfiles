package main

import (
	"fmt"
	"os"

	"github.com/spf13/pflag"
)

func main() {
	configFilePath, err := defaultConfigFilePath()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to construct the default "+
			"config file path: %v\n", err)
		os.Exit(1)
	}
	pflag.StringVarP(&configFilePath, "config", "c", configFilePath,
		"Path to the config file")

	pflag.Parse()

	if err := run(configFilePath); err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}
}

func defaultConfigFilePath() (string, error) {
	homeDir, err := os.UserHomeDir()
	if err != nil {
		return "", fmt.Errorf("failed to find a home directory: %w", err)
	}
	return homeDir + "/.dotfiles/src/linkdotfiles/config.yaml", nil
}

func run(configFilePath string) error {
	// configFileDirFS := os.DirFS(configFilePath)
	config, err := loadConfig(configFilePath)
	if err != nil {
		return fmt.Errorf("failed to load config: %w", err)
	}

	fmt.Println(config)

	// files, err := fs.ReadDir(configFileDirFS, ".")
	// if err != nil {
	// 	return Config{}, fmt.Errorf("failed to read config file: %w", err)
	// }

	// if err := linkFiles(config); err != nil {
	// 	return fmt.Errorf("failed to link files: %w", err)
	// }

	return nil
}
