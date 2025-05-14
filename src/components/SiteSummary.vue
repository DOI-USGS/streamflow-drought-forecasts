<template>
  <section>
    <div>
      <p><b>Station:</b> {{ selectedSite }} </p>
      <p><b>Name:</b> {{ selectedSiteInfo.station_nm }} </p>
      <p><b>State:</b> {{ selectedSiteInfo.state }} </p>
      <p><b>County:</b> {{ selectedSiteInfo.county }}</p>
      <p><b>Forecast week:</b> {{ selectedWeek }}</p>
      <b>Median predicted percentile:</b>
      <p> {{ selectedSiteForecast.median }}</p>
    </div>
  </section>
</template>

<script setup>
  import { computed, inject } from 'vue';

  const { selectedWeek, selectedDate } = inject('dates')
  const { siteInfo, selectedSite } = inject('sites')
  const { currentForecasts } = inject('forecasts')

  // Define selectedSiteInfo, based on selectedSite
  const selectedSiteInfo = computed(() => {
    return siteInfo.value.find(d => d.StaID == selectedSite.value);
  })

  // Define selectedSiteForecast, based on selectedSite
  const selectedSiteForecast = computed(() => {
    return currentForecasts.value.find(d => d.StaID == selectedSite.value && d.forecast_date == selectedDate.value);
  })
</script>

<style>
</style>