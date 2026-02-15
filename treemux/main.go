package main

import (
	"errors"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

func main() {
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v", err)
		os.Exit(1)
	}
}

func run() error {
	if len(os.Args) < 2 {
		usage()
		return nil
	}

	switch os.Args[1] {
	case "create-root":
		return createRoot(os.Args[2:])
	case "create-child":
		return createChild(os.Args[2:])
	case "-h", "--help", "help":
		usage()
		return nil
	default:
		return fmt.Errorf("unknown command: %s", os.Args[1])
	}
}

func usage() {
	fmt.Fprintln(os.Stderr, "Usage:")
	fmt.Fprintln(os.Stderr, "  treemux create-root <root-name> <root-dir>")
	fmt.Fprintln(os.Stderr, "  treemux create-child <child-name> <command>")
}

func createRoot(args []string) error {
	if len(args) != 2 {
		return errors.New("Usage: treemux create-root <root-name> <root-dir>")
	}

	rootName := args[0]
	rootDir := args[1]

	absRootDir, err := normalizePath(rootDir)
	if err != nil {
		return err
	}

	if info, err := os.Stat(absRootDir); err != nil || !info.IsDir() {
		return fmt.Errorf("root directory does not exist: %s", absRootDir)
	}

	sessionName := sanitizeRootName(rootName)
	if sessionName == "" {
		return errors.New("root session name is empty after sanitizing")
	}

	if tmuxHasSession(sessionName) {
		fmt.Printf("Session '%s' already exists, skipping creation\n", sessionName)
		return nil
	}

	if err := runTmux("new-session", "-d", "-s", sessionName, "-c", absRootDir); err != nil {
		return fmt.Errorf("failed to create tmux session '%s': %v", sessionName, err)
	}
	if err := runTmux("set-option", "-q", "-t", sessionName, "@tree_root_dir", absRootDir); err != nil {
		return fmt.Errorf("failed to set tmux option @tree_root_dir for session '%s': %v", sessionName, err)
	}
	if err := runTmux("set-option", "-q", "-t", sessionName, "@tree_root_name", sessionName); err != nil {
		return fmt.Errorf("failed to set tmux option @tree_root_name for session '%s': %v", sessionName, err)
	}

	fmt.Printf("Created root session: %s\n", sessionName)
	return nil
}

func createChild(args []string) error {
	if len(args) != 2 {
		return errors.New("Usage: treemux create-child <child-name> <command>")
	}

	if os.Getenv("TMUX") == "" {
		return errors.New("tmux is not running")
	}

	childName := args[0]
	command := args[1]

	rootName, err := tmuxShowOption("@tree_root_name")
	if err != nil {
		return err
	}
	rootName = strings.TrimSpace(rootName)
	if rootName == "" {
		return errors.New("missing root metadata (@tree_root_name) for current session")
	}

	rootDir, err := tmuxShowOption("@tree_root_dir")
	if err != nil {
		return err
	}
	rootDir = strings.TrimSpace(rootDir)
	if rootDir == "" {
		return fmt.Errorf("missing root metadata (@tree_root_dir) for session: %s", rootName)
	}

	separator := tmuxSeparator()
	childSession := rootName + separator + childName

	if tmuxHasSession(childSession) {
		fmt.Printf("Child session '%s' already exists, skipping creation\n", childSession)
		return nil
	}

	if err := runTmux("new-session", "-d", "-s", childSession, "-c", rootDir, "--", command); err != nil {
		return fmt.Errorf("failed to create child tmux session '%s': %v", childSession, err)
	}
	if err := runTmux("set-option", "-q", "-t", childSession, "@tree_root_dir", rootDir); err != nil {
		return fmt.Errorf("failed to set tmux option @tree_root_dir for child session '%s': %v", childSession, err)
	}
	if err := runTmux("set-option", "-q", "-t", childSession, "@tree_root_name", rootName); err != nil {
		return fmt.Errorf("failed to set tmux option @tree_root_name for child session '%s': %v", childSession, err)
	}

	fmt.Printf("Created child session: %s\n", childSession)
	return nil
}

func tmuxSeparator() string {
	if sep := os.Getenv("TMUX_TREE_SEPARATOR"); sep != "" {
		return sep
	}

	const defaultSeparator = " 🌿 "
	return defaultSeparator
}

// TODO: This prints "can't find session: <name>" to stderr when the session doesn't exist, which is
// a bit noisy. We should suppress that output
func tmuxHasSession(name string) bool {
	err := runTmux("has-session", "-t", name)
	return err == nil
}

func tmuxShowOption(name string) (string, error) {
	cmd := exec.Command("tmux", "show-option", "-qv", name)
	output, err := cmd.Output()
	if err != nil {
		return "", fmt.Errorf("failed to read tmux option %s", name)
	}
	return string(output), nil
}

func runTmux(args ...string) error {
	cmd := exec.Command("tmux", args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

func normalizePath(path string) (string, error) {
	if strings.HasPrefix(path, "~") {
		home, err := os.UserHomeDir()
		if err != nil {
			return "", err
		}
		path = filepath.Join(home, strings.TrimPrefix(path, "~"))
	}

	if !filepath.IsAbs(path) {
		cwd, err := os.Getwd()
		if err != nil {
			return "", err
		}
		path = filepath.Join(cwd, path)
	}

	return filepath.Clean(path), nil
}

func sanitizeRootName(name string) string {
	for strings.HasPrefix(name, ".") {
		name = strings.TrimPrefix(name, ".")
	}
	name = strings.ReplaceAll(name, ".", "_")
	return name
}
