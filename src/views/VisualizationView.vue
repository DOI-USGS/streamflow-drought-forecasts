<template>
  <section id="visualization-container">
    <ExperimentalWarning />
    <TitleDialog />
    <FaqDialog />
    <div
      id="page-container"
    >
      <!-- render map once siteInfo and selectedWeek are defined -->
      <MapboxMap
        v-if="globalDataStore.siteInfo && selectedWeek !== null"
      />
      <!-- render sidebar once selectedWeek is defined -->
      <MapSidebar
        v-if="selectedWeek !== null && globalDataStore.siteList"
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
  import ExperimentalWarning from "@/components/ExperimentalWarning.vue";
  import TitleDialog from '../components/TitleDialog.vue';
  import FaqDialog from '../components/FaqDialog.vue';

  import { useGlobalDataStore } from "@/stores/global-data-store";
  import { useTimeseriesDataStore } from "@/stores/timeseries-data-store";

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
  const timeseriesDataStore = useTimeseriesDataStore();
  const publicPath = import.meta.env.BASE_URL;
  const s3Path = `${import.meta.env.VITE_APP_S3_PROD_URL}${import.meta.env.VITE_APP_TITLE}/${import.meta.env.VITE_APP_DATA_TIER}/`;
  const { dateInfoData } = storeToRefs(globalDataStore);
  const { siteInfoData } = storeToRefs(globalDataStore);
  const { droughtRecordsData } = storeToRefs(globalDataStore);
  const { stateLayoutData } = storeToRefs(globalDataStore);
  const { timeDomainData } = storeToRefs(timeseriesDataStore);
  const datasetConfigs = [
    { 
      file: 'date_info.csv', 
      path: s3Path, 
      ref: dateInfoData, 
      type: 'csv', 
      numericFields: ['f_w'], 
      booleanFields: null, 
      booleanTrue: null
    },
    { 
      file: 'site_info.csv', 
      path: s3Path, 
      ref: siteInfoData, 
      type: 'csv', 
      numericFields: null, 
      booleanFields: ['site_regulated', 'site_intermittent', 'site_snow_dominated', 'site_ice_impacted'], 
      booleanTrue: '1'
    },
    { 
      file: 'drought_records.csv', 
      path: s3Path, 
      ref: droughtRecordsData, 
      type: 'csv', 
      numericFields: ['total_drought_length', 'current_drought_category', 'current_drought_length'], 
      booleanFields: null, 
      booleanTrue: null
    },
    {
      file: 'conus_grid_layout.csv',
      path: publicPath, 
      ref: stateLayoutData,
      type: 'csv',
      numericFields: ['row', 'col'],
      booleanFields: null,
      booleanTrue: null
    },
    { 
      file: 'timeseries_x_domain.csv', 
      path: s3Path,
      ref: timeDomainData, 
      type: 'csv', 
      numericFields: [],
      booleanFields: null,
      booleanTrue: null
    }
  ]
  const { selectedWeek } = storeToRefs(globalDataStore);

  onMounted(async () => {
    await loadDatasets(datasetConfigs);
    // Update selected week
    selectedWeek.value = globalDataStore.dataWeeks[0];
  });

  async function loadDatasets(configs) {
    for (const { file, path, ref, type, numericFields, booleanFields, booleanTrue} of configs) {
      try {
        ref.value = await loadData(file, path, type, numericFields, booleanFields, booleanTrue);
        console.log(`${file} data in`);
      } catch (error) {
        console.error(`Error loading ${file}`, error);
      }
    }
  }

  async function loadData(dataFile, dataPath, dataType, dataNumericFields, dataBooleanFields, booleanTrue) {
    try {
      let data;
      if (dataType == 'csv') {
        data = await d3.csv(dataPath + dataFile, d => {
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
        data = await d3.json(dataPath + dataFile);
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