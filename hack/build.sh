#!/usr/bin/env bash
#set -x
clear
export TERM="screen-256color"

inform () {
cat <<EOF
>>
>> INFO: Successfully started developer container
>>
>> INFO: Connect to the developer with the following command:
>>
>>         ${runCmd} exec -it kargo-builder connect
>>
EOF
}

dev () {
${runCmd} kill kargo-dev container >/dev/null
cat <<EOF
>> INFO: Starting kargo-builder-dev container
EOF
${runCmd} pull -q quay.io/cloudctl/konductor:latest
${runCmd} run -d \
    --name kargo-builder-dev \
    --rm --workdir /build \
    --volume $(pwd):/build \
    --hostname kargo-builder-dev \
    -u $(id -u):$(id -g) --user root \
  quay.io/cloudctl/konductor:latest
[[ $? == 0 ]] && inform
}

build () {
cat <<EOF
>> INFO: Starting builder container
EOF
${runCmd} pull -q quay.io/cloudctl/ansible:latest
${runCmd} run -t --pull never \
    --rm --workdir /build \
    --volume $(pwd):/build \
    --entrypoint ./build.yml \
    --hostname builder --name builder \
    -u $(id -u):$(id -g) --user root \
  quay.io/cloudctl/ansible:latest

[[ $? == 0 ]] && git status || echo "failed..."
sudo chown -R $USER:$USER ./
echo
}

run () {
if [[ -z "${mode}" ]]; then
    runMode=build
else
    runMode=dev
fi

dockerPath=$(which docker)
podmanPath=$(which podman)
if [[ ! ${dockerPath} == "1" ]]; then
  runCmd=${dockerPath};
elif [[ ! ${podmanPath} == "1" ]]; then
  runCmd=${podmanPath}
else
    echo ">> ERR: No container runtime found! Aborting...";
    runCmd=null
fi

[[ ! ${runCmd} == "null" ]] && ${runMode}
}

mode="$1"
run
