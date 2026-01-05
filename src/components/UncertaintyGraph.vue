<template>
  <g
    v-if="initialLoadingComplete"
    ref="uncertaintyGroup"
    class="uncertainty-group"
    :transform="transform"
    clip-path="url(#uncertainty-chart-clip)"
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
  import { drawDataRects } from "@/assets/scripts/d3/time-series-rects";

  /*
 * A component that renders boxes used to represent forecast uncertainty on the graph.
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
const { selectedWeek } = storeToRefs(globalDataStore);
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
    select(uncertaintyGroup.value).select("g").selectChildren()
      .style("stroke", "var(--grey_4pt6_1)")
      .style("stroke-width", "0.5px")
      .on("click", (event, d) => {
        const elementDate = d.id.slice(9)
        const elementWeek = globalDataStore.dateInfoData.find(d => d.dt == elementDate)?.f_w || undefined;
        // Only trigger update to selectedWeek if elementWeek is defined (i.e., site-specific data are up to date and element date is included in current globalDataStore.dateInfoData)
        if (elementWeek) selectedWeek.value = elementWeek;
      })
    select(uncertaintyGroup.value).select(`#rect-${globalDataStore.selectedSite}-${globalDataStore.selectedDate}`)
      .style("stroke", "var(--black-soft)")
      .style("stroke-width", "1px")
  }
});

</script>

<style lang="scss">
/* MUST match RECT_STROKE_WIDTH in `src/assets/scripts/d3/time-series-rects.js` */
$rect_stroke_width: 0.5px;
.ts-uncertainty-group rect {
  fill: transparent;
  stroke: var(--grey_4pt6_1);
  stroke-width: $rect_stroke_width;
  cursor: pointer;
}
</style>