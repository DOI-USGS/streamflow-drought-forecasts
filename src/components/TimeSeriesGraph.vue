<template>
  <div
    id="timeseries-graph"
  >
    <div
      id="graph-legend"
      class="legend"
    >
      <p
        id="timeseries-title"
      >
        <span>Timeseries of observed and forecast conditions</span>
      </p>
      <div
        id="legend-container"
        aria-hidden="true"
      >
        <div
          id="legend-content"
        >
          <div>
            <span 
              class="graph-legend-title slight-emph" 
            >
              Drought category
            </span>
            <span
              v-for="droughtCat, index in droughtCats"
              :key="index"
              class="timeseries-legend-key-container"
            >
              <span :style="{ 'background-color': droughtCat.color }" />{{ droughtCat.text }}
            </span>
          </div>
          <div> 
            <span
              class="graph-legend-title slight-emph" 
            >
              Observed streamflow
            </span>
            <span
              class="streamflow-legend-key-container"
            >
              <span />Last 90 days
            </span>
            <span
              class="streamflow-legend-box-container"
            >
              <span />Yesterday
            </span>
          </div>
          <div>
            <span
              class="graph-legend-title slight-emph" 
            >
              Forecast streamflow
            </span>
            <span
              class="forecast-legend-point-container"
            >
              <span />Median
            </span>
            <span
              class="forecast-legend-box-container"
            >
              <span />Uncertainty
            </span>
          </div>
        </div>
      </div>
    </div>
    <D3Chart 
      chart-id-prefix="timeseries"
      :layout="layout"
      :chart-title="`Timeseries of observed and forecast conditions for USGS gage ${globalDataStore.selectedSite}`"
      chart-description="description of chart"
      :enable-focus="false"
    >
      <template #chartTitle />
      <template #renderedContent>
        <TimeSeriesGraphAxes
          v-if="initialLoadingComplete"
          :offset-x-axis="config.DATA_STATUS_BAR_HEIGHT[screenCategory]"
          :x-scale="xScale"
          :left-y-scale="yScale"
          :left-y-tick-values="yTicks.tickValues"
          :left-y-tick-format="yTicks.tickFormat"
          :left-y-tick-size-inner="-layout.width-layout.margin.left*0.05"
          :left-y-tick-offset="-layout.margin.left*0.05"
          left-y-label="cfs"
          :left-y-label-x="-layout.margin.left*0.05*2"
          :left-y-label-y="-layout.margin.top"
          left-y-label-rotate-angle="0"     
          left-y-label-text-anchor="end"   
          left-y-label-dominant-baseline="hanging"  
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
        <Threshold20Graph 
          v-if="initialLoadingComplete"
          :initial-loading-complete="initialLoadingComplete"
          :transform="dataGroupTransform"
          :threshold-data="threshold20Dataset"
          :y-scale="yScale"
          :x-scale="xScale"
          parent-chart-id-prefix="timeseries"
        />
        <Threshold30Graph 
          v-if="initialLoadingComplete"
          :initial-loading-complete="initialLoadingComplete"
          :transform="dataGroupTransform"
          :threshold-data="threshold30Dataset"
          :y-scale="yScale"
          :x-scale="xScale"
          parent-chart-id-prefix="timeseries"
        />
        <OverlaysLowerGraph
          v-if="initialLoadingComplete"
          :initial-loading-complete="initialLoadingComplete"
          :transform="dataGroupTransform"
          :overlays-lower-data="overlaysLowerDataset"
          :y-scale="yScale"
          :x-scale="xScale"
          parent-chart-id-prefix="timeseries"
        />
        <OverlaysUpperGraph
          v-if="initialLoadingComplete"
          :initial-loading-complete="initialLoadingComplete"
          :transform="dataGroupTransform"
          :overlays-upper-data="overlaysUpperDataset"
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
        <IssueDateGraph
          v-if="initialLoadingComplete"
          :initial-loading-complete="initialLoadingComplete"
          :transform="dataGroupTransform"
          :y-scale="yScale"
          :x-scale="xScale"
          parent-chart-id-prefix="timeseries"
        />
        <DroughtsBar
          v-if="initialLoadingComplete"
          :initial-loading-complete="initialLoadingComplete"
          :streamflow-droughts-data="streamflowDroughtsDataset"
          :forecast-droughts-data="forecastMediansDataset"
          :x-scale="xScale"
          :layout="layout"
          :indicator-offset="config.DATA_STATUS_BAR_INDICATOR_OFFSET[screenCategory]"
          :bar-height="config.DATA_STATUS_BAR_HEIGHT[screenCategory]"
        />
        <CurrentStreamflowGraph 
          v-if="initialLoadingComplete && !globalDataStore.droughtStatusNA"
          :initial-loading-complete="initialLoadingComplete"
          :transform="dataGroupTransform"
          :current-streamflow-data="currentStreamflowDataset"
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
      </template>
    </D3Chart>
    <div
      id="graph-control-container"
    >
      <ToggleSwitch
        id="log-linear-toggle"
        v-model="toggleInfo.scaleLog"
        :left-label="toggleInfo.leftLabel"
        :right-label="toggleInfo.rightLabel"
        right-color="var(--inactive-grey)"
        aria-label="Use log scale"
      />
      <GraphButtonDialog
        :show-prompt="true"
      />
    </div>  
  </div>
</template>

<script setup>
  import { computed, onBeforeMount, reactive, ref, watch, watchEffect } from "vue";
  import { storeToRefs } from "pinia";

  import config from "@/assets/scripts/config.js";

  import { useScreenCategory } from "@/assets/scripts/composables/media-query";
  import { useTimeSeriesLayout } from "@/assets/scripts/composables/time-series-layout";
  import { timeScale, waterDataScale } from "@/assets/scripts/d3/time-series-scale";
  import { getWaterDataTicks } from "@/assets/scripts/d3/time-series-tick-marks";
  import { useGlobalDataStore } from "@/stores/global-data-store";
  import { useTimeseriesDataStore } from "@/stores/timeseries-data-store";
  import { useTimeseriesGraphStore } from "@/stores/timeseries-graph-store";
  import GraphButtonDialog from './GraphButtonDialog.vue';
  import D3Chart from "./D3Chart.vue";
  import TimeSeriesGraphAxes from "./TimeSeriesGraphAxes.vue";
  import UncertaintyGraph from "./UncertaintyGraph.vue";
  import ThresholdsGraph from "./ThresholdsGraph.vue";
  import Threshold20Graph from "./Threshold20Graph.vue";
  import Threshold30Graph from "./Threshold30Graph.vue";
  import OverlaysLowerGraph from "./OverlaysLowerGraph.vue";
  import OverlaysUpperGraph from "./OverlaysUpperGraph.vue";
  import StreamflowGraph from "./StreamflowGraph.vue";
  import IssueDateGraph from "./IssueDateGraph.vue";
  import CurrentStreamflowGraph from "./CurrentStreamflowGraph.vue";
  import ForecastGraph from "./ForecastGraph.vue";
  import DroughtsBar from "./DroughtsBar.vue";
  import ToggleSwitch from "./ToggleSwitch.vue";

  /*
  * @vue-prop {Number} containerWidth - The width of the container for this component.
  */
  const props = defineProps({
    containerWidth: {
      type: Object,
      default: () => ({}),
      required: true,
    }
  });

  //global variables
  const globalDataStore = useGlobalDataStore();
  const timeseriesDataStore = useTimeseriesDataStore();
  const timeseriesGraphStore = useTimeseriesGraphStore();
  const { selectedSite } = storeToRefs(globalDataStore);
  const { scaleKind } = storeToRefs(timeseriesGraphStore);
  let previousSite = '';
  const siteHasChanged = ref(false);
  const screenCategory = useScreenCategory();
  const initialLoadingComplete = ref(false);
  const droughtCats = [
    { text: 'Moderate', color: "rgb(var(--color-moderate))" }, 
    { text: 'Severe', color: "rgb(var(--color-severe))" },
    { text: 'Extreme', color: "rgb(var(--color-extreme))" }
  ];

  // log/linear toggle
  // set up reactive variable
  const toggleInfo = reactive(
    {
      leftLabel: 'linear',
      rightLabel: 'log',
      scaleLog: scaleKind.value == 'log',
    }
  );
  // Watches toggleInfo for changes
  watch(toggleInfo, () => {
    scaleKind.value = toggleInfo.scaleLog ? 'log' : 'linear';
    siteHasChanged.value = false;
  });

  const dataGroupTransform = computed(
    () => `translate(${layout.value.margin.left},${layout.value.margin.top})`,
  );

  const streamflowDataset = computed(() => {
    return timeseriesDataStore.getDataset(selectedSite.value, "streamflow")
  })

  const currentStreamflowDataset = computed(() => {
    return timeseriesDataStore.getFilteredDataset(selectedSite.value, "streamflow", "dt", globalDataStore.currentStreamflowDate)
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

  const threshold20Dataset = computed(() => {
    return timeseriesDataStore.getFilteredDataset(selectedSite.value, "thresholds", "pd", "20")
  })  

  const threshold30Dataset = computed(() => {
    return timeseriesDataStore.getFilteredDataset(selectedSite.value, "thresholds", "pd", "30")
  })  

  const overlaysLowerDataset = computed(() => {
    return timeseriesDataStore.getDataset(selectedSite.value, "overlays_lower")
  })

  const overlaysUpperDataset = computed(() => {
    return timeseriesDataStore.getDataset(selectedSite.value, "overlays_upper")
  })

  const streamflowDroughtsDataset = computed(() => {
    return timeseriesDataStore.getDataset(selectedSite.value, "streamflow_droughts")
  })

  const xDomain = computed(() => {
    const timeDomain = globalDataStore.timeDomainData;
    let xDomainMin;
    let xDomainMax;
    if (timeDomain?.length) {
      xDomainMin = globalDataStore.timeDomainStart;
      xDomainMax = globalDataStore.timeDomainEnd;
    }
    return [xDomainMin, xDomainMax];
  })

  const xScale = computed(() => {
    return timeScale(
      xDomain.value,
      layout.value.width,
    );
  });

  const yDomain = computed(() => {
    const streamflowDomain =
      timeseriesDataStore.getDatasetResultDomain(selectedSite.value, "streamflow") || [];
    const forecastsDomain =
      timeseriesDataStore.getDatasetResultDomain(selectedSite.value, "forecasts") || [];
    const thresholdsDomain =
      timeseriesDataStore.getDatasetResultDomain(selectedSite.value, "thresholds", "result_max") || [];
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
      return undefined;
    }
  });

  const yScale = computed(() => {
    return waterDataScale(
      yDomain.value,
      layout.value.height,
      scaleKind.value == "log",
      false,
    );
  });

  const yTicks = computed(() =>
    getWaterDataTicks(yDomain.value, scaleKind.value == "log", false),
  );
  const layout = computed(() => {
    return useTimeSeriesLayout(props.containerWidth, yDomain.value, scaleKind.value == "log").value;
  })

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
      const fetchOverlaysLowerDataPromise = timeseriesDataStore
        .fetchAndAddDatasets(selectedSite.value, "overlays_lower", ["result_min", "result_max"])
      fetchDataPromises.push(fetchOverlaysLowerDataPromise);
      const fetchOverlaysUpperDataPromise = timeseriesDataStore
        .fetchAndAddDatasets(selectedSite.value, "overlays_upper", ["result_min", "result_max"])
      fetchDataPromises.push(fetchOverlaysUpperDataPromise);
      const fetchStreamflowDroughtsDataPromise = timeseriesDataStore
        .fetchAndAddDatasets(selectedSite.value, "streamflow_droughts", [])
      fetchDataPromises.push(fetchStreamflowDroughtsDataPromise);
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
    const fetchStreamflowDataPromise = timeseriesDataStore
      .fetchAndAddDatasets(selectedSite.value, "streamflow", ["result"])
    fetchDataPromises.push(fetchStreamflowDataPromise);
    const fetchForecastDataPromise = timeseriesDataStore
      .fetchAndAddDatasets(selectedSite.value, "forecasts", ["result"])
    fetchDataPromises.push(fetchForecastDataPromise);
    const fetchThresholdsDataPromise = timeseriesDataStore
      .fetchAndAddDatasets(selectedSite.value, "thresholds", ["result_min", "result_max"])
    fetchDataPromises.push(fetchThresholdsDataPromise);
    const fetchOverlaysLowerDataPromise = timeseriesDataStore
      .fetchAndAddDatasets(selectedSite.value, "overlays_lower", ["result_min", "result_max"])
    fetchDataPromises.push(fetchOverlaysLowerDataPromise);
    const fetchOverlaysUpperDataPromise = timeseriesDataStore
      .fetchAndAddDatasets(selectedSite.value, "overlays_upper", ["result_min", "result_max"])
    fetchDataPromises.push(fetchOverlaysUpperDataPromise);
    const fetchStreamflowDroughtsDataPromise = timeseriesDataStore
      .fetchAndAddDatasets(selectedSite.value, "streamflow_droughts", [])
    fetchDataPromises.push(fetchStreamflowDroughtsDataPromise);
    Promise.all(fetchDataPromises).then(() => {
      initialLoadingComplete.value = true;
    });

  })
</script>

<style lang="scss">
  $legend-spacing: 8px;
  #graph-legend {
    font-weight: 300;
    line-height: 2.4rem;
    margin-bottom: 1rem;
  }
  #timeseries-graph #timeseries-title {
    border-bottom: 1px solid var(--grey_1pt25_1);
    padding: 0rem 0 0 0;
    margin-bottom: 1rem;
  }
  #timeseries-title span {
    position: relative;
    top: 0.3rem;
    @media only screen and (min-width: 641px) {
      top: 0.2rem;
    }
  }
  #legend-content {
    font-size: 1.6rem;
  }
  #graph-legend .graph-legend-title {
    margin-right: 4px;
  }
  .streamflow-legend-key-container {
    margin-right: $legend-spacing;
  }
  .streamflow-legend-key-container span {
    display: inline-block;
    height: 1.8px;
    margin-bottom: 3.5px;
    margin-right: 5px;
    width: 15px;
    background-color: var(--grey_15_1);
    border: none;
  }
  .streamflow-legend-box-container {
    white-space: nowrap;
  }
  .streamflow-legend-box-container span {
    border-radius: 0px;
    display: inline-block;
    height: 8px;
    margin-left: 2.5px;
    margin-right: 5px;
    width: 8px;
    border: 1px solid var(--grey_6_1);
    transform: rotate(45deg);
  }
  .timeseries-legend-key-container {
    margin-right: $legend-spacing;
    white-space: nowrap;
  }
  .timeseries-legend-key-container span {
    border-radius: 2px;
    display: inline-block;
    height: 12px;
    margin-right: 5px;
    width: 12px;
    background: linear-gradient(to left top, rgba(255, 255, 255, 0.55) 50%, rgba(255, 255, 255, 0) 50%);
    border: 0.5px solid var(--grey_3_1);
  }
  .forecast-legend-point-container {
    margin-right: $legend-spacing;
  }
  .forecast-legend-point-container span {
    border-radius: 5.5px;
    display: inline-block;
    height: 11px;
    margin-right: 5px;
    width: 11px;
    border: 1px solid var(--grey_6_1);
  }
  .forecast-legend-box-container {
    white-space: nowrap;
  }
  .forecast-legend-box-container span {
    border-radius: 0px;
    display: inline-block;
    height: 15px;
    margin-right: 5px;
    width: 8px;
    border: 0.5px solid var(--grey_4pt6_1);
  }
  #timeseries-graph {
    margin: 2rem auto 0rem auto;
  }
  #graph-control-container {
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
    margin-top: 0.5rem;
  }
  #log-linear-toggle {
    font-size: 1.6rem;
    font-weight: 300;
  }
</style>