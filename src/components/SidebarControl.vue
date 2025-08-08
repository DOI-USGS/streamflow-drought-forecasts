<template>
  <div
    id="sidebar-control"
  >
    <h3
      id="showing-statement"
    >
      Showing
      <span
        id="type-text-container"
      >
        <span
          class="type-text left"
          title="observed"
          :class="globalDataStore.dataType == 'Observed' ? 'major-emph' : 'de-emph'"
        >observed
        </span>
        <span
          id="divider"
        >
          |
        </span>
        <span
          class="type-text"
          title="forecast"
          :class="globalDataStore.dataType == 'Forecast' ? 'major-emph' : 'de-emph'"
        >forecast
        </span>
      </span>
      conditions for
    </h3>
    <Slider 
      id="date-slider"
      v-model="selectedWeek"
      :min="Number(globalDataStore.dataWeeks[0])"
      :max="Number(globalDataStore.dataWeeks[globalDataStore.dataWeeks.length - 1])"
      :format="formatTooltip"
      :aria="{ 
        'aria-label': 'Change the date for which streamflow drought conditions are shown' 
      }"
    />
  </div>
</template>

<script setup>
  import Slider from '@vueform/slider';
  import { useGlobalDataStore } from "@/stores/global-data-store";
  import { storeToRefs } from "pinia";

  // Define global variables
  const globalDataStore = useGlobalDataStore();
  const { selectedWeek } = storeToRefs(globalDataStore);

  function formatTooltip(val) {
    const valIndex = globalDataStore.dataWeeks.indexOf(val)
    const dateFormatted = globalDataStore.dataDatesFormatted[valIndex]
    if (val > 1) { 
      return `<span class='slider-date major-emph'>${dateFormatted}</span><br/><span class='slider-horizon de-emph'>${val} weeks out</span>`
    } else if (val === 1 ) {
      return `<span class='slider-date major-emph'>${dateFormatted}</span><br/><span class='slider-horizon de-emph'>${val} week out</span>`
    } else {
      return `<span class='slider-date major-emph'>${dateFormatted}</span><br/><span class='slider-horizon de-emph'>yesterday</span>`
    }
  }
</script>
<style src="@vueform/slider/themes/default.css"></style>
<style lang="scss">
  $slider-date-lineheight-mobile: 1.6rem;
  $slider-horizon-lineheight-mobile: 1.6rem;
  $slider-date-lineheight: 2rem;
  $slider-horizon-lineheight: 2rem;
  #showing-statement {
    padding-top: 0.5rem;
    font-weight: 300;
    @media only screen and (min-width: 641px) {
      padding-top: 1rem;
    }
  }
  .type-text {
    display: inline-block;
    font-style: italic;
  }
  /* pseudo element to prevent shifting */
  // .type-text::before {
  //   display: block;
  //   content: attr(title);
  //   font-weight: 800;
  //   height: 0;
  //   overflow: hidden;
  //   visibility: hidden;
  // }
  .type-text.left {
    text-align: right;
  }
  #divider {
    font-size: 2.5rem;
  }
  #date-slider {
    margin: calc($slider-date-lineheight-mobile + $slider-horizon-lineheight-mobile + 12px) auto 20px auto;
    max-width: 81%;
    --slider-tooltip-bg: var(--color-background);
    --slider-connect-bg: var(--grey_3_1);
    --slider-handle-ring-width: 2px;
    --slider-handle-ring-color: var(--grey_5_1);
    --slider-tooltip-color: var(--color-text);
    --slider-tooltip-arrow-size: 0px;
    --slider-tooltip-distance: 3px;
    --slider-height: 5px;
    @media only screen and (min-width: 641px) {
      margin: calc($slider-date-lineheight + $slider-horizon-lineheight + 12px) auto 20px auto;
      --slider-height: 6px;
    }
  }
  .slider-tooltip {
    padding: 2px 6px 2px 1px;
    font-size: 1.6rem;
    @media only screen and (min-width: 641px) {
      font-size: 2rem;
    }
  }
  .slider-date {
    font-size: 1.6rem;
    line-height: $slider-date-lineheight-mobile;
    @media only screen and (min-width: 641px) {
      font-size: 2rem;
      line-height: $slider-date-lineheight;
    }
  }
  .slider-horizon {
    font-size: 1.4rem;
    line-height: $slider-horizon-lineheight-mobile;
    @media only screen and (min-width: 641px) {
      font-size: 1.6rem;
      line-height: $slider-horizon-lineheight
    }
  }
</style>