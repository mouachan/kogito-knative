#build and push to quay native image v1
./mvnw quarkus:add-extension -Dextensions="container-image-docker"
./mvnw clean package -Dquarkus.container-image.build=true  -Dquarkus.container-image.name=frequent-flyer -Dquarkus.container-image.tag=native-1.0 -Pnative -Dquarkus.native.container-build=true  
docker run -i --rm -p 8080:8080 mouachani/frequent-flyer:native-1.0 
docker commit 92d1cdab4400 quay.io/mouachan/frequent-flyer:native-1.0
docker push quay.io/mouachan/frequent-flyer:native-1.0

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