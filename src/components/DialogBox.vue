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
      @click="closeDialog()"
    >
      <div
        :id="dialogId"
        ref="target"
        class="dialog"
        role="dialog"
        @click="handleChildClick"
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
            <CloseButton 
              id="dialog-close-button" 
              button-title="Close the dialog" 
              aria-label="Close button"
              button-dim="25px"
              button-svg-dim="25px"
              @click="closeDialog" 
            />
          </div>
        </div>
        <div class="dialog-content">
          <div class="scroll-watcher" />
          <slot name="dialogContent" />
        </div>
      </div>
    </div>  
  </UseFocusTrap>
</template>

<script setup>
  import { nextTick, watch } from 'vue';
  import { UseFocusTrap } from '@vueuse/integrations/useFocusTrap/component';
  import CloseButton from './CloseButton.vue';

  const props = defineProps({
    modelValue: {
      type: Boolean,
      required: true,
      default: false
    }, // v-model binding for selected value
    dialogId: {
      type: String,
      required: true,
      default: ""
    }, // id of dialog, for selection
    tooltipFunction: {
      type: Function,
      required: false,
      default: () => {
        console.log('Default function');
      }
    }
  })

  const emit = defineEmits(['update:modelValue']);

  watch(() => props.modelValue, () => {
    if (props.modelValue == true) {
      watchScroll()
      if (props.tooltipFunction) {
        handleTooltips()
      }
    }
  });

  async function handleTooltips() {
    await nextTick();
    props.tooltipFunction(props.dialogId)
  }

  async function watchScroll() {
    // wait until DOM is updated
    await nextTick();
    const dialog = document.querySelector(`#${props.dialogId}`)
    const header = dialog.querySelector('.dialog-header');
    const scrollWatcher = dialog.querySelector('.scroll-watcher');

    // when scroll watcher leaves viewport, add stuck class to header
    const observer = new IntersectionObserver(([entry]) => {
        if (!entry.isIntersecting) {
          header.classList.add('stuck');
        } else {
          header.classList.remove('stuck');
        }
    });

    observer.observe(scrollWatcher);
  }

  function closeDialog() {
    emit('update:modelValue', false)
  }

  function handleChildClick(event) {
    event.stopPropagation();
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
  display: flex;
  align-items: center;
  @media only screen and (min-width: 641px) {
    width: 100%;
    height: 100%;
  }
}
.dialog {
  display: flex;
  flex-direction: column;
  background-color: var(--color-background);
  border-radius: 4px;
  margin-left: auto;
  margin-right: auto;
  overflow: hidden;
  width: 95vw;
  max-width: 95vw;
  max-height: 95vh;
  @media only screen and (min-width: 641px) {
    width: 75rem;
    max-width: 75rem;
    max-height: 90vh;
  }
}
.dialog-header {
  position: sticky;
  top: 0px;
  z-index: 10;
  background-color: var(--color-background);
  padding-top: 1rem;
  padding-bottom: 0.5rem;
  padding-left: $lr-padding;
  padding-right: $lr-padding;
  display: flex;
  justify-content: space-between;
  transition: box-shadow 0.3s ease-in-out; /* For smooth transition */
  @media only screen and (min-width: 641px) {
    padding-top: 2rem;
    padding-bottom: 1rem;
  }
}
.dialog-header.stuck {
  box-shadow: 0px 5px 4px -4px rgba(0, 0, 0, 0.2); /* Shadow when stuck */
}
.dialog-content {  
  padding-top: 1rem;
  padding-bottom: 2.5rem;
  padding-left: $lr-padding;
  padding-right: $lr-padding;
  height: 100%;
  overflow-y: auto;
  scrollbar-width: thin;
  scrollbar-color: var(--grey_3_1) #FCFCFC;
}
.dialog-close-button-container {
  display: flex;
  justify-content: end;
}
.dialog-close-button-container button {
  margin: 0rem -1.5px 0 0; /* negative margin to align w/ accordion close if accordions are present */
}
</style>