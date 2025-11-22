<template>
  <div
    id="sidebar-control"
  >
    <div
      id="showing-statement-container"
    >
      <button
        id="control-toggle-button" 
        type="button"
        :title="controlTitle"
        :aria-label="controlTitle"
        :aria-expanded="!controlMinimized"
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
      <div
        id="intro-text-container"
      >
        <h3
          v-if="!controlMinimized"
          class="showing-statement"
          role="presentation"
        >
          Showing
          <span
            class="major-emph"
            role="presentation"
          >{{ globalDataStore.dataType.toLowerCase() }}
          </span>
          conditions for
        </h3>
        <h3
          v-if="controlMinimized"
          class="showing-statement"
          role="presentation"
        >
          Showing
          <span
            class="type-text major-emph"
            role="presentation"
          >{{ globalDataStore.dataType.toLowerCase() }}
          </span>
          conditions for
          <span
            class="major-emph"
            role="presentation"
          >{{ globalDataStore.selectedDateFormatted }}
          </span>
        </h3>
      </div>
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
  import { computed, nextTick, onMounted, ref, watch } from 'vue';
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
  const ariaValuetext = computed(() => {
    const valIndex = globalDataStore.dataWeeks.indexOf(selectedWeek.value)
    const dateFormatted = globalDataStore.dataDatesFormatted[valIndex]
    const preface = `Showing ${globalDataStore.dataType} streamflow drought conditions for`
    if (selectedWeek.value > 1) { 
      return `${preface} ${dateFormatted}, which is ${selectedWeek.value} weeks out`
    } else if (selectedWeek.value === 1 ) {
      return `${preface} ${dateFormatted}, which is ${selectedWeek.value} week out`
    } else {
      return `${preface} ${dateFormatted}, which is yesterday`
    }
  })

  onMounted(async () => {
    await nextTick();
    // update aria-valuetext
    const sliderHandle = document.querySelector('.slider-handle')
    sliderHandle.setAttribute('aria-valuetext', ariaValuetext.value)
    addSliderTicks(globalDataStore.dataWeeks.length)
  })

  watch(selectedSite, (newValue, oldValue) => {
    if (newValue == null) {
      resetControl()
    }
    if (oldValue == null) {
      resetControl()
    }
  });
  watch(selectedExtent, () => {
    resetControl()
  });
  watch(selectedWeek, () => {
    // update aria-valuetext
    const sliderHandle = document.querySelector('.slider-handle')
    sliderHandle.setAttribute('aria-valuetext', ariaValuetext.value)
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

  function addSliderTicks(nTicks) {
    const slider = document.querySelector('.slider-connects')
    const tickDiv = document.createElement("div");
    tickDiv.id = "slider-tick-container"
    slider.appendChild(tickDiv);
    for (let i = 0; i < nTicks; i++) {      
      const tickSpan = document.createElement("span")
      tickDiv.appendChild(tickSpan);
    }
  }

  function toggleControl() {
    if (controlMinimized.value == true) {
      resetControl();
    } else {
      controlMinimized.value = true;
    }
  }

  async function resetControl() {
    controlMinimized.value = false;
    await nextTick();
    addSliderTicks(globalDataStore.dataWeeks.length)
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
  $slider-height-desktop: 6px;
  $slider-height-mobile: 5px;
  #showing-statement-container {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
  }
  #control-toggle-button {
    order: 2;
  }
  #intro-text-container {
    order: 1;
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
    --slider-handle-shadow: 0px 0px 2px 1px rgba(0,0,0,.5);
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
      line-height: $slider-horizon-lineheight;
    }
  }
  #slider-tick-container {
    display: flex;
    justify-content: space-between;
    align-items: center;
    height: $slider-height-mobile;
    @media only screen and (min-width: 641px) {
      height: $slider-height-desktop;
    }
  }
  #slider-tick-container span {
    border-radius: 50%;
    height: $slider-height-mobile * 0.8;
    width: $slider-height-mobile * 0.8;
    border: 0.5px solid var(--grey_3_1);
    background-color: var(--near-white);
    z-index: 10;
    cursor: pointer;
    @media only screen and (min-width: 641px) {
      height: $slider-height-desktop * 0.8;
      width: $slider-height-desktop * 0.8;
    }
  }
</style>