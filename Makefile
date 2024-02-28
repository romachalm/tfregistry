.PHONY: vendor
vendor:
	GO111MODULE=on go mod vendor
	GO111MODULE=on go mod tidy

.PHONY: lint
lint:
	golangci-lint version
	GL_DEBUG=linters_output GO111MODULE=on golangci-lint run --go 1.17

.PHONY: generate
generate: package := modules
generate:
	# install the generator with go get github.com/deepmap/oapi-codegen/cmd/oapi-codegen
	oapi-codegen \
		--package=${package}  \
		--generate=types,chi-server,spec \
		-o pkg/${package}/${package}.gen.go \
		api/${package}.yaml

.PHONY: server
server:
	VERBOSE=1 go run cmd/tfregistry/main.go

.PHONY: local
local:
	BACKEND=fake \
	VERBOSE=1 \
	go run cmd/tfregistry/main.go

.PHONY: doc
doc:
	openapi-generator generate -i api/modules.yaml -g markdown --skip-validate-spec -o docs

.PHONY: test
test:
	go test -cover ./... -v

.PHONY: prepare-test-module
prepare-test-module:
	tar -czvf pkg/backends/fake/fake_storage/testModule.tar.gz -C test/testModule .

KO_DOCKER_REPO := registry.magicleap.io/infra/tfregistry
VERSION := $(shell cat VERSION)

.PHONY: build
build:
	GOFLAGS="-ldflags=-X=main.version=${VERSION}" \
	KO_DOCKER_REPO=${KO_DOCKER_REPO} \
	ko publish ./cmd/tfregistry --bare

.PHONY: push
push:
	GOFLAGS="-ldflags=-X=main.version=${VERSION}" \
	KO_DOCKER_REPO=${KO_DOCKER_REPO} \
	ko publish ./cmd/tfregistry --bare --push

NAMESPACE := tfregistry
HELM_FOLDER := deployments/helm

.PHONY: helm-dependency
helm-dependency:
	helm dependency update ${HELM_FOLDER}

.PHONY: helm
helm:
	helm template test ${HELM_FOLDER} -n ${NAMESPACE} --debug > rendered.yaml