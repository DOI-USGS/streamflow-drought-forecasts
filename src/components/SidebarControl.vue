<template>
  <div
    id="sidebar-control"
  >
    <div
      id="showing-statement-container"
    >
      <h3
        v-if="!controlMinimized"
        class="showing-statement"
      >
        Showing
        <span
          id="type-text-container"
        >
          <button
            :disabled="globalDataStore.dataType == 'Observed'"
            class="type-text type-button left"
            title="Show observed conditions"
            :class="globalDataStore.dataType == 'Observed' ? 'major-emph' : 'de-emph'"
            @click="updateWeek(0)"
          >observed
          </button>
          <span
            class="divider"
          >
            |
          </span>
          <button
            :disabled="globalDataStore.dataType == 'Forecast'"
            class="type-text type-button"
            title="Show 1-week forecast"
            :class="globalDataStore.dataType == 'Forecast' ? 'major-emph' : 'de-emph'"
            @click="updateWeek(1)"
          >forecast
          </button>
        </span>
        conditions for
      </h3>
      <h3
        v-if="controlMinimized"
        class="showing-statement"
      >
        Showing
        <span
          class="type-text major-emph"
        >{{ globalDataStore.dataType.toLowerCase() }}
        </span>
        conditions for
        <span
          class="major-emph"
        >{{ globalDataStore.selectedDateFormatted }}
        </span>
        <span
          class="divider placeholder"
        >
          |
        </span>
      </h3>
      <button
        id="control-toggle-button" 
        type="button"
        :title="controlTitle"
        :aria-label="controlTitle"
        aria-disabled="false"
        @click="toggleControl"
      >
        <span 
          id="toggle-button-icon"
          aria-hidden="true"
          :title="controlTitle"
          :style="{ 'background-image': 'url(' + imgSrc + ')', 'background-size': imgSize + ' auto' }"
        />
      </button>
    </div>
    <Slider 
      v-if="!controlMinimized"
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
  import { computed, ref, watch } from 'vue';
  import Slider from '@vueform/slider';
  import { useGlobalDataStore } from "@/stores/global-data-store";
  import { storeToRefs } from "pinia";
  import { useScreenCategory } from "@/assets/scripts/composables/media-query";

  // Define global variables
  const globalDataStore = useGlobalDataStore();
  const screenCategory = useScreenCategory();
  const { selectedWeek } = storeToRefs(globalDataStore);
  const { selectedSite } = storeToRefs(globalDataStore);
  const { selectedExtent } = storeToRefs(globalDataStore);
  const controlMinimized = ref(false);
  const controlTitle = computed(() => { 
    return controlMinimized.value ? 'Expand date slider' : 'Collapse date slider'; 
  })
  const imgSrc = computed(() => {
    return controlMinimized.value ? getImageURL("expand_icon.png") : getImageURL("collapse_icon.png");
  })
  const imgSize = computed(() => {
    return screenCategory.value == 'phone' ? "16px" : "18px";
  })

  watch(selectedSite, (newValue, oldValue) => {
    if (newValue == null) {
      controlMinimized.value = false;
    }
    if (oldValue == null) {
      controlMinimized.value = false;
    }
  });
  watch(selectedExtent, () => {
    controlMinimized.value = false;
  });

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

  function toggleControl() {
    controlMinimized.value = !controlMinimized.value;
  }

  function updateWeek(week) {
    selectedWeek.value = week;
  }

  function getImageURL(filename) {
    return new URL(`../assets/images/${filename}`, import.meta.url).href
  }
</script>
<style src="@vueform/slider/themes/default.css"></style>
<style lang="scss">
  $slider-date-lineheight-mobile: 1.6rem;
  $slider-horizon-lineheight-mobile: 1.6rem;
  $slider-date-lineheight: 2rem;
  $slider-horizon-lineheight: 2rem;
  #showing-statement-container {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
  }
  .showing-statement {
    padding: 0.75rem 0 0.75rem 0;
    font-weight: 300;
    line-height: 2.6rem;;
    @media only screen and (min-width: 641px) {
      padding: 1rem 0 1rem 0;
      line-height: 3.2rem;
    }
  }
  .type-button {
    background-color: transparent;
    border: none;
    padding: 0;
    cursor: pointer;
  }
  .type-button:disabled {
    color: var(--color-text);
    cursor: not-allowed;
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
  .divider {
    font-size: 2rem;
    @media only screen and (min-width: 641px) {
      font-size: 2.5rem;
    }
  }
  .divider.placeholder {
    color: var(--color-background)
  }
  #control-toggle-button {
    background-color: transparent;
    border: none;
    cursor: pointer;
    padding: 0;
    height: 20px;
    width: 20px;
    @media only screen and (min-width: 641px) {
      height: 25px;
      width: 25px;
    }
  }
  #toggle-button-icon {
    background-position: 50%;
    background-repeat: no-repeat;
    display: block;
    height: 100%;
    width: 100%;
    opacity: 0.55;
  }
  #date-slider {
    margin: calc($slider-date-lineheight-mobile + $slider-horizon-lineheight-mobile + 8px) auto 25px auto;
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
      margin: calc($slider-date-lineheight + $slider-horizon-lineheight + 7px) auto 20px auto;
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