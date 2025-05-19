<template>
  <section>
    <div
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
          v-model="selectedWeek"
          :options="dateInfoData"
          :label-field="dropdownLabelField"
          :value-field="dropdownValueField"
          @change="updateSelectedWeek(selectedWeek)"
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
        />  
      </div>
    </div>
  </section>
</template>

<script setup>
  import { computed, inject, ref } from 'vue';
  import DropdownMenu from './DropdownMenu.vue';
  import ExtentSummary from './ExtentSummary.vue';
  import SiteSummary from './SiteSummary.vue';

  // inject values
  const { dateInfoData, selectedWeek, updateSelectedWeek } = inject('dates');
  const { selectedSite } = inject('sites');

  // define global variables
  const dropdownLabelField = 'forecast_date';  
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
    /* width: 350px; */
    max-width: 440px;
    overflow: hidden;
    /* white-space: nowrap; */
    /* height: calc(100vh - 20px); */
    background: #fff;  
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
</style>