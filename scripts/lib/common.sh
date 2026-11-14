#!/usr/bin/env bash
# Shared helpers for MayaOS scripts.
# shellcheck shell=bash

mayaos_repo_root() {
	local here
	here="$(cd "$(dirname "${BASH_SOURCE[1]}")/.." && pwd)"
	# scripts/lib → repo root is ../..
	if [[ -f "${here}/VERSION" ]]; then
		echo "${here}"
		return 0
	fi
	here="$(cd "$(dirname "${BASH_SOURCE[1]}")/../.." && pwd)"
	echo "${here}"
}

mayaos_version() {
	local root="$1"
	if [[ -f "${root}/VERSION" ]]; then
		tr -d '[:space:]' < "${root}/VERSION"
	else
		echo "0.0.0-unknown"
	fi
}

log()  { printf '==> %s\n' "$*"; }
warn() { printf 'WARNING: %s\n' "$*" >&2; }
die()  { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

need_cmd() {
	command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

free_kib() {
	# Free KiB on filesystem containing path $1
	df -Pk "$1" 2>/dev/null | awk 'NR==2 {print $4}'
}

human_mib() {
	local kib="$1"
	awk -v k="$kib" 'BEGIN { printf "%.1f GiB", k/1024/1024 }'
}
