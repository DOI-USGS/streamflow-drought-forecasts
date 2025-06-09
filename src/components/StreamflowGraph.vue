<template>
  <!-- <g
    ref="streamflowGroup"
    class="streamflow-group"
    :transform="transform"
  >
    <path d="M 10,30 A 20,20 0,0,1 50,30" />
  </g> -->
  <g
    v-if="initialLoadingComplete"
    ref="streamflowGroup"
    class="streamflow-group"
    :transform="transform"
  />
</template>

<script setup>
  import { computed, inject, ref, watchEffect } from "vue";
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

// Inject data
const { selectedSite } = inject('sites')

// global variables
const timeseriesDataStore = useTimeseriesDataStore();
const timeseriesGraphStore = useTimeseriesGraphStore();
const transitionLength = timeseriesGraphStore.transitionLength;
const streamflowGroup = ref(null);
const streamflowDataSegments = computed(() =>
  timeseriesDataStore.getDrawingSegments(selectedSite.value, "streamflow")
);

watchEffect(() => {
  if (streamflowGroup.value) {
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
  }
});

</script>