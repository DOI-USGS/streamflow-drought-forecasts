<template>
  <section id="visualization-container">
    <div
      class="text-container"
      :class="{ mobile: mobileView}"
    >
      <h1 class="title">
        {{ text.pageTitle }}
      </h1>
    </div>
    <MapboxMap />
    <ReferencesSection
      title-level="2"
      :references="references"
    />
    <AuthorshipSection
      title-level="2"
      :authors="authors"
    />
  </section>
</template>

<script setup>
  import { isMobile } from 'mobile-device-detect';

  import text from "@/assets/text/text.js";
  import references from "@/assets/text/references";
  import authors from "@/assets/text/authors";
  import ReferencesSection from '@/components/ReferencesSection.vue';
  import AuthorshipSection from '@/components/AuthorshipSection.vue';
  import MapboxMap from '../components/MapboxMap.vue';
  import '/node_modules/mapbox-gl/dist/mapbox-gl.css';

  // global variables
  const mobileView = isMobile;
</script>

<style scoped>
</style>