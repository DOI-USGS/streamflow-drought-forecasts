<template>
  <section>
    <div
      id="extent-summary-intro-container"
    >
      <p>Of <span class="slight-emph">{{ globalDataStore.siteList.length }}</span> sites in <span class="slight-emph">{{ globalDataStore.selectedExtent }}</span>,</p>
      <FaqButton />
    </div>
    <p>
      <span 
        v-if="globalDataStore.sitesExtreme"
        class="slight-emph"
      >
        {{ buildSummary(globalDataStore.sitesExtreme?.length) }}
      </span>
      are {{ summaryPreface }}in 
      <span class="highlight extreme slight-emph">extreme drought</span>
    </p>
    <p>
      <span 
        v-if="globalDataStore.sitesSevere"
        class="slight-emph"
      >
        {{ buildSummary(globalDataStore.sitesSevere?.length) }}
      </span> 
      are {{ summaryPreface }}in 
      <span class="highlight severe slight-emph">severe drought</span>
    </p>
    <p>
      <span  
        v-if="globalDataStore.sitesModerate"
        class="slight-emph"
      >
        {{ buildSummary(globalDataStore.sitesModerate?.length) }}
      </span> 
      are {{ summaryPreface }}in 
      <span class="highlight moderate slight-emph">moderate drought</span>
    </p>
  </section>
</template>

<script setup>
  import { computed } from 'vue';
  import { useGlobalDataStore } from "@/stores/global-data-store";
  import FaqButton from './FaqButton.vue';

  // Global variables
  const globalDataStore = useGlobalDataStore();
  const summaryPreface = computed(() => {
    return globalDataStore.dataType == 'Forecast' ? 'forecast to be ' : '';
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
  #extent-summary-intro-container {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 10px;
  }
  #extent-summary-intro-container p {
    line-height: 35px;
    padding: 0;
  }
</style>