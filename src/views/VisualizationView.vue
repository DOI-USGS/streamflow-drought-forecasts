<template>
  <section id="visualization-container">
    <div
      id="map-container"
    >
      <!-- render map once siteInfo is defined -->
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
  // import { isMobile } from 'mobile-device-detect';
  import * as d3 from 'd3-fetch'; // import smaller set of modules

  // import text from "@/assets/text/text.js";
  // import references from "@/assets/text/references";
  // import authors from "@/assets/text/authors";
  // import ReferencesSection from '@/components/ReferencesSection.vue';
  // import AuthorshipSection from '@/components/AuthorshipSection.vue';
  import MapSidebar from '../components/MapSidebar.vue';
  import extents from "@/assets/content/extents.js";
  import MapboxMap from '../components/MapboxMap.vue';

  // global variables
  // const mobileView = isMobile;
  const route = useRoute();  
  const defaultExtent = 'the continental U.S.';
  const publicPath = import.meta.env.BASE_URL;
  const dateInfoDataFile = 'forecast_info.csv'; /* for now, just forecast dates - will need to add observed */
  const dateInfoData = ref(null);
  const siteInfoDataFile = 'site_info.csv';
  const siteInfoData = ref();
  const forecastDataFile = 'forecast_data.csv'
  const forecastData = ref();
  const selectedWeek = ref(null);
  const selectedSite = ref(null);  
  const stateSelected = ref(extents.states.includes(route.query.extent))
  const selectedExtent = ref(stateSelected.value ? route.query.extent : defaultExtent);

  // Define forecast weeks
  const forecastWeeks = computed(() => {
    return dateInfoData.value?.map(d => d.f_w)
  })
  // Define selectedDate, based on selectedWeek
  const selectedDate = computed(() => {
    return dateInfoData.value.find(d => d.f_w == selectedWeek.value).forecast_date
  })
  // Define siteInfo, based on selectedExtent
  const siteInfo = computed(() => {
    if (selectedExtent.value == defaultExtent) {
      return siteInfoData.value;
    } else {
      return siteInfoData.value?.filter(d => d.state == selectedExtent.value)
    }
  })
  // Define siteList, based on siteInfo (which is computed based on selectedExtent)
  const siteList = computed(() => {
    return siteInfo.value?.map(d => d.StaID)
  })
  // Define allForecasts, based on siteList (which is computed based on selectedExtent)
  const allForecasts = computed(() => {
    return forecastData.value.filter(d => siteList.value.includes(d.StaID));
  })
  // Define currentForecasts, based on siteList (which is computed based on selectedExtent) and selectedDate
  const currentForecasts = computed(() => {
    return allForecasts.value.filter(d => d.forecast_date == selectedDate.value)
  })

  // provide data for child components
  provide('dates', {
    dateInfoData,
    selectedWeek,
    updateSelectedWeek,
    selectedDate
  })
  provide('sites', {
    siteInfo,
    siteList,
    selectedSite,
    updateSelectedSite
  })
  provide('forecasts', {
    forecastData,
    allForecasts,
    currentForecasts
  })
  provide('extents', {
    extents,
    defaultExtent,
    selectedExtent,
    updateSelectedExtent
  })

  onMounted(async () => {
    await loadDatasets({
      dataFiles: [dateInfoDataFile, siteInfoDataFile, forecastDataFile], 
      dataRefs: [dateInfoData, siteInfoData, forecastData],
      dataTypes: ['csv', 'csv', 'csv'],
      dataNumericFields: [['f_w'], [], ['pred_interv_05','median','pred_interv_95']]
    });

    // Update selected date
    updateSelectedWeek(forecastWeeks.value[0])
  });

  async function loadDatasets({dataFiles, dataRefs, dataTypes, dataNumericFields}) {
    try {
      for (let i = 0; i < Math.min(dataFiles.length, dataRefs.length, dataNumericFields.length); i++) {
        dataRefs[i].value = await loadData(dataFiles[i], dataTypes[i], dataNumericFields[i]);
        console.log(`${dataFiles[i]} data in`);
      }
    } catch (error) {
      console.error('Error loading datasets', error);
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

  function updateSelectedWeek(week) {
    selectedWeek.value = week;
  }

  function updateSelectedSite(site) {
    selectedSite.value = site;
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