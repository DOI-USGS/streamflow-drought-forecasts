<template>
  <section>
    <div
      ref="wrapper"
      class="sidebar"
    >
      <div
        id="upper-section"
      >
        <h1>
          <span
            class="major-emph"
          >
            {{ globalDataStore.dataType }}
          </span>
          streamflow drought
        </h1>
        <DropdownMenu 
          id="dropdown-container"
          v-model="selectedOption"
          :options="globalDataStore.dateInfoData"
          :label-field="dropdownLabelField"
          :value-field="dropdownValueField"
          @change="updateSelectedWeek(selectedOption)"
        />
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
  import { ref, useTemplateRef, watch } from 'vue';
  import { storeToRefs } from "pinia";
  import { useGlobalDataStore } from "@/stores/global-data-store";
  import DropdownMenu from './DropdownMenu.vue';
  import ExtentSummary from './ExtentSummary.vue';
  import SiteSummary from './SiteSummary.vue';

  // Define global variables
  const globalDataStore = useGlobalDataStore();
  const { selectedWeek } = storeToRefs(globalDataStore);
  const wrapper = useTemplateRef('wrapper');
  const wrapperSize = useElementSize(wrapper);
  const dropdownLabelField = 'dt';  
  const dropdownValueField = 'f_w'
  const selectedOption = ref(selectedWeek.value);
  
  // When selectedWeek changes, update selected option
  watch(selectedWeek, (newValue) => {
    selectedOption.value = newValue;
  });  

  function updateSelectedWeek(week) {
    selectedWeek.value = week;
  }
</script>

<style>
  .sidebar {
    /*display: block; /*none;*/
    padding: 2rem 2rem 2rem 2rem; /* reduce on right if scroll needed? */
    position: absolute;
    left: 10px;
    top: 10px;
    width: 440px;
    max-width: 440px;
    max-height: calc(100% - 20px);
    overflow: hidden;
    white-space: wrap;
    /* height: calc(100vh - 20px); */
    background: var(--color-background);  
    border-radius: 5px;
    box-shadow: 0 1px 2px rgba(0, 0, 0, 0.2);
    z-index: 5;
  }
  #upper-section {
    border-bottom: solid 1px var(--dark-grey);
    padding: 0 1rem 1rem 1rem;
    margin: 0 -1rem 2rem -1rem;
  }
  #dropdown-container {
    margin: 10px 0 10px 0;
  }
  #dropdown-container select {
    padding: 0.2rem 0.5rem 0.2rem 0.2rem;
    /* match h1 styles */
    font-size: 3rem;
    font-family: var(--default-font);
    font-weight: 200;
  }
  .highlight {
    border-left: 4px solid red;
    padding-left: 4px;
    background-image: linear-gradient(to right, pink, var(--color-background));
  }
  .extreme {
    border-color: rgb(var(--color-extreme));
    background-image: linear-gradient(to right, rgba(var(--color-extreme), 0.5), var(--color-background));
  }
  .severe {
    border-color: rgb(var(--color-severe));
    background-image: linear-gradient(to right, rgba(var(--color-severe), 0.5), var(--color-background));
  }
  .moderate {
    border-color: rgb(var(--color-moderate));
    background-image: linear-gradient(to right, rgba(var(--color-moderate), 0.5), var(--color-background));
  }
  #lower-section {
    max-width: 100%;
  }
</style>