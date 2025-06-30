<template>
  <section>
    <div
      id="station-name-container"
    >
      <p class="station_id">
        Gage <b> {{ globalDataStore.selectedSite }} </b>
      </p>
      <p class="station_name">
        {{ selectedSiteInfo.station_nm }}
      </p>
    </div>
    <div
      id="status-statement-container"
    >
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
      <p v-else-if="!isNA">
        {{ statusPreface }}
        <span
          class="slight-emph"
        >
          not
        </span>
        {{ statusPhrase }} drought
      </p>
      <p v-else>
        <i>No drought status data available</i>
      </p>
    </div>
    <TimeSeriesGraph 
      :container-width="containerWidth"
    />
  </section>
</template>

<script setup>
  import { computed, inject } from 'vue';
  import { useGlobalDataStore } from "@/stores/global-data-store";
  import TimeSeriesGraph from './TimeSeriesGraph.vue';

  /*
  * @vue-prop {Number} containerWidth - The width of the container for this component.
  */
  const props = defineProps({
    containerWidth: {
      type: Object,
      default: () => ({}),
      required: true,
    },
  });

  // Inject data
  const { siteInfo } = inject('sites')
  const { currentConditions } = inject('conditions')

  // Define global variables
  const globalDataStore = useGlobalDataStore();

  // Define selectedSiteInfo, based on selectedSite
  const selectedSiteInfo = computed(() => {
    return siteInfo.value.find(d => d.StaID == globalDataStore.selectedSite);
  })

  // Define selectedSiteConditions, based on selectedSite
  const selectedSiteConditions = computed(() => {
    return currentConditions.value.find(d => d.StaID == globalDataStore.selectedSite);
  })

  // Define data type
  const statusPreface = computed(() => {
    const statusPreface = globalDataStore.selectedWeek > 0 ? 'Forecast to' : 'Currently';
    return statusPreface
  })

  const statusPhrase = computed(() => {
    const statusPreface = globalDataStore.selectedWeek > 0 ? 'be in' : 'in';
    return statusPreface
  })

  const inDrought = computed(() => {
    return selectedSiteConditions.value.pd < 20;
  })

  const isNA = computed(() => {
    return selectedSiteConditions.value.pd == 999;
  })

  // Determine site status
  const siteStatus = computed(() => {
    let siteValue = selectedSiteConditions.value.pd
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
#status-statement-container {
  padding-top: 15px;
}
</style>