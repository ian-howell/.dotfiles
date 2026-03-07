// improve-repo runs an opencode command sequentially N times against a git
// repository, streaming each agent's output live and printing a pass/fail
// summary at the end. Runs are sequential (not concurrent) so that the
// shared .ideas file at the repo root is never written to simultaneously.
//
// Usage:
//
//	go run ./src/improve-repo -n 5 -dir /path/to/repo
//	go run ./src/improve-repo -n 15 -dir . -command improve-repo
//
// Flags:
//
//	-n        number of runs (default 5)
//	-dir      path to the repo (default ".")
//	-command  opencode command to run (default "improve-repo")
package main

import (
	"flag"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"time"
)

const banner = "══════════════════════════════════════════════════════"

func main() {
	n := flag.Int("n", 5, "number of runs")
	dir := flag.String("dir", ".", "path to the repo to improve")
	command := flag.String("command", "improve-repo", "opencode command to run")
	flag.Parse()

	repoDir, err := filepath.Abs(*dir)
	if err != nil {
		fmt.Fprintf(os.Stderr, "error resolving dir: %v\n", err)
		os.Exit(1)
	}

	ocBin, err := exec.LookPath("opencode")
	if err != nil {
		fmt.Fprintf(os.Stderr, "opencode not found in PATH\n")
		os.Exit(1)
	}

	type result struct {
		run     int
		elapsed time.Duration
		err     error
	}

	results := make([]result, 0, *n)
	total := time.Now()

	for i := 1; i <= *n; i++ {
		fmt.Printf("\n%s\n Run %d / %d  [%s]\n%s\n\n", banner, i, *n, *command, banner)

		start := time.Now()
		cmd := exec.Command(ocBin, "run", "--command", *command, "--dir", repoDir)
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		cmd.Stdin = os.Stdin

		runErr := cmd.Run()
		elapsed := time.Since(start)

		if runErr != nil {
			fmt.Printf("\n✗ Run %d failed (%s): %v\n", i, fmtDuration(elapsed), runErr)
		} else {
			fmt.Printf("\n✓ Run %d complete (%s)\n", i, fmtDuration(elapsed))
		}

		results = append(results, result{run: i, elapsed: elapsed, err: runErr})
	}

	// Summary
	fmt.Printf("\n%s\n Summary\n%s\n", banner, banner)

	passed, failed := 0, 0
	for _, r := range results {
		status := "✓"
		if r.err != nil {
			status = "✗"
			failed++
		} else {
			passed++
		}
		fmt.Printf("  %s  Run %d  (%s)\n", status, r.run, fmtDuration(r.elapsed))
	}

	fmt.Printf("\n  Runs:    %d\n", *n)
	fmt.Printf("  Passed:  %d\n", passed)
	fmt.Printf("  Failed:  %d\n", failed)
	fmt.Printf("  Total:   %s\n\n", fmtDuration(time.Since(total)))

	if failed > 0 {
		os.Exit(1)
	}
}

func fmtDuration(d time.Duration) string {
	d = d.Round(time.Second)
	m := d / time.Minute
	s := (d % time.Minute) / time.Second
	if m > 0 {
		return fmt.Sprintf("%dm%02ds", m, s)
	}
	return fmt.Sprintf("%ds", s)
}
