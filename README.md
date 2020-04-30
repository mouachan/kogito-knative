

![Ouachani Logo](/img/logo.png) 

# kogito-knative demo

## Goal

This demo uses Quarkus, Kogito and Knative, it aims to :
- create a discount service for a traveler based on a business rule 
- build and push 2 natives images versions on an external registry (Quay) 
- deploy 2 versions of a servless application on Openshift, apply a 50% routing

## Prerequesties 
Install :
- oc client
- knative client (kn)
- Openshift serverless operator from the operatorhub on your Openshift cluster

## Create a registry secret

```
oc create secret docker-registry quay-secret \
    --docker-server=quay.io/username \
    --docker-username=username \
    --docker-password=password\
    --docker-email=email

oc secrets link builder quay-secret
oc secrets link default quay-secret --for=pull
```

## Clone the source from github

```
git clone https://github.com/mouachan/kogito-knative
```

## Checkout frequent-flyer-v1 brnach

```
git checkout frequent-flyer-v1
```

## Build and generate native container image

```
./mvnw clean package  -Dquarkus.container-image.build=true -Dquarkus.container-image.name=frequent-flyer -Dquarkus.container-image.tag=native-1.0 -Pnative  -Dquarkus.native.container-build=true 

```

## Push the image to your registry (change the username by yours)

Make sure that you are connected to your images registry and create a repo named frequent-flyer
```
docker tag 'username -to be changed -'/frequent-flyer:native-1.0 quay.io/'username -to be changed -'/frequent-flyer:native-1.0
docker push quay.io/'username -to be changed -'/frequent-flyer:native-1.0
```

## Apply the service v1

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

## Clone the source from github

```
git clone https://github.com/mouachan/kogito-knative
```

## Checkout frequent-flyer v2 branch

```
git checkout frequent-flyer-v2
```

## Build and generate native container image

```
./mvnw clean package  -Dquarkus.container-image.build=true -Dquarkus.container-image.name=frequent-flyer -Dquarkus.container-image.tag=native-2.0 -Pnative  -Dquarkus.native.container-build=true 

```
## Push the generated image to your registry (change the username by yours)

Make sure that you are connected to your registry hub and create a repo named 'frequent-flyer'

```
docker tag 'username - to be changed -'/frequent-flyer:native-2.0 quay.io/'username -to be changed -'/frequent-flyer:native-2.0
docker push quay.io/'username - to be changed -'/frequent-flyer:native-1.0
```

## Apply the service v2

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

## Verify that the routing is 50% 

Call the service `http://frequent-flyer-native.kogito-knative.apps.ocp4.ouachani.net/frequent_score`, the result is  **_"Silver : message v1"_**
```
MacBook-Pro:kogito-knative mouachani$ curl -X POST http://frequent-flyer-native.kogito-knative.apps.ocp4.ouachani.net/frequent_score -H "accept: application/json" -H "Content-Type: application/json" -d "{\"Score\":700,\"Status\":\"Silver\"}"

{"Status":"Silver","Score":700, "Message":"Silver : message v1"}
```

Call a second time the same service, the result is **_"Silver : message v2"_**
```
MacBook-Pro:kogito-knative mouachani$ curl -X POST http://frequent-flyer-native.kogito-knative.apps.ocp4.ouachani.net/frequent_score -H "accept: application/json" -H "Content-Type: application/json" -d "{\"Score\":700,\"Status\":\"Silver\"}"

{"Status":"Silver","Score":700,"Message":"Silver : message v2"}
```
