<template>
  <section>
    <div>
      <p class="station_id">
        Gage <b> {{ selectedSite }} </b>
      </p>
      <p class="station_name">
        {{ selectedSiteInfo.station_nm }}
      </p>
    </div>
    <div>
      <p v-if="inDrought">
        {{ statusPreface }} {{ statusPhrase }} 
        <span 
          v-if="inDrought"
          class="highlight slight-emph"
          :class="siteStatus"
        >
          {{ siteStatus }} drought
        </span>
        <span
          v-else
        >
          drought
        </span>
      </p>
      <p v-else>
        {{ statusPreface }}
        <span
          class="slight-emph"
        >
          not
        </span>
        {{ statusPhrase }} drought
      </p>
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

  // Define data type
  const statusPreface = computed(() => {
    const statusPreface = selectedWeek.value > 0 ? 'Forecast to' : 'Currently';
    return statusPreface
  })

  const statusPhrase = computed(() => {
    const statusPreface = selectedWeek.value > 0 ? 'be in' : 'in';
    return statusPreface
  })

  const inDrought = computed(() => {
    return selectedSiteForecast.value.median < 20;
  })

  // Determine site status
  const siteStatus = computed(() => {
    let siteValue = selectedSiteForecast.value.median
    let siteStatus;
    switch(true) {
      case siteValue < 5:
        siteStatus = "extreme";
        break;
      case siteValue < 10:
        siteStatus = "severe";
        break;
      case siteValue < 20:
        siteStatus = "moderate";
        break;
      default:
        siteStatus = "none";
    }
    return(siteStatus)
  })
</script>

<style lang="scss" scoped>
.station_id {
  padding-bottom: 3px;
}
.station_name {
  font-size: 1.6rem;
  color: var(--grey_5_1);
}
</style>