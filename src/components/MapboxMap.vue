<template>
  <section id="map-container">
    <div
      id="interactive-map-container"
      ref="mapContainer"
    />
    <div>
      <button
        @click="updateQuery('Maine')"
      >
        Maine
      </button>
      <button
        @click="updateQuery('Blue')"
      >
        Blue
      </button>
      <button
        @click="resetView()"
      >
        CONUS
      </button>
    </div>
    <div
      id="map-legend"
      class="legend"
    >
      <p 
        class="legend-title" 
        v-text="pointLegendTitle" 
      />
      <div
        v-for="dataBin, index in pointDataBin"
        id="legend-key-container"
        :key="index"
      >
        <span :style="{ 'background-color': dataBin.color }" />{{ dataBin.text }}
      </div>
    </div>
  </section>
</template>

<script setup>
    import { useRoute, useRouter } from 'vue-router';
    import { computed, inject, onMounted, ref, watch } from 'vue';
    import * as d3 from 'd3';
    import mapboxgl from "mapbox-gl";
    mapboxgl.accessToken = import.meta.env.VITE_APP_MAPBOX_TOKEN;
    import '/node_modules/mapbox-gl/dist/mapbox-gl.css';
    import { useWindowSizeStore } from '@/stores/WindowSizeStore';

    // Global variables
    const route = useRoute();
    const router = useRouter();
    const windowSizeStore = useWindowSizeStore();
    const publicPath = import.meta.env.BASE_URL;
    const mapContainer = ref(null);
    const map = ref();
    const mapStyleURL = 'mapbox://styles/hcorson-dosch/cm7jkdo7g003201s5hepq8ulm';
    const mapCenter = [-98.5, 40];
    const startingZoom = 3.5;
    const minZoom = 3;
    const maxZoom = 16;
    const pointSourceName = 'gages';
    const pointDataFile = 'CONUS_data.geojson';
    const pointData = ref();
    const pointLayerID = 'gages-layer';
    const pointFeatureIdField = 'StaID';
    const pointSelectedFeature = ref(null);
    const pointLegendTitle = "Drought category"
    const pointDataBreaks = [5, 10, 20];
    const pointDataBin = [
        { text: 'Extreme drought', color: "#680000" }, 
        { text: 'Severe drought', color: "#A7693F" }, 
        { text: 'Moderate drought', color: "#DCD5A8" }, 
        { text: 'Not in drought', color: "#f8f8f8" }
    ];

    // inject values
    const { selectedWeek } = inject('dates')
    const { siteList, updateSelectedSite } = inject('sites')
    const { extents, defaultExtent, selectedExtent, updateSelectedExtent } = inject('extents')

    // Set point value field based on selectedWeek
    const pointFeatureValueField = computed(() => {
        return `pd${selectedWeek.value}`
    })

    // Dynamically filter data based on selectedExtent
    const filteredPointData = computed(() => {
        if (selectedExtent.value == defaultExtent) {
            return pointData.value
        } else {
            const filteredPointData = {}
            filteredPointData.type = "FeatureCollection";
            filteredPointData.crs = pointData.value?.crs;
            filteredPointData.features = pointData.value?.features.filter(d => siteList.value.includes(d.properties[pointFeatureIdField]))
            return filteredPointData;
        }
    });

    // Watch router query for changes
    watch(
      () => route.query.extent, 
      (newQuery) => {

        // sort of hacky, but check if query extent is state, otherwise use default
        const stateSelected = extents.states.includes(newQuery)
        const newExtent = stateSelected ? newQuery : defaultExtent;

        // Update global selected extent
        updateSelectedExtent(newExtent)

        // if input query extent is invalid, wipe query
        if (!stateSelected) {
            router.replace({ ...router.currentRoute, query: null});
        }

        // Update map to use updated filtered data (computed based on selectedExtent)
        map.value.getSource(pointSourceName).setData(filteredPointData.value)

        // Zoom and pan map, as needed
        const stateGeometry = getGeometryInfo(filteredPointData.value);
        if (stateSelected) {
          map.value.fitBounds(stateGeometry.bounds, {
            padding: {
              top: Math.round(windowSizeStore.windowHeight*0.10), 
              bottom: Math.round(windowSizeStore.windowHeight*0.15), 
              left: Math.round(windowSizeStore.windowWidth*0.1), 
              right: Math.round(windowSizeStore.windowWidth*0.1)
            }
          });
        } else {
          map.value.fitBounds(stateGeometry.bounds, {
            padding: 0
          });
        }

    })

    // Watches selectedWeek for changes and updates map to use correct data field for paint
    watch(selectedWeek, () => {
        map.value?.getSource(pointSourceName).setData(filteredPointData.value)
        map.value?.setPaintProperty(pointLayerID, 'circle-color', [
            'step',
            ['get', pointFeatureValueField.value],
            // predicted percentile is < 5 -> first color
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
            dataFiles: [pointDataFile], 
            dataRefs: [pointData],
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

    function updateQuery(newExtent) {
        // Undo site selection
        undoSiteSelection()

        // Update router extent query
        router.replace({ ...router.currentRoute, query: { extent: newExtent}})
    }

    function resetView() {
        // Undo site selection
        undoSiteSelection()

        // remove router extent query, which triggers reset to CONUS view
        router.replace({ ...router.currentRoute, query: null})
    }

    function undoSiteSelection() {
        // If site selected, deselect, updating global ref
        updateSelectedSite(null);
        // Also remove map selection
        if (pointSelectedFeature.value) {
          map.value.setFeatureState(pointSelectedFeature.value, { selected: false });
          pointSelectedFeature.value = null;
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

        // Need to set padding here?

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
                        // predicted percentile is < 5 -> first color
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
        // Clicking on a feature will select it
        map.value.addInteraction('click', {
            type: 'click',
            target: { layerId: pointLayerID },
            handler: ({ feature }) => {
                if (pointSelectedFeature.value) {
                    map.value.setFeatureState(pointSelectedFeature.value, { selected: false });
                }

                pointSelectedFeature.value = feature;
                map.value.setFeatureState(feature, { selected: true });
                
                // update global ref
                updateSelectedSite(feature.properties[pointFeatureIdField])
            }
        });

        // Clicking on the map will deselect the selected feature
        map.value.addInteraction('map-click', {
            type: 'click',
            handler: () => {
                if (pointSelectedFeature.value) {
                    map.value.setFeatureState(pointSelectedFeature.value, { selected: false });
                    pointSelectedFeature.value = null;

                    // update global ref
                    updateSelectedSite(null);
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

  .legend {
    font-weight: 300;
  }

  .legend-title {
    font-weight: 500;
  }

  .legend div span {
    border-radius: 50%;
    display: inline-block;
    height: 10px;
    margin-right: 5px;
    width: 10px;
    border: 0.1px solid #1A1A1A;
  }
</style>