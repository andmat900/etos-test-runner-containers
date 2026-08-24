#!/bin/bash

# Log a message with a timestamp.
#
# Arguments:
#   $@ - The message to log.
log() {
    echo "[$(date --iso-8601=seconds)] - $*"
}

PIP_ARGS=${PIP_ARG:-""}

DEV=${DEV:-false}
if [ "$DEV" = "true" ] ; then
    ETR_BRANCH=${ETR_BRANCH:-main}
    ETR_REPOSITORY=${ETR_REPOSITORY:-https://github.com/eiffel-community/etos-test-runner.git}
    ETR_INSTALL="git+$ETR_REPOSITORY@$ETR_BRANCH"
else
    ETR_INSTALL="etos_test_runner==$ETR_VERSION"
fi

# Optionally constrain the ETR installation to a locked set of dependency
# versions. Set ETR_CONSTRAINTS to the path of a constraints file (e.g. a
# requirements.lock) to pin the transitive dependency closure for a
# reproducible install. When unset, dependency versions are resolved
# freely by the installer.
#
# A lock is only valid for the exact ETR version it was generated from. If the
# image records the version of ETR pre-installed in it (ETR_PREINSTALLED_VERSION)
# and the version being installed differs (e.g. a runtime upgrade), the lock is
# skipped so the upgrade resolves its own dependencies instead of failing
# against a mismatched lock.
CONSTRAINTS_ARGS=""
if [ -n "${ETR_CONSTRAINTS:-}" ] ; then
    if [ -n "${ETR_PREINSTALLED_VERSION:-}" ] && [ "${ETR_VERSION:-}" != "$ETR_PREINSTALLED_VERSION" ] ; then
        log "Requested ETR version ('${ETR_VERSION:-}') differs from the image's pre-installed version ('$ETR_PREINSTALLED_VERSION'); skipping the baked dependency lock."
    elif [ ! -f "$ETR_CONSTRAINTS" ] ; then
        log "ERROR: ETR_CONSTRAINTS is set to '$ETR_CONSTRAINTS' but no such file exists."
        exit 1
    else
        CONSTRAINTS_ARGS="--constraint $ETR_CONSTRAINTS"
    fi
fi

log "Installing ETR."
uv pip install $PIP_ARGS $CONSTRAINTS_ARGS "$ETR_INSTALL"
log "ETR installed."

log "Executing ETR."
exec python -m etos_test_runner.etr "$@"
log "ETR finished."
