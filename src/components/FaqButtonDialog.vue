<template>
  <div>
    <div
      id="faq-button-container"
    >
      <button
        class="faq-button info-button"
        @click="showFaqDialog"
      >
        <span
          class="button-icon"
          aria-hidden="true"
          title="View FAQs" 
        />
      </button>
    </div>
    <DialogBox
      v-model="faqDialogShown"
    >
      <template #dialogTitle>
        <div
          id="faq-title-container"
        >
          <div
            class="faq-button info-button static"
          >
            <span
              class="button-icon"
              aria-hidden="true"
            />
          </div>
          <p>{{ text.title }}</p>
        </div>
      </template>
      <template #dialogContent>
        <CollapsibleAccordion 
          v-for="item, index in text.accordionData"
          :key="index"
          :heading="item.heading"
          :content="item.content"
          :active-on-load="item.activeOnLoad"
          left-border-color="var(--usgs-blue_3_1)"
          button-active-background-color="var(--extremely-faded-usgs-blue)"
          button-inactive-background-color="var(--color-background)"
          button-font-weight="300"
          button-font-color="var(--usgs-blue)"
        />
      </template>
    </DialogBox>
  </div>
</template>

<script setup>
  import { ref } from 'vue';
  import DialogBox from './DialogBox.vue';
  import CollapsibleAccordion from './CollapsibleAccordion.vue';

  const props = defineProps({
    text: {
      type: Object,
      default: () => ({}),
      required: true,
    },
  })

  // global variables
  const faqDialogShown = ref(false);

  function showFaqDialog() {
    faqDialogShown.value = true;
  }
</script>

<style>
#faq-button-container {
  display: flex;
  align-items: center;
}
.faq-button {
  background-image: url("data:image/svg+xml;charset=utf-8,%3Csvg viewBox='0 0 20 20' xmlns='http://www.w3.org/2000/svg' fill-rule='evenodd'%3E%3Cpath d='M4 10a6 6 0 1 0 12 0 6 6 0 1 0-12 0m5-3a1 1 0 1 0 2 0 1 1 0 1 0-2 0m0 3a1 1 0 1 1 2 0v3a1 1 0 1 1-2 0'/%3E%3C/svg%3E");
}
.faq-button .button-icon {
  background-position: 50%;
  background-repeat: no-repeat;
  display: block;
  height: 100%;
  width: 100%;
}
#faq-title-container {
  display: flex;
  gap: 1rem;
}
</style>