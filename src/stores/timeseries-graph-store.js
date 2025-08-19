import { defineStore } from "pinia";

export const useTimeseriesGraphStore = defineStore("timeseriesGraphStore", {
  state: () => ({
    scaleKind: "linear",
    transitionLength: 2000
  }),
})