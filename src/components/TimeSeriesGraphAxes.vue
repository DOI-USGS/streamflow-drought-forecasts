<template>
  <g 
    ref="xAxisGroup" 
    class="x-axis" 
    :transform="xAxisTransform"
  />
  <g
    v-if="leftYTickValues"
    class="left-y-axis"
    :transform="leftYAxisTransform"
  >
    <g ref="leftYAxisGroup" />
    <text
      v-if="leftYLabel && showYAxisLabels"
      :transform="leftYLabelRotateAngle ? `rotate(${leftYLabelRotateAngle})` : `rotate(-90)`"
      class="y-axis-label"
      :x="leftYLabelX ? leftYLabelX : leftYLabelLocation.x"
      :y="leftYLabelY ? leftYLabelY : leftYLabelLocation.y"
      :dominant-baseline="leftYLabelDominantBaseline ? leftYLabelDominantBaseline : 'text-before-edge'"
      :text-anchor="leftYLabelTextAnchor ? leftYLabelTextAnchor : 'start'"
    >
      {{ leftYLabel }}
    </text>
  </g>
  <g
    v-if="rightYTickValues"
    class="right-y-axis"
    :transform="rightYAxisTransform"
  >
    <g ref="rightYAxisGroup" />
    <text
      v-if="rightYLabel && showYAxisLabels"
      transform="rotate(-90)"
      class="y-axis-label"
      :x="rightYLabelLocation.x"
      :y="rightYLabelLocation.y"
    >
      {{ rightYLabel }}
    </text>
  </g>
</template>

<script setup>
import { axisLeft, axisRight, axisBottom } from "d3-axis";
import { select } from "d3-selection";
import { computed, ref, watch, watchEffect } from "vue";
import { storeToRefs } from "pinia";
import { useGlobalDataStore } from "@/stores/global-data-store";
import { useTimeseriesGraphStore } from "@/stores/timeseries-graph-store";

// global variables
const globalDataStore = useGlobalDataStore();
const timeseriesGraphStore = useTimeseriesGraphStore();
const transitionLength = timeseriesGraphStore.transitionLength;
const { selectedSite } = storeToRefs(globalDataStore);
import { generateTimeTicks } from "@/assets/scripts/d3/time-series-tick-marks";

/*
 * @vue-prop {Object} layout - describes layout of the graph's layout
 *    @prop {Number} height
 *    @prop {Number} weight
 *    @prop {Number} margin - Object with top, right, bottom, left Number properties
 * @vue-prop {Number} offsetXAxis - normally the axis would be drawn at the bottom of the graph.
 *    Specify an additional offset to move it down/up (if negative) from the bottom of the graph.
 * @vue-prop {Function} xScale - the horizontal D3 scale function
 * @vue-prop {Function} leftYScale - the vertical D3 scale function for the left YAxis
 * @vue-prop {Array of Number} - leftYTickValues - An array of Numbers for the desired left Y axis
 *    tick marks. When the left Y axis is not wanted, don't set
 *    this property or set to undefined.
 *  @vue-prop {Function} leftYTickFormat - a format function where the function takes a numerical value and
 *      returns a string. By default, this uses the .toString() function to create the string.
 * @vue-prop {String} leftYLabel - The label for the axis. Is null by default
 * @vue-prop {Function} rightYScale - the vertical D3 scale function for the right YAxis
 * @vue-prop {Array of Number} - rightYTickValues - An array of Numbers for the desired right Y axis
 *    tick marks. When the right Y axis is not wanted, don't set
 *    this property or set to undefined.
 *  @vue-prop {Function} rightYTickFormat - a format function where the function takes a numerical value and
 *      returns a string. By default, this uses the .toString() function to create the string.
 * @vue-prop {String} rightYLabel - The label for the axis. Is null by default.
 * @vue-prop {Boolean} showYAxisLabels - By default true. Can be used to change the visibility of the
 *    label reactively such as when the size of the screen changes
 * @vue-prop {String} ianaTimeZone - Used to generate the time tick marks
 */
const props = defineProps({
  layout: {
    type: Object,
    required: true,
  },
  offsetXAxis: {
    type: Number,
    default: 0,
  },
  xScale: {
    type: Function,
    required: true,
  },
  leftYScale: {
    type: Function,
    default: () => {},
  },
  leftYTickValues: {
    type: Array,
    default: undefined,
  },
  leftYTickFormat: {
    type: Function,
    default: (value) => value.toString(),
  },
  leftYTickSizeInner: {
    type: Number,
    default: 0
  },
  leftYTickOffset: {
    type: Number,
    default: 0
  },
  leftYLabel: {
    type: String,
    default: "",
  },
  leftYLabelX: {
    type: Number,
    default: null
  },
  leftYLabelY: {
    type: Number,
    default: null
  },
  leftYLabelRotateAngle: {
    type: String,
    default: null
  },
  leftYLabelTextAnchor: {
    type: String,
    default: null,
  },
  leftYLabelDominantBaseline: {
    type: String,
    default: null,
  },
  rightYScale: {
    type: Function,
    default: () => {},
  },
  rightYTickValues: {
    type: Array,
    default: undefined,
  },
  rightYTickFormat: {
    type: Function,
    default: (value) => value.toString(),
  },
  rightYLabel: {
    type: String,
    default: "",
  },
  showYAxisLabels: {
    type: Boolean,
    default: true,
  },
  scaleKind: {
    type: String,
    default: "linear",
  },
  newTimeSeries: {
    type: Boolean,
    default: true,
  }
});

const xAxisGroup = ref(null);
const leftYAxisGroup = ref(null);
const rightYAxisGroup = ref(null);

const xAxisTransform = computed(
  () =>
    `translate(${props.layout.margin.left},${
      props.layout.height + props.layout.margin.top + props.offsetXAxis
    })`,
);
const leftYAxisTransform = computed(
  () => `translate(${props.layout.margin.left},${props.layout.margin.top})`,
);
const rightYAxisTransform = computed(
  () =>
    `translate(${props.layout.width + props.layout.margin.left}, ${
      props.layout.margin.top
    })`,
);

const leftYLabelLocation = computed(() => {
  return {
    x: props.layout.height / -2 + props.layout.margin.top,
    y: -1 * props.layout.margin.left,
  };
});

const rightYLabelLocation = computed(() => {
  return {
    x: props.layout.height / -2 + props.layout.margin.top,
    y: props.layout.margin.right,
  };
});

watchEffect(() => {
  if (xAxisGroup.value) {
    select(xAxisGroup.value).selectChildren().remove();
    const [startDate, endDate] = props.xScale.domain();
    const ticks = generateTimeTicks(startDate, endDate);
    const startYear = ticks.dates[0].year
    const xAxis = axisBottom()
      .scale(props.xScale)
      .tickValues(ticks.dates)
      .tickSizeOuter(0)
      .tickFormat((d,i) => {
        // Include the year if it is the first tick, or if the year has changed
        return i == 0 | d.year != startYear ? ticks.formatWithYear(d) : ticks.formatWithoutYear(d);
      });
    select(xAxisGroup.value)
      .call(xAxis);
    // select(xAxisGroup.value).select(".domain").remove();
    select(xAxisGroup.value).select(".domain")
      .attr("transform", `translate(0,-${props.offsetXAxis})`)
  }
});

watch(selectedSite, () => {
  // If the site changes, remove the leftYAxisGroup contents
  select(leftYAxisGroup.value).selectChildren().remove();
})

watchEffect(() => {
  if (leftYAxisGroup.value) {
    if (props.leftYTickValues) {
      const yAxis = axisLeft()
        .scale(props.leftYScale)
        .tickValues(props.leftYTickValues)
        .tickSizeOuter(0)
        .tickSizeInner(props.leftYTickSizeInner)
        .tickFormat(props.leftYTickFormat);
      select(leftYAxisGroup.value)
        .transition()
        .duration(props.newTimeSeries ? 0 : transitionLength) // Only transition if haven't changed site
        .call(yAxis);
      const yAxisPlaced = select(leftYAxisGroup.value)
      yAxisPlaced.select(".domain").remove();
      yAxisPlaced.selectAll(".tick line")
        .attr("transform", `translate(${props.leftYTickOffset},0)`)
      yAxisPlaced.selectAll(".tick text")
        .attr("transform", `translate(${props.leftYTickOffset},0)`)
    }
  }
});

watchEffect(() => {
  if (rightYAxisGroup.value) {
    select(rightYAxisGroup.value).selectChildren().remove();
    if (props.rightYTickValues) {
      const yAxis = axisRight()
        .scale(props.rightYScale)
        .tickValues(props.rightYTickValues.tickValues)
        .tickSizeInner(-props.layout.width)
        .tickPadding(3)
        .tickSizeOuter(0)
        .tickFormat(props.rightYTickFormat);
      select(rightYAxisGroup.value).call(yAxis);
    }
  }
});
</script>

<style lang="scss">
.left-y-axis .tick line {
  stroke-width: 0.25px;
  stroke: var(--grey_2_1);
}
.y-axis-label {
  font-style: italic;
  font-weight: 300;
  color: var(--grey_7_1);
  user-select: none;
}
.x-axis .domain {
  stroke-width: 0.5px;
  stroke: var(--grey_3_1);
}
.x-axis .tick line {
  stroke-width: 0.5px;
  stroke: var(--grey_5_1);
}
.tick text {
  color: var(--grey_7_1);
  font-family: var(--default-font);
  font-size: 1.6rem;
  font-weight: 300;
  user-select: none;
}
</style>
