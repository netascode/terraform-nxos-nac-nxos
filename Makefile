default: help

# Preview unreleased changelog entries from .changelog/ fragments
.PHONY: changelog-preview
changelog-preview:
	python3 scripts/changelog.py preview

# Finalize a release: collect changelog fragments into CHANGELOG.md
# Usage: make release VERSION=X.Y.Z
.PHONY: release
release:
	@if [ -z "$(VERSION)" ]; then echo "Usage: make release VERSION=X.Y.Z"; exit 1; fi
	python3 scripts/changelog.py release $(VERSION)

.PHONY: help
help:
	@echo "Available targets:"
	@echo "  changelog-preview  - Preview unreleased changelog entries"
	@echo "  release            - Collect fragments into CHANGELOG.md (VERSION=X.Y.Z)"
