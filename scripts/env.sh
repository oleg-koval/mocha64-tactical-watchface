#!/usr/bin/env bash
# Puts the Connect IQ toolchain on PATH. Source it, don't run it:
#   source scripts/env.sh
#
# The SDK ships no JDK and Homebrew's openjdk is keg-only, so neither ends up on
# PATH by default -- that is the whole reason this file exists.

_CIQ_SDK_ROOT="$HOME/Library/Application Support/Garmin/ConnectIQ/Sdks"

if [ -z "${JAVA_HOME:-}" ] && command -v brew >/dev/null 2>&1; then
  _JDK="$(brew --prefix openjdk 2>/dev/null)/libexec/openjdk.jdk/Contents/Home"
  [ -x "$_JDK/bin/java" ] && export JAVA_HOME="$_JDK"
fi
[ -n "${JAVA_HOME:-}" ] && export PATH="$JAVA_HOME/bin:$PATH"

_CIQ_SDK="$(ls -d "$_CIQ_SDK_ROOT"/connectiq-sdk-mac-* 2>/dev/null | sort -V | tail -1)"
if [ -n "$_CIQ_SDK" ]; then
  export CIQ_SDK="$_CIQ_SDK"
  export PATH="$CIQ_SDK/bin:$PATH"
fi

if [ -z "${CIQ_SDK:-}" ]; then
  echo "WARNING: no Connect IQ SDK found under $_CIQ_SDK_ROOT" >&2
fi
