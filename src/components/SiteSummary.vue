<template>
  <section>
    <div>
      <p><b>Station:</b> {{ selectedSite }} </p>
      <p><b>State:</b> {{ selectedSiteInfo.state }} </p>
      <p><b>County:</b> {{ selectedSiteInfo.county }}</p>
      <p><b>Forecast week:</b> {{ selectedWeek }}</p>
      <b>Median predicted percentile:</b>
      <p> {{ selectedSiteForecast.median }}</p>
    </div>
    <TimeSeriesGraph />
  </section>
</template>

<script setup>
  import { computed, inject } from 'vue';
  import TimeSeriesGraph from './TimeSeriesGraph.vue';

  // Inject data
  const { selectedWeek } = inject('dates')
  const { siteInfo, selectedSite } = inject('sites')
  const { currentForecasts } = inject('forecasts')

  // Define selectedSiteInfo, based on selectedSite
  const selectedSiteInfo = computed(() => {
    return siteInfo.value.find(d => d.StaID == selectedSite.value);
  })

  // Define selectedSiteForecast, based on selectedSite
  const selectedSiteForecast = computed(() => {
    return currentForecasts.value.find(d => d.StaID == selectedSite.value);
  })
</script>

<style>
</style>