# tfregistry

Terraform module registry with GCS bucket as a storage backend


## Configure the server

We chose to configure the server only with envars, easy to set in a pod

- `PORT` : port to listen to, default `8080`
- `LISTEN` : accepted IP range, default `0.0.0.0`
- `BACKEND` : storage backend to use, `gcs` or `fake`, default `gcs`
- `OVERWRITE` : accepts to overwrite existing modules with same version, default `0`
- `VERBOSE` : debug logs, default `0`
- `MODULE_PATH` : default ""
- `GOOGLE_BUCKET` : name of the GCS bucket to use. Mandatory is backend is `gcp`

## Curl instructions

### List versions
```
curl localhost:8080/test/mymodule/gcp/versions
```

### Upload file

To create the module v0.0.2 from local tar.gz
```
curl -X POST --data-binary "@myfile.tar.gz" localhost:8080/test/mymodule/gcp/0.0.2 -H "module-source: https://whatever.com/wherever.git"
```

### Get latest version
```
curl localhost:8080/test/mymodule/gcp
```

## Build

If you need to change the API, you have to install [`oapi-codegen`](https://github.com/deepmap/oapi-codegen) to generate code

```
go get github.com/deepmap/oapi-codegen/cmd/oapi-codegen
make generate
```

This generates the file `pkg/modules/modules.gen.go`

We build and push the image using [`ko`](https://github.com/google/ko) from Google
```
go install github.com/google/ko
make push
```

You can change the repository by overriding the variable `IMAGE_REPOSITORY`
```
make KO_DOCKER_REPO=wherever.com/whatever build
```
## Run locally

A test bucklet has been created in `ml-calleocho-st` project.
Retrieve the JSON file in https://vault.magicleap.io/ui/vault/secrets/ci/show/sre/tfregistry/gcp_authent

Then
```
export GOOGLE_APPLICATION_CREDENTIALS=path/to/file.json
export GOOGLE_BUCKET=ml-test-modules-registry
export MODULE_PATH=/
make server
```

In another window :
```
curl -v localhost:8080/test/mymodule/gcp/versions
```

A `fake` server is also available to test without having to connect to GCP. It is used for unit testing
