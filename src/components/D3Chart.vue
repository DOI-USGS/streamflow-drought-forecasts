<template>
  <div>
    <slot name="chartTitle" />
    <div
      :id="`${chartIdPrefix}-chart-container`"
      class="chart-container"
    >
      <svg
        ref="mainSvg"
        :tabindex="focusable"
        xmlns="http://www.w3.org/2000/svg"
        class="chart-svg"
        :viewBox="graphViewBox"
        :aria-describedby="`${chartIdPrefix}-chart-desc`"
        :aria-labelledby="`${chartIdPrefix}-chart-title`"
      >
        <title :id="`${chartIdPrefix}-chart-title`">
          {{ chartTitle }}
        </title>
        <desc :id="`${chartIdPrefix}-chart-desc`">
          {{ chartDescription }}
        </desc>
        <clipPath
          :id="`${chartIdPrefix}-chart-clip`"
          class="chart-clip"
        >
          <rect 
            x="0"
            y="0"
            :width="layout.width"
            :height="layout.height"
          />
        </clipPath>
        <slot name="renderedContent" />
      </svg>
    </div>
  </div>
</template>

<script setup>
  import { computed, ref } from 'vue'

  /*
    * @vue-slot - graphTitle - used to render a title on the graph which will appear at the top
    * @vue-slot - renderedContent - used to render the chart and other elements within the chart.
    * @vue-prop {String} chartIdPrefix - unique id for this chart. It will be prepended to
    *    elements that require an id set as the mask definitions.
    * @vue-prop {Object} layout - describes layout of the graph's layout
    *    @prop {Number} height
    *    @prop {Number} weight
    *    @prop {Number} margin - Object with top, right, bottom, left Number properties
    * @vue-prop {Boolean} showWatermark - set to true if the USGS watermark should be rendered. Defaults to false
    * @vue-prop {String} chartTitle - descriptive title for the SVG used for screen readers
    * @vue-prop {String} chartDescription - description for the SVG used for screen readers
    * @vue-prop {Boolean} enableFocus - set to false if the graph has no user interaction.
  */
  const props = defineProps({
    chartIdPrefix: {
        type: String,
        required: true,
    },
    layout: {
      type: Object,
      required: true,
    },
    chartTitle: {
        type: String,
        required: true,
    },
    chartDescription: {
        type: String,
        required: true,
    },
    enableFocus: {
        type: Boolean,
        default: true,
    },
  });
  console.log(props)

  // global variables
  const mainSvg = ref(null);
  const focusable = computed(() => (props.enableFocus ? "0" : undefined));
  const graphViewBox = computed(() => {
    const viewBoxWidth =
        props.layout.width + props.layout.margin.left + props.layout.margin.right;
    const viewBoxHeight =
        props.layout.height + props.layout.margin.top + props.layout.margin.bottom;
    return `0 0 ${viewBoxWidth} ${viewBoxHeight}`;
  });

</script>

<style lang="scss">
  .time-series-container {
    position: relative;
  }
</style>