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
    padding: 2rem 2rem 2rem 2rem; /* reduce on right if scroll needed? */
    position: absolute;
    left: 10px;
    top: 10px;
    width: 485px;
    max-width: 485px;
    max-height: calc(100% - 20px);
    overflow: hidden;
    white-space: wrap;
    background: var(--color-background);  
    border-radius: 5px;
    box-shadow: 0 1px 2px rgba(0, 0, 0, 0.2);
    z-index: 5;
  }
  #sidebar-title {
    line-height: 3.4rem;
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
    margin-top: 0.25rem;
    padding-top: 1.5rem
  }
</style>