VERSION=3.2.1
BUILD_NUMBER=21011601

build_vendor:
	cd build \
	&& ./build-vendor.sh \
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
