<template>
  <div
    id="expanding-legend-container"
  >
    <div
      id="button-container"
    >
      <div
        id="legend-button-container"
      >
        <button 
          id="legend-button" 
          type="button" 
          class="expanding-button" 
          :class="{ active: legendActive }" 
          :title="buttonTitle" 
          :aria-label="buttonTitle" 
          aria-disabled="false"
          @click="legendClick"
        >
          <span
            aria-hidden="true" 
            :title="buttonTitle"
          >
            <IntermittentIcon
              class="button-icon"
              aria-hidden="true"
            />
          </span>
        </button>
      </div>  
      <div
        id="close-button-container"
      >
        <button 
          class="panel-close-button" 
          type="button"
          :title="activeButtonTitle" 
          :aria-label="activeButtonTitle"
          :class="{ active: legendActive }" 
          @click="legendClick"
        >
          <span 
            class="symbol"
          >
            <svg 
              xmlns="http://www.w3.org/2000/svg"
              viewBox="0 0 20 20"
            >
              <line 
                class="symbol-line"
                x1="10"
                y1="1"
                x2="10"
                y2="19"
              />
              <line
                class="symbol-line"
                x1="19"
                y1="10"
                x2="1"
                y2="10"
              />
            </svg>  
          </span>
        </button>
      </div>
    </div>  
    <div 
      class="panel legend" 
      :class="{ active: legendActive }"
    >
      <p 
        id="legend-title" 
        v-text="legendTitle" 
      />
      <div
        v-for="dataBin, index in orderedLegendBins"
        :key="index"
      >
        <span :style="{ 'background-color': dataBin.color }" />{{ dataBin.text }}
      </div>
      <div
        v-if="noDataBinShown"
        id="no-data-key"
      >
        <span :style="{ 'background-color': legendNoDataBin.color }" />{{ legendNoDataBin.text }}
      </div>
    </div> 
  </div>
</template>

<script setup>
  import { computed, ref, watch } from "vue";
  import IntermittentIcon from "@/assets/svgs/intermittent.svg";

  const props = defineProps({
    modelValue: {
      type: Boolean,
      required: true,
      default: false
    }, // v-model binding for selected value
    legendTitle: {
      type: String,
      default: "Key",
      required: true
    },
    legendDataBins: {
      type: Object,
      default: () => ({}),
      required: true,
    }, // must have fields of 'color' and 'text'
    reverseDataBins: {
      type: Boolean,
      default: false,
      required: false
    },
    legendNoDataBin: {
      type: Object,
      default: () => ({}),
      required: true,
    },
    noDataBinShown: {
      type: Boolean,
      default: false,
      required: true
    }
  })
  
  // global variables
  const legendActive = ref(props.modelValue);
  const activeButtonTitle = "Close legend"
  const orderedLegendBins = computed(() => {
    console.log(props.legendDataBins)
    return props.reverseDataBins ? props.legendDataBins.slice().reverse() : props.legendDataBins;
  })
  const buttonTitle = computed(() => {
    return legendActive.value ? activeButtonTitle : "View legend"
  })

  const emit = defineEmits(['update:modelValue']);

  // When props.modelValue changes, update legendActive
  watch(() => props.modelValue, (newValue) => {
    legendActive.value = newValue;
  })

  function legendClick() {
    legendActive.value = !legendActive.value;
    emit('update:modelValue', legendActive.value)
  }

  function getImageURL(filename) {
    return new URL(`../assets/images/${filename}`, import.meta.url).href
  }
</script>

<style scoped lang="scss">
  #expanding-legend-container {
    font-family: var(--default-font);
    font-size: 1.6rem;
    line-height: 1.2;
    @media only screen and (min-width: 641px) {
      font-size: 2rem;
    }
  }
  .expanding-button {
    background-color: transparent;
    height: 29px;
    width: 29px;
    border: 0;
    @media only screen and (min-width: 641px) {
      float: right;
    }
  }
  .button-icon {
    width: 100%;
    height: 100%;
  }
  #button-container {
    display: flex;
    justify-content: space-between;
  }
  #legend-button-container {
    order: 1;
    @media only screen and (min-width: 641px) {
      order: 2;
    }
  }
  #close-button-container {
    order: 2;
    @media only screen and (min-width: 641px) {
      order: 1;
    }
  }
  #close-button-container button {
    display: flex;
    align-items: center;
    justify-content: center;
    display: none;
    height: 29px;
    width: 29px;
    background-color: transparent;
    border: 0;
    padding: 0;
  }
  #close-button-container button.active {
    display: flex;
  }
  .symbol {
    display: flex;
    align-items: center;
  }
  .symbol svg {
    width: 22px;
    height: 22px;
    transform: rotate(45deg);
  }
  .symbol-line {
    stroke: var(--color-text);
    stroke-width: 0.8px;
  }
  .panel {
    display: none; 
    padding: 1rem 30px 1rem 1rem;
  }
  .panel.active {
    display: block; 
  }
  .legend {
    font-weight: 300;
  }
  .legend #legend-title {
    font-weight: 500;
  }
  .legend div span {
    border-radius: 50%;
    display: inline-block;
    height: 10px;
    margin-right: 5px;
    width: 10px;
    border: 1px solid #1A1A1A;
  }
  #no-data-key span {
    border: 0.75px solid #878787;
  }
</style>