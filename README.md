# kogito-knative project

This project uses Quarkus, the Supersonic Subatomic Java Framework.

If you want to learn more about Quarkus, please visit its website: https://quarkus.io/ .

## Running the application in dev mode

You can run your application in dev mode that enables live coding using:
```
./mvnw quarkus:dev
```

## Packaging and running the application

The application can be packaged using `./mvnw package`.
It produces the `kogito-knative-1.0-SNAPSHOT-runner.jar` file in the `/target` directory.
Be aware that it’s not an _über-jar_ as the dependencies are copied into the `target/lib` directory.

The application is now runnable using `java -jar target/kogito-knative-1.0-SNAPSHOT-runner.jar`.

## Creating a native executable

You can create a native executable using: `./mvnw package -Pnative`.

Or, if you don't have GraalVM installed, you can run the native executable build in a container using: `./mvnw package -Pnative -Dquarkus.native.container-build=true`.

You can then execute your native executable with: `./target/kogito-knative-1.0-SNAPSHOT-runner`

If you want to learn more about building native executables, please consult https://quarkus.io/guides/building-native-image.# kogito-knative
![Ouachani Logo](/img/logo.png)
# kogito-knative demo

## Goal

This demo uses Quarkus, Kogito and Knative, it aims to : 
- build and push 2 natives images versions on an external registry (Quay) 
- deploy 2 versions of a servless application on Openshift, apply a 50% routing

## Prerequesties 
Install :
- oc client
- knative client (kn)
- Openshift serverless operator from the operatorhub on your Openshift cluster

## Create a registry secret
oc create secret docker-registry quay-secret \
    --docker-server=quay.io/username \
    --docker-username=username \
    --docker-password=password\
    --docker-email=email

## chekout the source from github
git clone https://github.com/mouachan/kogito-knative

## basculate from master to v1
git checkout frequent-flyer-v1

## build and generate native container image

```
./mvnw clean package  -Dquarkus.container-image.build=true -Dquarkus.container-image.name=frequent-flyer -Dquarkus.container-image.tag=native-1.0 -Pnative  -Dquarkus.native.container-build=true 

```

## Push the generated image to your registry (change the username by yours)

Make sure that you are connected to your images registry and create a repo named frequent-flyer
```
docker tag 'username -to be changed -'/frequent-flyer:native-1.0 quay.io/'username -to be changed -'/frequent-flyer:native-1.0
docker push quay.io/'username -to be changed -'/frequent-flyer:native-1.0
```

## apply the service v1

Connect to your openshift cluster and apply the service (it will create a new revision with version 2)
```
echo "apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: frequent-flyer-native
spec:
  template:
    metadata:
      name: frequent-flyer-native-v1
    spec:
      containers:
        - image: >-
            quay.io/'username -to be changed -'/frequent-flyer:native-1.0
          env:
            - name: JAVA_OPTS
              value: "-Dvertx.cacheDirBase=/work/vertx"
      imagePullSecrets:
        - name: quay-secret" | oc apply -f -
```

## Get the source from github

```
git clone https://github.com/mouachan/kogito-knative
```

## basculate from master to v1

```
git checkout frequent-flyer-v2
```
## build and generate native container image
```
./mvnw clean package  -Dquarkus.container-image.build=true -Dquarkus.container-image.name=frequent-flyer -Dquarkus.container-image.tag=native-2.0 -Pnative  -Dquarkus.native.container-build=true 

```
## Push the generated image to your registry (change the username by yours)

Make sure that you are connected to your registry hub and create a repo named 'frequent-flyer'

```
docker tag 'username - to be changed -'/frequent-flyer:native-2.0 quay.io/'username -to be changed -'/frequent-flyer:native-2.0
docker push quay.io/'username - to be changed -'/frequent-flyer:native-1.0
```

## apply the service v2

Connect to your openshift cluster and apply the service (it will create a new revision with image version 2)

```
echo "apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: frequent-flyer-native
spec:
  template:
    metadata:
      name: frequent-flyer-native-v2
    spec:
      containers:
        - image: >-
            quay.io/'username -to be changed -'/frequent-flyer:native-2.0
          env:
            - name: JAVA_OPTS
              value: "-Dvertx.cacheDirBase=/work/vertx"
      imagePullSecrets:
        - name: quay-secret" | oc apply -f -
```

## Get the route
```
MacBook-Pro:kogito-knative mouachani$ kn route list
NAME                    URL                                                                  READY
frequent-flyer-java     http://frequent-flyer-java.kogito-knative.apps.ocp4.ouachani.net     True
frequent-flyer-native   http://frequent-flyer-native.kogito-knative.apps.ocp4.ouachani.net   True 
```

## Apply 50% routing for each service from Openshift console 
![Routing](/img/routing.png)

## Run the service 
### Call the service the result will include "message v1"
```
MacBook-Pro:kogito-knative mouachani$ curl -X POST http://frequent-flyer-native.kogito-knative.apps.ocp4.ouachani.net/frequent_score -H "accept: application/json" -H "Content-Type: application/json" -d "{\"Score\":700,\"Status\":\"Silver\"}"

{"Status":"Silver","Score":700,"Message":"Silver : message v1"}
```

### Call the service The result should be with message v2
```
MacBook-Pro:kogito-knative mouachani$ curl -X POST http://frequent-flyer-native.kogito-knative.apps.ocp4.ouachani.net/frequent_score -H "accept: application/json" -H "Content-Type: application/json" -d "{\"Score\":700,\"Status\":\"Silver\"}"

{"Status":"Silver","Score":700,"Message":"Silver : message v2"}
```