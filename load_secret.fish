export BEATLEADER_CLIENT_SECRET=(kubectl get secret beatleader-oauth --context accsaber -o jsonpath="{.data.client_secret}" | base64 -d)
export DISCORD_CLIENT_ID=(kubectl get secret discord-oauth --context accsaber -o jsonpath="{.data.client_id}" | base64 -d)
export DISCORD_CLIENT_SECRET=(kubectl get secret discord-oauth --context accsaber -o jsonpath="{.data.client_secret}" | base64 -d)echo