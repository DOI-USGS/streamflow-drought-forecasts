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
            {{ dataType }}
          </span>
          streamflow drought
        </h1>
        <DropdownMenu 
          id="dropdown-container"
          v-model="selectedOption"
          :options="dateInfoData"
          :label-field="dropdownLabelField"
          :value-field="dropdownValueField"
          @change="updateSelectedWeek(selectedOption)"
        />
      </div>
      <div
        id="lower-section"
      >
        <ExtentSummary 
          v-if="!selectedSite"
        />
        <SiteSummary
          v-if="selectedSite"
          :container-width="wrapperSize.width"
        />  
      </div>
    </div>
  </section>
</template>

<script setup>
  import { useElementSize } from "@vueuse/core";
  import { computed, inject, ref, useTemplateRef, watch } from 'vue';
  import DropdownMenu from './DropdownMenu.vue';
  import ExtentSummary from './ExtentSummary.vue';
  import SiteSummary from './SiteSummary.vue';

  // inject values
  const { dateInfoData, selectedWeek, updateSelectedWeek } = inject('dates');
  const { selectedSite } = inject('sites');

  // Define selected option
  const selectedOption = ref(selectedWeek.value);
  
  // When selectedWeek changes, update selected option
  watch(selectedWeek, (newValue) => {
    selectedOption.value = newValue;
  });

  // define global variables
  const wrapper = useTemplateRef('wrapper');
  const wrapperSize = useElementSize(wrapper); //ref(null);
  const dropdownLabelField = 'date';  
  const dropdownValueField = 'f_w'

  // Define data type
  const dataType = computed(() => {
    return selectedWeek.value > 0 ? 'Forecast' : 'Observed';
  })
</script>

<style>
  .sidebar {
    /*display: block; /*none;*/
    padding: 2rem 2rem 2rem 2rem;
    position: absolute;
    left: 10px;
    top: 10px;
    width: 420px;
    max-width: 440px;
    overflow: hidden;
    white-space: wrap;
    /* height: calc(100vh - 20px); */
    background: var(--color-background);  
    border-radius: 5px;
    box-shadow: 0 1px 2px rgba(0, 0, 0, 0.2);
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