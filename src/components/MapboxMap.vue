<template>
  <section id="map-container">
    <div
      id="interactive-map-container"
      ref="mapContainer"
    />
    <div id="state-picker-button">
      <StatePickerButton 
        v-model="stateClicked"
        :picker-data="layoutData"
      />
    </div>
    <div id="legend-button">
      <ExpandingLegend 
        v-model="legendShown"
        :legend-title="pointLegendTitle"
        :legend-data-bins="pointDataBin"
        :reverse-data-bins="true"
        :legend-no-data-bin="noDataBin"
        :no-data-bin-shown="globalDataStore.sitesNA?.length > 0"
      />
    </div>
  </section>
</template>

<script setup>
    import { useRoute } from 'vue-router';
    import { computed, onMounted, ref, watch } from 'vue';
    import { storeToRefs } from "pinia";
    import * as d3 from 'd3';
    import mapboxgl from "mapbox-gl";
    mapboxgl.accessToken = import.meta.env.VITE_APP_MAPBOX_TOKEN;
    import '/node_modules/mapbox-gl/dist/mapbox-gl.css';
    import { useWindowSizeStore } from '@/stores/WindowSizeStore';
    import { useGlobalDataStore } from "@/stores/global-data-store";
    import { useScreenCategory } from "@/assets/scripts/composables/media-query";
    import ExpandingLegend from './ExpandingLegend.vue';
    import StatePickerButton from './StatePickerButton.vue'

    // Global variables
    const route = useRoute();
    const windowSizeStore = useWindowSizeStore();
    const globalDataStore = useGlobalDataStore();
    const screenCategory = useScreenCategory();
    const { legendShown } = storeToRefs(globalDataStore);
    const { pickerActive } = storeToRefs(globalDataStore);
    const { selectedWeek } = storeToRefs(globalDataStore);
    const { initialGeojsonLoadingComplete } = storeToRefs(globalDataStore);
    const { selectedSite } = storeToRefs(globalDataStore);
    const { selectedExtent } = storeToRefs(globalDataStore);
    const publicPath = import.meta.env.BASE_URL;
    const mapContainer = ref(null);
    const map = ref();
    const mapLoaded = ref(false);
    const mapStyleURL = 'mapbox://styles/hcorson-dosch/cm7jkdo7g003201s5hepq8ulm';
    // const mapCenter = [-98.5, 40];
    // const startingZoom = 3.5;
    const mapPaddingLeft = screenCategory.value == 'phone' ? 0 : 460; 
    const defaultMapPaddingTop = screenCategory.value == 'phone' ? 0 : 100;
    const defaultMapPaddingBottom = screenCategory.value == 'phone' ? 340 : 50;
    const minZoom = screenCategory.value == 'phone' ? 2 : 3;
    const maxZoom = 16;
    const pointSourceName = 'gages';
    const layoutData = ref();
    const datasetConfigs = [
      {
        file: 'conus_grid_layout.csv', 
        ref: layoutData,
        type: 'csv',
        numericFields: ['row', 'col'],
        booleanFields: null,
        booleanTrue: null
      }
    ]
    const pointLayerID = 'gages-layer';
    const pointFeatureIdField = 'StaID';
    const pointFeatureValueField = 'pd';
    const pointSelectedFeature = ref(null);
    const pointDataBreaks = [5, 10, 20, 999];
    //  Have to use hex values directly for mapbox paint
    const pointDataBin = [
      { text: 'Extreme streamflow drought', color: "#680000" }, 
      { text: 'Severe streamflow drought', color: "#A7693F" }, 
      { text: 'Moderate streamflow drought', color: "#DCD5A8" }, 
      { text: 'No streamflow drought', color: "#ffffff" }
    ];
    const noDataBin = { 
      text: 'No streamflow data', 
      color: "#CFCFCF"
    };
    const stateClicked = ref(globalDataStore.stateSelected ? selectedExtent.value : "null");
    const pointLegendTitle = computed(() => {
      return globalDataStore.dataType == 'Forecast' ? 'Forecast conditions' : 'Observed conditions';
    })

    // Watch legendShown for changes
    watch(legendShown, () => {
      if (legendShown.value == true) {
        pickerActive.value = false;
      }
    })
    // Watch pickerActive for changes
    watch(pickerActive, () => {
      if (pickerActive.value == true) {
        legendShown.value = false;
      }
    })

    // Watch route query for changes
    watch(
      () => route.query.extent, 
      (newQuery) => {
        if (mapLoaded.value == true && initialGeojsonLoadingComplete.value == true) {
          // Update map to use updated filtered data (computed based on selectedExtent)
          map.value.getSource(pointSourceName).setData(globalDataStore.filteredPointData)

          // Zoom and pan map, as needed
          const stateGeometry = getGeometryInfo(globalDataStore.filteredPointData);
          if (globalDataStore.stateSelected) {
            map.value.fitBounds(stateGeometry.bounds, {
              padding: {
                top: Math.round(windowSizeStore.windowHeight*0.10), 
                bottom: Math.round(windowSizeStore.windowHeight*0.15), 
                left: mapPaddingLeft + Math.round(windowSizeStore.windowWidth*0.1),
                right: Math.round(windowSizeStore.windowWidth*0.1)
              }
            });
          } else {
            map.value.fitBounds(stateGeometry.bounds, {
              padding: {
                top: defaultMapPaddingTop,
                left: mapPaddingLeft,
                bottom: defaultMapPaddingBottom
              }
            });
          }
        }
      },
    )

    // Update disabled status of conus button
    // watch(selectedExtent, () => {
    //   const conusButton = document.getElementById("reset-map")
    //   if (selectedExtent.value == globalDataStore.defaultExtent) {
    //     conusButton.disabled = true;
    //     conusButton.setAttribute('aria-disabled', 'true');
    //   } else {
    //     conusButton.disabled = false;
    //     conusButton.setAttribute('aria-disabled', 'false');
    //   }
    // })

    // If a state selection button is clicked, drop the site selection
    watch(stateClicked, () => {
      // Undo site selection
      undoSiteSelection()
    })

    // Set data and draw data on initial load
    watch(mapLoaded, () => {
      // console.log(`map loaded: ${mapLoaded.value}`)
      // console.log(`data loaded: ${initialGeojsonLoadingComplete.value}`)
      if (mapLoaded.value == true && initialGeojsonLoadingComplete.value == true) {
        // console.log('triggered b/c map loaded and data loaded')
        addPointData();
        drawPointData();
        addMapInteraction();
      }
    })

    // Build/update map when dataset is added
    watch(initialGeojsonLoadingComplete, () => {
      // If map is not yet built, and data is loaded, build map
      if (!mapLoaded.value && initialGeojsonLoadingComplete.value == true) {
        buildMap();
      }
      // If map is already built, and data is loaded, update data source
      if (mapLoaded.value == true && initialGeojsonLoadingComplete.value == true) {
        // console.log('resetting data source b/c new data source added')
        map.value?.getSource(pointSourceName).setData(globalDataStore.filteredPointData);
      }
    })

    // Updated data when selectedWeek changes
    watch(selectedWeek, () => {
      if (mapLoaded.value == true && initialGeojsonLoadingComplete.value == true) {
        // console.log('resetting data source b/c selected week changed')
        map.value?.getSource(pointSourceName).setData(globalDataStore.filteredPointData);
      }
    });

    onMounted(async () => {
        // Load layout csv for state picker
        await loadDatasets(datasetConfigs);
    });

    async function loadDatasets(configs) {
      for (const { file, ref, type, numericFields, booleanFields, booleanTrue} of configs) {
        try {
          ref.value = await loadData(file, type, numericFields, booleanFields, booleanTrue);
          console.log(`${file} data in`);
        } catch (error) {
          console.error(`Error loading ${file}`, error);
        }
      }
    }

    async function loadData(dataFile, dataType, dataNumericFields, dataBooleanFields, booleanTrue) {
      try {
        let data;
        if (dataType == 'csv') {
          data = await d3.csv(publicPath + dataFile, d => {
            if (dataNumericFields) {
              dataNumericFields.forEach(numericField => {
                d[numericField] = +d[numericField]
              });
            }
            if (dataBooleanFields) {
              dataBooleanFields.forEach(booleanField => {
                d[booleanField] = d[booleanField] === booleanTrue
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

    function resetMapExtent() {
      // if statePicker is open, close it
      if (pickerActive.value == true) {
        pickerActive.value = false;
      }
      // if legend is shown AND on phone, close it
      if (legendShown.value == true && screenCategory.value == 'phone') {
        legendShown.value = false;
      }

      // Reset stateClicked.value
      stateClicked.value = "null"

      // Undo site selection
      undoSiteSelection()

      // Update selected extent, which updates router extent query
      selectedExtent.value = globalDataStore.defaultExtent;

      // Fit map to bounds of all CONUS data (in case extent query does not change)
      const stateGeometry = getGeometryInfo(globalDataStore.filteredPointData);
      map.value.fitBounds(stateGeometry.bounds, {
        padding: {
          top: defaultMapPaddingTop,
          left: mapPaddingLeft,
          bottom: defaultMapPaddingBottom
        }
      });
    }

    function undoSiteSelection() {
      // If site selected, deselect, updating global ref
      selectedSite.value = null;
      // Also remove map selection
      if (pointSelectedFeature.value) {
        map.value.setFeatureState(pointSelectedFeature.value, { selected: false });
        pointSelectedFeature.value = null;
      }
    }  
    
    function downloadForecasts() {
      console.log('Downloading forecasts')
    }

    function getImageURL(filename) {
      return new URL(`../assets/images/${filename}`, import.meta.url).href
    }

    function addLegendButton(map, position) {
      class LegendButton {
        onAdd(map) {
          const div = document.getElementById("legend-button")
          div.className = "mapboxgl-ctrl mapboxgl-ctrl-group";
          div.addEventListener("contextmenu", (e) => e.preventDefault());

          return div;
        }
      }
      const legendButton = new LegendButton();
      map.addControl(legendButton, position);
    }

    function addConusButton(map, position) {
      class ConusButton {
        onAdd(map) {
          const imgSrc = getImageURL("conus_map.png")
          const div = document.createElement("div");
          div.className = "mapboxgl-ctrl mapboxgl-ctrl-group";
          div.innerHTML = `<button type="button" id="reset-map" title="Reset map" aria-label="Reset map" aria-disabled="false">
            <span class="mapboxgl-ctrl-icon" aria-hidden="true" title="Reset map" style="background-image: url(${imgSrc}); background-size: 20px auto;"></span></button>`;
          div.addEventListener("contextmenu", (e) => e.preventDefault());
          div.addEventListener("click", () => resetMapExtent());

          return div;
        }
      }
      const conusButton = new ConusButton();
      map.addControl(conusButton, position);
    }

    function addStatePickerButton(map, position) {
      class StatePickerButton {
        onAdd(map) {
          const div = document.getElementById("state-picker-button")
          div.className = "mapboxgl-ctrl mapboxgl-ctrl-group";
          div.addEventListener("contextmenu", (e) => e.preventDefault());

          return div;
        }
      }
      const statePickerButton = new StatePickerButton();
      map.addControl(statePickerButton, position);
    }

    function addDownloadButton(map, position) {
      class DownloadButton {
        onAdd(map) {
          const imgSrc = getImageURL("download_icon.png")
          const div = document.createElement("div");
          div.className = "mapboxgl-ctrl mapboxgl-ctrl-group";
          div.innerHTML = `<button type="button" id="download-forecasts" title="Download forecasts" aria-label="Download forecasts" aria-disabled="false">
            <span class="mapboxgl-ctrl-icon" aria-hidden="true" title="Download forecasts" style="background-image: url(${imgSrc}); background-size: 18px auto;"></span></button>`;
          div.addEventListener("contextmenu", (e) => e.preventDefault());
          div.addEventListener("click", () => downloadForecasts());

          return div;
        }
      }
      const downloadButton = new DownloadButton();
      map.addControl(downloadButton, position);
    }

    function buildMap() {
      // console.log('build map')
      // Use base point dataset to set initial map extent
      const stateGeometry = getGeometryInfo(globalDataStore.filteredPointData);
      
      map.value = new mapboxgl.Map({
          container: mapContainer.value, // container ID
          style: mapStyleURL, // style URL
          // center: mapCenter, // starting position [lng, lat]
          // zoom: startingZoom, // starting zoom
          maxZoom: maxZoom,
          minZoom: minZoom,
          attributionControl: false,
          logoPosition: 'bottom-right', // Move the logo to the bottom right
          bounds: stateGeometry.bounds,
          hash: "map_parameters"
      });

      map.value.fitBounds(stateGeometry.bounds, {
        padding: {
          top: defaultMapPaddingTop,
          left: mapPaddingLeft,
          bottom: defaultMapPaddingBottom
        }
      });

      const legendPosition = screenCategory.value == 'phone' ? 'top-left' : 'top-right';
      const navControlPosition = screenCategory.value == 'phone' ? 'top-right' : 'bottom-right';
      const attributionPosittion = screenCategory.value == 'phone' ? 'top-right' : 'bottom-left';

      if (screenCategory.value == 'phone') {
        addLegendButton(map.value, legendPosition)

        // Add the custom navigation control buttons
        addStatePickerButton(map.value, navControlPosition)
        addConusButton(map.value, navControlPosition)

        // Add mapbox navigation control buttons
        map.value.addControl(new mapboxgl.NavigationControl(), navControlPosition);

        addDownloadButton(map.value, legendPosition)

        map.value.addControl(new mapboxgl.AttributionControl({
            customAttribution: 'Powered by the <b><a href="//labs.waterdata.usgs.gov/visualizations/index.html#/" target="_blank">USGS Vizlab</a></b>'
        }), attributionPosittion);
      } else {
        addLegendButton(map.value, legendPosition)
        addDownloadButton(map.value, legendPosition)

        // Add mapbox navigation control buttons
        map.value.addControl(new mapboxgl.NavigationControl(), navControlPosition);
        map.value.addControl(new mapboxgl.AttributionControl({
            customAttribution: 'Powered by the <b><a href="//labs.waterdata.usgs.gov/visualizations/index.html#/" target="_blank">USGS Vizlab</a></b>'
        }), attributionPosittion);

        // Add the custom navigation control buttons
        addConusButton(map.value, navControlPosition)
        addStatePickerButton(map.value, navControlPosition)
      }


      map.value.on('load', () => {
        // console.log('map loaded')
        mapLoaded.value = true;
      });
    }

    function addPointData() {
      // console.log('add point data')
      // Add source for point data
      map.value.addSource(pointSourceName, {
        type: 'geojson',
        // Use a URL for the value for the `data` property.
        data: globalDataStore.filteredPointData, //subsetPointData.value, 
        promoteId: pointFeatureIdField, // Use StaID field as unique feature ID
        buffer: 0, // Do not buffer around eeach tiles, since small cirles used for symbolization
        maxzoom: 12 // Improve map performance by limiting max zoom for creating vector tiles
      });
    }

    function drawPointData() {
      // console.log('draw point data')
      // Draw point data
      map.value.addLayer({
        'id': pointLayerID,
        'type': 'circle',
        'source': pointSourceName,
        'slot': 'top',
        'minzoom': minZoom,
        'layout': {
          'circle-sort-key': [
            "*", 
            -1, 
            ["get", pointFeatureValueField]
          ]
        },
        'paint': {
          'circle-radius': [
            "interpolate",
            ["linear"],
            ["zoom"],
            // zoom is 5 (or less) -> circle radius will be 2.5px
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
              2.5
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
            2,
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
            ['get', pointFeatureValueField],
            // predicted percentile is below first break -> first color
            pointDataBin[0].color,
            pointDataBreaks[0],
            // predicted percentile is >= first break and < second break -> second color
            pointDataBin[1].color,
            pointDataBreaks[1],
            // predicted percentile is >= second break and < third break -> third color
            pointDataBin[2].color,
            pointDataBreaks[2],
            // predicted percentile is >= third break and < fourth break -> fourth color
            pointDataBin[3].color,
            pointDataBreaks[3],
            // predicted percentile is >= fourth break -> fifth color
            noDataBin.color
          ],
          'circle-stroke-color': [
            'case',
            ['boolean', ['feature-state', 'selected'], false],
            // if map feature is selected
            '#1A1A1A',
            ['boolean', ['feature-state', 'highlight'], false],
            // if map feature is highlighted
            '#1A1A1A',
            // if map feature is not selected and not highlighted
            [
              'step',
              ['get', pointFeatureValueField],
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
              '#636363',
              pointDataBreaks[3],
              // predicted percentile is >=999 (NA)
              '#878787'
            ]
          ],
        }
      });
    }

    function addMapInteraction() {
      // console.log('add interaction')
      // Add interaction to point features
      // Clicking on a feature will select it
      map.value.addInteraction('click', {
        type: 'click',
        target: { layerId: pointLayerID },
        handler: ({ feature }) => {
          // hide legend, if open
          if (legendShown.value == true) {
            legendShown.value = false;
          }
          // hide picker, if open
          if (pickerActive.value == true) {
            pickerActive.value = false;
          }
          if (pointSelectedFeature.value) {
            map.value.setFeatureState(pointSelectedFeature.value, { selected: false });
          }

          pointSelectedFeature.value = feature;
          map.value.setFeatureState(feature, { selected: true });
          
          // update global ref
          selectedSite.value = feature.properties[pointFeatureIdField];
        }
      });

      // Clicking on the map will deselect the selected feature
      map.value.addInteraction('map-click', {
        type: 'click',
        handler: () => {
          // hide legend, if open
          if (legendShown.value == true) {
            legendShown.value = false;
          }
          // hide picker, if open
          if (pickerActive.value == true) {
            pickerActive.value = false;
          }
          if (pointSelectedFeature.value) {
            map.value.setFeatureState(pointSelectedFeature.value, { selected: false });
            pointSelectedFeature.value = null;

            // update global ref
            selectedSite.value = null;
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
    height: calc(100vh - 23.4px - 87px - 47px - 32px - 93px - 0rem); /* page height - USWDS banner - USGS header - Experimental banner - prefooter code links - USGS footer - container margin (top + bottom) */
    width: 100vw;
    margin: 0 auto;
    padding: 0;
    flex: 1;
    /* ----------- Non-Retina Screens ----------- */
    @media screen 
      and (min-device-width: 1200px) 
      and (max-device-width: 1600px) 
      and (-webkit-min-device-pixel-ratio: 1) { 
      height: 100vh;
      width: 100%;
    }

    /* ----------- Retina Screens ----------- */
    @media screen 
      and (min-device-width: 1200px) 
      and (max-device-width: 1600px) 
      and (-webkit-min-device-pixel-ratio: 2)
      and (min-resolution: 192dpi) { 
      height: 100vh;
      width: 100%;
    }
    /* ----------- Phones ----------- */
    @media only screen and (max-width: 641px) {
      height: 100vh;
      width: 100%;
    }
  }
</style>