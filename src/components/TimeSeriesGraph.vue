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
        <TimeSeriesGraphAxes
          :x-scale="xScale"
          :left-y-scale="yScale"
          :left-y-tick-values="yTicks.tickValues"
          :left-y-tick-format="yTicks.tickFormat"
          :layout="layout"
        />
        <StreamflowGraph 
          :transform="dataGroupTransform"
          :streamflow-data="dataset"
          :y-domain="yDomain"
          :x-domain="xDomain"
        />
      </template>
    </D3Chart>
    <button @click="chageScaleKind()">
      {{ scaleKind }}
    </button>
  </div>
</template>

<script setup>
  import { computed, inject, onBeforeMount, onMounted, ref, watch } from "vue";
  import { storeToRefs } from "pinia";
  import * as d3 from "d3-fetch"; // import smaller set of modules
  import { timeScale, waterDataScale } from "@/assets/scripts/d3/time-series-scale";
  import { getWaterDataTicks } from "@/assets/scripts/d3/time-series-tick-marks";
  import { useTimeseriesDataStore } from "@/stores/timeseries-data-store";
  import D3Chart from "./D3Chart.vue";
  import TimeSeriesGraphAxes from "./TimeSeriesGraphAxes.vue";
  import StreamflowGraph from "./StreamflowGraph.vue";

  // Inject data
  const { selectedSite } = inject('sites')

  //global variables  
  const publicPath = import.meta.env.BASE_URL;
  const timeseriesDataStore = useTimeseriesDataStore();
  const { scaleKind } = storeToRefs(timeseriesDataStore);
  const timeDomainData = ref(null);
  const datasetConfigs = [
    { file: 'timeseries_x_domain.csv', ref: timeDomainData, type: 'csv', numericFields: []}
  ]
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

  const dataGroupTransform = computed(
    () => `translate(${layout.margin.left},${layout.margin.top})`,
  );

  const dataset = computed(() => {
    return timeseriesDataStore.getDataset(selectedSite.value, "streamflow")
  })

  const xDomain = computed(() => {
    const timeDomain = timeDomainData?.value
    let xDomainMin;
    let xDomainMax;
    if (timeDomain?.length) {
      xDomainMin = timeDomain[0].start;
      xDomainMax = timeDomain[0].end;
    }
    return [xDomainMin, xDomainMax];
  })

  const xScale = computed(() => {
    return timeScale(
      xDomain.value,
      layout.width,
    );
  });

  const yDomain = computed(() => {
    const streamflowDomain =
      timeseriesDataStore.getDatasetResultDomain(selectedSite.value, "streamflow") || [];
    // const measurementsDomain =
    //   fieldMeasurementsStore.getResultDomain(
    //     datastream.value.monitoringLocationNumber,
    //     datastream.value.observedProperty.parameterCode,
    //   ) || [];
    let lowYDomain = [];
    let highYDomain = [];
    if (streamflowDomain.length) {
      lowYDomain.push(streamflowDomain[0]);
      highYDomain.push(streamflowDomain[1]);
    }
    // if (measurementsDomain.length) {
    //   lowYDomain.push(measurementsDomain[0]);
    //   highYDomain.push(measurementsDomain[1]);
    // }
    // if (medianStatsDomain.value.length) {
    //   lowYDomain.push(medianStatsDomain.value[0]);
    //   highYDomain.push(medianStatsDomain.value[1]);
    // }
    if (lowYDomain.length && highYDomain.length) {
      return [Math.min(...lowYDomain), Math.max(...highYDomain)];
    } else {
      return [];
    }
  });

  const yScale = computed(() => {
    return waterDataScale(
      yDomain.value,
      layout.height,
      scaleKind.value == "log",
      false,
    );
  });

  const yTicks = computed(() =>
    getWaterDataTicks(yDomain.value, scaleKind.value == "log", false),
  );

  // 
  watch(selectedSite, (newValue) => {
    const storedDataset = timeseriesDataStore.getDataset(selectedSite.value, "streamflow")
    console.log('stored dataset')
    console.log(storedDataset)
    const storedDatasets = timeseriesDataStore.getDatasets(selectedSite.value)
    console.log('stored datasets')
    console.log(storedDatasets)
    if (!storedDatasets.length > 0) {
      timeseriesDataStore.fetchAndAddDatasets(newValue, "streamflow");
    } else {
      console.log('have data already')
    }
  });

  onBeforeMount(() => {
    timeseriesDataStore.fetchAndAddDatasets(selectedSite.value, "streamflow")
  })

  onMounted(async () => {
    console.log('on mounted')
    console.log(dataset.value)

    await loadDatasets(datasetConfigs);
  });

  async function loadDatasets(configs) {
    for (const { file, ref, type, numericFields} of configs) {
      try {
        ref.value = await loadData(file, type, numericFields);
        console.log(`${file} data in`);
      } catch (error) {
        console.error(`Error loading ${file}`, error);
      }
    }
  }

  async function loadData(dataFile, dataType, dataNumericFields) {
    try {
      let data;
      if (dataType == 'csv') {
        data = await d3.csv(publicPath + dataFile, d => {
          if (dataNumericFields) {
            dataNumericFields.forEach(numericField => {
              d[numericField] = +d[numericField]
            });
          }
          return d;
        });
      } else if (dataType == 'json') {
        data = await d3.json(publicPath + dataFile);
      } else {
        console.error(`Data type ${dataType} is not supported. Data type must be 'csv' or 'json'`)
      }

      return data;
    } catch (error) {
      console.error(`Error loading data from ${dataFile}`, error);
      return [];
    }
  }

  function chageScaleKind() {
    const currentScaleKind = scaleKind.value
    scaleKind.value = currentScaleKind == "log" ? "linear" : "log"
  }
</script>

<style>
</style>