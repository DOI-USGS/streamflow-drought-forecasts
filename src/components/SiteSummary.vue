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
          <p class="station-id">
            Gage <span class="slight-emph"> {{ globalDataStore.selectedSite }} </span>
            <button
              id="gage-link-button"
              type="button"
              title="Go to monitoring page"
              :aria-label="`Go to monitoring page for USGS site ${globalDataStore.selectedSite}`"
              aria-disabled="false"
              tabindex="-1"
            >              
              <a
                :href="`https://waterdata.usgs.gov/monitoring-location/${globalDataStore.selectedSite}`"
                target="_blank"
                aria-label="Go to monitoring page"
              >
                <span
                  aria-hidden="true"
                  :style="{ backgroundImage: `url(${getImageURL('link_icon.png')})`}"
                />
              </a>
            </button>
          </p>
          <HydrologicIcons
            v-if="screenCategory != 'phone' | fullSummaryShownOnMobile"
            :text="text.icons"
            :site-regulated="siteRegulated"
            :site-intermittent="siteIntermittent"
            :site-snow-dominated="siteSnowDominated"
            :site-ice-impacted="siteIceImpacted"
          />
        </div>
        <div
          id="map-button-container"
        >        
          <div
            v-if="screenCategory != 'phone' | fullSummaryShownOnMobile"
            id="site-map-container"
          >
            <img 
              class="site-map"
              :src="getMapImageURL(globalDataStore.selectedSite)"
              :alt="mapAltText"
            >
          </div>
          <div
            v-if="screenCategory == 'phone'"
            id="expand-button-container"
          >
            <button
              id="expand-button" 
              type="button"
              :title="buttonTitle" 
              :aria-label="buttonTitle"
              aria-disabled="false"
              @click="summaryClick"
            >
              <span 
                id="expand-button-icon"
                aria-hidden="true"
                :title="buttonTitle"
                :style="{ 'background-image': 'url(' + imgSrc + ')', 'background-size': '25px auto' }"
              />
            </button>
          </div>
        </div>
      </div>
      <p
        class="station-name"
      >
        {{ globalDataStore.selectedSiteInfo.station_nm }}
      </p>
    </div>
    <div
      id="gage-summary-container"
    >
      <div class="scroll-watcher" />
      <div
        id="status-statement-container"
      >
        <div
          id="status-statement"
        >
          <p v-if="globalDataStore.inDrought">
            {{ globalDataStore.statusPreface }} {{ globalDataStore.statusPhrase }} 
            <span 
              class="highlight slight-emph"
              :class="globalDataStore.selectedSiteStatus"
            >
              {{ globalDataStore.selectedSiteStatus }}
            </span>
            streamflow drought
          </p>
          <p v-else-if="!globalDataStore.droughtStatusNA">
            {{ globalDataStore.statusPreface }}
            <span
              class="slight-emph"
            >
              not
            </span>
            {{ globalDataStore.statusPhrase }} streamflow drought
          </p>
          <p v-else>
            <i>No streamflow data available for {{ globalDataStore.selectedDateFormatted }}</i>
          </p>
        </div>
        <FaqButton />
      </div>
      <TimeSeriesGraph
        v-if="screenCategory != 'phone' | fullSummaryShownOnMobile"
        :container-width="containerWidth"
        :text="text"
      />
      <div
        v-if="screenCategory != 'phone' | fullSummaryShownOnMobile"
        id="context-container"
      >
        <div
          id="streamflow-context-container"
        >
          <p
            v-if="globalDataStore.selectedSiteRecord.last_year_obs_per < 100"
          >
            This site is missing some daily streamflow data. Daily streamflow has been recorded on {{ globalDataStore.selectedSiteRecord.last_year_obs_per }}% of the last 365 days and {{ globalDataStore.selectedSiteRecord.antecedent_obs_per }}% of the last {{ globalDataStore.selectedSiteRecord.antecedent_days }} days. 
          </p>
        </div>
        <div
          v-if="globalDataStore.inDrought && globalDataStore.selectedWeek == 0"
          id="drought-context-container"
        >
          <p>
            As of {{ globalDataStore.selectedDateFormatted }}, this site has been in continuous streamflow drought for
            <span 
              v-if="globalDataStore.selectedSiteRecord.continuous_drought_length <= 365"
              class="slight-emph"
            >
              {{ globalDataStore.selectedSiteRecord.continuous_drought_length }}
            </span>
            <span 
              v-else
              class="slight-emph"
            >
              over a year.
            </span>
            <span 
              v-if="globalDataStore.selectedSiteRecord.continuous_drought_length > 1 & globalDataStore.selectedSiteRecord.continuous_drought_length <= 365"
              class="slight-emph"
            >
              days</span><span 
              v-if="globalDataStore.selectedSiteRecord.continuous_drought_length > 1 & globalDataStore.selectedSiteRecord.continuous_drought_length <= 365"
            >, since {{ globalDataStore.selectedSiteRecord.continuous_drought_start }}.
            </span>
            <span 
              v-else-if="globalDataStore.selectedSiteRecord.continuous_drought_length == 1"
              class="slight-emph"
            >
              day.
            </span>
            The current  
            <span 
              class="highlight slight-emph"
              :class="globalDataStore.selectedSiteStatus"
            >
              {{ globalDataStore.selectedSiteStatus }}
            </span>
            streamflow drought began
            <span 
              v-if="globalDataStore.selectedSiteRecord.current_drought_length <= 365"
              class="slight-emph"
            >
              {{ globalDataStore.selectedSiteRecord.current_drought_length }}
            </span>
            <span 
              v-else
              class="slight-emph"
            >
              over a year ago.
            </span>
            <span 
              v-if="globalDataStore.selectedSiteRecord.current_drought_length > 1 & globalDataStore.selectedSiteRecord.current_drought_length <= 365"
              class="slight-emph"
            >
              days ago</span><span 
              v-if="globalDataStore.selectedSiteRecord.current_drought_length > 1 & globalDataStore.selectedSiteRecord.current_drought_length <= 365"
            >, on {{ globalDataStore.selectedSiteRecord.current_drought_start }}.
            </span>
            <span 
              v-else-if="globalDataStore.selectedSiteRecord.current_drought_length == 1"
              class="slight-emph"
            >
              day ago.
            </span>
          </p>
        </div>
        <div
          v-if="globalDataStore.selectedSiteRecord.last_year_obs_per == 100 | globalDataStore.selectedSiteRecord.antecedent_obs_per == 100"
          id="last-year-context-container"
        >        
          <p>
            This site was in streamflow drought on 
            <span
              v-if="globalDataStore.selectedSiteRecord.last_year_obs_per == 100"
            >
              {{ globalDataStore.selectedSiteRecord.last_year_drought_per }}% of the last 365 days, and 
            </span>
            <span
              v-if="globalDataStore.selectedSiteRecord.antecedent_obs_per == 100"
            >
              {{ globalDataStore.selectedSiteRecord.antecedent_drought_per }}%  of the last {{ globalDataStore.selectedSiteRecord.antecedent_days }} days ({{ globalDataStore.selectedSiteRecord.antecedent_drought_days }} days)</span>.
          </p>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
  import { computed, onMounted } from 'vue';
  import { useGlobalDataStore } from "@/stores/global-data-store";
  import { storeToRefs } from 'pinia';
  import { useScreenCategory } from "@/assets/scripts/composables/media-query";
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
  const screenCategory = useScreenCategory();
  const { fullSummaryShownOnMobile } = storeToRefs(globalDataStore);
  const activeButtonTitle = "Close site summary"
  const buttonTitle = computed(() => {
    return fullSummaryShownOnMobile.value ? activeButtonTitle : "View site summary"
  })
  const imgSrc = computed(() => {
    return fullSummaryShownOnMobile.value ? getImageURL("collapse_icon.png") : getImageURL("expand_icon.png");
  })

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

  const mapAltText = computed(() => {
    return `Map of the continental U.S. showing the location of site ${globalDataStore.selectedSite} as a black dot`
  })

  onMounted(async () => {
    const header = document.querySelector('#gage-info-container');
    const scrollWatcher = document.querySelector('.scroll-watcher');

    const observer = new IntersectionObserver(([entry]) => {
        if (!entry.isIntersecting) {
            header.classList.add('stuck');
        } else {
            header.classList.remove('stuck');
        }
    });

    observer.observe(scrollWatcher);
  });

  function summaryClick() {
    fullSummaryShownOnMobile.value = !fullSummaryShownOnMobile.value
  }

  function getMapImageURL(site) {
    return new URL(`${import.meta.env.VITE_APP_S3_PROD_URL}${import.meta.env.VITE_APP_TITLE}/site_maps/${site}.png`, import.meta.url).href
  }

  function getImageURL(filename) {
    return new URL(`../assets/images/${filename}`, import.meta.url).href
  }
</script>

<style lang="scss" scoped>
#site-summary-container {  
  display: flex;
  flex-direction: column;
  max-height: 100%;
}
#gage-info-container {
  position: sticky;
  top: 0px;
  z-index: 10;
  background-color: var(--color-background);
  transition: box-shadow 0.3s ease-in-out; /* For smooth transition */
  padding-top: 0.25rem;
  @media only screen and (min-width: 641px) {
    padding-top: 0.75rem;
  }
}
#gage-info-container.stuck {
  box-shadow: 0px 5px 4px -4px rgba(0, 0, 0, 0.2); /* Shadow when stuck */
}
#staid-icon-map-container {
  display: flex;
  justify-content: space-between;
}
#staid-icon-map-container .station-id {
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
.station-name {
  font-size: 1.6rem;
  color: var(--grey_7_1);
  padding-top: 3px;
}
#map-button-container {
  display: flex;
  flex-direction: row; 
  gap: 1rem;
}
#site-map-container {
  display: flex;
  align-items: start;
}
.site-map {
  width: 80px;
}
#expand-button-container {
  display: flex;
  justify-content: end;
  margin-right: 2px;
}
#expand-button {
  background-color: transparent;
  border: none;
  cursor: pointer;
  padding: 0;
  height: 30px;
  width: 30px;
  animation: animate 0.5s ease-in 2;
}
@keyframes animate {
  0% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.2);    
  }
  100% {
    transform: scale(1);
  }
}
#expand-button-icon {
  background-position: 50%;
  background-repeat: no-repeat;
  display: block;
  height: 100%;
  width: 100%;
}
#gage-summary-container {
  height: 100%;
  overflow-y: auto;
  scrollbar-width: thin;
  scrollbar-color: var(--grey_3_1) #FCFCFC;
  padding-right: 5px; /* add a little padding for cases when scroll needed */
}
#status-statement-container {
  display: flex;
  justify-content: space-between;
  padding-top: 2.25rem;
  padding-bottom: 1.25rem;
  min-height: 35px;
  align-items: center;
  @media only screen and (min-width: 641px) {
    padding-top: 2.5rem;
    padding-bottom: 1.5rem;
  }
}
#status-statement-container p {
  padding: 0;
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
#context-container {
  margin-top: 4rem;
}
</style>