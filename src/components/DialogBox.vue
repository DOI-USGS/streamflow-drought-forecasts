<template>
  <UseFocusTrap
    v-if="modelValue" 
    :options="{ immediate: true }"
  >
    <div
      v-show="modelValue"
      tabindex="-1"
      class="overlay"
      role="none presentation"
      @keydown.esc="closeDialog()"
    >
      <div
        ref="target"
        class="dialog"
        role="dialog"
      >
        <div
          class="dialog-header"
        >
          <div>
            <slot name="dialogTitle" />
          </div>
          <div
            class="dialog-close-button-container"
          >
            <button 
              id="dialog-close-button"
              class="close-button" 
              type="button"
              title="Close the dialog" 
              aria-label="close button"
              @click="closeDialog"
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
        <div class="dialog-content">
          <slot name="dialogContent" />
        </div>
      </div>
    </div>  
  </UseFocusTrap>
</template>

<script setup>
  import { UseFocusTrap } from '@vueuse/integrations/useFocusTrap/component';

  const props = defineProps({
    modelValue: {
      type: Boolean,
      required: true,
      default: false
    }, // v-model binding for selected value
  })

  const emit = defineEmits(['update:modelValue']);

  function closeDialog() {
    emit('update:modelValue', false)
  }
</script>
<style scoped lang="scss">
$lr-padding: 2.5rem;
.overlay {
  background-color: rgba(0, 0, 0, 0.5);
  height: 100vh;
  position: fixed;
  top: 0px;
  right: 0px;
  bottom: 0px;
  left: 0px;
  width: 100vw;
  z-index: 10;
  @media only screen and (min-width: 641px) {
    width: 100%;
    height: 100%;
  }
}
.dialog {
  background-color: var(--color-background);
  border-radius: 4px;
  margin-left: auto;
  margin-right: auto;
  padding-left: $lr-padding;
  padding-right: $lr-padding;
  overflow-y: auto;
  scrollbar-width: thin;
  scrollbar-color: var(--grey_3_1) #FCFCFC;
  margin-top: 2.5vh;
  width: 95vw;
  max-width: 95vw;
  max-height: 95vh;
  @media only screen and (min-width: 641px) {
    margin-top: 5vh;
    width: 75rem;
    max-width: 75rem;
    max-height: 90vh;
  }
}
.dialog-header {
  padding-top: 2rem;
  padding-bottom: 1rem;
  display: flex;
  justify-content: space-between;
}
.dialog-content {  
  padding-top: 1rem;
  padding-bottom: 2.5rem;
}
.dialog-close-button-container {
  display: flex;
  justify-content: end;
}
.dialog-close-button-container button {
  display: flex;
  align-items: center;
  justify-content: center;
  border: none;
  height: 25px;
  width: 25px;
  background: transparent;
  margin: 0rem -2.5px 0 0; /* negative margin to align w/ accordion close if accordions are present */
}
.symbol {
  display: flex;
  align-items: center;
}
.symbol svg {
  width: 25px;
  height: 25px;
  transform: rotate(45deg);
}
.symbol-line {
  stroke: var(--color-text);
  stroke-width: 0.8px;
}
</style>