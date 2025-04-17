<template>
  <section id="visualization-container">
    <MapboxMap />
    <!--ReferencesSection
      title-level="2"
      :references="references"
    />
    <AuthorshipSection
      title-level="2"
      :authors="authors"
    /-->
  </section>
</template>

<script setup>
  import { useRoute } from 'vue-router';
  import { watch } from 'vue';
  // import { isMobile } from 'mobile-device-detect';

  // import text from "@/assets/text/text.js";
  // import references from "@/assets/text/references";
  // import authors from "@/assets/text/authors";
  // import ReferencesSection from '@/components/ReferencesSection.vue';
  // import AuthorshipSection from '@/components/AuthorshipSection.vue';
  import MapboxMap from '../components/MapboxMap.vue';

  // global variables
  // const mobileView = isMobile;
  const route = useRoute()
  // const state = ref(route.params.state);

  // const mapExtent = computed(() => {
  //   return state.value ? state.value : 'the continental U.S.';
  // });

  //watches router params for changes
  watch(route, () => {
    console.log('NEW ROUTE')
    // state.value = route.params.state;
  })
</script>

<style scoped>
</style>