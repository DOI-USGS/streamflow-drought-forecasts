<template>
  <div>
    <DialogBox
      v-model="dialogShown"
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
        <h1>
          <span
            class="major-emph"
          >
            Streamflow
          </span>
          drought assessment and forecasting tool
        </h1>
        <div
          id="more-info-content"
        >
          <p>
            Click here 
          </p>
          <span>
            <FaqButtonDialog
              :text="text.faqs"
            />
          </span> 
          <p>
            to learn more about this tool.
          </p>
        </div>
      </template>
    </DialogBox>
  </div>
</template>

<script setup>
  import { ref } from 'vue';
  import DialogBox from './DialogBox.vue';
  import FaqButtonDialog from './FaqButtonDialog.vue';
  import text from "@/assets/text/text.js";

  const props = defineProps({
    dialogShown: {
      type: Boolean,
      default: false,
      required: true
    }
  })
//2021_usgs-logo-sub-black
  // global variables
  const dialogShown = ref(props.dialogShown);

  function getImageURL(filename) {
    return new URL(`../assets/images/${filename}`, import.meta.url).href
  }
</script>

<style scoped lang="scss">
  #logo-image {
    height: 50px;
  }
  #more-info-content {
    display: flex;
    flex-direction: row;
    margin: auto;
    align-items: center;
    max-width: max-content;
    p {
      text-align: center;
      font-weight: 400;
      line-height: 35px;
      padding: 0;
      font-size: 1.6rem;
      color: var(--usgs-blue);
    }
  }
</style>
