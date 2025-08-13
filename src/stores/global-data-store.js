import { defineStore } from "pinia";
import { useRoute, useRouter } from 'vue-router';
import { computed, ref, watch } from 'vue'; // Import ref for reactivity
import * as d3 from 'd3-fetch'; // import smaller set of modules
import { useScreenCategory } from "@/assets/scripts/composables/media-query";

export const useGlobalDataStore = defineStore("globalDataStore", () => {
  const screenCategory = useScreenCategory();
  const titleDialogShown = ref(true)
  const faqDialogShown = ref(false)
  const legendShown = ref(screenCategory.value != 'phone')
  const fullSummaryShownOnMobile = ref(false)
  const route = useRoute()
  const router = useRouter()
  const dateInfoData = ref(null)
  const siteInfoData = ref(null)
  const droughtRecordsData = ref(null)
  let conditionsDatasets = []
  const initialConditionsLoadingComplete = ref(false)
  let geojsonDatasets = []
  const initialGeojsonLoadingComplete = ref(false)
  const selectedWeek = ref(null)
  const selectedSite = ref(null)
  const defaultExtent = 'CONUS'
  const extents = [
    "Alabama", "Arizona", "Arkansas", "California", "Colorado", 
    "Connecticut", "Delaware", "Florida", "Georgia", "Idaho", 
    "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", 
    "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", 
    "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", 
    "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", 
    "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", 
    "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", 
    "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", 
    "Wyoming"
  ]
  const issueDate = computed(() => dateInfoData.value[0].issue_date)
  const dataDatesFormatted = computed(() => dateInfoData.value.map(d => d.dt_formatted) || [])
  const dataWeeks = computed(() => dateInfoData.value.map(d => d.f_w) || [])
  const selectedDate = computed(() => dateInfoData.value.find(d => d.f_w == selectedWeek.value).dt || null)
  const selectedDateFormatted = computed(() => dateInfoData.value.find(d => d.f_w == selectedWeek.value).dt_formatted || null)
  // Define data type
  const dataType = computed(() => {
    return selectedWeek.value > 0 ? 'Forecast' : 'Observed';
  })
  const stateSelected = computed(() => extents.includes(route.query.extent))
  // const selectedExtent = computed(() => stateSelected.value ? route.query.extent : defaultExtent)
  const selectedExtent = computed({
    get: () => {
      return stateSelected.value ? route.query.extent : defaultExtent
    },
    set(selectedExtent) {
      // pass the query
      if (extents.includes(selectedExtent)) {
        router.replace({ ...router.currentRoute, query: { extent: selectedExtent}})
      } else {
        router.replace({ ...router.currentRoute, query: null});
      }
    }
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
  // Define selectedSiteInfo, based on selectedSite
  const selectedSiteInfo = computed(() => {
    return siteInfo.value.find(d => d.StaID == selectedSite.value);
  })
  // Get drought record for selectedSite
  const selectedSiteRecord = computed(() => {
    return droughtRecordsData.value.find(d => d.StaID == selectedSite.value);
  })
  async function fetchAndAddConditionsDatasets(week) {
    let response;
    if (dataWeeks.value.includes(week)) {
      response = await d3.csv(`${import.meta.env.VITE_APP_S3_PROD_URL}${import.meta.env.VITE_APP_TITLE}/${import.meta.env.VITE_APP_DATA_TIER}/conditions/conditions_w${week}.csv`, d => {
        d.pd = +d.pd;
        return d;
      })
    } else {
      response = []
    }
    const dataset = [{
        datasetWeek: week,
        values: response
    }]
    conditionsDatasets = conditionsDatasets.concat(dataset);
  }
  async function fetchAndAddGeojsonDatasets(week) {
    let response;
    if (dataWeeks.value.includes(week)) {
      response = await d3.json(`${import.meta.env.VITE_APP_S3_PROD_URL}${import.meta.env.VITE_APP_TITLE}/${import.meta.env.VITE_APP_DATA_TIER}/conditions_geojsons/CONUS_data_w${week}.geojson`);
    } else {
      response = {
        type: "FeatureCollection",
        features: []
      }
    }
    const dataset = [{
        datasetWeek: week,
        values: response
    }]
    geojsonDatasets = geojsonDatasets.concat(dataset);
  }
  function getConditionsDataset(week) {
    const weekData = conditionsDatasets.find((dataset) => {
      return (
        dataset.datasetWeek === week 
      );
    })
    return weekData
  }
  function getGeojsonDataset(week) {
    const weekData = geojsonDatasets.find((dataset) => {
      return (
        dataset.datasetWeek === week 
      );
    })
    return weekData
  }
  watch(selectedWeek, (newValue) => {
    const storedConditionsDataset = getConditionsDataset(newValue)
    if (storedConditionsDataset === undefined) {
      initialConditionsLoadingComplete.value = false;
      const fetchConditionsDataPromise = fetchAndAddConditionsDatasets(newValue);
      Promise.all([fetchConditionsDataPromise]).then(() => {
        initialConditionsLoadingComplete.value = true;
      });
    }
    const storedGeojsonDataset = getGeojsonDataset(newValue)
    if (storedGeojsonDataset === undefined) {
      initialGeojsonLoadingComplete.value = false;
      const fetchGeojsonDataPromise = fetchAndAddGeojsonDatasets(newValue);
      Promise.all([fetchGeojsonDataPromise]).then(() => {
        initialGeojsonLoadingComplete.value = true;
      });
    }
  });
  const conditionsData = computed(() => {
    if (initialConditionsLoadingComplete.value) {
      const conditionsDataset = getConditionsDataset(selectedWeek.value)
      return conditionsDataset.values
    } else {
      return undefined
    }
  })
  // Define allConditions, based on siteList (which is computed based on selectedExtent)
  const allConditions = computed(() => {
    // Don't bother filtering for defaultExtent, when all sites are included
    if (selectedExtent.value == defaultExtent) {
      return conditionsData.value;
    } else {
      return conditionsData.value?.filter(d => siteList.value.includes(d.StaID));
    }
  })
  const sitesExtreme = computed(() => {
    return allConditions.value?.filter(d => d.pd < 5);
  })
  const sitesSevere = computed(() => {
    return allConditions.value?.filter(d => d.pd < 10 && d.pd >= 5);
  })
  const sitesModerate = computed(() => {
    return allConditions.value?.filter(d => d.pd < 20 && d.pd >= 10);
  })
  const sitesNA = computed(() => {
    return allConditions.value?.filter(d => d.pd === 999);
  })
  // Define selectedSiteConditions, based on selectedSite
  const selectedSiteConditions = computed(() => {
    return allConditions.value?.find(d => d.StaID == selectedSite.value);
  })
  const inDrought = computed(() => {
    return selectedSiteConditions.value?.pd < 20;
  })
  const droughtStatusNA = computed(() => {
    return selectedSiteConditions.value?.pd == 999;
  })
  const geojsonData = computed(() => {
    if (initialGeojsonLoadingComplete.value) {
      const geojsonDataset = getGeojsonDataset(selectedWeek.value)
      return geojsonDataset.values
    } else {
      return undefined
    }
  })  
  // Dynamically filter data based on selectedExtent
  const filteredPointData = computed(() => {
    if (selectedExtent.value == defaultExtent) {
      return geojsonData.value;
    } else {
      const filteredPointData = {}
      filteredPointData.type = "FeatureCollection";
      filteredPointData.features = geojsonData.value?.features.filter(d => siteList.value.includes(d.properties.StaID))
      return filteredPointData;
    }
  })

  return { 
    titleDialogShown,
    faqDialogShown,
    legendShown,
    fullSummaryShownOnMobile,
    dateInfoData,
    siteInfoData,
    droughtRecordsData,
    conditionsData,
    initialConditionsLoadingComplete,
    initialGeojsonLoadingComplete,
    issueDate,
    selectedWeek,
    selectedSite,
    defaultExtent,
    extents,
    stateSelected,
    dataDatesFormatted,
    dataWeeks,
    selectedDate,
    selectedDateFormatted,
    dataType,
    selectedExtent,
    siteInfo,
    siteList,
    allConditions,
    sitesExtreme,
    sitesSevere,
    sitesModerate,
    sitesNA,
    selectedSiteInfo,
    selectedSiteRecord,
    selectedSiteConditions,
    inDrought,
    droughtStatusNA,
    filteredPointData
  }
})