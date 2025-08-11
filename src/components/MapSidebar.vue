<template>
  <section>
    <div
      ref="wrapper"
      class="sidebar"
    >
      <div
        id="upper-section"
      >
        <h2
          id="sidebar-title"
          v-html="text.siteInfo.title"
        />
        <SidebarControl />
      </div>
      <div
        id="lower-section"
      >
        <ExtentSummary 
          v-if="!globalDataStore.selectedSite"
        />
        <SiteSummary
          v-if="globalDataStore.selectedSite"
          :container-width="wrapperSize.width"
        />  
      </div>
    </div>
  </section>
</template>

<script setup>
  import { useElementSize } from "@vueuse/core";
  import { useTemplateRef } from 'vue';
  import { useGlobalDataStore } from "@/stores/global-data-store";
  import SidebarControl from "./SidebarControl.vue";
  import ExtentSummary from './ExtentSummary.vue';
  import SiteSummary from './SiteSummary.vue';
  import text from "@/assets/text/text.js";

  // Define global variables
  const globalDataStore = useGlobalDataStore();
  const wrapper = useTemplateRef('wrapper');
  const wrapperSize = useElementSize(wrapper);
  
</script>

<style lang="scss">
  .sidebar {
    display: flex;
    flex-direction: column;
    padding: 1.40rem 1.6rem 1rem 1.6rem; /* reduce on right if scroll needed? */
    position: absolute;
    left: 0px;
    top: auto;
    bottom: 0px;
    width: 100vw;
    max-width: 100vw;
    max-height: 85%;
    overflow: hidden;
    white-space: wrap;
    background: var(--color-background);  
    border-radius: 0px;
    box-shadow: 0px -4px 4px -2px rgba(0, 0, 0, 0.2);
    z-index: 5;
    @media only screen and (min-width: 641px) {
      padding: 2rem 2rem 2rem 2rem;
      left: 10px;
      top: 10px;
      bottom: auto;
      width: 485px;
      max-width: 485px;
      max-height: calc(100% - 20px);
      border-radius: 4px;
      box-shadow: 0px 0px 6px rgba(0, 0, 0, 0.2);
    }
  }
  #sidebar-title {
    line-height: 2.65rem;
    @media only screen and (min-width: 641px) {
      line-height: 3.4rem;
    }
  }
  #upper-section {
    border-bottom: solid 1px var(--dark-grey);
    padding: 0 1rem 0rem 1rem;
    margin: 0 -1rem 0.25rem -1rem;
  }
  #lower-section {
    max-width: 100%;
    overflow-y: auto;
    scrollbar-width: thin;
    scrollbar-color: var(--grey_3_1) #FCFCFC;
    margin-top: 0rem;
    padding-top: 0.5rem;
    @media only screen and (min-width: 641px) {
      margin-top: 0.25rem;
      padding-top: 1.5rem;
    }
  }
  #lower-section p {
    padding: 0 0 0.75rem 0;
    @media only screen and (min-width: 641px) {
      padding: 0 0 1rem 0;
    }
  }
</style>