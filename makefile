OWNER=graphql
IMAGE_NAME=jwks-provider
QNAME=$(OWNER)/$(IMAGE_NAME)

GIT_TAG=$(QNAME):$(TRAVIS_COMMIT)
BUILD_TAG=$(QNAME):$(TRAVIS_BUILD_NUMBER).$(TRAVIS_COMMIT)
TAG=$(QNAME):`echo $(TRAVIS_BRANCH) | sed 's/master/latest/;s/develop/unstable/'`

lint:
	docker run -it --rm -v "$(PWD)/Dockerfile:/Dockerfile:ro" redcoolbeans/dockerlint

build:
	# go get ./...
	# gox -osarch="linux/amd64" -output="bin/devops-alpine"
	# CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o bin/binary .
	docker build -t $(GIT_TAG) .
	
tag:
	docker tag $(GIT_TAG) $(BUILD_TAG)
	docker tag $(GIT_TAG) $(TAG)
	
login:
	@docker login -u "$(DOCKER_USER)" -p "$(DOCKER_PASS)"
push: login
	# docker push $(GIT_TAG)
	# docker push $(BUILD_TAG)
	docker push $(TAG)

generate:
	go run github.com/99designs/gqlgen
	go generate ./...

build-local:
	# go get ./...
	# go build -o $(IMAGE_NAME) ./server/server.go
	go build -o app

deploy-local:
	make build-local
	mv app /usr/local/bin/${IMAGE_NAME}

run:
	make build-local && DATABASE_URL=sqlite3://test.db PORT=8080 ./app

# test:
# 	DATABASE_URL=sqlite3://test.db $(IMAGE_NAME) server -p 8005
	# DATABASE_URL="mysql://root:root@tcp(localhost:3306)/test?parseTime=true" go run *.go server -p 8000
