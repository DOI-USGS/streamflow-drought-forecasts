<template>
  <section>
    <p>Summary for {{ selectedExtent }}</p>
    <p>The default is {{ defaultExtent }}</p>
    <p>{{ selectedExtent == defaultExtent }}</p>
    <p> {{ siteSubset.length }} sites</p>
  </section>
</template>

<script setup>
  import { computed, inject } from 'vue';

  // inject values
  const { siteInfoData } = inject('sites')
  const { defaultExtent, selectedExtent } = inject('extents')

  // Define siteSubset, based on selectedSite
  const siteSubset = computed(() => {
    if (selectedExtent.value == defaultExtent.value) {
      return ['a', 'b', 'c', 'd', 'e']//siteInfoData.map(d => d.StaID);
    } else {
      const siteInfoSubset = siteInfoData.value.filter(d => d.state == selectedExtent);
      return ['a', 'b', 'c']
      return siteInfoSubset.map(d => d.StaID);
    }
  })
</script>

<style>
</style>