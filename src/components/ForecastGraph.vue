<template>
  <g
    v-if="initialLoadingComplete"
    ref="backgroundForecastGroup"
    class="background-forecast-group"
    :transform="transform"
  />
  <g
    v-if="initialLoadingComplete"
    ref="forecastGroup"
    class="forecast-group"
    :transform="transform"
  />
</template>

<script setup>
  import { computed, inject, ref, watchEffect } from "vue";
  import { useTimeseriesDataStore } from "@/stores/timeseries-data-store";
  import { useTimeseriesGraphStore } from "@/stores/timeseries-graph-store";
  import { select } from "d3-selection";
  import { drawDataPoints } from "@/assets/scripts/d3/time-series-points";

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
  forecastData: {
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
const { selectedDate } = inject('dates')

// global variables
const timeseriesDataStore = useTimeseriesDataStore();
const timeseriesGraphStore = useTimeseriesGraphStore();
const transitionLength = timeseriesGraphStore.transitionLength;
const backgroundForecastGroup = ref(null);
const forecastGroup = ref(null);
const forecastDataSegments = computed(() =>
  timeseriesDataStore.getDrawingSegments({ 
    siteId: selectedSite.value, 
    dataType: "forecasts", 
    values: props.forecastData.values,
    resultFields: {
      result: "result",
      class: "drought_cat"
    },
  })
);

watchEffect(() => {
  if (backgroundForecastGroup.value) {
    drawDataPoints(select(backgroundForecastGroup.value), {
      visible: true,
      segments: forecastDataSegments.value,
      dataKind: "background-forecasts",
      xScale: props.xScale,
      yScale: props.yScale,
      transitionLength: transitionLength,
      enableClip: false,
      clipIdKey: props.parentChartIdPrefix
    });
    // Style background forecast point for current date
    select(backgroundForecastGroup.value).select("g").selectChildren()
      .style("stroke-width", "1px")
    select(backgroundForecastGroup.value).select(`#circle-${selectedSite.value}-${selectedDate.value}`)
      .style("stroke-width", d => {
        let strokeWidth;
        switch(d.class) {
          case '5':
            strokeWidth = 5;
            break;
          case '10':
            strokeWidth = 5;
            break;
          case '20':
            strokeWidth = 5;
            break;
          default:
            strokeWidth = 4.5;
        }
        return strokeWidth
      })
  }
  if (forecastGroup.value) {
    drawDataPoints(select(forecastGroup.value), {
      visible: true,
      segments: forecastDataSegments.value,
      dataKind: "forecasts",
      xScale: props.xScale,
      yScale: props.yScale,
      transitionLength: transitionLength,
      enableClip: false,
      clipIdKey: props.parentChartIdPrefix
    });
    // Style forecast point for current date
    select(forecastGroup.value).select("g").selectChildren()
      .style("stroke", d => {
        let strokeColor;
        switch(d.class) {
          case '5':
            strokeColor = "var(--white-soft)";
            break;
          case '10':
            strokeColor = "var(--white)";
            break;
          case '20':
            strokeColor = "var(--grey_6_1)";
            break;
          default:
            strokeColor = "var(--grey_6_1)";
        }
        return strokeColor
      })
    select(forecastGroup.value).select(`#circle-${selectedSite.value}-${selectedDate.value}`)
      .style("stroke", d => {
        let strokeColor;
        switch(d.class) {
          case '5':
            strokeColor = "var(--white-soft)";
            break;
          case '10':
            strokeColor = "var(--white-soft)";
            break;
          case '20':
            strokeColor = "var(--white-soft)";
            break;
          default:
            strokeColor = "var(--white-soft)";
        }
        return strokeColor
      })
  }
});

</script>

<style lang="scss">
.ts-forecasts-group circle {
  stroke-width: 1px;
}
.point-5 {
  fill: rgb(var(--color-extreme));
  stroke: var(--white-soft);
}
.point-10 {
  fill: rgb(var(--color-severe));
  stroke: var(--white);
}
.point-20 {
  fill: rgb(var(--color-moderate));
  stroke: var(--grey_6_1);
}
.point-none {
  fill: var(--color-not-in-drought);
  stroke: var(--grey_6_1);
}
.ts-background-forecasts-group circle {
  stroke: var(--grey_6_1);
  stroke-width: 1px;
}
</style>