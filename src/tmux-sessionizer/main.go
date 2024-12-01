package main

import (
	"fmt"
	"io"
	"os"
	"os/exec"
	"strings"
)

type Session struct {
	Name   string
	Dir    string
	Exists bool
}

type Sessions []Session

func (ss Sessions) Read(p []byte) (int, error) {
	lines := make([]string, 0, len(ss))
	for _, s := range ss {
		line := strings.Builder{}
		if s.Exists {
			line.WriteString("- ")
		} else {
			line.WriteString("  ")
		}
		line.WriteString(s.Name + " ")
		if s.Dir != "" {
			line.WriteString("(" + s.Dir + ")")
		}
		lines = append(lines, line.String())
	}

	output := strings.Join(lines, "\n")
	n := copy(p, output)
	if n < len(output) {
		return n, nil
	}
	fmt.Println(string(p))
	return 0, io.EOF
}

func main() {
	os.Exit(run())
}

func run() int {
	session, err := getSession()
	if err != nil {
		fmt.Fprintf(os.Stderr, "failed to get session: %v\n", err)
		return 1
	}
	if session.Name == "" {
		return 0
	}

	if err := switchToSession(session); err != nil {
		return 1
	}

	return 0
}

func getSession() (Session, error) {
	if len(os.Args) == 2 {
		cwd, err := os.Getwd()
		if err != nil {
			return Session{}, fmt.Errorf("failed to get current working directory: %w", err)
		}
		return Session{
			Name: os.Args[1],
			Dir:  cwd,
		}, nil
	}

	sessions := PresetSessions()
	sessions = append(sessions, tmuxSessions()...)
	return fzfSessions(sessions)
}

func switchToSession(session Session) error {
	args := []string{"switch-client", "-t", session.Name}
	if session.Dir != "" {
		args = append(args, "-c", session.Dir)
	}
	cmd := exec.Command("tmux", args...)
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

func tmuxSessions() []Session {
	out, err := exec.Command("tmux", "list-sessions", "-F", "#{session_name}").Output()
	if err != nil {
		// TMUX may not be running
		return nil
	}

	var sessions []Session
	for _, name := range strings.Split(string(out), "\n") {
		if name == "" {
			continue
		}
		sessions = append(sessions, Session{
			Name:   name,
			Exists: true,
		})
	}
	return sessions
}

func fzf(data io.Reader) (string, error) {
	var result strings.Builder
	cmd := exec.Command("fzf") //, "--reverse", "--height", "40%", "--preview", "echo {}")
	// 	out, err := exec.Command("fzf", "--reverse", "--height", "40%", "--preview", "echo {}").StdinPipe()
	cmd.Stdout = &result
	cmd.Stderr = os.Stderr
	stdin, err := cmd.StdinPipe()
	if err != nil {
		return "", err
	}

	_, err = io.Copy(stdin, data)
	//_, err = data.WriteTo(stdin)
	if err != nil {
		return "", err
	}
	// err = stdin.Close()
	// if err != nil {
	// 	return "", err
	// }

	err = cmd.Start()
	if err != nil {
		return "", err
	}

	err = cmd.Wait()
	if err != nil {
		return "", err
	}
	return strings.TrimSpace(result.String()), nil

}

func fzfSessions(sessions []Session) (Session, error) {
	name, err := fzf(Sessions(sessions))
	if err != nil {
		return Session{}, err
	}
	for _, s := range sessions {
		if s.Name == name {
			return s, nil
		}
	}
	return Session{}, nil
}
