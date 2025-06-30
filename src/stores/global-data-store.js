import { defineStore } from "pinia";

export const useGlobalDataStore = defineStore("globalDataStore", {
  state: () => ({
    dateInfoData: null,
    selectedWeek: null,
    siteInfoData: null,
    selectedSite: null,
  }),
  getters: {
    dataWeeks: (state) => state.dateInfoData.map(d => d.f_w) || null,
    selectedDate: (state) => state.dateInfoData.find(d => d.f_w == state.selectedWeek).dt || null,
  }
})