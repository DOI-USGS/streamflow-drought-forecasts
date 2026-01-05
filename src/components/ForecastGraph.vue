<template>
  <g
    v-if="initialLoadingComplete"
    ref="backgroundForecastGroup"
    class="background-forecast-group"
    :transform="transform"
    aria-hidden="true"
  />
  <g
    v-if="initialLoadingComplete"
    ref="forecastGroup"
    class="forecast-group"
    :transform="transform"
    aria-hidden="true"
  />
</template>

<script setup>
  import { computed, ref, watchEffect } from "vue";
  import { useGlobalDataStore } from "@/stores/global-data-store";
  import { useTimeseriesDataStore } from "@/stores/timeseries-data-store";
  import { useTimeseriesGraphStore } from "@/stores/timeseries-graph-store";
  import { storeToRefs } from "pinia";
  import { select } from "d3-selection";
  import { drawDataPoints } from "@/assets/scripts/d3/time-series-points";

  /*
 * A component that renders points to represent forecast medians on the graph.
 * @vue-prop {String} transform - transform to use on the group that renders the lines.
 *      Defaults to the empty string.
 * @vue-prop {Function} xScale - The D3 scale function used to translate the dateTime to a X coordinate.
 * @vue-prop {Function} yScale - The D3 scale function used to translate the statValue to a Y coordinate.
 */

const props = defineProps({
  initialLoadingComplete: {
    type: Boolean,
    required: true,
  },
  transform: {
    type: String,
    default: "",
  },
  forecastData: {
    type: Object,
    default: () => ({}),
    required: true,
  },  
  xScale: {
    type: Function,
    required: true,
  },
  yScale: {
    type: Function,
    required: true,
  },
  parentChartIdPrefix: {
    type: String,
    default: ""
  }
});

// global variables
const globalDataStore = useGlobalDataStore();
const timeseriesDataStore = useTimeseriesDataStore();
const timeseriesGraphStore = useTimeseriesGraphStore();
const { selectedWeek } = storeToRefs(globalDataStore);
const transitionLength = timeseriesGraphStore.transitionLength;
const backgroundForecastGroup = ref(null);
const forecastGroup = ref(null);
const forecastDataSegments = computed(() =>
  timeseriesDataStore.getDrawingSegments({ 
    siteId: globalDataStore.selectedSite, 
    dataType: "forecasts", 
    values: props.forecastData.values,
    resultFields: {
      result: "result",
      class: "drought_cat"
    },
  })
);

watchEffect(() => {
  if (backgroundForecastGroup.value) {
    drawDataPoints(select(backgroundForecastGroup.value), {
      visible: true,
      segments: forecastDataSegments.value,
      dataKind: "background-forecasts",
      xScale: props.xScale,
      yScale: props.yScale,
      transitionLength: transitionLength,
      enableClip: false,
      clipIdKey: props.parentChartIdPrefix
    });
    // Style background forecast point for current date
    select(backgroundForecastGroup.value).select("g").selectChildren()
      .style("stroke-width", "1px")
    select(backgroundForecastGroup.value).select(`#circle-${globalDataStore.selectedSite}-${globalDataStore.selectedDate}`)
      .style("stroke-width", d => {
        let strokeWidth;
        switch(d.class) {
          case '5':
            strokeWidth = 5;
            break;
          case '10':
            strokeWidth = 5;
            break;
          case '20':
            strokeWidth = 5;
            break;
          default:
            strokeWidth = 4.5;
        }
        return strokeWidth
      })
  }
  if (forecastGroup.value) {
    drawDataPoints(select(forecastGroup.value), {
      visible: true,
      segments: forecastDataSegments.value,
      dataKind: "forecasts",
      xScale: props.xScale,
      yScale: props.yScale,
      transitionLength: transitionLength,
      enableClip: false,
      clipIdKey: props.parentChartIdPrefix
    });
    // Style forecast point for current date
    select(forecastGroup.value).select("g").selectChildren()
      .style("stroke", d => {
        let strokeColor;
        switch(d.class) {
          case '5':
            strokeColor = "var(--grey_10_1)";
            break;
          case '10':
            strokeColor = "var(--grey_7_1)";
            break;
          case '20':
            strokeColor = "var(--grey_6_1)";
            break;
          default:
            strokeColor = "var(--grey_6_1)";
        }
        return strokeColor
      })
      .on("click", (event, d) => {
        const elementDate = d.id.slice(9)
        const elementWeek = globalDataStore.dateInfoData.find(d => d.dt == elementDate)?.f_w || undefined;
        // Only trigger update to selectedWeek if elementWeek is defined (i.e., site-specific data are up to date and element date is included in current globalDataStore.dateInfoData)
        if (elementWeek) selectedWeek.value = elementWeek;
      })
    select(forecastGroup.value).select(`#circle-${globalDataStore.selectedSite}-${globalDataStore.selectedDate}`)
      .style("stroke", d => {
        let strokeColor;
        switch(d.class) {
          case '5':
            strokeColor = "var(--white-soft)";
            break;
          case '10':
            strokeColor = "var(--white-soft)";
            break;
          case '20':
            strokeColor = "var(--white-soft)";
            break;
          default:
            strokeColor = "var(--grey_2_1)";
        }
        return strokeColor
      })
  }
});

</script>

<style lang="scss">
.ts-forecasts-group circle {
  stroke-width: 1px;
  cursor: pointer;
}
.point-5 {
  fill: rgb(var(--color-extreme));
  stroke: var(--grey_10_1);
}
.point-10 {
  fill: rgb(var(--color-severe));
  stroke: var(--grey_7_1);
}
.point-20 {
  fill: rgb(var(--color-moderate));
  stroke: var(--grey_6_1);
}
.point-NA {
  fill: var(--color-not-in-drought);
  stroke: var(--grey_6_1);
}
.ts-background-forecasts-group circle {
  stroke: var(--grey_17_1);
  stroke-width: 1px;
}
</style>