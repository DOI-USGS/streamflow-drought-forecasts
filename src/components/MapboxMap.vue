<template>
  <section>
    <div id="dropdown-container">
      <select v-model="currentWeek">
        <option v-for="option in options" :key="option.value" :value="option.value">
          {{ option.text }}
        </option>
      </select>
    </div>
    <div
      ref="mapContainer"
      class="map-container"
    />
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
    const options = [
        { text: 'Week 1', value: 1 },
        { text: 'Week 2', value: 2 },
        { text: 'Week 4', value: 4 },
        { text: 'Week 9', value: 9 },
        { text: 'Week 13', value: 13 }
    ];
    const currentWeek = ref(options[0].value);
    const colors = ["#7E1717", "#F24C3D", "#E3B418", "#9DB9F1"];

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
            style: 'mapbox://styles/hcorson-dosch/cm7jkdo7g003201s5hepq8ulm', // style URL
            center: [-98.5, 40], // starting position [lng, lat]
            zoom: 4, // starting zoom
            maxZoom: 16,
            minZoom: 3
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
                        colors[0],
                        5,
                        // predicted percentile is >=5 and <10 -> second color
                        colors[1],
                        10,
                        // predicted percentile is >=10 and <20 -> third color
                        colors[2],
                        20,
                        // predicted percentile is >=20 -> fourth color
                        colors[3]
                    ],
                    'circle-stroke-color': '#1A1A1A'
                }
            });
        });
    }

</script>

<style>
    .map-container {
        display: flex;
        height: 100vh;
        width: 95vw;
        margin: 0 auto;
        padding: 0;
        flex: 1;
    }
</style>