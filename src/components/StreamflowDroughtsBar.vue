<template>
  <g
    v-if="initialLoadingComplete"
    ref="streamflowDroughtsGroup"
    class="streamflow-droughts-group"
    :transform="transform"
  />
  <g 
    :id="streamflow-droughts-bar-group"
    :transform="transform"
  >
    <clipPath :id="streamflow-droughts-bar-clip">
      <rect 
        x="0"
        y="0"
        :width="layout.width"
        :height="barHeight"
      />
    </clipPath>
    <line 
      x1="0"
      :x2="props.xScale.range()[1]"
      y1="0"
      y2="0"
    />
    <rect
      v-for="interval in streamflowDroughtIntervals"
      :key="interval.startX"
      :class="interval.class"
      :x="interval.startX"
      :y="indicatorOffset"
      :width="interval.width"
      :height="barHeight - 2 * indicatorOffset"
      :clip-path="`url(#streamflow-droughts-bar-clip)`"
    />
  </g>
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
  streamflowDroughtsData: {
    type: Object,
    default: () => ({}),
    required: true,
  },  
  xScale: {
    type: Function,
    required: true,
  },
  layout: {
    type: Object,
    default: () => ({}),
    required: true,
  },
  barHeight: {
    type: Number,
    required: true,
  },
  indicatorOffset: {
    type: Number,
    required: true,
  }
});

// Inject data
const { selectedSite } = inject('sites')

// global variables
const timeseriesDataStore = useTimeseriesDataStore();
const timeseriesGraphStore = useTimeseriesGraphStore();
// const transitionLength = timeseriesGraphStore.transitionLength;
const streamflowDroughtsGroup = ref(null);
// const streamflowDroughtsDataSegments = computed(() => 
//   // Build data segments for streamflow_droughts
//   timeseriesDataStore.getDrawingSegments({ 
//     siteId: selectedSite.value, 
//     dataType: "streamflow_droughts", 
//     resultFields: {
//       result_min: "result_min",
//       result_max: "result_max"
//     },
//     groupIdentifier: "pd"
//   })
// );

const transform = computed(
  () =>
    `translate(${props.layout.margin.left}, ${
      props.layout.height + props.layout.margin.top
    })`,
);

const streamflowDroughtIntervals = computed(() => {
  return props.streamflowDroughtsData.values.map((drought) => {
    const startX = props.xScale(new Date(drought.start));
    let endX = props.xScale(new Date(drought.end));
    const width = endX - startX;
    return {
      startX: startX,
      width: width < 2 ? 2 : width,
      class: `bar-${drought.drought_cat}`,
    };
  });
});
console.log(props.streamflowDroughtsData.values)
console.log(streamflowDroughtIntervals.value)


watchEffect(() => {
  if (streamflowDroughtsGroup.value) {
    // drawDataAreas(select(streamflowDroughtsGroup.value), {
    //   visible: true,
    //   segments: streamflowDroughtsDataSegments.value,
    //   groupedAreas: true,
    //   dataKind: "streamflow_droughts",
    //   xScale: props.xScale,
    //   yScale: props.yScale,
    //   transitionLength: transitionLength,
    //   enableClip: true,
    //   clipIdKey: props.parentChartIdPrefix
    // });
  }
});

</script>

<style lang="scss">
.bar-5 {
  fill: rgb(var(--color-extreme));
}
.bar-10 {
  fill: rgb(var(--color-severe));
}
.bar-20 {
  fill: rgb(var(--color-moderate));
}
</style>