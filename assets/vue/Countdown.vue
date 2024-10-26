<template>
    <div :class="{ 'opacity-0': timeToStart.getTime() < 0, 'transition-all': true }">
        {{ timeToStart.toLocaleTimeString("en-AU", {
            minute: "numeric",
            second: "2-digit"
        }) }}</div>
</template>
<script setup lang="ts">
import { onMounted, ref } from 'vue';


const props = defineProps<{ startTime: string }>();
const startTime = new Date(props.startTime)

const timeToStart = ref(new Date(startTime.getTime() - Date.now()))

onMounted(() => {
    setInterval(() => {
        timeToStart.value = new Date(startTime.getTime() - Date.now());
    }, 200)
})
</script>