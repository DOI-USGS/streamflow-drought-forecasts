<template>
  <g 
    v-if="initialLoadingComplete"
    id="streamflow-droughts-group"
    ref="streamflowDroughtsGroup"
    :transform="transform"
    aria-hidden="true"
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
      v-for="point in backgroundForecastDroughtPoints"
      :id="point.id"
      :key="point.cx"
      :class="point.class"
      :cx="point.cx"
      :cy="indicatorOffset + (adjustedBarHeight / 2)"
      :r="point.r"
    />
    <circle 
      v-for="point in forecastDroughtPoints"
      :id="point.id"
      :key="point.cx"
      :class="point.class"
      :cx="point.cx"
      :cy="indicatorOffset + (adjustedBarHeight / 2)"
      :r="point.r"
    />
  </g>
</template>

<script setup>
  import { computed, ref, watchEffect } from "vue";
  import { useGlobalDataStore } from "@/stores/global-data-store";
  import { storeToRefs } from "pinia";
  import { timeDay as d3TimeDay } from "d3-time";
  import { select } from "d3-selection";

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
  const globalDataStore = useGlobalDataStore();
  const { selectedWeek } = storeToRefs(globalDataStore);
  const streamflowDroughtsGroup = ref(null);

  const transform = computed(
    () =>
      `translate(${props.layout.margin.left}, ${
        props.layout.height + props.layout.margin.top
      })`,
  );

  const adjustedBarHeight = props.barHeight - props.indicatorOffset
  const streamflowDroughtIntervals = computed(() => {
    return props.streamflowDroughtsData.values.map((drought) => {
      const startX = props.xScale(globalDataStore.getDateAtMidnight(drought.start));
      let endX = props.xScale(globalDataStore.getDateAtMidnight(drought.end));
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
      const droughtDate = globalDataStore.getDateAtMidnight(drought.dt)
      const cx = props.xScale(droughtDate);
      const radius = (props.xScale(d3TimeDay.offset(droughtDate, WIDTH_IN_DAYS)) - props.xScale(droughtDate)) / 2;
      return {
        cx: cx,
        r: radius,
        class: `bar-point point-${drought.drought_cat}`,
        id: `forecast-${drought.dt}`
      };
    });
  })
  const backgroundForecastDroughtPoints = computed(() => {
    return props.forecastDroughtsData.values.map((drought) => {
      const droughtDate = globalDataStore.getDateAtMidnight(drought.dt)
      const cx = props.xScale(droughtDate);
      const radius = (props.xScale(d3TimeDay.offset(droughtDate, WIDTH_IN_DAYS)) - props.xScale(droughtDate)) / 2;
      return {
        cx: cx,
        r: radius,
        class: `bar-point-background point-${drought.drought_cat}`,
        id: `background-forecast-${drought.dt}`
      };
    });
  })

  watchEffect(() => {
    if (streamflowDroughtsGroup.value) {
      // Style forecast point for current date
      select(streamflowDroughtsGroup.value).selectAll(".bar-point-background")
        .style("stroke-width", "1px")
      select(streamflowDroughtsGroup.value).selectAll(".bar-point")
        .style("stroke", "var(--grey_6_1)")
        .on("click", (event) => {
          const elementDate = event.target.id.slice(9)
          const elementWeek = globalDataStore.dateInfoData.find(d => d.dt == elementDate)?.f_w || undefined;
          // Only trigger update to selectedWeek if elementWeek is defined (i.e., site-specific data are up to date and element date is included in current globalDataStore.dateInfoData)
          if (elementWeek) selectedWeek.value = elementWeek;
        })
      const currentBackgroundPoint = select(streamflowDroughtsGroup.value).select(`#background-forecast-${globalDataStore.selectedDate}`)
      if (currentBackgroundPoint.node()) {
        const currentBackgroundPointClassList = currentBackgroundPoint.node().classList
        if (currentBackgroundPointClassList[1].includes('none')) {
          currentBackgroundPoint
            .style("stroke-width", "4.5px")
        } else {
          currentBackgroundPoint
            .style("stroke-width", "5px")
        }      
      }
      const currentPoint = select(streamflowDroughtsGroup.value).select(`#forecast-${globalDataStore.selectedDate}`)
      if (currentPoint.node()) {
        const currentPointClassList = currentPoint.node().classList
        if (currentPointClassList[1].includes('none')) {
          currentPoint
            .style("stroke", "var(--grey_2_1)")
        } else {
          currentPoint
            .style("stroke", "var(--white-soft)")
        }
      }
    }
  });
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
  cursor: pointer;
}
.bar-point-background {
  stroke: var(--grey_17_1);
}
</style>