<template>
  <section id="page-container">
    <div id="dropdown-container">
      <select v-model="currentWeek">
        <option
          v-for="option in dropdownOptions"
          :key="option.value"
          :value="option.value"
        >
          {{ option.text }}
        </option>
      </select>
    </div>
    <div
      ref="mapContainer"
      class="map-container"
    >
      <div
        id="map-legend"
        class="legend"
      >
        <h4 v-text="legendTitle" />
        <div
          v-for="dataBin, index in dataBins"
          :key="index"
        >
          <span :style="{ 'background-color': dataBin.color }" />{{ dataBin.text }}
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
    import { computed, onMounted, ref, watch } from 'vue';
    import * as d3 from 'd3';
    import mapboxgl from "mapbox-gl";
    mapboxgl.accessToken = import.meta.env.VITE_APP_MAPBOX_TOKEN;;
    
    // Global variables
    const publicPath = import.meta.env.BASE_URL;
    const mapContainer = ref(null);
    const map = ref();
    const mapDataFile = 'CONUS_data.geojson';
    const mapData = ref();
    const mapStyleURL = 'mapbox://styles/hcorson-dosch/cm7jkdo7g003201s5hepq8ulm';
    const mapCenter = [-98.5, 40];
    const startingZoom = 3.5;
    const minZooom = 3;
    const maxZoom = 18;
    const dropdownOptions = [
        { text: 'Week 1', value: 1 },
        { text: 'Week 2', value: 2 },
        { text: 'Week 4', value: 4 },
        { text: 'Week 9', value: 9 },
        { text: 'Week 13', value: 13 }
    ];
    const currentWeek = ref(dropdownOptions[0].value);
    const dataBreaks = [5, 10, 20];
    const dataBins = [
        { text: 'Extreme drought', color: "#7E1717" }, 
        { text: 'Severe drought', color: "#F24C3D" }, 
        { text: 'Moderate drought', color: "#E3B418" }, 
        { text: 'Not in drought', color: "#9DB9F1" }
    ];
    const legendTitle = "Drought status"

    // Dynamically filter data to current week
    const filteredMapData = computed(() => {
        const filteredMapData = {}
        filteredMapData.type = "FeatureCollection";
        filteredMapData.crs = mapData.value.crs;
        filteredMapData.features = mapData.value.features.filter(d => d.properties.Forecast_Week == currentWeek.value)
        return filteredMapData;
    });

    // Watches currentWeek for changes and updates map to use filtered data
    watch(currentWeek, () => {
        map.value.getSource('gages').setData(filteredMapData.value)
    });

    onMounted(async () => {
        await loadDatasets({
                dataFiles: [mapDataFile], 
                dataRefs: [mapData],
                dataTypes: ['json'],
                dataNumericFields: [[]]
        });

        // build mapbox map
        buildMap();
    });

    async function loadDatasets({dataFiles, dataRefs, dataTypes, dataNumericFields}) {
        try {
            for (let i = 0; i < Math.min(dataFiles.length, dataRefs.length, dataNumericFields.length); i++) {
                dataRefs[i].value = await loadData(dataFiles[i], dataTypes[i], dataNumericFields[i]);
                console.log(`${dataFiles[i]} data in`);
            }
        } catch (error) {
            console.error('Error loading datasets', error);
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

    function buildMap() {
        map.value = new mapboxgl.Map({
            container: mapContainer.value, // container ID
            style: mapStyleURL, // style URL
            center: mapCenter, // starting position [lng, lat]
            zoom: startingZoom, // starting zoom
            maxZoom: maxZoom,
            minZoom: minZooom
        });

        map.value.addControl(new mapboxgl.NavigationControl());

        map.value.on('load', () => {
            map.value.addSource('gages', {
                type: 'geojson',
                // Use a URL for the value for the `data` property.
                data: filteredMapData.value
            });

            map.value.addLayer({
                'id': 'gages-layer',
                'type': 'circle',
                'source': 'gages',
                'paint': {
                    'circle-radius': [
                        "interpolate",
                        ["linear"],
                        ["zoom"],
                        // zoom is 5 (or less) -> circle radius will be 1px
                        5, 2,
                        // zoom is 10 (or greater) -> circle radius will be 5px
                        10, 5
                    ],
                    'circle-stroke-width': 0.5,
                    // Use step expressions (https://docs.mapbox.com/style-spec/reference/expressions/#step)
                    // with four steps to implement four types of circles based on drought severity
                    'circle-color': [
                        'step',
                        ['get', 'prediction'],
                        // predicted percentile is 5 or below -> first color
                        dataBins[0].color,
                        dataBreaks[0],
                        // predicted percentile is >=5 and <10 -> second color
                        dataBins[1].color,
                        dataBreaks[1],
                        // predicted percentile is >=10 and <20 -> third color
                        dataBins[2].color,
                        dataBreaks[2],
                        // predicted percentile is >=20 -> fourth color
                        dataBins[3].color
                    ],
                    'circle-stroke-color': '#1A1A1A'
                }
            });
        });
    }

</script>

<style>
    #page-container {
        width: 95vw;
        margin: 0 auto;
    }
    #dropdown-container {
        margin: 10px 0 10px 0;
    }
    .map-container {
        display: flex;
        height: 100vh;
        width: 100%;
        margin: 0 auto;
        padding: 0;
        flex: 1;
    }
    .legend {
        background-color: #fff;
        border-radius: 3px;
        top: 15px;
        left: 15px;
        box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
        font:
            12px/20px 'Helvetica Neue',
            Arial,
            Helvetica,
            sans-serif;
        padding: 10px;
        position: absolute;
        z-index: 1;
    }

    .legend h4 {
        margin: 0 0 10px;
    }

    .legend div span {
        border-radius: 50%;
        display: inline-block;
        height: 10px;
        margin-right: 5px;
        width: 10px;
    }
</style>