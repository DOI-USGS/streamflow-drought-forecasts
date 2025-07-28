<template>
  <div>
    <DialogBox
      v-model="titleDialogShown"
    >
      <template #dialogTitle>
        <div
          id="logo-container"
        >
          <img 
            id="logo-image" 
            :src="getImageURL('2021_usgs-logo-sub-black.png')"
          >
        </div>
      </template>  
      <template #dialogContent>
        <div
          id="site-info-container"
        >
          <div
            id="title-container"
          >
            <h1 v-html="text.siteInfo.title" />
          </div>
          <div
            id="about-container"
          >
            <p v-html="text.siteInfo.about1" />
            <p v-html="text.siteInfo.about2" />
          </div>
          <div
            id="title-dialog-button-container"
          >
            <button
              id="access-button"
              class="title-dialog-button"
              title="Use the tool"
              @click="hideTitleDialog"
            >
              Get started
            </button>
            <button
              id="more-button"
              class="title-dialog-button"
              title="View FAQs"
              @click="showFaqDialog"
            >
              <div
                id="more-button-content"
              >         
                <span>Learn more</span>
                <FaqButton 
                  :is-static="true"
                />
              </div>
            </button>
          </div>
        </div>
      </template>
    </DialogBox>
  </div>
</template>

<script setup>
  import { storeToRefs } from "pinia";
  import DialogBox from './DialogBox.vue';
  import FaqButton from './FaqButton.vue';
  import text from "@/assets/text/text.js";
  import { useGlobalDataStore } from "@/stores/global-data-store";

  // global variables
  const globalDataStore = useGlobalDataStore();  
  const { titleDialogShown } = storeToRefs(globalDataStore);
  const { faqDialogShown } = storeToRefs(globalDataStore);

  function hideTitleDialog() {
    titleDialogShown.value = false;
  }

  function showFaqDialog() {
    titleDialogShown.value = false;
    faqDialogShown.value = true;
  }

  function getImageURL(filename) {
    return new URL(`../assets/images/${filename}`, import.meta.url).href
  }
</script>

<style scoped lang="scss">
  #site-info-container p {
    font-weight: 400;
    padding-bottom: 2rem;
  }
  #site-info-container hr {
    margin: 1rem 0 1rem 0;
  }
  #title-container {
    text-align: center;
    margin: 1.5rem 0 4rem 0;
  }
  #about-container {
    margin: auto;
    text-align: center;
  }
  #logo-image {
    height: 45px;
  }
  #title-dialog-button-container {
    margin: 2rem 0 4rem 0;
    text-align: center;
  }
  .title-dialog-button {
    border-radius: 4px;
    border: 2px solid var(--usgs-blue);
    cursor: pointer;
    box-shadow: 0 0 5px 2px rgba(0,51,102,.15);
    padding: 15px 18px 15px 18px;
    margin: 0 10px 0 10px;
  }
  #access-button {
    background-color: var(--usgs-blue);
    color: var(--color-background);
    font-weight: 800;
  }
  #more-button {
    background-color: var(--color-background);
    color: var(--usgs-blue);
    padding: 10px 18px 10px 18px;
  }
  #more-button-content {
    display: flex;
    flex-direction: row;
    align-items: center;
    gap: 3px;
  }
  .title-dialog-button:focus-visible {
    outline: 2px solid black;
  }
  .title-dialog-button:hover {
    box-shadow: 0 0 5px 2px rgba(0,51,102,.4);
  }
</style>
