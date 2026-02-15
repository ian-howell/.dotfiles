package tmux

import (
	"fmt"
	"io"
	"os/exec"
)

type Client struct {
	Binary string
}

func New() *Client {
	return &Client{Binary: "tmux"}
}

func (c *Client) HasSession(name string) bool {
	// Use '=' to match the session name exactly, otherwise tmux will match any session that
	// contains the name as a prefix.
	return c.run(WithArgs("has-session", "-t", "="+name)) == nil
}

func (c *Client) ShowOption(name string) (string, error) {
	cmd := exec.Command(c.Binary, "show-option", "-qv", name)
	output, err := cmd.Output()
	if err != nil {
		return "", fmt.Errorf("failed to read tmux option %s", name)
	}
	return string(output), nil
}

func (c *Client) SetOption(target, name, value string) error {
	args := []string{"set-option", "-q"}
	if target != "" {
		args = append(args, "-t", target)
	}
	args = append(args, name, value)
	return c.run(WithArgs(args...))
}

func (c *Client) NewSession(name, dir string, command []string) error {
	args := []string{"new-session", "-d", "-s", name, "-c", dir}
	if len(command) > 0 {
		args = append(args, "--")
		args = append(args, command...)
	}
	return c.run(WithArgs(args...))
}

type runOptions struct {
	args   []string
	stdout io.Writer
	stderr io.Writer
}

type RunOpt func(*runOptions)

func WithArgs(args ...string) RunOpt {
	return func(opts *runOptions) {
		opts.args = args
	}
}

func WithStdout(stdout io.Writer) RunOpt {
	return func(opts *runOptions) {
		opts.stdout = stdout
	}
}

func WithStderr(stderr io.Writer) RunOpt {
	return func(opts *runOptions) {
		opts.stderr = stderr
	}
}

func (c *Client) run(opts ...RunOpt) error {
	options := &runOptions{}
	for _, opt := range opts {
		opt(options)
	}
	if len(options.args) == 0 {
		return fmt.Errorf("missing tmux args")
	}

	cmd := exec.Command(c.Binary, options.args...)
	cmd.Stdout = options.stdout
	cmd.Stderr = options.stderr
	return cmd.Run()
}
