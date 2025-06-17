<template>
  <g
    v-if="initialLoadingComplete"
    ref="overlaysUpperGroup"
    class="overlays-upper-group"
    :transform="transform"
  />
</template>

<script setup>
  import { computed, inject, ref, watchEffect } from "vue";
  import { useTimeseriesDataStore } from "@/stores/timeseries-data-store";
  import { useTimeseriesGraphStore } from "@/stores/timeseries-graph-store";
  import { select } from "d3-selection";
  import { drawDataAreas } from "@/assets/scripts/d3/time-series-areas";

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

// Inject data
const { selectedSite } = inject('sites')

// global variables
const timeseriesDataStore = useTimeseriesDataStore();
const timeseriesGraphStore = useTimeseriesGraphStore();
const transitionLength = timeseriesGraphStore.transitionLength;
const overlaysUpperGroup = ref(null);
const overlaysUpperDataSegments = computed(() => 
  // Build data segments for thresholds, using pd (percentile) as the group identifier
  timeseriesDataStore.getDrawingSegments({ 
    siteId: selectedSite.value, 
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
.ts-overlays_upper-group path {
  fill: var(--white);
  opacity: 0.75;
}
</style>