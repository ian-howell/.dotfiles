# tmux tree manual test plan

## pre-flight
- ensure tmux is running
- ensure fzf and fd are installed
- reload tmux config: `prefix r`

## root creation
1. press `prefix S` to open the root picker
2. select a directory
3. confirm a root session is created with the directory name
4. confirm the root session path matches the selected directory

## child creation from root
1. from a root session, press `prefix o`
2. confirm a child session named `<root> 🌿 opencode` is created
3. confirm the session starts in the root directory
4. repeat for `prefix v` (nvim), `prefix k` (k9s), and `prefix g` (lazygit)

## child creation from child
1. from an existing child session, press `prefix o`
2. confirm it switches to `<root> 🌿 opencode`
3. press `prefix v` and confirm it switches to `<root> 🌿 nvim`

## last-used child tracking
1. from a root session, press `prefix o` then `prefix v`
2. press `prefix z` to switch to the root
3. press `prefix l` and confirm it returns to `<root> 🌿 nvim`

## root picker behavior
1. press `prefix s` to open the root picker
2. select a root with a known last-used child
3. confirm it switches to the last-used child, not the root
4. select a root with no child history and confirm it lands on the root

## new window behavior
1. from a root session, press `prefix c`
2. confirm the window starts in the root directory
3. from a child session (e.g., nvim), press `prefix c`
4. confirm the new window runs the child program and starts in the root directory

## global last session
1. switch between two different roots or children
2. press `prefix L`
3. confirm it switches to the last tmux session globally

## root sessions list script
1. run `tmux-tree-list-roots` in a shell
2. confirm it lists only root sessions (no ` 🌿 ` entries)

## root tree listing script
1. run `tmux-tree-list-root-sessions <root>` in a shell
2. confirm it lists the root and its child sessions
