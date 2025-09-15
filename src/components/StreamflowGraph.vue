<template>
  <g
    v-if="initialLoadingComplete"
    ref="streamflowGroupMask"
    class="streamflow-group-mask"
    :transform="transform"
  />
  <g
    v-if="initialLoadingComplete"
    ref="streamflowGroup"
    class="streamflow-group"
    :transform="transform"
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
 * A component that renders shaded regions and horizontal lines used to
 * represent flood levels on the graph.
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
  streamflowData: {
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
const streamflowGroupMask = ref(null);
const streamflowGroup = ref(null);
const streamflowDataSegments = computed(() =>
  timeseriesDataStore.getDrawingSegments({ 
    siteId: globalDataStore.selectedSite, 
    dataType: "streamflow"
  })
);

watchEffect(() => {
  // If site has streamflow data, draw it
  if (streamflowGroup.value && streamflowDataSegments.value.length > 0) {
    // Eventually, should use mask, but this works for now
    drawDataSegments(select(streamflowGroupMask.value), {
      visible: true,
      segments: streamflowDataSegments.value,
      dataKind: "streamflow",
      xScale: props.xScale,
      yScale: props.yScale,
      transitionLength: transitionLength,
      enableClip: true,
      clipIdKey: props.parentChartIdPrefix
    });
    drawDataSegments(select(streamflowGroup.value), {
      visible: true,
      segments: streamflowDataSegments.value,
      dataKind: "streamflow",
      xScale: props.xScale,
      yScale: props.yScale,
      transitionLength: transitionLength,
      enableClip: true,
      clipIdKey: props.parentChartIdPrefix
    });
  } else {
    // if selected site has no streamflow data, remove currently drawn streamflow (for previously selected site)
     select(streamflowGroupMask.value).select("g").selectChildren()
      .remove()
    select(streamflowGroup.value).select("g").selectChildren()
      .remove()
  }
});

</script>

<style lang="scss">
.ts-line {
  fill: none;
}
.ts-streamflow-group path {
  stroke: var(--grey_15_1);
  stroke-width: 1.8px;
}
.streamflow-group-mask path {
  stroke-width: 3.5px;
  stroke: white
}


</style>