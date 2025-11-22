<template>
  <section
    id="extent-summary-container"
  >
    <div
      id="extent-summary-intro-container-wrapper"
    >
      <div
        :id="containerID"
      >
        <FaqButton 
          id="intro-faq-button"
          data-open-modal
          aria-controls="faq-dialog"
        />
        <div
          id="intro-text-container"
        >
          <p>
            <span>
              Of
              <span class="slight-emph">{{ globalDataStore.siteList?.length.toLocaleString('en-US') }}</span>
            </span>
            sites in 
            <span 
              v-if="globalDataStore.selectedExtent"
              class="slight-emph"
            >
              {{ globalDataStore.selectedExtent }}
            </span>
            <span
              v-else
            >
              <span class="tooltip-group">
                <span class="tooltip-span">
                  {{ globalDataStore.defaultExtent }}              
                  <span 
                    id="conus-tooltip" 
                    class="tooltiptext"
                  >
                    The conterminous United States, or the lower 48 states.
                  </span>
                </span>
              </span>
            </span>
            <span>,</span>
            <span v-if="globalDataStore.dataType == 'Forecast'"> the forecast is for</span>
          </p>
        </div>
      </div>
      <div
        v-if="globalDataStore.dataType == 'Observed' && globalDataStore.sitesNA?.length > 0"
        id="current-data-statement-container"
      >
        <p>
          <span
            class="slight-emph"
          >
            {{ (globalDataStore.siteList?.length - globalDataStore.sitesNA?.length).toLocaleString('en-US') }}
          </span>
          <span v-if="globalDataStore.siteList?.length - globalDataStore.sitesNA?.length == 1"> has</span>
          <span v-else> have</span>
          current streamflow data. Of these,
        </p>
      </div>
    </div>
    <p>
      <span  
        v-if="globalDataStore.sitesDrought"
        :class="globalDataStore.sitesDrought?.length > 0 ? 'slight-emph' : ''"
      >
        {{ buildSummary(globalDataStore.sitesDrought?.length, false) }}
      </span> 
      {{ mainSummaryPreface }}in streamflow drought, with
    </p>
    <p>
      <span  
        v-if="globalDataStore.sitesModerate"
        :class="globalDataStore.sitesModerate?.length > 0 ? 'slight-emph' : ''"
      >
        {{ buildSummary(globalDataStore.sitesModerate?.length, false) }}
      </span> 
      in 
      <span class="highlight moderate slight-emph">moderate</span>
      streamflow drought
    </p>
    <p>
      <span 
        v-if="globalDataStore.sitesSevere"
        :class="globalDataStore.sitesSevere?.length > 0 ? 'slight-emph' : ''"
      >
        {{ buildSummary(globalDataStore.sitesSevere?.length, false) }}
      </span> 
      in 
      <span class="highlight severe slight-emph">severe</span>
      streamflow drought
    </p>
    <p>
      <span 
        v-if="globalDataStore.sitesExtreme"
        :class="globalDataStore.sitesExtreme?.length > 0 ? 'slight-emph' : ''"
      >
        {{ buildSummary(globalDataStore.sitesExtreme?.length, false) }}
      </span>
      in 
      <span class="highlight extreme slight-emph">extreme</span>
      streamflow drought
    </p>
  </section>
</template>

<script setup>
  import { computed, onMounted } from 'vue';
  import { useGlobalDataStore } from "@/stores/global-data-store";
  import FaqButton from './FaqButton.vue';

  // Global variables
  const globalDataStore = useGlobalDataStore();
  const containerID = 'extent-summary-intro-container'
  const mainSummaryPreface = computed(() => {
    return globalDataStore.dataType == 'Forecast' ? 'to be ' : 'are ';
  })

  onMounted(() => {
    // re-position tooltips that go off screen
    globalDataStore.positionTooltips(containerID)
  })

  // Build summary values
  function buildSummary(nCategory, includeNaSites) {
    let percentCategory;
    if (includeNaSites) {
      percentCategory = (nCategory / (globalDataStore.siteList?.length)) * 100;
    } else {
      percentCategory = (nCategory / (globalDataStore.siteList?.length - globalDataStore.sitesNA?.length)) * 100;
    }
    let percentCategoryRounded;
    switch(true) {
      case percentCategory < 0.05:
        percentCategoryRounded = Math.round(percentCategory * 100) / 100;
        break;
      case percentCategory < 1:
        percentCategoryRounded = Math.round(percentCategory * 10) / 10;
        break;
      default:
        percentCategoryRounded = Math.round(percentCategory);
    }
    return nCategory > 0 ? `${percentCategoryRounded}%` : 'None'
  }

</script>

<style scoped lang="scss">
  #extent-summary-container {
    margin-top: 1.5rem;
    @media only screen and (min-width: 641px) {
      margin-top: 1rem;
    }
  }
  #extent-summary-intro-container-wrapper {
    display: flex;
    flex-direction: column;
    margin-bottom: 0.5rem;
    @media only screen and (min-width: 641px) {
      margin-bottom: 1rem;
    }
  }
  #extent-summary-intro-container {
    display: flex;
    justify-content: space-between;
    align-items: end;
  }
  #current-data-statement-container {
    margin-bottom: 0.4rem;
    @media only screen and (min-width: 641px) {
      margin-bottom: 0.25rem;
    }
  }
  #intro-text-container {
    order: 1;
  }
  #intro-faq-button {
    order: 2;
  }
  #extent-summary-intro-container-wrapper p {
    padding: 0;
  }
  #extent-summary-intro-container p {
    line-height: 2.4rem;
    @media only screen and (min-width: 641px) {
      line-height: auto;
    }
  }
</style>