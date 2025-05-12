<template>
  <section>
    <div
      class="map-overlay"
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
        v-model="dropdownSelection"
        :options="props.forecastInfo"
        :label-field="dropdownLabelField"
        :value-field="dropdownLabelField"
      />
      {{ dropdownSelection }}
    </div>
  </section>
</template>

<script setup>
    import { ref } from 'vue';
import DropdownMenu from './DropdownMenu.vue';

    // define props
    const props = defineProps({
        forecastInfo: { 
            type: Object,
            default() {
                return {}
            }
        }
    })

    // define global variables
    const dropdownSelection = ref(props.forecastInfo[0].forecast_date)
    const dropdownLabelField = 'forecast_date';
    const forecastDates = props.forecastInfo.map(d => d.forecast_date)
    const dataType = ref(forecastDates.includes(dropdownSelection.value) ? 'Forecast' : 'Observed');

</script>

<style>
.map-overlay {
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