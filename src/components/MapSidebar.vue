<template>
  <section>
    <div
      ref="wrapper"
      class="sidebar"
    >
      <div
        id="upper-section"
      >
        <h2>
          <span
            class="major-emph"
          >
            Streamflow drought
          </span>
          conditions
        </h2>
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
      <div
        id="lower-section"
      >
        <ExtentSummary 
          v-if="!globalDataStore.selectedSite"
        />
        <SiteSummary
          v-if="globalDataStore.selectedSite"
          :container-width="wrapperSize.width"
        />  
      </div>
    </div>
  </section>
</template>

<script setup>
  import { useElementSize } from "@vueuse/core";
  import { useTemplateRef } from 'vue';
  import Slider from '@vueform/slider';
  import { storeToRefs } from "pinia";
  import { useGlobalDataStore } from "@/stores/global-data-store";
  import ExtentSummary from './ExtentSummary.vue';
  import SiteSummary from './SiteSummary.vue';

  // Define global variables
  const globalDataStore = useGlobalDataStore();
  const { selectedWeek } = storeToRefs(globalDataStore);
  const wrapper = useTemplateRef('wrapper');
  const wrapperSize = useElementSize(wrapper);

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
$slider-date-lineheight: 2rem;
$slider-horizon-lineheight: 2rem;
  .sidebar {
    display: flex;
    flex-direction: column;
    padding: 2rem 2rem 2rem 2rem; /* reduce on right if scroll needed? */
    position: absolute;
    left: 10px;
    top: 10px;
    width: 500px;
    max-width: 500px;
    max-height: calc(100% - 20px);
    overflow: hidden;
    white-space: wrap;
    background: var(--color-background);  
    border-radius: 5px;
    box-shadow: 0 1px 2px rgba(0, 0, 0, 0.2);
    z-index: 5;
  }
  #upper-section {
    border-bottom: solid 1px var(--dark-grey);
    padding: 0 1rem 1rem 1rem;
    margin: 0 -1rem 2rem -1rem;
  }
  #showing-statement {
    padding: 2rem 0 0.5rem 0;
    font-weight: 300;
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
    margin: calc($slider-date-lineheight + $slider-horizon-lineheight + 20px) auto 20px auto;
    max-width: 82%;
    --slider-tooltip-bg: var(--color-background);
    --slider-connect-bg: var(--grey_3_1);
    --slider-handle-ring-width: 2px;
    --slider-handle-ring-color: var(--grey_5_1);
    --slider-tooltip-color: var(--color-text);
    --slider-tooltip-arrow-size: 0px;
    --slider-tooltip-distance: 3px;
  }
  .slider-date {
    font-size: 2.0rem;
    line-height: $slider-date-lineheight;
  }
  .slider-horizon {
    font-size: 1.6rem;
    line-height: $slider-horizon-lineheight;
  }
  #lower-section {
    max-width: 100%;
    overflow-y: auto;
    scrollbar-width: thin;
    scrollbar-color: var(--grey_3_1) #FCFCFC;
  }
</style>