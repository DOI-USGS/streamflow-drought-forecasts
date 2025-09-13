<template>
  <g
    v-if="initialLoadingComplete"
    ref="uncertaintyGroup"
    class="uncertainty-group"
    :transform="transform"
    clip-path="url(#uncertainty-chart-clip)"
  />
</template>

<script setup>
  import { computed, ref, watchEffect } from "vue";
  import { useGlobalDataStore } from "@/stores/global-data-store";
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

// global variables
const globalDataStore = useGlobalDataStore();
const timeseriesDataStore = useTimeseriesDataStore();
const timeseriesGraphStore = useTimeseriesGraphStore();
const transitionLength = timeseriesGraphStore.transitionLength;
const uncertaintyGroup = ref(null);
const uncertaintyDataSegments = computed(() => 
  // Build data segments for uncertainty
  timeseriesDataStore.getDrawingSegments({ 
    siteId: globalDataStore.selectedSite, 
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
      enableClip: false,
      clipIdKey: props.parentChartIdPrefix
    });
  }
});

</script>

<style lang="scss">
/* MUST match RECT_STROKE_WIDTH in `src/assets/scripts/d3/time-series-rects.js` */
$rect_stroke_width: 0.5px;
.ts-uncertainty-group rect {
  fill: var(--color-background);
  stroke: var(--grey_3_1);
  stroke-width: $rect_stroke_width;
}
</style>