<template>
  <g
    v-if="initialLoadingComplete"
    ref="overlaysUpperGroup"
    class="overlays-upper-group"
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
  import { drawDataAreas } from "@/assets/scripts/d3/time-series-areas";

  /*
 * A component that renders shaded regions to partially mask drought thresholds on the graph.
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
  overlaysUpperData: {
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
const overlaysUpperGroup = ref(null);
const overlaysUpperDataSegments = computed(() => 
  // Build data segments for upper overlays, using f_w (forecast weeek) as the group identifier
  timeseriesDataStore.getDrawingSegments({ 
    siteId: globalDataStore.selectedSite, 
    dataType: "overlays_upper", 
    resultFields: {
      result_min: "result_min",
      result_max: "result_max"
    },
    groupIdentifier: "f_w"
  })
);

watchEffect(() => {
  if (overlaysUpperGroup.value) {
    drawDataAreas(select(overlaysUpperGroup.value), {
      visible: true,
      segments: overlaysUpperDataSegments.value,
      groupedAreas: true,
      allGroupsRepresented: false,
      allGroups: ['1','2','4','9','13'],
      dataKind: "overlays_upper",
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
.overlays-upper-group path {
  fill: var(--white);
  opacity: 0.65;
  stroke: var(--white);
  stroke-width: 0.3px;
  stroke-opacity: 0.65;
}
</style>