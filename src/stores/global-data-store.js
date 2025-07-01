import { defineStore } from "pinia";
// import { useRoute } from 'vue-router';
import { computed, ref } from 'vue'; // Import ref for reactivity

export const useGlobalDataStore = defineStore("globalDataStore", () => {
  const dateInfoData = ref(null)
  const selectedWeek = ref(null)
  const siteInfoData = ref(null)
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
    const stateSelected = ref(false)
    const dataWeeks = computed(() => dateInfoData.value.map(d => d.f_w) || null)
    const selectedDate = computed(() => dateInfoData.value.find(d => d.f_w == selectedWeek.value).dt || null)

  return { dateInfoData, selectedWeek, siteInfoData, selectedSite, defaultExtent, extents, stateSelected, dataWeeks, selectedDate}
})