<template>
  <section id="visualization-container">
    <div
      id="map-container"
    >
      <!-- render map once siteInfo and selectedWeek are defined -->
      <MapboxMap
        v-if="siteInfo && selectedWeek"
      />
      <!-- render sidebar once selectedWeek is defined -->
      <MapSidebar
        v-if="selectedWeek && siteList"
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
  import { useRoute } from 'vue-router';
  import { computed, onMounted, provide, ref } from 'vue';
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
  const route = useRoute();
  const publicPath = import.meta.env.BASE_URL;
  const { dateInfoData } = storeToRefs(globalDataStore);
  const { selectedWeek } = storeToRefs(globalDataStore);
  const { siteInfoData } = storeToRefs(globalDataStore);
  const { stateSelected } = storeToRefs(globalDataStore);
  const conditionsData = ref(null);
  const datasetConfigs = [
    { file: 'date_info.csv', ref: dateInfoData, type: 'csv', numericFields: []},
    { file: 'site_info.csv', ref: siteInfoData, type: 'csv', numericFields: []},
    { file: 'conditions_data.csv', ref: conditionsData, type: 'csv', numericFields: ['pd']}
  ]
  const selectedExtent = ref(stateSelected.value ? route.query.extent : globalDataStore.defaultExtent);

  // Define siteInfo, based on selectedExtent
  const siteInfo = computed(() => {
    if (selectedExtent.value == globalDataStore.defaultExtent) {
      return siteInfoData.value;
    } else {
      return siteInfoData.value?.filter(d => d.state == selectedExtent.value)
    }
  })
  // Define siteList, based on siteInfo (which is computed based on selectedExtent)
  const siteList = computed(() => {
    return siteInfo.value?.map(d => d.StaID)
  })
  // Define allConditions, based on siteList (which is computed based on selectedExtent)
  const allConditions = computed(() => {
    // Don't bother filtering for defaultExtent, when all sites are included
    if (selectedExtent.value == globalDataStore.defaultExtent) {
      return conditionsData.value;
    } else {
      return conditionsData.value.filter(d => siteList.value.includes(d.StaID));
    }
  })
  // Define currentConditions, based on siteList (which is computed based on selectedExtent) and selectedDate
  const currentConditions = computed(() => {
    return allConditions.value.filter(d => d.dt == globalDataStore.selectedDate)
  })

  // provide data for child components
  provide('sites', {
    siteInfo,
    siteList
  })
  provide('conditions', {
    allConditions,
    currentConditions
  })
  provide('extents', {
    selectedExtent,
    updateSelectedExtent
  })

  onMounted(async () => {
    await loadDatasets(datasetConfigs);
    stateSelected.value = globalDataStore.extents.includes(route.query.extent)
    // Update selected week
    selectedWeek.value = globalDataStore.dataWeeks[0];
  });

  async function loadDatasets(configs) {
    for (const { file, ref, type, numericFields} of configs) {
      try {
        ref.value = await loadData(file, type, numericFields);
        console.log(`${file} data in`);
      } catch (error) {
        console.error(`Error loading ${file}`, error);
      }
    }
  }

  async function loadData(dataFile, dataType, dataNumericFields) {
    try {
      let data;
      if (dataType == 'csv') {
        data = await d3.csv(publicPath + dataFile, d => {
          if (dataNumericFields) {
            dataNumericFields.forEach(numericField => {
              d[numericField] = +d[numericField]
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

  function updateSelectedExtent(extent) {
    selectedExtent.value = extent;
  }
</script>

<style scoped>
  #visualization-container {
    width: 100%;
    margin: 0 auto;
  }
  #map-container {
    position: relative;
  }
</style>