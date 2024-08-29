#!/usr/bin/env bash
cd $(dirname $0)
export IMAGE_NAME=ghcr.io/accsaber/tournament-2
export IMAGE_TAG=latest

export IMAGE=$IMAGE_NAME:$IMAGE_TAG

echo -e "\x1b[1mbuilding image...\x1b[0m"
docker build . \
    --platform=linux/arm64 \
    -t $IMAGE --push \
    || exit $?
export IMAGE=$(docker inspect --format='{{index .RepoDigests 0}}' $IMAGE | tr -d '\n')
export DIGEST=${IMAGE#*@}
echo -ne "\x1b[1mdeploying \x1b[32m"
echo -n $DIGEST
echo -e "\x1b[0m"

export MANIFESTS="/tmp/manifests-$(tr -d '\n' <<< $DIGEST | tail -c7)"
echo -ne "patched manifests copied to \x1b[33m"
echo -n $MANIFESTS
echo -e "\x1b[0m"

cp -r manifests $MANIFESTS
yq -i ".images[0].digest = \"$DIGEST\"" $MANIFESTS/kustomization.yml || exit $?
yq -i ".images[0].newName = \"$IMAGE_NAME\"" $MANIFESTS/kustomization.yml || exit $?
yq -i ".images[0].newTag = \"$IMAGE_TAG\"" $MANIFESTS/kustomization.yml || exit $?
mkdir -p $MANIFESTS/built
kubectl kustomize $MANIFESTS > $MANIFESTS/all.yml
gcsplit --elide-empty-files  --quiet -f $MANIFESTS/built/chunk $MANIFESTS/all.yml "/---/" "{*}"
pids=()
for chunk in $MANIFESTS/built/chunk*; do
    kubectl apply -f $chunk --context accsaber --server-side &
    pids[${chunk//[^0-9]/}]=$!
done
for pid in ${pids[*]}; do
    wait $pid
done

echo -e "\x1b[1mcleaning up\x1b[0m"
rm -r $MANIFESTS
