
#build and push to quay java image v1
./mvnw clean package  -Dquarkus.container-image.build=true -Dquarkus.container-image.name=frequent-flyer -Dquarkus.container-image.tag=java-1.0  -Dquarkus.native.container-build=true 
docker tag mouachani/frequent-flyer:java-1.0 quay.io/mouachan/frequent-flyer:java-1.0
docker push quay.io/mouachan/frequent-flyer:java-1.0
oc apply -f manifest/frequent-flyer-service-java-v1.yml 

#build and push to quay java image v2
./mvnw clean package  -Dquarkus.container-image.build=true -Dquarkus.container-image.name=frequent-flyer -Dquarkus.container-image.tag=java-2.0  -Dquarkus.native.container-build=true 
docker tag mouachani/frequent-flyer:java-2.0 quay.io/mouachan/frequent-flyer:java-2.0
docker push quay.io/mouachan/frequent-flyer:java-2.0
oc apply -f manifest/frequent-flyer-service-java-v2.yml 
#build and push to quay native image v1
./mvnw clean package  -Dquarkus.container-image.build=true -Dquarkus.container-image.name=frequent-flyer -Dquarkus.container-image.tag=native-1.0 -Pnative  -Dquarkus.native.container-build=true 
docker run -i --rm -p 8080:8080 mouachani/frequent-flyer:native-1.0 
docker commit ad62a50d1cf1 quay.io/mouachan/frequent-flyer:native-1.0
docker push quay.io/mouachan/frequent-flyer:native-1.0
oc apply -f manifest/frequent-flyer-service-native-v1.yml 

#build native image v2
./mvnw quarkus:add-extension -Dextensions="container-image-docker"
./mvnw clean package -Dquarkus.container-image.build=true  -Dquarkus.container-image.name=frequent-flyer -Dquarkus.container-image.tag=native-2.0 -Pnative -Dquarkus.native.container-build=true  
docker run -i --rm -p 8080:8080 mouachani/frequent-flyer:native-2.0 
docker commit 4fdf77ff491e quay.io/mouachan/frequent-flyer:native-2.0
docker push quay.io/mouachan/frequent-flyer:native-2.0


oc create secret docker-registry quay-secret \
    --docker-server=quay.io/mouachan \
    --docker-username=mouachan \
    --docker-password=it{Sjej7via}2302\
    --docker-email=mourad.ouachani@gmail.com

    oc secrets link builder quay-secret
    oc secrets link default quay-secret --for=pull


    curl -X POST "http://frequent-flyer-native.kogito-knative.apps.ocp4.ouachani.net/frequent_score" --data '{"Score":700, "Status":"Silver"}'