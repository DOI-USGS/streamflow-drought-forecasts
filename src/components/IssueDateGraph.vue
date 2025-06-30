<template>
  <g
    v-if="initialLoadingComplete"
    ref="issueDateGroup"
    class="issue-date-group"
    :transform="transform"
  />
</template>

<script setup>
  import { computed, inject, ref, watchEffect } from "vue";
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
const globalDataStore = useGlobalDataStore();
const issueDate = globalDataStore.dateInfoData[0].issue_date
const dataType = "issue_date"
const timeseriesDataStore = useTimeseriesDataStore();
const timeseriesGraphStore = useTimeseriesGraphStore();
const transitionLength = timeseriesGraphStore.transitionLength;
const issueDateGroup = ref(null);
const issueDateData = computed(() => {
  return {
    datasetID: selectedSite.value + dataType,
    siteId: selectedSite.value,
    dataType: dataType,
    values: [
      {
        dt: issueDate,
        result: props.yScale.domain()[0]
      },
      {
        dt: issueDate,
        result: props.yScale.domain()[1]
      }
    ]
  }
});
const issueDateDataSegments = computed(() => 
  // Build data segments for issue date line
  timeseriesDataStore.getDrawingSegments({ 
    siteId: selectedSite.value, 
    dataType: dataType, 
    values: issueDateData.value.values
  })
);

watchEffect(() => {
  if (issueDateGroup.value) {
    drawDataSegments(select(issueDateGroup.value), {
      visible: true,
      segments: issueDateDataSegments.value,
      dataKind: dataType,
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
.ts-issue_date-group path {
  stroke-width: 0.5px;
  stroke: var(--grey_6_1);
  stroke-dasharray: 2 3;
}
</style>