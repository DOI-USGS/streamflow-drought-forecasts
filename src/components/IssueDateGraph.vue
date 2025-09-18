<template>
  <g
    v-if="initialLoadingComplete"
    ref="issueDateGroup"
    class="issue-date-group"
    :transform="transform"
    aria-hidden="true"
  />
  <g
    v-if="initialLoadingComplete"
    class="issue-date-label-group"
    :transform="transform"
    aria-hidden="true"
  >
    <text
      dominant-baseline="hanging"
      class="issue-date-label"
      :transform="issueDateTransform"
    >
      {{ issueDateFormatted }}
    </text>
  </g>
</template>

<script setup>
  import { computed, ref, watchEffect } from "vue";
  import { useGlobalDataStore } from "@/stores/global-data-store";
  import { useTimeseriesDataStore } from "@/stores/timeseries-data-store";
  import { useTimeseriesGraphStore } from "@/stores/timeseries-graph-store";
  import { select } from "d3-selection";
  import { utcFormat } from "d3-time-format"
  import { drawDataSegments } from "@/assets/scripts/d3/time-series-lines";

  /*
 * A component that renders a vertical line to represent the issue date on the graph.
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

// global variables
const globalDataStore = useGlobalDataStore();
const issueDate = globalDataStore.issueDate
const dataType = "issue_date"
const timeseriesDataStore = useTimeseriesDataStore();
const timeseriesGraphStore = useTimeseriesGraphStore();
const transitionLength = timeseriesGraphStore.transitionLength;
const issueDateGroup = ref(null);
const issueDateData = computed(() => {
  return {
    datasetID: globalDataStore.selectedSite + dataType,
    siteId: globalDataStore.selectedSite,
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
    siteId: globalDataStore.selectedSite, 
    dataType: dataType, 
    values: issueDateData.value.values
  })
);
const issueDateTransform = computed(
  () => {
    const issueDatetime = new Date(globalDataStore.issueDate)
    return `translate(${props.xScale(issueDatetime)+5},0)` 
  },
);
const issueDateFormatted = computed(
  () => {
    const formatTime = utcFormat("%m/%d/%y")
    return formatTime(new Date(globalDataStore.issueDate)) 
  },
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
  stroke: var(--grey_7_1);
}
.issue-date-label {
  color: var(--grey_7_1);
  font-family: var(--default-font);
  font-size: 1.6rem;
  font-weight: 300;
  user-select: none;
}
</style>