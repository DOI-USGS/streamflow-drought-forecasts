<template>
  <div>
    <div
      id="faq-button-container"
    >
      <button
        class="faq-button info-button"
        :class="{static: isStatic}"
        :disabled="isStatic"
        @click="showFaqDialog"
      >
        <span
          class="button-icon"
          aria-hidden="true"
          title="View FAQs" 
        />
      </button>
    </div>
  </div>
</template>

<script setup>
  import { storeToRefs } from "pinia";
  import { useGlobalDataStore } from "@/stores/global-data-store";

  const props = defineProps({
    isStatic: {
      type: Boolean,
      default: false,
      required: false,
    },
  })

  // global variables
  const globalDataStore = useGlobalDataStore();
  const { faqDialogShown } = storeToRefs(globalDataStore);

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
  align-items: center;
}
#faq-title-container p {
  padding: 0;
}
</style>