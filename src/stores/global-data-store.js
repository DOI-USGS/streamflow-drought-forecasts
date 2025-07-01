import { defineStore } from "pinia";
import { useRoute } from 'vue-router';
import { computed, ref } from 'vue'; // Import ref for reactivity

export const useGlobalDataStore = defineStore("globalDataStore", () => {
  const route = useRoute();
  const dateInfoData = ref(null)
  const siteInfoData = ref(null)
  const conditionsData = ref(null)
  const selectedWeek = ref(null)
  const selectedSite = ref(null)
  const defaultExtent = 'the continental U.S.'
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
  const dataWeeks = computed(() => dateInfoData.value.map(d => d.f_w) || [])
  const selectedDate = computed(() => dateInfoData.value.find(d => d.f_w == selectedWeek.value).dt || null)
  // Define data type
  const dataType = computed(() => {
    return selectedWeek.value > 0 ? 'Forecast' : 'Observed';
  })
  const stateSelected = computed(() => extents.includes(route.query.extent))
  const selectedExtent = computed(() => stateSelected.value ? route.query.extent : defaultExtent)
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
  // Define allConditions, based on siteList (which is computed based on selectedExtent)
  const allConditions = computed(() => {
    // Don't bother filtering for defaultExtent, when all sites are included
    if (selectedExtent.value == defaultExtent) {
      return conditionsData.value;
    } else {
      return conditionsData.value?.filter(d => siteList.value.includes(d.StaID));
    }
  })
  // Define currentConditions, based on siteList (which is computed based on selectedExtent) and selectedDate
  const currentConditions = computed(() => {
    return allConditions.value?.filter(d => d.dt == selectedDate.value)
  })
  const sitesExtreme = computed(() => {
    return currentConditions.value.filter(d => d.pd < 5);
  })
  const sitesSevere = computed(() => {
    return currentConditions.value.filter(d => d.pd < 10 && d.pd >= 5);
  })
  const sitesModerate = computed(() => {
    return currentConditions.value.filter(d => d.pd < 20 && d.pd >= 10);
  })
  // Define selectedSiteInfo, based on selectedSite
  const selectedSiteInfo = computed(() => {
    return siteInfo.value.find(d => d.StaID == selectedSite.value);
  })
  // Define selectedSiteConditions, based on selectedSite
  const selectedSiteConditions = computed(() => {
    return currentConditions.value.find(d => d.StaID == selectedSite.value);
  })

  return { 
    dateInfoData, 
    siteInfoData, 
    conditionsData, 
    selectedWeek, 
    selectedSite, 
    defaultExtent,
    extents, 
    stateSelected, 
    dataWeeks, 
    selectedDate, 
    dataType,
    selectedExtent, 
    siteInfo, 
    siteList, 
    allConditions, 
    currentConditions, 
    sitesExtreme, 
    sitesSevere, 
    sitesModerate,
    selectedSiteInfo,
    selectedSiteConditions
  }
})