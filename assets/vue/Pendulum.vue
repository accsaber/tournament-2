<script setup lang="ts">
import BSPlusClient from "@/js/bsplus";
import { LUID, ScoreEvent } from "@/js/bsplus/event";
import { onBeforeMount, reactive, ref } from "vue"
const props = defineProps<{ player_1: string; player_2: string }>()

const players = reactive<Map<LUID, string>>(new Map);
const scores = reactive<Map<string, ScoreEvent["Score"]>>(new Map());


onBeforeMount(() => {

    const client = new BSPlusClient();



    client.callback = (event) => {
        if (event._event == "PlayerJoined") {
            const { LUID, UserID } = event.PlayerJoined;
            players.set(LUID, UserID);
        }

        if (event._event == "RoomState" && event.RoomState == "WarmingUp") {
            scores.clear();

        }
        if (event._event == "Score") {
            const score = event.Score;
            const player = players.get(score.LUID);
            if (!player) return;
            scores.set(player, score);
            console.log({ player, score })

            const player1Acc = scores.get(props.player_1)?.Accuracy ?? 0;
            const player2Acc = scores.get(props.player_2)?.Accuracy ?? 0;

            delta.value = player2Acc - player1Acc;
        }
    };
})

const delta = ref(0);



const accToPendulum = (n: number) => {
    n = n * 100;
    n = Math.max(n, 0)
    n = Math.min(n, 1)
    console.log(n)


    return `${n * 100}%`
}

</script>

<template>
    <div class="grid grid-cols-2">
        <div class="h-4 bg-white bg-gradient-to-l ml-auto from-blue-600 to-purple-600 rounded-bl-lg transition-all"
            :style="{
                width: accToPendulum(-delta)
            }"></div>
        <div class="h-4 bg-white bg-gradient-to-r from-blue-600 to-purple-600 rounded-br-lg transition-all" :style="{
            width: accToPendulum(delta)
        }"></div>
    </div>
    <div class="grid grid-cols-2 gap-x-4 text-4xl mt-4">
        <div :class="{
            'text-5xl': delta < 0,
            'transition-all': true,
            flex: true,
            'gap-2': true,
            'flex-row-reverse': true
        }">
            <div>{{ ((scores.get(props.player_1)?.Accuracy ?? 0) * 100).toFixed(2) }}%</div>
            <div class="text-xl mx-2 my-0.5">{{ scores.get(props.player_1)?.Score.toLocaleString('en-AU') }}</div>
        </div>
        <div :class="{ 'text-5xl': delta > 0, 'transition-all': true, flex: true, 'gap-2': true }">
            <div>{{ ((scores.get(props.player_2)?.Accuracy ?? 0) * 100).toFixed(2) }}%</div>
            <div class="text-xl mx-2 my-0.5">{{ scores.get(props.player_2)?.Score.toLocaleString('en-AU') }}</div>
        </div>
        <div class="text-red-500 text-3xl col-start-1 text-end" v-if="scores.get(props.player_1)?.MissCount ?? 0 > 0">{{
            scores.get(props.player_1)?.MissCount }}x</div>
        <div class="text-red-500 text-3xl col-start-2" v-if="scores.get(props.player_2)?.MissCount">{{
            scores.get(props.player_2)?.MissCount }}x</div>
    </div>
</template>