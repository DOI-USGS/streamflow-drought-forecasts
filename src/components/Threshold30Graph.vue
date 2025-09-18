<template>
  <g
    v-if="initialLoadingComplete"
    ref="threshold30Group"
    class="threshold-30-group"
    :transform="transform"
    aria-hidden="true"
  />
</template>

<script setup>
  import { computed, ref, watchEffect } from "vue";
  import { useGlobalDataStore } from "@/stores/global-data-store";
  import { useTimeseriesDataStore } from "@/stores/timeseries-data-store";
  import { useTimeseriesGraphStore } from "@/stores/timeseries-graph-store";
  import { select } from "d3-selection";
  import { drawDataSegments } from "@/assets/scripts/d3/time-series-lines";

  /*
 * A component that renders a line to represent a drought threshold on the graph.
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
  thresholdData: {
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
const transitionLength = timeseriesGraphStore.transitionLength;
const threshold30Group = ref(null);
const threshold30DataSegments = computed(() =>
  timeseriesDataStore.getDrawingSegments({ 
    siteId: globalDataStore.selectedSite, 
    dataType: "threshold",
    values: props.thresholdData.values,
    resultFields: {
      result: "result_max"
    }
  })
);

watchEffect(() => {
  if (threshold30Group.value) {
    drawDataSegments(select(threshold30Group.value), {
      visible: true,
      segments: threshold30DataSegments.value,
      dataKind: "threshold-30",
      xScale: props.xScale,
      yScale: props.yScale,
      transitionLength: transitionLength,
      enableClip: true,
      clipIdKey: props.parentChartIdPrefix
    });
  }
});

</script>

<style lang="scss">
.ts-line {
  fill: none;
}
.ts-threshold-30-group path {
  stroke-width: 1.5px;
  stroke: var(--grey_15_1);
  stroke-dasharray: 0.1 5;
  stroke-linecap: round;
}
</style>