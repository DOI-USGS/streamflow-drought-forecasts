<template>
  <section id="page-container">
    <div id="dropdown-container">
      <select v-model="currentFilterOption">
        <option
          v-for="option in dropdownFilterOptions"
          :key="option.value"
          :value="option.value"
        >
          {{ option.text }}
        </option>
      </select>
    </div>
    <div id="map-container">
      <div
        id="interactive-map-container"
        ref="mapContainer"
      />
      <div
        id="map-legend"
        class="legend"
      >
        <h4 v-text="pointLegendTitle" />
        <div
          v-for="dataBin, index in pointDataBin"
          :key="index"
        >
          <span :style="{ 'background-color': dataBin.color }" />{{ dataBin.text }}
        </div>
      </div>
      <div 
        ref="card" 
        class="map-overlay right"
      />
    </div>
  </section>
</template>

<script setup>
    import { computed, onMounted, ref, watch } from 'vue';
    import * as d3 from 'd3';
    import mapboxgl from "mapbox-gl";
    mapboxgl.accessToken = import.meta.env.VITE_APP_MAPBOX_TOKEN;
    import '/node_modules/mapbox-gl/dist/mapbox-gl.css';
    
    // Global variables
    const publicPath = import.meta.env.BASE_URL;
    const mapContainer = ref(null);
    const map = ref();
    const mapStyleURL = 'mapbox://styles/hcorson-dosch/cm7jkdo7g003201s5hepq8ulm';
    const mapCenter = [-98.5, 40];
    const startingZoom = 3.5;
    const minZoom = 3;
    const maxZoom = 17;
    const forecastInfoDataFile = 'forecast_info.csv';
    const forecastInfoData = ref();
    const siteInfoDataFile = 'site_info.csv';
    const siteInfoData = ref();
    const pointSourceName = 'gages';
    const pointDataFile = 'CONUS_data.geojson';
    const pointData = ref();
    const pointLayerID = 'gages-layer';
    const pointFeatureIdField = 'StaID';
    const pointFeatureValueField = 'pd';
    const pointFeatureFilterField = 'f_w';
    const pointSelectedFeature = ref(null);
    const card = ref(null);
    const lineSourceName = 'nhgf11';
    const lineDataFile = 'CONUS_precip.geojson';
    const lineData = ref();
    const lineLayerID = 'nhgf-layer';
    const lineFeatureIdField = 'seg_id_nhm';
    const dropdownFilterOptions = [
        { text: 'Week 1', value: 1 },
        { text: 'Week 2', value: 2 },
        { text: 'Week 4', value: 4 },
        { text: 'Week 9', value: 9 },
        { text: 'Week 13', value: 13 }
    ];
    const currentFilterOption = ref(dropdownFilterOptions[0].value);
    const pointLegendTitle = "Drought status"
    const pointDataBreaks = [5, 10, 20];
    const pointDataBin = [
        { text: 'Extreme drought', color: "#7E1717" }, 
        { text: 'Severe drought', color: "#F24C3D" }, 
        { text: 'Moderate drought', color: "#E3B418" }, 
        { text: 'Not in drought', color: "#9DB9F1" }
    ];

    // Dynamically filter data to current week
    const filteredPointData = computed(() => {
        const filteredPointData = {}
        filteredPointData.type = "FeatureCollection";
        filteredPointData.crs = pointData.value.crs;
        filteredPointData.features = pointData.value.features.filter(d => d.properties[pointFeatureFilterField] == currentFilterOption.value)
        return filteredPointData;
    });

    // Watches currentFilterOption for changes and updates map to use filtered data
    watch(currentFilterOption, () => {
        map.value.getSource(pointSourceName).setData(filteredPointData.value)
    });

    onMounted(async () => {
        await loadDatasets({
            dataFiles: [forecastInfoDataFile, siteInfoDataFile, pointDataFile, lineDataFile], 
            dataRefs: [forecastInfoData, siteInfoData, pointData, lineData],
            dataTypes: ['csv', 'csv', 'json', 'json'],
            dataNumericFields: [['f_w'], [], [], []]
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
            minZoom: minZoom,
            attributionControl: false
        });

        map.value.addControl(new mapboxgl.NavigationControl());
        map.value.addControl(new mapboxgl.AttributionControl({
            customAttribution: 'Powered by the <b><a href="//labs.waterdata.usgs.gov/visualizations/index.html#/" target="_blank">USGS Vizlab</a></b>'
        }));

        map.value.on('load', () => {
            addPointData();
            // addLineData();
        });
    }

    function addPointData() {
        // Add source for point data
        map.value.addSource(pointSourceName, {
            type: 'geojson',
            // Use a URL for the value for the `data` property.
            data: filteredPointData.value,
            promoteId: pointFeatureIdField, // Use StaID field as unique feature ID
            buffer: 0, // Do not buffer around eeach tiles, since small cirles used for symbolization
            maxzoom: 12 // Improve map performance by limiting max zoom for creating vector tiles
        });

        // Draw point data
        map.value.addLayer({
            'id': pointLayerID,
            'type': 'circle',
            'source': pointSourceName,
            'minzoom': minZoom,
            'paint': {
                'circle-radius': [
                    "interpolate",
                    ["linear"],
                    ["zoom"],
                    // zoom is 5 (or less) -> circle radius will be 2px
                    // unless selected or highlighted
                    5, 
                    [
                        'case',
                        ['boolean', ['feature-state', 'selected'], false],
                        // if map feature is selected
                        6,
                        ['boolean', ['feature-state', 'highlight'], false],
                        // if map feature is highlighted
                        4,
                        // if map feature is not selected and not highlighted
                        2
                    ],
                    // zoom is 10 (or greater) -> circle radius will be 5px
                    // unless selected or highlighted
                    10,
                    [
                        'case',
                        ['boolean', ['feature-state', 'selected'], false],
                        // if map feature is selected
                        9,
                        ['boolean', ['feature-state', 'highlight'], false],
                        // if map feature is highlighted
                        7,
                        // if map feature is not selected and not highlighted
                        5
                    ]
                ],
                'circle-stroke-width': [
                    'case',
                    ['boolean', ['feature-state', 'selected'], false],
                    // if map feature is selected
                    7,
                    ['boolean', ['feature-state', 'highlight'], false],
                    // if map feature is highlighted
                    2,
                    // if map feature is not selected and not highlighted
                    0.5
                ],
                // Use step expressions (https://docs.mapbox.com/style-spec/reference/expressions/#step)
                // with four steps to implement four types of circles based on drought severity
                'circle-color': [
                    'step',
                    ['get', pointFeatureValueField],
                    // predicted percentile is 5 or below -> first color
                    pointDataBin[0].color,
                    pointDataBreaks[0],
                    // predicted percentile is >=5 and <10 -> second color
                    pointDataBin[1].color,
                    pointDataBreaks[1],
                    // predicted percentile is >=10 and <20 -> third color
                    pointDataBin[2].color,
                    pointDataBreaks[2],
                    // predicted percentile is >=20 -> fourth color
                    pointDataBin[3].color
                ],
                'circle-stroke-color': [
                    'case',
                    ['boolean', ['feature-state', 'selected'], false],
                    // if map feature is selected
                    '#FFFFFF',
                    ['boolean', ['feature-state', 'highlight'], false],
                    // if map feature is highlighted
                    '#1A1A1A',
                    // if map feature is not selected and not highlighted
                    '#1A1A1A'
                ]
            }
        });

        // Add interaction to point features
        // Clicking on a feature will highlight it and display its properties in the card
        map.value.addInteraction('click', {
            type: 'click',
            target: { layerId: pointLayerID },
            handler: ({ feature }) => {
                if (pointSelectedFeature.value) {
                    map.value.setFeatureState(pointSelectedFeature.value, { selected: false });
                }

                pointSelectedFeature.value = feature;
                map.value.setFeatureState(feature, { selected: true });
                showCard(feature);
            }
        });

        // Clicking on the map will deselect the selected feature
        map.value.addInteraction('map-click', {
            type: 'click',
            handler: () => {
                if (pointSelectedFeature.value) {
                    map.value.setFeatureState(pointSelectedFeature.value, { selected: false });
                    pointSelectedFeature.value = null;
                    card.value.style.display = 'none';
                }
            }
        });

        // Hovering over a feature will highlight it
        map.value.addInteraction('mouseenter', {
            type: 'mouseenter',
            target: { layerId: pointLayerID },
            handler: ({ feature }) => {
                map.value.setFeatureState(feature, { highlight: true });
                map.value.getCanvas().style.cursor = 'pointer';
            }
        });

        // Moving the mouse away from a feature will remove the highlight
        map.value.addInteraction('mouseleave', {
            type: 'mouseleave',
            target: { layerId: pointLayerID },
            handler: ({ feature }) => {
                map.value.setFeatureState(feature, { highlight: false });
                map.value.getCanvas().style.cursor = '';
                return false;
            }
        });
    }

    function addLineData() {
        // Add source for line data
        map.value.addSource(lineSourceName, {
            type: 'geojson',
            // Use a URL for the value for the `data` property.
            data: lineData.value,
            promoteId: lineFeatureIdField // Use StaID field as unique feature ID
        });

        // Draw line data
        map.value.addLayer({
            'id': lineLayerID,
            'type': 'line',
            'source': lineSourceName,
            'layout': {
                'line-join': 'round',
                'line-cap': 'round'
            },
            'paint': {
                'line-color': '#888',
                'line-width': 0.5
            }
        });
    }

    function showCard(feature) {
        const siteInfo = siteInfoData.value.find(d => d.StaID == feature.properties[pointFeatureIdField])
        card.value.innerHTML = `
            <div class="map-overlay-inner">
                <p><b>Station:</b> ${feature.properties[pointFeatureIdField]}</p>
                <p><b>State:</b> ${siteInfo.state}</p>
                <p><b>County:</b> ${siteInfo.county}</p>
                <p><b>Forecast week:</b> ${currentFilterOption.value}</p>
                <b>Median predicted percentile:</b>
                <p>${feature.properties[pointFeatureValueField]}</p>
            </div>`;

        card.value.style.display = 'block';
    };

</script>

<style>
    #page-container {
        width: 95vw;
        margin: 0 auto;
    }
    #dropdown-container {
        margin: 10px 0 10px 0;
    }
    #map-container {
        position: relative;
    }
    #interactive-map-container {
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
    .map-overlay {
        display: none;
        font: 12px/20px sans-serif;
        padding: 10px;
        position: absolute;
        right: 40px;
        top: 0;
        width: 230px;
        overflow: hidden;
        white-space: nowrap;
    }

    .map-overlay-inner {
        background: #fff;
        padding: 10px;
        border-radius: 3px;
    }
</style>