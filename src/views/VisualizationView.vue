<template>
  <section id="visualization-container">
    <div
      id="page-container"
    >
      <!-- render map once siteInfo and selectedWeek are defined -->
      <MapboxMap
        v-if="globalDataStore.siteInfo && selectedWeek"
      />
      <!-- render sidebar once selectedWeek is defined -->
      <MapSidebar
        v-if="selectedWeek && globalDataStore.siteList"
      />
    </div>
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
  import { onMounted } from 'vue';
  import { storeToRefs } from "pinia";
  // import { isMobile } from 'mobile-device-detect';
  import * as d3 from 'd3-fetch'; // import smaller set of modules

  import { useGlobalDataStore } from "@/stores/global-data-store";

  // import text from "@/assets/text/text.js";
  // import references from "@/assets/text/references";
  // import authors from "@/assets/text/authors";
  // import ReferencesSection from '@/components/ReferencesSection.vue';
  // import AuthorshipSection from '@/components/AuthorshipSection.vue';
  import MapSidebar from '../components/MapSidebar.vue';
  import MapboxMap from '../components/MapboxMap.vue';

  // global variables
  // const mobileView = isMobile;
  const globalDataStore = useGlobalDataStore();
  const publicPath = import.meta.env.BASE_URL;
  const { dateInfoData } = storeToRefs(globalDataStore);
  const { siteInfoData } = storeToRefs(globalDataStore);
  const datasetConfigs = [
    { file: 'date_info.csv', ref: dateInfoData, type: 'csv', numericFields: null, booleanFields: null, booleanTrue: null},
    { file: 'site_info.csv', ref: siteInfoData, type: 'csv', numericFields: null, booleanFields: ['site_regulated', 'site_intermittent', 'site_snow_dominated', 'site_ice_impacted'], booleanTrue: '1'}
  ]
  const { selectedWeek } = storeToRefs(globalDataStore);

  onMounted(async () => {
    await loadDatasets(datasetConfigs);
    // Update selected week
    selectedWeek.value = globalDataStore.dataWeeks[0];
  });

  async function loadDatasets(configs) {
    for (const { file, ref, type, numericFields, booleanFields, booleanTrue} of configs) {
      try {
        ref.value = await loadData(file, type, numericFields, booleanFields, booleanTrue);
        console.log(`${file} data in`);
      } catch (error) {
        console.error(`Error loading ${file}`, error);
      }
    }
  }

  async function loadData(dataFile, dataType, dataNumericFields, dataBooleanFields, booleanTrue) {
    try {
      let data;
      if (dataType == 'csv') {
        data = await d3.csv(publicPath + dataFile, d => {
          if (dataNumericFields) {
            dataNumericFields.forEach(numericField => {
              d[numericField] = +d[numericField]
            });
          }
          if (dataBooleanFields) {
            dataBooleanFields.forEach(booleanField => {
              d[booleanField] = d[booleanField] === booleanTrue
            });
          }
          return d;
        });
      } else if (dataType == 'json') {
        data = await d3.json(publicPath + dataFile);
      } else {
        console.error(`Data type ${dataType} is not supported. Data type must be 'csv' or 'json'`)
      }

      return data;
    } catch (error) {
      console.error(`Error loading data from ${dataFile}`, error);
      return [];
    }
  }
</script>

<style scoped>
  #visualization-container {
    width: 100%;
    margin: 0 auto;
  }
  #page-container {
    position: relative;
  }
</style>