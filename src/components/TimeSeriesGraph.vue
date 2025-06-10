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
          v-if="initialLoadingComplete"
          :x-scale="xScale"
          :left-y-scale="yScale"
          :left-y-tick-values="yTicks.tickValues"
          :left-y-tick-format="yTicks.tickFormat"
          :layout="layout"
          :scale-kind="scaleKind"
          :new-time-series="siteHasChanged"
        />
        <ThresholdsGraph 
          v-if="initialLoadingComplete"
          :initial-loading-complete="initialLoadingComplete"
          :transform="dataGroupTransform"
          :thresholds-data="thresholdsDataset"
          :y-scale="yScale"
          :x-scale="xScale"
          parent-chart-id-prefix="timeseries"
        />
        <UncertaintyGraph 
          v-if="initialLoadingComplete"
          :initial-loading-complete="initialLoadingComplete"
          :transform="dataGroupTransform"
          :uncertainty-data="forecastWideDataset"
          :y-scale="yScale"
          :x-scale="xScale"
          parent-chart-id-prefix="timeseries"
        />
        <StreamflowGraph 
          v-if="initialLoadingComplete"
          :initial-loading-complete="initialLoadingComplete"
          :transform="dataGroupTransform"
          :streamflow-data="streamflowDataset"
          :y-scale="yScale"
          :x-scale="xScale"
          parent-chart-id-prefix="timeseries"
        />
        <ForecastGraph 
          v-if="initialLoadingComplete"
          :initial-loading-complete="initialLoadingComplete"
          :transform="dataGroupTransform"
          :forecast-data="forecastMediansDataset"
          :y-scale="yScale"
          :x-scale="xScale"
          parent-chart-id-prefix="timeseries"
        />
        <!-- <g
          v-if="initialLoadingComplete"
          ref="plotDataLinesGroup"
          class="plot-data-lines-group"
          :transform="dataGroupTransform"
        /> -->
      </template>
    </D3Chart>
    <button @click="toggleScaleKind()">
      {{ scaleKind }}
    </button>
  </div>
</template>

<script setup>
  import { computed, inject, onBeforeMount, ref, watch, watchEffect } from "vue";
  import { storeToRefs } from "pinia";
  import * as d3 from "d3-fetch"; // import smaller set of modules
  // import { select } from "d3-selection";
  import { timeScale, waterDataScale } from "@/assets/scripts/d3/time-series-scale";
  import { getWaterDataTicks } from "@/assets/scripts/d3/time-series-tick-marks";
  // import { drawDataSegments } from "@/assets/scripts/d3/time-series-lines";
  import { useTimeseriesDataStore } from "@/stores/timeseries-data-store";
  import { useTimeseriesGraphStore } from "@/stores/timeseries-graph-store";
  import D3Chart from "./D3Chart.vue";
  import TimeSeriesGraphAxes from "./TimeSeriesGraphAxes.vue";
  import UncertaintyGraph from "./UncertaintyGraph.vue";
  import ThresholdsGraph from "./ThresholdsGraph.vue";
  import StreamflowGraph from "./StreamflowGraph.vue";
  import ForecastGraph from "./ForecastGraph.vue";

  // Inject data
  const { selectedSite } = inject('sites')

  //global variables  
  let previousSite = '';
  const siteHasChanged = ref(false);
  const publicPath = import.meta.env.BASE_URL;
  const timeseriesDataStore = useTimeseriesDataStore();
  const timeseriesGraphStore = useTimeseriesGraphStore();
  const { scaleKind } = storeToRefs(timeseriesGraphStore);
  const initialLoadingComplete = ref(false);
  const timeDomainData = ref(null);
  const datasetConfigs = [
    { file: 'timeseries_x_domain.csv', ref: timeDomainData, type: 'csv', numericFields: []}
  ]
  // const plotDataLinesGroup = ref(null);
  const layout = {
    height: 300,
    width: 300,
    margin: {
        top: 10,
        right: 50,
        bottom: 20,
        left: 40
    }
  }

  const dataGroupTransform = computed(
    () => `translate(${layout.margin.left},${layout.margin.top})`,
  );

  const streamflowDataset = computed(() => {
    return timeseriesDataStore.getDataset(selectedSite.value, "streamflow")
  })

  const forecastMediansDataset = computed(() => {
    return timeseriesDataStore.getFilteredDataset(selectedSite.value, "forecasts", "parameter", "median")
  })  

  const forecastWideDataset = computed(() => {
    const siteId = selectedSite.value
    const dataType = "forecasts"
    const groupIdentifier = "dt"
    const dataset = timeseriesDataStore.getDataset(siteId, dataType)
    const wideDataset = {}
    wideDataset.datasetID = siteId + dataType
    wideDataset.siteId = siteId
    wideDataset.dataType = dataType
    wideDataset.values = []
    function pivotData(data, indexKey, columnKey, valueKey) {
      return data.reduce((acc, item) => {
        const indexValue = item[indexKey];
        const columnValue = item[columnKey];
        const value = item[valueKey];

        if (!acc[indexValue]) {
          acc[indexValue] = {};
        }

        acc[indexValue][indexKey] = indexValue;
        acc[indexValue][columnValue] = value;

        return acc;
      }, {});
    }
    const pivotedData = pivotData(dataset.values, groupIdentifier, "parameter", "result")
    wideDataset.values = Object.values(pivotedData)
    return(wideDataset)
  })

  const thresholdsDataset = computed(() => {
    return timeseriesDataStore.getDataset(selectedSite.value, "thresholds")
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
    const forecastsDomain =
      timeseriesDataStore.getDatasetResultDomain(selectedSite.value, "forecasts") || [];
    const thresholdsDomain =
      timeseriesDataStore.getDatasetResultDomain(selectedSite.value, "thresholds", "result") || [];
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
    if (forecastsDomain.length) {
      lowYDomain.push(forecastsDomain[0]);
      highYDomain.push(forecastsDomain[1]);
    }
    if (thresholdsDomain.length) {
      lowYDomain.push(thresholdsDomain[0]);
      highYDomain.push(thresholdsDomain[1]);
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

  // Update data when site changes
  watch(selectedSite, (newValue) => {
    const storedDatasets = timeseriesDataStore.getDatasets(selectedSite.value)
    if (!storedDatasets.length > 0) {
      initialLoadingComplete.value = false;
      let fetchDataPromises = [];
      const fetchStreamflowDataPromise = timeseriesDataStore
        .fetchAndAddDatasets(newValue, "streamflow", ["result"])
      fetchDataPromises.push(fetchStreamflowDataPromise);
      const fetchForecastDataPromise = timeseriesDataStore
        .fetchAndAddDatasets(selectedSite.value, "forecasts", ["result"])
      fetchDataPromises.push(fetchForecastDataPromise);
      const fetchThresholdsDataPromise = timeseriesDataStore
        .fetchAndAddDatasets(selectedSite.value, "thresholds", ["result_min", "result_max"])
      fetchDataPromises.push(fetchThresholdsDataPromise);
      Promise.all(fetchDataPromises).then(() => {
        initialLoadingComplete.value = true;
      });
    } else {
      console.log('Have data already. No need to fetch data')
    }
  });

  watchEffect(() => {
    if (selectedSite.value !== previousSite) {
      siteHasChanged.value = true;
      previousSite = selectedSite.value
    } else {
      siteHasChanged.value = false;
    }
  })

  onBeforeMount(() => {
    /* Fetch all data needed to set the scale of the time series graph */
    let fetchDataPromises = [];
    const datasetsPromises = loadDatasets(datasetConfigs);
    fetchDataPromises.push(datasetsPromises);
    const fetchStreamflowDataPromise = timeseriesDataStore
      .fetchAndAddDatasets(selectedSite.value, "streamflow", ["result"])
    fetchDataPromises.push(fetchStreamflowDataPromise);
    const fetchForecastDataPromise = timeseriesDataStore
      .fetchAndAddDatasets(selectedSite.value, "forecasts", ["result"])
    fetchDataPromises.push(fetchForecastDataPromise);
    const fetchThresholdsDataPromise = timeseriesDataStore
        .fetchAndAddDatasets(selectedSite.value, "thresholds", ["result_min", "result_max"])
      fetchDataPromises.push(fetchThresholdsDataPromise);
    Promise.all(fetchDataPromises).then(() => {
      initialLoadingComplete.value = true;
    });

  })

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

  function toggleScaleKind() {
    const currentScaleKind = scaleKind.value
    scaleKind.value = currentScaleKind == "log" ? "linear" : "log"
    siteHasChanged.value = false;
  }
</script>

<style lang="scss">
  .ts-line {
    fill: none;
    stroke: black;
    stroke-width: 2;
  }
</style>