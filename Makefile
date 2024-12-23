PHONY: create_package

# create new package to the packages directory
# extract the name from args
# cleanup the name, if
create_package:
	cd packages &&flutter create --template=package tagflow_$(name) && cd ..
