package main

import (
	"fmt"
	"os"

	"github.com/spf13/pflag"
)

func main() {
	configFilePath, err := defaultConfigFilePath()
	if err != nil {

		os.Exit(1)
	}
	pflag.StringVarP(&configFilePath, "config", "c", configFilePath, "Path to the config file")

	pflag.Parse()

	fmt.Println("Config file path:", configFilePath)
}

func defaultConfigFilePath() (string, error) {
	homeDir, err := os.UserHomeDir()
	if err != nil {
		return "", fmt.Errorf("failed to find a home directory: %w", err)
	}
	return homeDir + "/.dotfiles/src/linkdotfiles/config.yaml", nil
}
