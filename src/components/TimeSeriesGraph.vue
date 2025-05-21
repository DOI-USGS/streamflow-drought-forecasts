<template>
  <div>
    <D3Chart 
      chart-id-prefix="timeseries"
      :layout="layout"
      chart-title="title of chart"
      chart-description="description of chart"
      :enable-focus="true"
    >
      <template #chartTitle>
        <h3>main title</h3>
      </template>
      <template #renderedContent>
        <g id="line-group">
          <path d="M 10,30 A 20,20 0,0,1 50,30" />
        </g>
      </template>
    </D3Chart>
  </div>
</template>

<script setup>
  import D3Chart from './D3Chart.vue';

  //global variables
  const layout = {
    height: 300,
    width: 300,
    margin: {
        top: 10,
        right: 50,
        bottom: 20,
        left: 30
    }
  }
</script>

<style>
</style>