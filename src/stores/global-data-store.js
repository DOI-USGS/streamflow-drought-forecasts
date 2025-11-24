import { defineStore } from "pinia";
import { useRoute, useRouter } from 'vue-router';
import { computed, ref, shallowRef, watch } from 'vue'; // Import ref for reactivity
import * as d3 from 'd3-fetch'; // import smaller set of modules
import { useScreenCategory } from "@/assets/scripts/composables/media-query";
import { useWindowSizeStore } from '@/stores/WindowSizeStore';

export const useGlobalDataStore = defineStore("globalDataStore", () => {
  const screenCategory = useScreenCategory()
  const windowSizeStore = useWindowSizeStore()
  const titleDialogShown = ref(true)
  const faqDialogShown = ref(false)
  const normalDialogShown = ref(false)
  const intermittentDialogShown = ref(false)
  const regulatedDialogShown = ref(false)
  const snowDialogShown = ref(false)
  const iceDialogShown = ref(false)
  const legendShown = ref(screenCategory.value != 'phone')
  const pickerActive = ref(false)
  const fullSummaryShownOnMobile = ref(false)
  const route = useRoute()
  const router = useRouter()
  const dateInfoData = ref(null)
  const timeDomainData = ref(null)
  const siteInfoData = ref(null)
  const droughtRecordsData = ref(null)
  const stateLayoutData = ref(null)
  let conditionsDatasets = shallowRef([])
  const initialConditionsLoadingComplete = ref(false)
  let geojsonDatasets = shallowRef([])
  const initialGeojsonLoadingComplete = ref(false)
  let stateGeojsonDatasets = shallowRef([])
  const initialStateGeojsonLoadingComplete = ref(false)
  const selectedWeek = ref(null)
  const selectedSite = ref(null)
  const hoveredSite = ref(null)
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
  const currentStreamflowDate = computed(() => dateInfoData.value[0].dt)
  const dataDatesFormatted = computed(() => dateInfoData.value.map(d => d.dt_formatted) ?? [])
  const dataWeeks = computed(() => dateInfoData.value.map(d => d.f_w) ?? [])
  const selectedDate = computed(() => dateInfoData.value.find(d => d.f_w == selectedWeek.value).dt ?? null)
  const selectedDateFormatted = computed(() => dateInfoData.value.find(d => d.f_w == selectedWeek.value).dt_formatted ?? null)
  const timeDomainStart = computed(() => timeDomainData.value[0].start)
  const timeDomainEnd = computed(() => timeDomainData.value[0].end)
  // Define data type
  const dataType = computed(() => {
    return selectedWeek.value > 0 ? 'Forecast' : 'Observed';
  })
  const statusPreface = computed(() => {
    const statusPreface = dataType.value == 'Forecast' ? 'Forecast to' : 'Currently';
    return statusPreface
  })
  const statusPhrase = computed(() => {
    const statusPhrase = dataType.value == 'Forecast' ? 'be in' : 'in';
    return statusPhrase
  })
  const stateSelected = computed(() => extents.includes(route.query.extent))
  const selectedExtent = computed({
    get: () => {
      return stateSelected.value ? route.query.extent : null
    },
    set(selectedExtent) {
      // pass the query
      if (selectedExtent) {
        router.replace({ query: { extent: selectedExtent}})
      } else {
        router.replace({ query: null})
      }
    }
  })
  // Define siteInfo, based on selectedExtent
  const siteInfo = computed(() => {
    if (selectedExtent.value) {
      return siteInfoData.value?.filter(d => d.state == selectedExtent.value)
    } else {
      return siteInfoData.value;
    }
  })
  // Define siteList, based on siteInfo (which is computed based on selectedExtent)
  const siteList = computed(() => {
    return siteInfo.value?.map(d => d.StaID)
  })
  // Define selectedSiteInfo, based on selectedSite
  const selectedSiteInfo = computed(() => {
    return siteInfo.value.find(d => d.StaID == selectedSite.value) || null;
  })
  // Define hoveredSiteInfo, based on hoveredSite
  const hoveredSiteInfo = computed(() => {
    return siteInfo.value.find(d => d.StaID == hoveredSite.value);
  })
  // Get drought record for selectedSite
  const selectedSiteRecord = computed(() => {
    return droughtRecordsData.value.find(d => d.StaID == selectedSite.value);
  })
  async function fetchAndAddConditionsDatasets(week) {
    let response;
    if (dataWeeks.value.includes(week)) {
      response = await d3.csv(`${import.meta.env.VITE_APP_S3_PROD_URL}${import.meta.env.VITE_APP_TITLE}/conditions/conditions_w${week}.csv`, d => {
        d.pd = +d.pd;
        return d;
      })
    } else {
      response = []
    }
    const dataset = {
        datasetIssueDate: issueDate.value,
        datasetWeek: week,
        values: response
    }
    conditionsDatasets.value = [...conditionsDatasets.value, dataset]
  }
  async function fetchAndAddGeojsonDatasets(week) {
    let response;
    if (dataWeeks.value.includes(week)) {
      response = await d3.json(`${import.meta.env.VITE_APP_S3_PROD_URL}${import.meta.env.VITE_APP_TITLE}/conditions_geojsons/CONUS_data_w${week}.geojson`);
    } else {
      response = {
        type: "FeatureCollection",
        features: []
      }
    }
    const dataset = {
        datasetIssueDate: issueDate.value,
        datasetWeek: week,
        values: response
    }
    geojsonDatasets.value = [...geojsonDatasets.value, dataset]
  }
  async function fetchAndAddStateGeojsonDatasets(state) {
    let response;
    if (extents.includes(state)) {
      const state_key = state.replaceAll(' ', '_');
      response = await d3.json(`${import.meta.env.VITE_APP_S3_PROD_URL}${import.meta.env.VITE_APP_TITLE}/state_geojsons/${state_key}.geojson`);
    } else {
      response = {
        type: "FeatureCollection",
        features: []
      }
    }
    const dataset = {
        datasetState: state,
        values: response
    }
    stateGeojsonDatasets.value = [...stateGeojsonDatasets.value, dataset]
  }
  function getConditionsDataset(week) {
    const weekData = conditionsDatasets.value.find((dataset) => {
      return (
        dataset.datasetIssueDate === issueDate.value && dataset.datasetWeek === week
      );
    })
    return weekData
  }
  function getGeojsonDataset(week) {
    const weekData = geojsonDatasets.value.find((dataset) => {
      return (
        dataset.datasetIssueDate === issueDate.value && dataset.datasetWeek === week 
      );
    })
    return weekData
  }
  function getStateGeojsonDataset(state) {
    if (extents.includes(state)) {
      const stateData = stateGeojsonDatasets.value.find((dataset) => {
        return (
          dataset.datasetState === state
        );
      })
      return stateData
    }
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
      return conditionsDataset?.values
    } else {
      return undefined
    }
  })
  // Define allConditions, based on siteList (which is computed based on selectedExtent)
  const allConditions = computed(() => {
    return conditionsData.value?.filter(d => siteList.value.includes(d.StaID));
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
  const sitesDrought = computed(() => {
    return allConditions.value?.filter(d => d.pd < 20);
  })
  const sitesNA = computed(() => {
    return allConditions.value?.filter(d => d.pd === 999);
  })
  // Define selectedSiteConditions, based on selectedSite
  const selectedSiteConditions = computed(() => {
    return allConditions.value?.find(d => d.StaID == selectedSite.value);
  })
  const inDrought = computed(() => {
    return (selectedSiteConditions.value && selectedSiteConditions.value.pd < 20);
  })
  const droughtStatusNA = computed(() => {
    return selectedSiteConditions.value?.pd === 999 || false;
  })
  const selectedSiteStatus = computed(() => {
    let siteValue = selectedSiteConditions.value.pd
    let siteStatus;
    switch(true) {
      case siteValue < 5:
        siteStatus = "extreme";
        break;
      case siteValue < 10:
        siteStatus = "severe";
        break;
      case siteValue < 20:
        siteStatus = "moderate";
        break;
      default:
        siteStatus = "none";
    }
    return(siteStatus)
  })
  // Define hoveredSiteConditions, based on hoveredSite
  const hoveredSiteConditions = computed(() => {
    return allConditions.value?.find(d => d.StaID == hoveredSite.value);
  })
  const hoveredSiteStatus = computed(() => {
    const siteValue = hoveredSiteConditions.value.pd
    let siteStatus;
    switch(true) {
      case siteValue < 5:
        siteStatus = "extreme";
        break;
      case siteValue < 10:
        siteStatus = "severe";
        break;
      case siteValue < 20:
        siteStatus = "moderate";
        break;
      case siteValue == 999:
        siteStatus = "NA";
        break;
      default:
        siteStatus = "none";
    }
    return(siteStatus)
  })
  const geojsonData = computed(() => {
    if (initialGeojsonLoadingComplete.value) {
      const geojsonDataset = getGeojsonDataset(selectedWeek.value)
      return geojsonDataset?.values
    } else {
      return undefined
    }
  })  
  // Dynamically filter data based on selectedExtent
  const filteredPointData = computed(() => {
    if (selectedExtent.value) {
      const filteredPointData = {}
      filteredPointData.type = "FeatureCollection";
      filteredPointData.features = geojsonData.value?.features.filter(d => siteList.value.includes(d.properties.StaID))
      return filteredPointData;
    } else {
      return geojsonData.value;
    }
  })
  watch(selectedExtent, (newValue) => {
    if (newValue) {
      const storedStateGeojsonDataset = getStateGeojsonDataset(newValue)
      if (storedStateGeojsonDataset === undefined) {
        initialStateGeojsonLoadingComplete.value = false;
        const fetchStateGeojsonDataPromise = fetchAndAddStateGeojsonDatasets(newValue);
        Promise.all([fetchStateGeojsonDataPromise]).then(() => {
          initialStateGeojsonLoadingComplete.value = true;
        });
      }
    }
  }, { immediate : true });
  const stateGeojsonData = computed(() => {
    if (initialStateGeojsonLoadingComplete.value) {
      const stateGeojsonDataset = getStateGeojsonDataset(selectedExtent.value)
      return stateGeojsonDataset?.values
    } else {
      return undefined
    }
  }) 

  function positionTooltips(id) {
    // get all tooltips in specified container
    const container = document.querySelector(`#${id}`)
    let refTooltips = container.querySelectorAll(".tooltip-group");
    refTooltips.forEach(tooltip => positionTooltip(tooltip)); 
  }

  function positionTooltip(tooltip_group) {
    // Get .tooltiptext sibling
    const tooltip = tooltip_group.querySelector(".tooltiptext");
    
    // Get calculated tooltip coordinates and size
    let tooltip_rect = tooltip.getBoundingClientRect();

    // Corrections if out of window to left
    if (tooltip_rect.x < 0) {
      // reset left position and drop transformation
      tooltip.classList.add('tooltip-left')
    }    
    // Corrections if out of window to right
    tooltip_rect = tooltip.getBoundingClientRect();
    if ((tooltip_rect.x + tooltip_rect.width) > windowSizeStore.windowWidth*0.95) {
      // reset tooltip width, with some buffer room
      document.getElementById(tooltip.id).style.width = (windowSizeStore.windowWidth - tooltip_rect.x)*0.8 + "px";
    }
  }

  return { 
    titleDialogShown,
    faqDialogShown,
    normalDialogShown,
    intermittentDialogShown,
    regulatedDialogShown,
    snowDialogShown,
    iceDialogShown,
    legendShown,
    pickerActive,
    fullSummaryShownOnMobile,
    dateInfoData,
    timeDomainData,
    timeDomainStart,
    timeDomainEnd,
    siteInfoData,
    droughtRecordsData,
    stateLayoutData,
    conditionsData,
    initialConditionsLoadingComplete,
    initialGeojsonLoadingComplete,
    initialStateGeojsonLoadingComplete,
    stateGeojsonData,
    issueDate,
    currentStreamflowDate,
    selectedWeek,
    selectedSite,
    hoveredSite,
    defaultExtent,
    extents,
    stateSelected,
    dataDatesFormatted,
    dataWeeks,
    selectedDate,
    selectedDateFormatted,
    dataType,
    statusPreface,
    statusPhrase,
    selectedExtent,
    siteInfo,
    siteList,
    allConditions,
    sitesExtreme,
    sitesSevere,
    sitesModerate,
    sitesDrought,
    sitesNA,
    selectedSiteInfo,
    selectedSiteRecord,
    selectedSiteConditions,
    selectedSiteStatus,
    inDrought,
    droughtStatusNA,
    hoveredSiteInfo,
    hoveredSiteConditions,
    hoveredSiteStatus,
    filteredPointData,
    positionTooltips
  }
})