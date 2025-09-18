<template>
  <div>
    <div
      class="picker-container"
    > 
      <div
        id="button-container"
      >
        <div
          id="close-button-container"
        >
          <CloseButton 
            class="panel-close-button" 
            :class="{ active: pickerActive }" 
            :button-title="activeButtonTitle"
            :aria-label="activeButtonTitle"
            @click="pickerClick" 
          />
        </div>
        <button 
          id="select-state-button" 
          type="button" 
          class="expanding-button" 
          :class="{ active: pickerActive, closedWithSelection: stateSelectedAndButtonClosed}" 
          :title="buttonTitle" 
          :aria-label="buttonTitle" 
          :aria-expanded="pickerActive"
          aria-disabled="false"
          @click="pickerClick"
        >
          <span
            class="mapboxgl-ctrl-icon"
            aria-hidden="true" 
            :title="buttonTitle"
            :style="{ 'background-image': 'url(' + getImageURL('state_map.png') + ')', 'background-size': '20px auto' }"
          />
        </button>
      </div>
      <fieldset 
        class="panel" 
        :class="{ active: pickerActive }"
        :aria-expanded="pickerActive"
      >
        <legend>
          <p>Select a state to view</p>
        </legend>
        <div
          id="state-button-grid-container"
          class="radio-group"
          role="radiogroup"
        >  
          <label
            v-for="item in pickerData"
            :id="`label-${item.code}`"
            :key="item.code"
            :for="`input-${item.code}`"
            class="radio-label"
            :class="{ active: item.name === modelValue }"
            :style="{ 'grid-row': item.row, 'grid-column': item.col }"
          >
            <input
              :id="`input-${item.code}`"
              type="radio"
              class="radio-input"
              :value="item.name"
              :checked="modelValue === item.name"
              :aria-checked="modelValue === item.name"
              :aria-label="item.name"
              name="state-button"
              @change="$emit('update:modelValue', item.name)"
            >
            <span
              class="state-button"
              :class="{ active: item.name === modelValue }"
            >
              <span
                aria-hidden="true"
              >
                {{ item.code }}
              </span>
            </span>
          </label>
        </div>
      </fieldset>    
    </div>
  </div>
</template>

<script setup>
  import { computed } from "vue";
  import { storeToRefs } from "pinia";
  import { useGlobalDataStore } from "@/stores/global-data-store";
  import CloseButton from "./CloseButton.vue";
  
  const props = defineProps({
    modelValue: {
      type: [String, null],
      required: true,
      default: null
    }, // v-model binding for selected value
    pickerData: {
      type: Object,
      default: () => ({}),
      required: true,
    },
  })
  // global variables
  const globalDataStore = useGlobalDataStore();
  const { pickerActive } = storeToRefs(globalDataStore);
  const stateSelectedAndButtonClosed = computed(() => {
    return props.modelValue && !pickerActive.value
  })
  const activeButtonTitle = "Close state view menu"
  const buttonTitle = computed(() => {
    return pickerActive.value ? activeButtonTitle : "Select state view"
  })

  const emit = defineEmits(['update:modelValue']);

  function pickerClick() {
    pickerActive.value = !pickerActive.value
  }

  function getImageURL(filename) {
    return new URL(`../assets/images/${filename}`, import.meta.url).href
  }
</script>

<style scoped lang="scss">
#button-container {
  display: flex;
  justify-content: space-between;
}
#select-state-button.closedWithSelection {
  border-radius: 4px;
  box-shadow: 0 0 1px 2px rgba(0,0,0,.5);
}
#select-state-button:focus-visible {
  border-radius: 4px;
}
.expanding-button {
  float: right;
}
#close-button-container {
  display: flex;
  justify-content: end;
}
.panel-close-button {
  display: none;
}
.panel-close-button.active {
  display: flex;
}
.panel {
  display: none; 
  padding: 1rem 30px 1rem 30px;
  border: none;
}
.panel.active {
  display: block; 
}
.panel p {
  font-family: var(--default-font);
  color: var(--color-text);
  font-size: 1.6rem;
  padding-bottom: 1.2rem;
  @media only screen and (min-width: 641px) {
    font-size: 2rem;
    padding-bottom: 1.5rem;
  }
}
#state-button-grid-container {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr;
  grid-template-rows: 1fr 1fr 1fr 1fr 1fr 1fr 1fr;
  gap: 1px;
  padding: 4px;
}
.radio-group:has(:focus-visible) {
  border: 2px solid var(--color-text);
  border-radius: 4px;
  padding: 2px;
  margin: -2px;
}
#state-button-grid-container .radio-input {
  position: absolute;
  left: -9999px;
}
#state-button-grid-container input[type="radio" i]:focus-visible {
  outline: none;
  border: none;
  color: transparent;
}
#state-button-grid-container .state-button {
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: transparent;
  border-radius: 4px;
  border: 1px solid var(--grey_3_1);
  box-sizing: border-box;
  cursor: pointer;
  height: 24px;
  width: 24px;
  outline: none;
  overflow: hidden;
  padding: 0;
  font-size: 1.4rem;
  font-family: var(--default-font);
  font-weight: 400;
  color: var(--color-text);
  @media only screen and (min-width: 641px) {
    font-size: 1.6rem;
    height: 30px;
    width: 30px;
  }
}
#state-button-grid-container .state-button:hover {
  background-color: var(--grey_3_1);
  font-weight: 500;
}
#state-button-grid-container .state-button.active {
  background-color: var(--grey_6_1);
  color: var(--color-background);
  font-weight: 700;
}
#state-button-grid-container input[type="radio" i]:focus-visible + .state-button {
  background-color: var(--grey_3_1);
  font-weight: 500;
}
#state-button-grid-container input[type="radio" i]:focus-visible + .state-button.active {
  background-color: var(--grey_6_1);
  color: var(--color-background);
  font-weight: 700;
}
</style>
