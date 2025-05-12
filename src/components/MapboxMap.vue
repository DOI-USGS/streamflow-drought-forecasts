<template>
  <section id="page-container">
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
      <MapSidebar
        v-if="forecastInfoData"
        :forecast-info="forecastInfoData"
      />
      <div
        class="map-overlay right"
      >
        <h1>
          <span
            class="emph"
          >
            {{ dataType }}
          </span>
          streamflow drought
        </h1>
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
        <div
          class="map-overlay-inner"
        >
          <div
            v-if="!siteSelected"
          >
            <p>
              Of {{ nSites }} forecast sites in {{ spatialExtent }}, {{ nSitesExtreme }} are forecast to be in 
              <span class="highlight extreme">extreme drought</span>
            </p>
          </div>
          <div
            v-if="siteSelected"
          >
            <p><b>Station:</b> {{ selectedSiteData[pointFeatureIdField] }} </p>
            <p><b>Name:</b> {{ selectedSiteInfo.station_nm }} </p>
            <p><b>State:</b> {{ selectedSiteInfo.state }} </p>
            <p><b>County:</b> {{ selectedSiteInfo.county }}</p>
            <p><b>Forecast week:</b> {{ currentFilterOption }}</p>
            <b>Median predicted percentile:</b>
            <p> {{ selectedSiteData[pointFeatureValueField] }}</p>
          </div>
        </div>
        <div 
          ref="card"
        />
      </div>
    </div>
  </section>
</template>

<script setup>
    import { useRoute } from 'vue-router';
    import { computed, onMounted, ref, watch } from 'vue';
    import * as d3 from 'd3';
    import mapboxgl from "mapbox-gl";
    mapboxgl.accessToken = import.meta.env.VITE_APP_MAPBOX_TOKEN;
    import '/node_modules/mapbox-gl/dist/mapbox-gl.css';
    import MapSidebar from '../components/MapSidebar.vue';

    // Global variables
    const route = useRoute();
    const publicPath = import.meta.env.BASE_URL;
    const dataType = ref(null);
    const defaultSpatialExtent = 'the continental U.S.'
    const state = ref(route.query.extent) //ref(route.params.state)
    const spatialExtentList = [
        "Alabama", "Arizona", "Arkansas", "California", "Colorado", 
        "Connecticut", "Delaware", "Florida", "Georgia", "Idaho", 
        "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", 
        "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", 
        "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", 
        "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", 
        "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", 
        "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", 
        "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", 
        "Wyoming"
    ];
    const siteSelected = ref(false);
    const selectedSiteId = ref(null);
    const selectedSiteInfo = ref({});
    const mapContainer = ref(null);
    const map = ref();
    const mapStyleURL = 'mapbox://styles/hcorson-dosch/cm7jkdo7g003201s5hepq8ulm';
    const mapCenter = [-98.5, 40];
    const startingZoom = 3.5;
    const minZoom = 3;
    const maxZoom = 16;
    const forecastInfoDataFile = 'forecast_info.csv';
    const forecastInfoData = ref(null);
    const siteInfoDataFile = 'site_info.csv';
    const siteInfoData = ref();
    const pointSourceName = 'gages';
    const pointDataFile = 'CONUS_data.geojson';
    const pointData = ref();
    const pointLayerID = 'gages-layer';
    const pointFeatureIdField = 'StaID';
    // const pointFeatureValueField = 'pd';
    const pointSelectedFeature = ref(null);
    const card = ref(null);
    const dropdownFilterOptions = ref([
        { text: 'Week 1', value: 1 },
        { text: 'Week 2', value: 2 },
        { text: 'Week 4', value: 4 },
        { text: 'Week 9', value: 9 },
        { text: 'Week 13', value: 13 }
    ]);
    const currentFilterOption = ref(dropdownFilterOptions.value[0].value);
    const pointLegendTitle = "Drought category"
    const pointDataBreaks = [5, 10, 20];
    const pointDataBin = [
        { text: 'Extreme drought', color: "#680000" }, 
        { text: 'Severe drought', color: "#A7693F" }, 
        { text: 'Moderate drought', color: "#DCD5A8" }, 
        { text: 'Not in drought', color: "#f8f8f8" }
    ];

    // Set point value field based on currentFilterOption
    const pointFeatureValueField = computed(() => {
        return `pd${currentFilterOption.value}`
    })

    // Dynamically filter data to current spatial extent
    const filteredPointData = computed(() => {
        if (spatialExtent.value == defaultSpatialExtent) {
            return pointData.value
        } else {
            const siteInfoSubset = siteInfoData.value?.filter(d => d.state == spatialExtent.value)
            const siteSubset = siteInfoSubset?.map(d => d[pointFeatureIdField])

            const filteredPointData = {}
            filteredPointData.type = "FeatureCollection";
            filteredPointData.crs = pointData.value?.crs;
            filteredPointData.features = pointData.value?.features.filter(d => siteSubset.includes(d.properties[pointFeatureIdField]))
            return filteredPointData;
        }
    });
    
    const nSites = computed(() => {
        return filteredPointData.value?.features?.length
    })
    const nSitesExtreme = computed(() => {
        const extremeSites = filteredPointData.value?.features?.filter(d => d.properties[pointFeatureValueField.value] < 5)
        return extremeSites?.length
    })

    const selectedSiteData = computed(() => {
        return filteredPointData.value?.features.find(d => d.properties[pointFeatureIdField] == selectedSiteId.value).properties
    })

    const spatialExtent = computed(() => {
        return state.value ? state.value : defaultSpatialExtent;
    })

    //watches router params for changes
    watch(route, () => {
        // sort of hacky, but check if route param is state, otherwise use default
        const inputValue = route.query.extent
        const inStateList = spatialExtentList?.includes(inputValue)
        state.value = inStateList ? route.query.extent : defaultSpatialExtent;
        const stateGeometry = getGeometryInfo(filteredPointData.value);
        map.value.fitBounds(stateGeometry.bounds);
    })

    watch(spatialExtent, () => {
        map.value.getSource(pointSourceName).setData(filteredPointData.value)
    });

    // Watches currentFilterOption for changes and updates map to use correct data field for paint
    watch(currentFilterOption, () => {
        map.value.getSource(pointSourceName).setData(filteredPointData.value)
        map.value.setPaintProperty(pointLayerID, 'circle-color', [
            'step',
            ['get', pointFeatureValueField.value],
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
        ])
    });

    onMounted(async () => {
        await loadDatasets({
            dataFiles: [forecastInfoDataFile, siteInfoDataFile, pointDataFile], 
            dataRefs: [forecastInfoData, siteInfoData, pointData],
            dataTypes: ['csv', 'csv', 'json'],
            dataNumericFields: [['f_w'], [], []]
        });

        // set dropdown options based on data
        forecastInfoData.value.sort((a, b) => a.f_w - b.f_w);
        dropdownFilterOptions.value.map((element, index) => {
            element.text = forecastInfoData.value[index].forecast_date
        })

        // build mapbox map
        dataType.value = "Forecast";
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
        
        const stateGeometry = getGeometryInfo(filteredPointData.value);

        map.value = new mapboxgl.Map({
            container: mapContainer.value, // container ID
            style: mapStyleURL, // style URL
            // center: mapCenter, // starting position [lng, lat]
            // zoom: startingZoom, // starting zoom
            maxZoom: maxZoom,
            minZoom: minZoom,
            attributionControl: false,
            bounds: stateGeometry.bounds,
            hash: "map_parameters"
        });

        map.value.addControl(new mapboxgl.NavigationControl());
        map.value.addControl(new mapboxgl.AttributionControl({
            customAttribution: 'Powered by the <b><a href="//labs.waterdata.usgs.gov/visualizations/index.html#/" target="_blank">USGS Vizlab</a></b>'
        }));

        map.value.on('load', () => {
            addPointData();
        });
    }

    function addPointData() {
        // Add source for point data
        map.value.addSource(pointSourceName, {
            type: 'geojson',
            // Use a URL for the value for the `data` property.
            data: filteredPointData.value, //subsetPointData.value, 
            promoteId: pointFeatureIdField, // Use StaID field as unique feature ID
            buffer: 0, // Do not buffer around eeach tiles, since small cirles used for symbolization
            maxzoom: 12 // Improve map performance by limiting max zoom for creating vector tiles
        });

        // Draw point data
        map.value.addLayer({
            'id': pointLayerID,
            'type': 'circle',
            'source': pointSourceName,
            'slot': 'top',
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
                        3
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
                        6
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
                    0.75
                ],
                // Use step expressions (https://docs.mapbox.com/style-spec/reference/expressions/#step)
                // with four steps to implement four types of circles based on drought severity
                'circle-color': [
                    'step',
                    ['get', pointFeatureValueField.value],
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
                    [
                        'step',
                        ['get', pointFeatureValueField.value],
                        // predicted percentile is 5 or below -> first color
                        '#1A1A1A',
                        pointDataBreaks[0],
                        // predicted percentile is >=5 and <10 -> second color
                        '#1A1A1A',
                        pointDataBreaks[1],
                        // predicted percentile is >=10 and <20 -> third color
                        '#1A1A1A',
                        pointDataBreaks[2],
                        // predicted percentile is >=20 -> fourth color
                        '#949494'
                    ]
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
                siteSelected.value = true;
                selectedSiteId.value = feature.properties[pointFeatureIdField];
                selectedSiteInfo.value = siteInfoData.value.find(d => d.StaID == feature.properties[pointFeatureIdField]);
            }
        });

        // Clicking on the map will deselect the selected feature
        map.value.addInteraction('map-click', {
            type: 'click',
            handler: () => {
                if (pointSelectedFeature.value) {
                    map.value.setFeatureState(pointSelectedFeature.value, { selected: false });
                    pointSelectedFeature.value = null;
                    // card.value.style.display = 'none';
                    siteSelected.value = false;
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

    function getGeometryInfo(json) {

      const bounds = d3.geoBounds(json),
            minX = bounds[0][0],
            maxX = bounds[1][0],
            minY = bounds[0][1],
            maxY = bounds[1][1],
            width = maxX - minX,
            height = maxY - minY
      
      const center =  [Math.abs(maxX - width / 2), minY + height / 2];

      const geometryInfo = {
        bounds,
        minX,
        maxX,
        minY,
        maxY,
        width,
        height,
        center,
        parallels: [minY + height * 1/3, minY + height * 2/3]
      }
      return geometryInfo
    }

</script>

<style scoped>
    #page-container {
        width: 100%;
        margin: 0 auto;
    }
    #dropdown-container {
        margin: 10px 0 10px 0;
    }
    #dropdown-container select {
        font-size: 3rem;
        font-family: var(--default-font);
        font-weight: 200;
        padding: 0.2rem 0.5rem 0.2rem 0.2rem;
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
        top: 10px;
        right: 55px; /* leave space at right for mapbox control */
        box-shadow: 0 0 0 2px rgba(0, 0, 0, .1); /* match mapbox control */
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
        border: 0.1px solid #1A1A1A;
    }
    .map-overlay {
        /*display: block; /*none;*/
        padding: 2rem 2rem 2rem 2rem;
        position: absolute;
        left: 10px;
        top: 250px;
        /* width: 350px; */
        max-width: 440px;
        overflow: hidden;
        /* white-space: nowrap; */
        /* height: calc(100vh - 20px); */
        background: #fff;  
        border-radius: 5px;
        box-shadow: 0 1px 2px rgba(0, 0, 0, 0.2);
    }

    .map-overlay-inner {
        background: #fff;
    }

    .highlight {
        border-left: 4px solid red;
        padding-left: 4px;
        background-image: linear-gradient(to right, green, var(--color-background));
    }

    .extreme {
        border-color: var(--color-extreme);
        background-image: linear-gradient(to right, rgba(var(--color-extreme), 0.4), var(--color-background));
    }
</style>