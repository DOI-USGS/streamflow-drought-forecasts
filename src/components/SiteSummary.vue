<template>
  <section
    id="site-summary-container"
  >
    <div
      id="gage-info-container"
    >
      <div
        id="staid-icon-map-container"
      >
        <div>        
          <p class="station_id">
            Gage <b> {{ globalDataStore.selectedSite }} </b>
          </p>
          <HydrologicIcons 
            :text="text.icons"
            :site-regulated="siteRegulated"
            :site-intermittent="siteIntermittent"
            :site-snow-dominated="siteSnowDominated"
            :site-ice-impacted="siteIceImpacted"
          />
        </div>
        <div
          id="site-map-container"
        >
          <img 
            class="site-map"
            :src="getMapImageURL(globalDataStore.selectedSite)"
            :alt="mapAltText"
          >
        </div>
      </div>
      <p class="station_name">
        {{ globalDataStore.selectedSiteInfo.station_nm }}
      </p>
    </div>
    <div
      id="status-statement-container"
    >
      <div
        id="status-statement"
      >
        <p v-if="globalDataStore.inDrought">
          {{ statusPreface }} {{ statusPhrase }} 
          <span 
            v-if="globalDataStore.inDrought"
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
        <p v-else-if="!globalDataStore.droughtStatusNA">
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
      <FaqButton />
    </div>
    <div
      id="site-timeseries-container"
    > 
      <GraphButtonDialog
        id="explanation-button-container"
        :text="text.graph"
      />
      <TimeSeriesGraph 
        :container-width="containerWidth"
      />
    </div>
  </section>
</template>

<script setup>
  import { computed } from 'vue';
  import { useGlobalDataStore } from "@/stores/global-data-store";
  import HydrologicIcons from './HydrologicIcons.vue';
  import FaqButton from './FaqButton.vue';
  import GraphButtonDialog from './GraphButtonDialog.vue';
  import TimeSeriesGraph from './TimeSeriesGraph.vue';
  import text from "@/assets/text/text.js";

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

  // Define global variables
  const globalDataStore = useGlobalDataStore();

  // Determine hydrologic info
  const siteRegulated = computed(() => { 
    return globalDataStore.selectedSiteInfo.site_regulated; 
  })
  const siteIntermittent = computed(() => { 
    return globalDataStore.selectedSiteInfo.site_intermittent; 
  })
  const siteSnowDominated = computed(() => { 
    return globalDataStore.selectedSiteInfo.site_snow_dominated; 
  })
  const siteIceImpacted = computed(() => { 
    return globalDataStore.selectedSiteInfo.site_ice_impacted; 
  })

  // Define data type
  const statusPreface = computed(() => {
    const statusPreface = globalDataStore.dataType == 'Forecast' ? 'Forecast to' : 'Currently';
    return statusPreface
  })

  const statusPhrase = computed(() => {
    const statusPreface = globalDataStore.dataType == 'Forecast' ? 'be in' : 'in';
    return statusPreface
  })

  const mapAltText = computed(() => {
    return `Map of the continental U.S. showing the location of site ${globalDataStore.selectedSite} as a black dot`
  })

  // Determine site status
  const siteStatus = computed(() => {
    let siteValue = globalDataStore.selectedSiteConditions.pd
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

  function getMapImageURL(site) {
    return new URL(`${import.meta.env.VITE_APP_S3_PROD_URL}${import.meta.env.VITE_APP_TITLE}/site_maps/${site}.png`, import.meta.url).href
  }
</script>

<style lang="scss" scoped>
#site-summary-container {  
  padding-right: 5px; /* add a little padding for cases when scroll needed */
}
.station_id {
  padding-bottom: 0px;
}
.station_name {
  font-size: 1.6rem;
  color: var(--grey_5_1);
  padding-top: 3px;
}
#status-statement-container {
  display: flex;
  justify-content: space-between;
  padding-top: 25px;
  padding-bottom: 15px;
}
#status-statement-container p {
  padding: 0;
}
#status-statement {
  line-height: 35px;
}
#faq-button {
  background-image: url("data:image/svg+xml;charset=utf-8,%3Csvg viewBox='0 0 20 20' xmlns='http://www.w3.org/2000/svg' fill-rule='evenodd'%3E%3Cpath d='M4 10a6 6 0 1 0 12 0 6 6 0 1 0-12 0m5-3a1 1 0 1 0 2 0 1 1 0 1 0-2 0m0 3a1 1 0 1 1 2 0v3a1 1 0 1 1-2 0'/%3E%3C/svg%3E");
}
#faq-button .button-icon {
  background-position: 50%;
  background-repeat: no-repeat;
  display: block;
  height: 100%;
  width: 100%;
}
#site-timeseries-container {
  position: relative;
}
#explanation-button-container {
  position: absolute;
  top: 0px;
  right: 0px;
}
#question-button {
  background-image: url("data:image/svg+xml;charset=utf-8,%3Csvg viewBox='0 0 20 20' xmlns='http://www.w3.org/2000/svg' fill-rule='evenodd'%3E%3Cpath d='M4 10a6 6 0 1 0 12 0 6 6 0 1 0-12 0m5-3a1 1 0 1 0 2 0 1 1 0 1 0-2 0m0 3a1 1 0 1 1 2 0v3a1 1 0 1 1-2 0'/%3E%3C/svg%3E");
}
#question-button .button-icon {
  background-position: 50%;
  background-repeat: no-repeat;
  display: block;
  height: 100%;
  width: 100%;
}
#staid-icon-map-container {
  display: flex;
  justify-content: space-between;
}
#site-map-container {
  display: flex;
  align-items: center;
}
.site-map {
  width: 70px;
}
</style>