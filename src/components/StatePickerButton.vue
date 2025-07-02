<template>
  <div
    class="picker-container"
  >
    <div 
      class="panel" 
      :class="[{ 'active': pickerActive }]"
    >
      <p>
        this is the panel
      </p>
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
  import { ref, watch } from "vue";
  
  const props = defineProps({
    modelValue: {
        type: Boolean,
        required: true,
        default: null
    }, // v-model binding for active state
    // pickerActive: Boolean,
  })
  // global variables
  const pickerActive = ref(props.modelValue)

  // When props.modelValue changes, update selected option
//   watch(() => props.pickerActive, (newValue) => {
//     active.value = newValue;
//   })
  watch(() => props.modelValue, (newValue) => {
    pickerActive.value = newValue;
  })

  defineEmits(['update:modelValue']);

  function pickerClick() {
    pickerActive.value = !pickerActive.value
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
</style>
