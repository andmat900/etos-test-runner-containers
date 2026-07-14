ARG DEBIAN_RELEASE=bookworm
FROM ghcr.io/eiffel-community/etos-base-test-runner:$DEBIAN_RELEASE

COPY --from=ghcr.io/astral-sh/uv:0.11.15 /uv /uvx /bin/

ARG PYTHON_VERSION=3.9.18
# Install additional Python version if not already present.
RUN uv python install $PYTHON_VERSION
