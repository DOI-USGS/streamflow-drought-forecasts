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
            Gage <span class="slight-emph"> {{ globalDataStore.selectedSite }} </span>
            <button
              id="gage-link-button"
              type="button"
              title="Go to monitoring page"
              :aria-label="`Go to monitoring page for USGS site ${globalDataStore.selectedSite}`"
              aria-disabled="false"
            >              
              <a
                :href="`https://waterdata.usgs.gov/monitoring-location/${globalDataStore.selectedSite}`"
                target="_blank"
              >
                <span
                  :style="{ backgroundImage: `url(${getImageURL('link_icon.png')})`}"
                />
              </a>
            </button>
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
            {{ siteStatus }}
          </span>
          streamflow drought
        </p>
        <p v-else-if="!globalDataStore.droughtStatusNA">
          {{ statusPreface }}
          <span
            class="slight-emph"
          >
            not
          </span>
          {{ statusPhrase }} streamflow drought
        </p>
        <p v-else>
          <i>No streamflow data available for {{ globalDataStore.selectedDateFormatted }}</i>
        </p>
      </div>
      <FaqButton />
    </div>
    <TimeSeriesGraph 
      :container-width="containerWidth"
      :text="text"
    />
  </section>
</template>

<script setup>
  import { computed } from 'vue';
  import { useGlobalDataStore } from "@/stores/global-data-store";
  import HydrologicIcons from './HydrologicIcons.vue';
  import FaqButton from './FaqButton.vue';
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

  function getImageURL(filename) {
    return new URL(`../assets/images/${filename}`, import.meta.url).href
  }
</script>

<style lang="scss" scoped>
#site-summary-container {  
  padding-right: 5px; /* add a little padding for cases when scroll needed */
}
.station_id {
  padding-bottom: 0px;
}
#gage-link-button {
  height: 20px;
  width: 20px;
  padding-inline: 1px;
  background-color: transparent;
  border: none;
  opacity: 0.6;
}
#gage-link-button span {
  background-size: 10px auto;
  background-position: 50%;
  background-repeat: no-repeat;
  display: block;
  height: 100%;
  width: 100%;
}
#gage-link-button:hover {
  transform: scale(1.2);
  opacity: 1;
}
.station_name {
  font-size: 1.6rem;
  color: var(--grey_7_1);
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
  align-items: start;
}
.site-map {
  width: 80px;
}
</style>