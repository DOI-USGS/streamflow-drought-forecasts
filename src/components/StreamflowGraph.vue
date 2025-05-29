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
});

// Inject data
const { selectedSite } = inject('sites')

// global variables
const timeseriesDataStore = useTimeseriesDataStore();
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
      enableClip: false,
    });
  }
});

watchEffect(() => {
  // This removes any existing children (e.g., children associated w/ other sites)
//   if (streamflowGroup.value) {
//     select(streamflowGroup.value).selectChildren().remove();
//   }

  // https://code.usgs.gov/wma/iow/waterdataui/-/blob/main/assets/src/scripts/vue-components/time-series-graph/FloodLevelsGraph.vue
  if (props.streamflowData) {
    console.log('in streamflow graph')
    console.log(props.streamflowData)
  }

  if (props.yScale) {
    console.log('streamflow graph y domain')
    console.log(props.yScale.domain())
  }

  if (props.xScale) {
    console.log('streamflow graph x domain')
    console.log(props.xScale.domain())
  }
});

</script>