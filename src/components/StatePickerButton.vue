<template>
  <div
    class="picker-container"
  >
    <div 
      class="panel" 
      :class="[{ 'active': pickerActive }]"
    >
      <div
        id="state-button-grid-container"
      >  
        <button
          v-for="item, index in pickerData"
          :key="index"
          class="state-button"
          :class="['row-' + item.row, 'column-' + item.col]"
          @click="updateExtent(item.name)"
        >
          {{ item.code }}
        </button>
      </div>
    </div>
    <button 
      id="select-state" 
      type="button" 
      class="expanding-button" 
      :class="{ active: pickerActive }" 
      title="Select state view" 
      aria-label="Select state view" 
      aria-disabled="false"
      @click="pickerClick"
    >
      <span
        class="mapboxgl-ctrl-icon"
        aria-hidden="true" 
        title="Select state view"
        :style="{ 'background-image': 'url(' + getImageURL('state_map.png') + ')', 'background-size': '20px auto' }"
      />
    </button>    
  </div>
</template>

<script setup>
  import { ref } from "vue";
  import { storeToRefs } from "pinia";
  import { useGlobalDataStore } from "@/stores/global-data-store";
  
  const props = defineProps({
     modelValue: {
        type: String,
        required: true,
        default: ""
    }, // v-model binding for selected value
    pickerData: {
      type: Object,
      default: () => ({}),
      required: true,
    },
  })
  // global variables
  const globalDataStore = useGlobalDataStore();
  const pickerActive = ref(false);
  const { selectedExtent } = storeToRefs(globalDataStore);

  const emit = defineEmits(['update:modelValue']);

  function pickerClick() {
    pickerActive.value = !pickerActive.value
  }

  function updateExtent(newExtent) {    
    emit('update:modelValue', newExtent)
    selectedExtent.value = newExtent;
  }

  function getImageURL(filename) {
    return new URL(`../assets/images/${filename}`, import.meta.url).href
  }
</script>

<style>
.expanding-button {
  float: right;
}
.panel {
  display: none; 
}
.panel.active {
  display: block; 
}
#state-button-grid-container {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr;
  grid-template-rows: 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr;
  margin: 1rem;
}
.state-button {
    background-color: grey;
    border: 0;
    box-sizing: border-box;
    cursor: pointer;
    display: inline;
    height: 29px;
    outline: none;
    overflow: hidden;
    padding: 0;
    width: 29px;
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
.row-8 {
  grid-row: 8;
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
