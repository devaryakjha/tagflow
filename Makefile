sync-git:
	@echo "Syncing branches and tags with remote..."
	@git fetch --prune --prune-tags origin # Fetch and remove deleted branches and tags
	@git fetch --tags -f # Force update all tags
	@echo "Updating local branches to match remote state..."
	@git remote prune origin # Clean up local references to deleted remote branches
	@git branch -vv | grep ': gone]' | awk '{print $$1}' | xargs -r git branch -D # Delete local branches whose remotes were deleted
	@echo "Git sync complete!"

# create new package to the packages directory
# extract the name from args
# cleanup the name, if
create_package:
	cd packages &&flutter create --template=package tagflow_$(name) && cd ..


# MELOS
activate-melos:
	@echo "Activating melos..."
	dart pub global activate melos ^7.8.1
	@echo "Melos activated!"

bootstrap:
	@echo "Bootstrapping workspace..."
	dart pub get
	dart run melos bootstrap
	@echo "Workspace bootstrapped!"

test:
	@echo "Running tests..."
	dart run melos run test
	@echo "Tests completed!"

format:
	@echo "Formatting code..."
	dart run melos run format
	@echo "Code formatted!"

version-dev:
	@echo "Updating version to dev..."
	dart run melos run version:dev
	@echo "Version updated to dev!"

version-alpha:
	@echo "Updating version to alpha..."
	dart run melos run version:alpha
	@echo "Version updated to alpha!"

version-stable:
	@echo "Updating version to stable..."
	dart run melos run version:stable
	@echo "Version updated to stable!"

publish-dry-run:
	@echo "Validating packages for publish..."
	dart run melos run publish:dry-run
	@echo "Publish validation completed!"

publish:
	@echo "Publishing packages..."
	dart run melos run publish:packages
	@echo "Packages published!"

release: test format version-dev version-stable publish

release-dev: test format version-dev publish

release-alpha: test format version-alpha publish-dry-run

.PHONY: create_package sync-git activate-melos bootstrap test format version-dev version-alpha version-stable publish-dry-run publish release release-dev release-alpha
