<template>
  <g
    v-if="initialLoadingComplete"
    ref="streamflowDroughtsGroup"
    class="streamflow-droughts-group"
    :transform="transform"
  />
  <g 
    id="streamflow-droughts-bar-group"
    :transform="transform"
  >
    <clipPath 
      id="streamflow-droughts-bar-clip"
    >
      <rect 
        x="0"
        y="0"
        :width="layout.width"
        :height="barHeight"
      />
    </clipPath>
    <rect
      v-for="interval in streamflowDroughtIntervals"
      :key="interval.startX"
      :class="interval.class"
      :x="interval.startX"
      :y="indicatorOffset"
      :width="interval.width"
      :height="adjustedBarHeight"
      clip-path="url(#streamflow-droughts-bar-clip)"
    />
    <circle 
      v-for="point in forecastDroughtPoints"
      :key="point.cx"
      :class="point.class"
      :cx="point.cx"
      :cy="indicatorOffset + (adjustedBarHeight / 2)"
      :r="point.r"
      clip-path="url(#streamflow-droughts-bar-clip)"
    />
  </g>
</template>

<script setup>
  import { computed, ref } from "vue";
  import { timeDay as d3TimeDay } from "d3-time";

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
    forecastDroughtsData: {
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

  // global variables
  const streamflowDroughtsGroup = ref(null);

  const transform = computed(
    () =>
      `translate(${props.layout.margin.left}, ${
        props.layout.height + props.layout.margin.top
      })`,
  );

  const adjustedBarHeight = props.barHeight - 2 * props.indicatorOffset
  const streamflowDroughtIntervals = computed(() => {
    return props.streamflowDroughtsData.values.map((drought) => {
      const startX = props.xScale(new Date(drought.start));
      let endX = props.xScale(new Date(drought.end));
      const width = endX - startX;
      return {
        startX: startX,
        width: width,
        class: `bar-${drought.drought_cat}`,
      };
    });
  });
  
  const WIDTH_IN_DAYS = 5;
  const forecastDroughtPoints = computed(() => {
    return props.forecastDroughtsData.values.map((drought) => {
      const cx = props.xScale(new Date(drought.dt));
      const radius = (props.xScale(d3TimeDay.offset(new Date(drought.dt), WIDTH_IN_DAYS)) - props.xScale(new Date(drought.dt))) / 2;
      return {
        cx: cx,
        r: radius,
        class: `bar-point point-${drought.drought_cat}`,
      };
    });
  })
</script>

<style lang="scss" scoped>
.bar-5 {
  fill: rgb(var(--color-extreme));
}
.bar-10 {
  fill: rgb(var(--color-severe));
}
.bar-20 {
  fill: rgb(var(--color-moderate));
}
.bar-point {
  stroke: var(--grey_6_1);
}
</style>