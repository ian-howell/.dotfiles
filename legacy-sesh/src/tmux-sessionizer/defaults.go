package main

func PresetSessions() []Session {
	return []Session{
		{
			Name: "tmp",
			Dir:  "(creates a tmp dir)",
		},
		{
			Name: "dotfiles",
			Dir:  "$HOME/.dotfiles",
		},
	}
}
