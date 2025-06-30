import { defineStore } from "pinia";

export const useGlobalDataStore = defineStore("globalDataStore", {
  state: () => ({
    dateInfoData: null,
    selectedWeek: null,
  }),
  getters: {
    selectedDate: (state) => state.dateInfoData.find(d => d.f_w == state.selectedWeek).dt || null,
  }
})