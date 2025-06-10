<template>
  <g
    v-if="initialLoadingComplete"
    ref="uncertaintyGroup"
    class="uncertainty-group"
    :transform="transform"
  />
</template>

<script setup>
  import { computed, inject, ref, watchEffect } from "vue";
  import { useTimeseriesDataStore } from "@/stores/timeseries-data-store";
  import { useTimeseriesGraphStore } from "@/stores/timeseries-graph-store";
  import { select } from "d3-selection";
  import { drawDataRects } from "@/assets/scripts/d3/time-series-rects";

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
  uncertaintyData: {
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
const uncertaintyGroup = ref(null);
const uncertaintyDataSegments = computed(() => 
  // Build data segments for uncertainty
  timeseriesDataStore.getDrawingSegments({ 
    siteId: selectedSite.value, 
    dataType: "uncertainty", 
    values: props.uncertaintyData.values,
    resultFields: {
      result_min: "pred_interv_05",
      result_max: "pred_interv_95"
    }
  })
);

watchEffect(() => {
  if (uncertaintyGroup.value) {
    drawDataRects(select(uncertaintyGroup.value), {
      visible: true,
      segments: uncertaintyDataSegments.value,
      dataKind: "uncertainty",
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
.ts-uncertainty-group rect {
  fill: transparent;
  stroke: black;
  stroke-width: 0.25px;
}
</style>