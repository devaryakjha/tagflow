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
	dart pub global activate melos
	@echo "Melos activated!"

test:
	@echo "Running tests..."
	melos run test
	@echo "Tests completed!"

format:
	@echo "Formatting code..."
	melos run format
	@echo "Code formatted!"

version-dev:
	@echo "Updating version to dev..."
	melos run version:dev
	@echo "Version updated to dev!"

version-stable:
	@echo "Updating version to stable..."
	melos run version:stable
	@echo "Version updated to stable!"

publish:
	@echo "Publishing packages..."
	melos run publish
	@echo "Packages published!"

.PHONY: create_package sync-git activate-melos