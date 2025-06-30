<template>
  <section>
    <p>Of <span class="slight-emph">{{ siteList.length }}</span> sites in <span class="slight-emph">{{ selectedExtent }}</span>,</p>
    <p> <span class="slight-emph">{{ buildSummary(sitesExtreme.length) }}</span> are {{ preface }}in <span class="highlight extreme slight-emph">extreme drought</span></p>
    <p> <span class="slight-emph">{{ buildSummary(sitesSevere.length) }}</span> are {{ preface }}in <span class="highlight severe slight-emph">severe drought</span></p>
    <p> <span class="slight-emph">{{ buildSummary(sitesModerate.length) }}</span> are {{ preface }}in <span class="highlight moderate slight-emph">moderate drought</span></p>
  </section>
</template>

<script setup>
  import { computed, inject } from 'vue';

  // inject values
  const { selectedWeek } = inject('dates');
  const { siteList } = inject('sites')
  const { currentConditions } = inject('conditions')
  const { selectedExtent } = inject('extents')

  // Global variables
  const preface = computed(() => {
    return selectedWeek.value > 0 ? 'forecast to be ' : '';
  })

  // Define sites{Category}, based on currentConditions (which is computed based on selectedExtent and selectedDate)
  const sitesExtreme = computed(() => {
    return currentConditions.value.filter(d => d.pd < 5);
  })
  const sitesSevere = computed(() => {
    return currentConditions.value.filter(d => d.pd < 10 && d.pd >= 5);
  })
  const sitesModerate = computed(() => {
    return currentConditions.value.filter(d => d.pd < 20 && d.pd >= 10);
  })

  // Build summary values
  function buildSummary(nCategory) {
    const percentCategory = (nCategory / siteList.value.length) * 100;
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

<style>
</style>