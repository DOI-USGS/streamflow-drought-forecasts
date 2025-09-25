<template>
  <div>
    <DialogBox
      v-model="faqDialogShown"
      dialog-id="faq-dialog"
    >
      <template #dialogTitle>
        <div
          id="faq-title-container"
        >
          <FaqButton
            :is-static="true"
            aria-hidden="true"
          />
          <p>{{ text.faqs.title }}</p>
        </div>
      </template>
      <template #dialogContent>
        <CollapsibleAccordion 
          v-for="item, index in text.faqs.accordionData"
          :key="index"
          class="faq-accordion"
          :accordion-id="`accordion-${index}`"
          :heading="item.heading"
          :content="item.content"
          :active-on-load="item.activeOnLoad"
          left-border-color="var(--usgs-blue_3_1)"
          button-active-background-color="var(--extremely-faded-usgs-blue)"
          button-inactive-background-color="var(--color-background)"
          button-font-weight="300"
          button-font-color="var(--usgs-blue)"
          :tooltip-function="globalDataStore.positionTooltips"
        />
      </template>
    </DialogBox>
  </div>
</template>

<script setup>
  import { storeToRefs } from "pinia";
  import { useGlobalDataStore } from "@/stores/global-data-store";
  import DialogBox from './DialogBox.vue';
  import FaqButton from "./FaqButton.vue";
  import CollapsibleAccordion from './CollapsibleAccordion.vue';  
  import text from "@/assets/text/text.js";

  // global variables
  const globalDataStore = useGlobalDataStore();
  const { faqDialogShown } = storeToRefs(globalDataStore);
</script>

<style>
#faq-title-container {
  display: flex;
  gap: 1rem;
  align-items: center;
}
#faq-title-container p {
  padding: 0;
}
#faq-dialog .faq-accordion p {
  line-height: 1.3;
}
.hydro-icon svg path{
  fill: var(--usgs-blue);
}
.hydro-icon svg polygon{
  fill: var(--medium-blue);
}
</style>