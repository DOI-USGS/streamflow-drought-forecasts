<template>
  <g
    v-if="initialLoadingComplete"
    ref="backgroundCurrentStreamflowGroup"
    class="background-current-streamflow-group"
    :transform="transform"
    aria-hidden="true"
  />
  <g
    v-if="initialLoadingComplete"
    ref="currentStreamflowGroup"
    class="current-streamflow-group"
    :transform="transform"
    clip-path="url(#current-streamflow-chart-clip)"
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
  import { drawDataDiamonds } from "@/assets/scripts/d3/time-series-diamonds";

  /*
 * A component that renders a diamond to represent yesterday's streamflow on the graph.
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
  currentStreamflowData: {
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
const backgroundCurrentStreamflowGroup = ref(null);
const currentStreamflowGroup = ref(null);
const currentStreamflowDataSegments = computed(() => 
  // Build data segments for current streamflow
  timeseriesDataStore.getDrawingSegments({ 
    siteId: globalDataStore.selectedSite, 
    dataType: "current_streamflow", 
    values: props.currentStreamflowData.values,
    resultFields: {
      result: "result",
      class: "drought_cat"
    }
  })
);

watchEffect(() => {
  if (backgroundCurrentStreamflowGroup.value) {
    drawDataDiamonds(select(backgroundCurrentStreamflowGroup.value), {
      visible: true,
      segments: currentStreamflowDataSegments.value,
      dataKind: "background_current_streamflow",
      xScale: props.xScale,
      yScale: props.yScale,
      transitionLength: transitionLength,
      enableClip: false,
      clipIdKey: props.parentChartIdPrefix
    });
    // Style background rect for current date
    select(backgroundCurrentStreamflowGroup.value).select("g").selectChildren()
      .style("stroke-width", "1px")
    select(backgroundCurrentStreamflowGroup.value).select(`#rect-${globalDataStore.selectedSite}-${globalDataStore.selectedDate}`)
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
  if (currentStreamflowGroup.value) {
    drawDataDiamonds(select(currentStreamflowGroup.value), {
      visible: true,
      segments: currentStreamflowDataSegments.value,
      dataKind: "current_streamflow",
      xScale: props.xScale,
      yScale: props.yScale,
      transitionLength: transitionLength,
      enableClip: false,
      clipIdKey: props.parentChartIdPrefix
    });
    select(currentStreamflowGroup.value).select("g").selectChildren()
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
        const elementWeek = globalDataStore.dateInfoData.find(d => d.dt == elementDate).f_w
        selectedWeek.value = elementWeek;
      })
    select(currentStreamflowGroup.value).select(`#rect-${globalDataStore.selectedSite}-${globalDataStore.selectedDate}`)
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
.ts-current_streamflow-group rect {
  stroke: var(--grey_6_1);
  stroke-width: 1px;
  cursor: pointer;
}
.rect-5 {
  fill: rgb(var(--color-extreme));
  stroke: var(--grey_10_1);
}
.rect-10 {
  fill: rgb(var(--color-severe));
  stroke: var(--grey_7_1);
}
.rect-20 {
  fill: rgb(var(--color-moderate));
  stroke: var(--grey_6_1);
}
.rect-NA {
  fill: var(--color-not-in-drought);
  stroke: var(--grey_6_1);
}
.ts-background_current_streamflow-group rect {
  stroke: var(--grey_17_1);
  stroke-width: 1px;
}
</style>