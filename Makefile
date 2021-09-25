VERSION=3.2.3
BUILD_NUMBER=25092021

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
