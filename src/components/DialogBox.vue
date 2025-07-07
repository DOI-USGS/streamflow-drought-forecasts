<template>
  <div
    v-show="modelValue"
    tabindex="-1"
    class="overlay"
    role="none presentation"
    @keydown.esc="closeDialog()"
  >
    <div
      class="dialog"
      role="dialog"
      aria-labelledby="dialogTitle"
    >
      <header>
        <div
          id="dialog-close-button-container"
        >
          <button 
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
      </header>
      <section class="dialog__content">
        <slot name="dialogContent">
          <!-- Dialog content -->
        </slot>
      </section>
    </div>
  </div>
</template>

<script setup>

  const props = defineProps({
    modelValue: {
      type: Boolean,
      required: true,
      default: false
    }, // v-model binding for selected value
  })

  const emit = defineEmits(['update:modelValue']);

  function closeDialog() {
    console.log('closing dialog')
    emit('update:modelValue', false)
  }
</script>
<style>

.overlay {
  background-color: rgba(0, 0, 0, 0.5);
  height: 100%;
  position: fixed;
  top: 0px;
  right: 0px;
  bottom: 0px;
  left: 0px;
  width: 100%;
  z-index: 10;
}
.dialog {
  background-color: var(--color-background);
  border-radius: 0.75rem;
  overflow: hidden;
  margin-left: auto;
  margin-right: auto;
  margin-top: 2.5rem;
  width: 75rem;
  max-width: 75rem;
  max-height: 90%;
}
.dialog__content {  
  padding: 2.5rem 2.5rem 2.5rem 2.5rem;
}
#dialog-close-button-container {
  display: flex;
  justify-content: end;
}
#dialog-close-button-container button {
  display: flex;
  align-items: center;
  justify-content: center;
  border: none;
  height: 29px;
  width: 29px;
  background: transparent;
  margin: 0.5rem 0.5rem 0 0;
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
</style>