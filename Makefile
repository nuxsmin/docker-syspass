VERSION=3.2.0
BUILD_NUMBER=20122001

build_vendor:
	cd build \
	&& ./build_vendor.sh \
	&& cd ..

build_version:
	cd common \
	&& VERSION=${VERSION} \
	BUILD_NUMBER=${BUILD_NUMBER} \
	./build.sh env \
	&& cd ..

build_docker:
	cd common \
	&& VERSION=${VERSION} \
	BUILD_NUMBER=${BUILD_NUMBER} \
	./build.sh docker \
	&& cd ..
