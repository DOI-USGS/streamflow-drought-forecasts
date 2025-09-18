<template>
  <div>
    <HeaderUSWDSBanner />
    <HeaderUSGS />
    <RouterView />
    <FooterUSGS />
  </div>
</template>

<script setup>
  import { onMounted } from "vue";
  import { RouterView } from 'vue-router'
  import HeaderUSWDSBanner from "@/components/HeaderUSWDSBanner.vue";
  import HeaderUSGS from '@/components/HeaderUSGS.vue';
  import FooterUSGS from '@/components/FooterUSGS.vue';
  import { useWindowSizeStore } from '@/stores/WindowSizeStore';

  const windowSizeStore = useWindowSizeStore();

  // Declare behavior on mounted
  // functions called here
  onMounted(() => {
    // Add window size tracking by adding a listener
    window.addEventListener('resize', handleResize);
    handleResize();
  });

  // Functions
  function handleResize() {
    // store the window size values in the Pinia state
    windowSizeStore.windowWidth = window.innerWidth;
    windowSizeStore.windowHeight = window.innerHeight;
  }
</script>

<style scoped>
</style>
