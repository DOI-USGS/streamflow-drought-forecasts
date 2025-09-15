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
            id="button-svg-container"
            aria-hidden="true" 
            :title="buttonTitle"
          >
            <LegendIcon
              class="button-icon"
              aria-hidden="true"
            />
          </span>
        </button>
      </div>  
      <div
        id="close-button-container"
      >
        <CloseButton 
          class="panel-close-button" 
          :class="{ active: legendActive }" 
          :button-title="activeButtonTitle"
          :aria-label="activeButtonTitle"
          @click="legendClick" 
        />
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
        <span :style="{ 'background-color': dataBin.color, 'border-color': dataBin.stroke }" />{{ dataBin.text }}
      </div>
      <div
        v-if="noDataBinShown"
        id="no-data-key"
      >
        <span :style="{ 'background-color': legendNoDataBin.color, 'border-color': legendNoDataBin.stroke }"><img :src="getImageURL('x_icon.png')"></span>{{ legendNoDataBin.text }}
      </div>
    </div> 
  </div>
</template>

<script setup>
  import { computed, ref, watch } from "vue";
  import LegendIcon from "@/assets/svgs/legend_icon.svg"
  import CloseButton from "./CloseButton.vue";

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
  #button-svg-container {
    display: flex;
    align-items: center;
    justify-content: center;
  }
  .button-icon {
    width: 70%;
    height: 70%;
  }
  #close-button-container {
    order: 2;
    @media only screen and (min-width: 641px) {
      order: 1;
    }
  }
  .panel-close-button {
    display: none;
  }
  .panel-close-button.active {
    display: flex;
  }
  .panel {
    display: none; 
    padding: 1rem 30px 1.5rem 30px;
    @media only screen and (min-width: 641px) {
      padding: 1rem 30px 2rem 30px;
    }
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
    border: 1px solid;
  }
  #no-data-key span {
    border: 1px solid;
    position: relative;
    text-align: left;
  }
  #no-data-key span img{
    position: absolute;
    top: 0.5px;
    left: 0.5px;
    width: 7px;
  }
</style>