<template>
  <div>
    <div
      class="picker-container"
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
      <div 
        class="panel" 
        :class="{ active: pickerActive }"
      >
        <p>Select a state to view</p>
        <div
          id="state-button-grid-container"
        >  
          <button
            v-for="item, index in pickerData"
            :key="index"
            type="button"
            class="state-button"
            :class="['row-' + item.row, 'column-' + item.col, item.name == selectedExtent ? 'active' : ''] "
            @click="updateExtent(item.name)"
          >
            {{ item.code }}
          </button>
        </div>
      </div>
      <button 
        id="select-state-button" 
        type="button" 
        class="expanding-button" 
        :class="{ active: pickerActive, closedWithSelection: stateSelectedAndButtonClosed}" 
        :title="buttonTitle" 
        :aria-label="buttonTitle" 
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
  </div>
</template>

<script setup>
  import { computed, ref } from "vue";
  import { storeToRefs } from "pinia";
  import { useGlobalDataStore } from "@/stores/global-data-store";
  import CloseButton from "./CloseButton.vue";
  
  const props = defineProps({
    modelValue: {
      type: String,
      required: true,
      default: "null"
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
  const { selectedExtent } = storeToRefs(globalDataStore);
  const stateSelectedAndButtonClosed = computed(() => {
    return props.modelValue != "null" && !pickerActive.value
  })
  const activeButtonTitle = "Close state view menu"
  const buttonTitle = computed(() => {
    return pickerActive.value ? activeButtonTitle : "Select state view"
  })

  const emit = defineEmits(['update:modelValue']);

  function pickerClick() {
    pickerActive.value = !pickerActive.value
  }

  function updateExtent(newExtent) {    
    emit('update:modelValue', newExtent)
    selectedExtent.value = newExtent;
    // close picker
    pickerActive.value = false;
  }

  function getImageURL(filename) {
    return new URL(`../assets/images/${filename}`, import.meta.url).href
  }
</script>

<style scoped lang="scss">
#select-state-button.closedWithSelection {
  border-radius: 4px;
  box-shadow: 0 0 0 2px rgba(0,0,0,.3);
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
}
#state-button-grid-container button {
  background-color: var(--color-background);
  border-radius: 4px;
  border: 1px solid var(--grey_3_1);
  box-sizing: border-box;
  cursor: pointer;
  display: inline;
  height: 24px;
  outline: none;
  overflow: hidden;
  padding: 0;
  width: 24px;
  font-size: 1.4rem;
  font-family: var(--default-font);
  font-weight: 400;
  @media only screen and (min-width: 641px) {
    font-size: 1.6rem;
    height: 30px;
    width: 30px;
  }
}
#state-button-grid-container button:hover {
  background-color: var(--grey_3_1);
  font-weight: 500;
}
#state-button-grid-container button.active {
  background-color: var(--grey_6_1);
  color: var(--color-background);
  font-weight: 600;
}
.row-1 {
  grid-row: 1;
}
.row-2 {
  grid-row: 2;
}
.row-3 {
  grid-row: 3;
}
.row-4 {
  grid-row: 4;
}
.row-5 {
  grid-row: 5;
}
.row-6 {
  grid-row: 6;
}
.row-7 {
  grid-row: 7;
}
.column-1 {
  grid-column: 1;
}
.column-2 {
  grid-column: 2;
}
.column-3 {
  grid-column: 3;
}
.column-4 {
  grid-column: 4;
}
.column-5 {
  grid-column: 5;
}
.column-6 {
  grid-column: 6;
}
.column-7 {
  grid-column: 7;
}
.column-8 {
  grid-column: 8;
}
.column-9 {
  grid-column: 9;
}
.column-10 {
  grid-column: 10;
}
.column-11 {
  grid-column: 11;
}
</style>
