<template>
  <div id="warning-container">
    <div
      v-if="screenCategory != 'phone'"
      class="warning-content button-content"
    >
      <p>
        You are viewing an <span class="major-emph">experimental</span> application. Click here 
      </p>
      <span>
        <FaqButton />
      </span> 
      <p>
        to learn about this tool.
      </p>
    </div>
    <div
      v-else
      class="warning-content"
    >
      <p>
        You are viewing an <span class="major-emph">experimental</span> application. 
      </p>
      <span
        class="button-content"
      >
        <p>
          Click here
        </p>
        <span>
          <FaqButton
            class="inline-button"
          />
        </span>
        <p>
          to learn about this tool.
        </p>
      </span>
    </div>
  </div>
</template>

<script setup>
  import FaqButton from './FaqButton.vue';
  import { useScreenCategory } from "@/assets/scripts/composables/media-query";

  // global variables
  const screenCategory = useScreenCategory();
</script>

<style scoped lang="scss">
  #warning-container {
    background-color: #b9c7d2;
    padding-bottom: 0.5rem;
    padding-top: 0.5rem;
    height: 63px;
    @media only screen and (min-width: 641px) {
      height: 45px;
    }
  }
  #warning-container p {
    text-align: center;
    font-weight: 400;
    line-height: 1;
    padding: 0;
    font-size: 1.4rem;
    color: var(--usgs-blue);
    @media only screen and (min-width: 641px) {
      font-size: 1.6rem;
      line-height: 35px;
    }
  }
  .warning-content {
    max-width: 95vw;
    margin: auto;
    padding: 0.5rem 0 0 0;
    @media only screen and (min-width: 641px) {
      padding: 0;
      max-width: max-content;
    }
  }
  .button-content {
    margin: auto;
    display: flex;
    flex-direction: row;
    align-items: center;
    max-width: max-content;
  }
</style>
