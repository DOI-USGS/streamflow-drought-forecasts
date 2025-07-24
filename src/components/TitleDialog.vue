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
          <p v-html="text.siteInfo.about" />
          <div
            id="access-button-container"
          >
            <button
              id="access-button"
              @click="hideTitleDialog"
            >
              Access the tool
            </button>
          </div>
          <hr>
          <div
            id="more-info-content"
          >
            <p>
              Click here 
            </p>
            <span>
              <FaqButton />
            </span> 
            <p>
              to learn more about this tool.
            </p>
          </div>
        </div>
      </template>
    </DialogBox>
  </div>
</template>

<script setup>
  import { watch } from 'vue';
  import { storeToRefs } from "pinia";
  import DialogBox from './DialogBox.vue';
  import FaqButton from './FaqButton.vue';
  import text from "@/assets/text/text.js";
  import { useGlobalDataStore } from "@/stores/global-data-store";

  // global variables
  const globalDataStore = useGlobalDataStore();  
  const { titleDialogShown } = storeToRefs(globalDataStore);
  const { faqDialogShown } = storeToRefs(globalDataStore);

  watch(faqDialogShown, (newValue) => {
    if (newValue == true) {
      titleDialogShown.value = false;
    }
  })

  function hideTitleDialog() {
    titleDialogShown.value = false;
  }

  function getImageURL(filename) {
    return new URL(`../assets/images/${filename}`, import.meta.url).href
  }
</script>

<style scoped lang="scss">
  #site-info-container p {
    font-weight: 400;
  }
  #site-info-container hr {
    margin: 1rem 0 1rem 0;
  }
  #title-container {
    text-align: center;
    margin: 1.5rem 0 4rem 0;
  }
  #logo-image {
    height: 45px;
  }
  #access-button-container {
    margin: 2rem 0 4rem 0;
    text-align: center;
  }
  #access-button {
    background-color: var(--usgs-blue);
    color: var(--color-background);
    font-weight: 600;
    border-radius: 4px;
    border: none;
    cursor: pointer;
    outline: none;
    box-shadow: 0 0 5px 2px rgba(0,51,102,.15);
    padding: 15px 18px 15px 18px;
  }
#access-button:focus-visible {
  outline: 2px solid;
}
#access-button:hover {
  box-shadow: 0 0 5px 2px rgba(0,51,102,.4);
}
#access-button.static:hover {
  box-shadow: 0 0 5px 2px rgba(0,51,102,.15);
}
  #more-info-content {
    display: flex;
    flex-direction: row;
    margin: auto;
    align-items: start;
    max-width: max-content;
    p {
      text-align: center;
      font-weight: 400;
      line-height: 35px;
      padding: 0;
    }
  }
</style>
