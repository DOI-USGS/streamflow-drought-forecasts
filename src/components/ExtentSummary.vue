<template>
  <section
    id="extent-summary-container"
  >
    <div
      :id="containerID"
    >
      <p>
        Of 
        <span class="slight-emph">{{ globalDataStore.siteList.length.toLocaleString('en-US') }}</span> 
        sites in 
        
        <span
          v-if="globalDataStore.selectedExtent == globalDataStore.defaultExtent"
        >
          <span class="tooltip-group">
            <span class="tooltip-span">
              {{ globalDataStore.selectedExtent }}              
              <span 
                id="conus-tooltip" 
                class="tooltiptext"
              >
                The conterminous United States, or the lower 48 states.
              </span>
            </span>
          </span>
        </span>
        <span 
          v-else
          class="slight-emph"
        >
          {{ globalDataStore.selectedExtent }}
        </span>,
        <span v-if="globalDataStore.dataType == 'Forecast'"> the forecast is for</span>
      </p>
      <FaqButton />
    </div>
    <p>
      <span  
        v-if="globalDataStore.sitesDrought"
        :class="globalDataStore.sitesDrought?.length > 0 ? 'slight-emph' : ''"
      >
        {{ buildSummary(globalDataStore.sitesDrought?.length) }}
      </span> 
      {{ mainSummaryPreface }}in streamflow drought, with
    </p>
    <p>
      <span  
        v-if="globalDataStore.sitesModerate"
        :class="globalDataStore.sitesModerate?.length > 0 ? 'slight-emph' : ''"
      >
        {{ buildSummary(globalDataStore.sitesModerate?.length) }}
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
        {{ buildSummary(globalDataStore.sitesSevere?.length) }}
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
        {{ buildSummary(globalDataStore.sitesExtreme?.length) }}
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
  function buildSummary(nCategory) {
    const percentCategory = (nCategory / globalDataStore.siteList.length) * 100;
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
  #extent-summary-intro-container {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 0.5rem;
    @media only screen and (min-width: 641px) {
      margin-bottom: 1rem;
    }
  }
  #extent-summary-intro-container p {
    line-height: 2.8rem;
    padding: 0;
    @media only screen and (min-width: 641px) {
      line-height: 3.5rem;
    }
  }
</style>