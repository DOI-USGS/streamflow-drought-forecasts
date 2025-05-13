<template>
  <section>
    <div
      class="sidebar"
    >
      <h1>
        <span
          class="emph"
        >
          {{ dataType }}
        </span>
        streamflow drought
      </h1>
      <DropdownMenu 
        id="dropdown-container"
        v-model="selectedWeek"
        :options="forecastInfoData"
        :label-field="dropdownLabelField"
        :value-field="dropdownValueField"
        @change="updateSelectedWeek(selectedWeek)"
      />
    </div>
  </section>
</template>

<script setup>
  import { inject, ref } from 'vue';
  import DropdownMenu from './DropdownMenu.vue';

  // inject values
  const { forecastInfoData, selectedWeek, updateSelectedWeek } = inject('dates')
  
  // define global variables
  const dropdownLabelField = 'forecast_date';  
  const dropdownValueField = 'f_w'
  const dataType = ref(selectedWeek.value > 0 ? 'Forecast' : 'Observed');

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
#dropdown-container {
    margin: 10px 0 10px 0;
}
#dropdown-container select {
    font-size: 3rem;
    font-family: var(--default-font);
    font-weight: 200;
    padding: 0.2rem 0.5rem 0.2rem 0.2rem;
}
</style>