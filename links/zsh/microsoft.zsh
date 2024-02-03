export GOPRIVATE=dev.azure.com,github.com/microsoft,msazure.visualstudio.com/msazure,dev.azure.com/msazure,dev.azure.com/mariner-org,dev.azure.com/msazuredev
export HELM_EXPERIMENTAL_OCI=1

if [[ -d "$HOME/notes" ]]; then
  export PATH=$HOME/notes/scripts:$PATH
  source "$HOME/notes/scripts/environment"
else
  echo "Hey! You're on your work branch but you haven't cloned your work stuff!"
  echo "You're lucky I'm nice ;)"
  echo
  echo "  git clone git@github.com:ian-howell/work-notes $HOME/notes"
  echo
fi

prepend "$HOME/nc-devbox"
# SKIP_CHECKS is used to skip the rg and vm existence checks in the devbox scripts
export SKIP_CHECKS=1
# Set up the SSH key paths for the devbox scripts
export SSH_PRIVATE_KEY_PATH="$HOME/.ssh/id_ed25519"
export SSH_PUBLIC_KEY_PATH="$HOME/.ssh/id_ed25519.pub"

export ALIAS=ianhowell

export GCM_INTERACTIVE=auto
export GIT_TERMINAL_PROMPT=1

export ENVTEST_K8S_VERSION=1.26.0
export KUBEBUILDER_ASSETS=$HOME/go/bin/kubebuilder-assets@$ENVTEST_K8S_VERSION
