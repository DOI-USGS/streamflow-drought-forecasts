<template>
  <section id="visualization-container">
    <div class="text-container" :class="{ mobile: mobileView}">
      <h1 class = 'title'>
        {{ text.pageTitle }}
      </h1>
    </div>
    <ReferencesSection titleLevel="2" :references="references"/>
    <AuthorshipSection titleLevel="2" :authors="authors"/>
  </section>
</template>

<script setup>
  import { isMobile } from 'mobile-device-detect';

  import text from "@/assets/text/text.js";
  import references from "@/assets/text/references";
  import authors from "@/assets/text/authors";
  import ReferencesSection from '@/components/ReferencesSection.vue';
  import AuthorshipSection from '@/components/AuthorshipSection.vue';

  // global variables
  const mobileView = isMobile;
</script>

<style scoped>
</style>