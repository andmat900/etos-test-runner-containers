#!/bin/bash

# Log a message with a timestamp.
#
# Arguments:
#   $@ - The message to log.
log() {
    echo "[$(date --iso-8601=seconds)] - $*"
}

log "Sourcing pyenv."
eval "$(pyenv init -)"

PIP_ARGS=${PIP_ARG:-""}

log "Setting pyenv shell to version '$ETR_PYTHON_VERSION'."
pyenv shell "$ETR_PYTHON_VERSION"

DEV=${DEV:-false}
if [ "$DEV" = "true" ] ; then
    ETR_BRANCH=${ETR_BRANCH:-main}
    ETR_REPOSITORY=${ETR_REPOSITORY:-https://github.com/eiffel-community/etos-test-runner.git}
    ETR_INSTALL="git+$ETR_REPOSITORY@$ETR_BRANCH"
else
    ETR_INSTALL="etos_test_runner==$ETR_VERSION"
fi

log "Installing ETR."
uv pip install $PIP_ARGS "$ETR_INSTALL"
log "ETR installed."

log "Executing ETR."
exec python -m etos_test_runner.etr "$@"
log "ETR finished."
