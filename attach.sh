#!/usr/bin/env bash
COMMAND=$1

k() {
    kubectl --context accsaber "$@"
}

POD_IP=$(k get endpoints -l app=tournament-website -o jsonpath="{.items[0].subsets[].addresses[*].ip}" | sed 's/ /\n/g' | shuf | head -n1)
POD_A_RECORD=$(echo $POD_IP | sed 's/\./-/g').default.pod.cluster.local
FULL_NODE_NAME="acc_tournament@${POD_A_RECORD}"
RELEASE_COOKIE=$(kubectl get secret --context accsaber acc-tournament-secret -o jsonpath='{.data.RELEASE_COOKIE}' | base64 -d)

if [[ $COMMAND == "livebook" ]]; then
    export LIVEBOOK_NODE="local"
    export LIVEBOOK_DEFAULT_RUNTIME="attached:${FULL_NODE_NAME}:${RELEASE_COOKIE}"
    livebook server
elif [[ $COMMAND == "iex" ]]; then
    iex --name remote@$(tailscale ip -4) \
        --cookie $RELEASE_COOKIE \
        --remsh $FULL_NODE_NAME \
        -e "IO.inspect(Node.list(), label: \"Connected Nodes\")"
else
    echo "Please provide a valid command: livebook or iex." >&2
fi

