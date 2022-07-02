VERSION=3.2.10
BUILD_NUMBER=22070101

.PHONY: all
all: build_docker build_vendor

.PHONY: build_vendor
build_vendor:
	cd build \
	&& ./build-vendor.sh \
	&& cd ..

.PHONY: build_version
build_version:
	cd common \
	&& VERSION=${VERSION} \
	BUILD_NUMBER=${BUILD_NUMBER} \
	./build.sh env \
	&& cd ..

.PHONY: build_docker
build_docker: build_version
	cd common \
	&& VERSION=${VERSION} \
	BUILD_NUMBER=${BUILD_NUMBER} \
	./build.sh docker \
	&& cd ..
