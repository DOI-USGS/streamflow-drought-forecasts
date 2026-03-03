<template>
  <div>
    <DialogBox
      v-model="titleDialogShown"
      dialog-id="title-dialog"
    >
      <template #dialogTitle>
        <div
          id="logo-container"
        >
          <img 
            id="logo-image" 
            :src="getImageURL('2021_usgs-logo-sub-black.png')"
            alt="U.S. Geological Survey logo"
          >
        </div>
      </template>  
      <template #dialogContent>
        <div
          id="website-info-container"
        >
          <div
            id="title-container"
          >
            <h1 
              class="site-title" 
              v-html="text.siteInfo.title"
            />
            <p 
              class="site-subtitle splash-subtitle"
              v-html="text.siteInfo.subtitle"
            />
          </div>
          <div
            id="about-container"
          >
            <p v-html="text.siteInfo.about1" />
          </div>
          <div
            id="title-dialog-button-container"
          >
            <button
              id="access-button"
              class="title-dialog-button"
              @click="hideTitleDialog"
            >
              Get started
            </button>
            <button
              id="more-button"
              class="title-dialog-button"
              data-open-modal
              aria-controls="faq-dialog"
              @click="showFaqDialog"
            >
              <div
                id="more-button-content"
              >      
                <FaqButton 
                  :is-static="true"
                />   
                <span>
                  Learn more
                </span>
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
  #website-info-container p {
    font-weight: 400;
    padding-bottom: 1.5rem;
    @media only screen and (min-width: 641px) {
      padding-bottom: 2rem;
    }
  }
  #title-container {
    text-align: center;
    margin: 2rem 0 3.0rem 0;
    @media only screen and (min-width: 641px) {
      margin: 1.5rem 0 3.5rem 0;
    }
  }
  #about-container {
    margin: auto;
    text-align: center;
  }
  #logo-image {
    height: 45px;
  }
  #title-dialog-button-container {
    margin: 1rem auto 1rem auto;
    display: flex;
    align-items: center;
    justify-content: center;
    height: 6.8rem;
    @media only screen and (min-width: 641px) {
      margin: 1.5rem auto 1rem auto;
      height: 5.8rem;
    }
  }
  .title-dialog-button {
    border-radius: 4px;
    border: 2px solid var(--usgs-blue);
    cursor: pointer;
    box-shadow: 0 0 5px 2px rgba(0,51,102,.15);
    margin: 0 10px 0 10px;
  }
  #access-button {
    background-color: var(--usgs-blue);
    color: var(--color-background);
    font-weight: 700;
    height: 100%;
    padding: 0 1.5rem 0 1.5rem;
    @media only screen and (min-width: 641px) {
      padding: 0 1.8rem 0 1.8rem;
    }
  }
  #more-button {
    background-color: var(--color-background);
    color: var(--usgs-blue);
    height: 100%;
    padding: 0 1.5rem 0 1.5rem;
    @media only screen and (min-width: 641px) {
      padding: 0 1.8rem 0 1.8rem;
    }
  }
  #more-button-content {
    display: flex;
    flex-direction: row;
    align-items: center;
    gap: 3px;
    margin: auto;
  }
  .title-dialog-button:focus-visible {
    outline: 2px solid var(--black-soft);
  }
  .title-dialog-button:hover {
    box-shadow: 0 0 5px 2px rgba(0,51,102,.4);
  }
</style>
