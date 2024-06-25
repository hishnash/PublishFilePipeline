ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

build:
	docker run --rm --volume "${ROOT_DIR}/:/src" --workdir "/src/" swift:5.10 swift build -c release -Xswiftc -static-stdlib
