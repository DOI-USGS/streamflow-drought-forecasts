<template>
  <div id="layers-menu-container">
    <div id="button-container">
      <div id="layers-button-container">
        <button
          id="layers-button"
          type="button"
          class="expanding-button"
          :class="{ active: layersMenuActive }"
          :title="buttonTitle"
          :aria-label="buttonTitle"
          :aria-expanded="layersMenuActive"
          aria-disabled="false"
          @click="layersMenuClick"
        >
          <span
            id="button-svg-container"
            aria-hidden="true"
            :title="buttonTitle"
          >
            <LayersIcon
              class="button-icon"
              aria-hidden="true"
            />
          </span>
        </button>
      </div>
      <div id="close-button-container">
        <CloseButton
          class="panel-close-button"
          :class="{ active: layersMenuActive }"
          :button-title="activeButtonTitle"
          :aria-label="activeButtonTitle"
          @click="layersMenuClick"
        />
      </div>
    </div>
    <div
      class="panel layers-menu"
      :class="{ active: layersMenuActive }"
    >
      <ToggleSwitch
        id="gages-toggle"
        v-model="globalDataStore.showGaged"
        class="menu-toggle"
        title="Show gages"
        label="Gages"
        right-color="var(--black-soft)"
        aria-label="Show gages"
      />
      <ToggleSwitch
        id="watersheds-toggle"
        v-model="globalDataStore.showUngaged"
        class="menu-toggle"
        title="Show watersheds"
        label="Watersheds"
        right-color="var(--black-soft)"
        aria-label="Show watersheds"
      />
    </div>
  </div>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import LayersIcon from '@/assets/svgs/layers_icon.svg'
import CloseButton from './CloseButton.vue'
import ToggleSwitch from './ToggleSwitch.vue'
import { useGlobalDataStore } from '@/stores/global-data-store'

const props = defineProps({
  modelValue: {
    type: Boolean,
    required: true,
    default: false
  } // v-model binding for selected value
})

// global variables
const globalDataStore = useGlobalDataStore()
const layersMenuActive = ref(props.modelValue)
const activeButtonTitle = 'Close layers menu'
const buttonTitle = computed(() => {
  return layersMenuActive.value ? activeButtonTitle : 'View layers menu'
})

const emit = defineEmits(['update:modelValue'])

// When props.modelValue changes, update layersMenuActive
watch(
  () => props.modelValue,
  (newValue) => {
    layersMenuActive.value = newValue
  }
)

function layersMenuClick() {
  layersMenuActive.value = !layersMenuActive.value
  emit('update:modelValue', layersMenuActive.value)
}
</script>

<style scoped lang="scss">
#layers-menu-container {
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
.expanding-button.active span {
  transform: scale(1.1);
}
#button-container {
  display: flex;
  justify-content: space-between;
}
#layers-button-container {
  order: 1;
  @media only screen and (min-width: 641px) {
    order: 2;
  }
}
#layers-button-container #layers-button:focus-visible {
  border-radius: 4px;
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
.menu-toggle {
  font-weight: 300;
}
</style>
