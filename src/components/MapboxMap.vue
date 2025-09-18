<template>
  <section id="map-container">
    <div
      id="interactive-map-container"
      ref="mapContainer"
    />
    <div id="state-picker-button">
      <StatePickerButton 
        v-model="selectedExtent"
        :picker-data="globalDataStore.stateLayoutData"
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
    import { computed, ref, watch } from 'vue';
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
    const { hoveredSite } = storeToRefs(globalDataStore);
    const { selectedExtent } = storeToRefs(globalDataStore);
    const { fullSummaryShownOnMobile } = storeToRefs(globalDataStore);
    const mapContainer = ref(null);
    const map = ref();
    const mapLoaded = ref(false);
    const mapStyleURL = 'mapbox://styles/hcorson-dosch/cm7jkdo7g003201s5hepq8ulm?optimize=true';
    // const mapCenter = [-98.5, 40];
    // const startingZoom = 3.5;
    const mapPaddingLeft = screenCategory.value == 'phone' ? 0 : 460; 
    const defaultMapPaddingTop = screenCategory.value == 'phone' ? 0 : 100;
    const defaultMapPaddingBottom = screenCategory.value == 'phone' ? 320 : 50;
    const stateMapPaddingTop = screenCategory.value == 'phone' ? Math.round(windowSizeStore.windowHeight*0.075) : Math.round(windowSizeStore.windowHeight*0.10); 
    const stateMapPaddingBottom = screenCategory.value == 'phone' ? 340 + Math.round(windowSizeStore.windowHeight*0.085): Math.round(windowSizeStore.windowHeight*0.15); 
    const stateMapPaddingLeft = screenCategory.value == 'phone' ? mapPaddingLeft + Math.round(windowSizeStore.windowWidth*0.15) : mapPaddingLeft + Math.round(windowSizeStore.windowWidth*0.1);
    const stateMapPaddingRight = screenCategory.value == 'phone' ? Math.round(windowSizeStore.windowWidth*0.15) : Math.round(windowSizeStore.windowWidth*0.1);
    const maxBounds = screenCategory.value == 'phone' ? 
      [
        [-165, -10], // Southwest coordinates
        [-22, 81] // Northeast coordinates
      ] :
      [
        [-135, 15], // Southwest coordinates
        [-52, 56] // Northeast coordinates
      ];
    const minZoom = screenCategory.value == 'phone' ? 2 : 3;
    const maxZoom = 16;
    const defaultHash = `#${minZoom}/0/0`
    const pointSourceName = 'gages';
    const pointLayerID = 'gages-layer';
    const naLayerID = 'na-layer'
    const pointFeatureIdField = 'StaID';
    const pointFeatureValueField = 'pd';
    const pointSelectedFeature = ref(null);
    const pointDataBreaks = [5, 10, 20, 999];
    //  Have to use hex values directly for mapbox paint
    const defaultStrokeHex = "#1A1A1A";
    const pointDataBin = [
      { text: 'Extreme streamflow drought', color: "#7A0000", stroke: defaultStrokeHex }, 
      { text: 'Severe streamflow drought', color: "#B77040", stroke: defaultStrokeHex }, 
      { text: 'Moderate streamflow drought', color: "#EFE19C", stroke: defaultStrokeHex }, 
      { text: 'No streamflow drought', color: "#ffffff", stroke: "#333333" }
    ];
    const noDataBin = { 
      text: 'Current streamflow unavailable', 
      color: "#CFCFCF",
      stroke: "#737373"
    };
    const pointLegendTitle = computed(() => {
      return globalDataStore.dataType == 'Forecast' ? 'Forecast conditions' : 'Observed conditions';
    })
    let mobilePopup;

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
                top: stateMapPaddingTop, 
                bottom: stateMapPaddingBottom, 
                left: stateMapPaddingLeft,
                right: stateMapPaddingRight
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

    // If selectedExtent changes (a state selection button is clicked or view reset to CONUS), drop the site selection
    watch(selectedExtent, () => {
      // Undo site selection
      undoSiteSelection()
      // close picker
      pickerActive.value = false;
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
        if (screenCategory.value != 'desktop') {
          if (selectedSite.value) {
            updateMobilePopup(selectedSite.value)
          }
        }
      }
    })

    // Updated data when selectedWeek changes
    watch(selectedWeek, () => {
      if (mapLoaded.value == true && initialGeojsonLoadingComplete.value == true) {
        // console.log('resetting data source b/c selected week changed')
        map.value?.getSource(pointSourceName).setData(globalDataStore.filteredPointData);
        if (screenCategory.value != 'desktop') {
          if (selectedSite.value) {
            updateMobilePopup(selectedSite.value)
          }
        }
      }
    });

    function resetMapExtent() {
      // if statePicker is open, close it
      if (pickerActive.value == true) {
        pickerActive.value = false;
      }
      // if legend is shown AND on phone, close it
      if (legendShown.value == true && screenCategory.value == 'phone') {
        legendShown.value = false;
      }

      // Update selected extent, which updates router extent query
      selectedExtent.value = null; //globalDataStore.defaultExtent;

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
      if (screenCategory.value != 'desktop') {
        // Close mobile popup if not on desktop and if defined
        if (mobilePopup) {
          mobilePopup.remove()
        }
        // On mobile, hide site summary view
        fullSummaryShownOnMobile.value = false;
      }
    }  
    
    function downloadForecasts() {
      const link = document.createElement('a');
      const filename = `USGS_streamflow_drought_forecasts_${globalDataStore.issueDate}.parquet`;
      const dataURL = `${import.meta.env.VITE_APP_S3_PROD_URL}${import.meta.env.VITE_APP_TITLE}/${import.meta.env.VITE_APP_DATA_TIER}/${filename}`;

      // set link href
      link.href = dataURL;

      // set download attribute with filename
      link.download = filename;

      // Make link invisible
      link.style.display = 'none';

      // Add to document
      document.body.appendChild(link);

      // Trigger download
      link.click();
      
      // Clean up
      document.body.removeChild(link);
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

    function addContactButton(map, position) {
      class ContactButton {
        onAdd(map) {
          const imgSrc = getImageURL("contact_icon.png")
          const div = document.createElement("div");
          div.className = "mapboxgl-ctrl mapboxgl-ctrl-group";
          div.innerHTML = `<button type="button" id="contact-team" title="Contact the Vizlab team" aria-label="Contact the development team to ask a question or provide feedback" aria-disabled="false">
            <a href="mailto:gs-w_vizlab@usgs.gov"><span class="mapboxgl-ctrl-icon" aria-hidden="true" title="Contact the Vizlab team" style="background-image: url(${imgSrc}); background-size: 18px auto;"></span></a></button>`;
          div.addEventListener("contextmenu", (e) => e.preventDefault());

          return div;
        }
      }
      const contactButton = new ContactButton();
      map.addControl(contactButton, position);
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
          logoPosition: 'bottom-left', // Move the logo to the bottom left
          bounds: stateGeometry.bounds,
          hash: true,
          maxBounds: maxBounds // Set the map's geographical boundaries.
      });
      // If url hash for map zoom and center is default (e.g., base url load), fit to bounds, with default padding
      if (window.location.hash == defaultHash) {
        map.value.fitBounds(stateGeometry.bounds, {
          padding: {
            top: defaultMapPaddingTop,
            left: mapPaddingLeft,
            bottom: defaultMapPaddingBottom
          }
        });
      // If url includes query for specific state, use state padding
      } else if (globalDataStore.stateSelected) {
        map.value.setPadding({
          top: stateMapPaddingTop, 
          bottom: stateMapPaddingBottom, 
          left: stateMapPaddingLeft,
          right: stateMapPaddingRight
        })
      // Else if url hash for map zoom and center is zoomed + panned, use default padding
      } else {
        map.value.setPadding({
          top: defaultMapPaddingTop,
          left: mapPaddingLeft,
          bottom: defaultMapPaddingBottom
        })
      }

      const legendPosition = screenCategory.value == 'phone' ? 'top-left' : 'top-right';
      const downloadPosition = screenCategory.value == 'phone' ? 'top-left' : 'bottom-right';
      const contactPosition = screenCategory.value == 'phone' ? 'top-left' : 'bottom-right';
      const navControlPosition = screenCategory.value == 'phone' ? 'top-right' : 'top-right';
      const attributionPosittion = screenCategory.value == 'phone' ? 'top-right' : 'bottom-right';
      const attributionContent = 'Powered by the <b><a href="//labs.waterdata.usgs.gov/visualizations/index.html#/" target="_blank">USGS Vizlab</a></b> <a href="https://github.com/DOI-USGS/streamflow-drought-forecasts" target="_blank"><svg data-v-38bc3ed5="" class="svg-inline--fa fa-github fa-github" aria-hidden="true" focusable="false" data-prefix="fab" data-icon="github" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 496 512"><path class="" fill="#00264C" d="M165.9 397.4c0 2-2.3 3.6-5.2 3.6-3.3.3-5.6-1.3-5.6-3.6 0-2 2.3-3.6 5.2-3.6 3-.3 5.6 1.3 5.6 3.6zm-31.1-4.5c-.7 2 1.3 4.3 4.3 4.9 2.6 1 5.6 0 6.2-2s-1.3-4.3-4.3-5.2c-2.6-.7-5.5.3-6.2 2.3zm44.2-1.7c-2.9.7-4.9 2.6-4.6 4.9.3 2 2.9 3.3 5.9 2.6 2.9-.7 4.9-2.6 4.6-4.6-.3-1.9-3-3.2-5.9-2.9zM244.8 8C106.1 8 0 113.3 0 252c0 110.9 69.8 205.8 169.5 239.2 12.8 2.3 17.3-5.6 17.3-12.1 0-6.2-.3-40.4-.3-61.4 0 0-70 15-84.7-29.8 0 0-11.4-29.1-27.8-36.6 0 0-22.9-15.7 1.6-15.4 0 0 24.9 2 38.6 25.8 21.9 38.6 58.6 27.5 72.9 20.9 2.3-16 8.8-27.1 16-33.7-55.9-6.2-112.3-14.3-112.3-110.5 0-27.5 7.6-41.3 23.6-58.9-2.6-6.5-11.1-33.3 2.6-67.9 20.9-6.5 69 27 69 27 20-5.6 41.5-8.5 62.8-8.5s42.8 2.9 62.8 8.5c0 0 48.1-33.6 69-27 13.7 34.7 5.2 61.4 2.6 67.9 16 17.7 25.8 31.5 25.8 58.9 0 96.5-58.9 104.2-114.8 110.5 9.2 7.9 17 22.9 17 46.4 0 33.7-.3 75.4-.3 83.6 0 6.5 4.6 14.4 17.3 12.1C428.2 457.8 496 362.9 496 252 496 113.3 383.5 8 244.8 8zM97.2 352.9c-1.3 1-1 3.3.7 5.2 1.6 1.6 3.9 2.3 5.2 1 1.3-1 1-3.3-.7-5.2-1.6-1.6-3.9-2.3-5.2-1zm-10.8-8.1c-.7 1.3.3 2.9 2.3 3.9 1.6 1 3.6.7 4.3-.7.7-1.3-.3-2.9-2.3-3.9-2-.6-3.6-.3-4.3.7zm32.4 35.6c-1.6 1.3-1 4.3 1.3 6.2 2.3 2.3 5.2 2.6 6.5 1 1.3-1.3.7-4.3-1.3-6.2-2.2-2.3-5.2-2.6-6.5-1zm-11.4-14.7c-1.6 1-1.6 3.6 0 5.9 1.6 2.3 4.3 3.3 5.6 2.3 1.6-1.3 1.6-3.9 0-6.2-1.4-2.3-4-3.3-5.6-2z"></path></svg></a>'

      if (screenCategory.value == 'phone') {
        addLegendButton(map.value, legendPosition)

        // Add the custom navigation control buttons
        addStatePickerButton(map.value, navControlPosition)
        addConusButton(map.value, navControlPosition)

        // Add mapbox navigation control buttons
        map.value.addControl(new mapboxgl.NavigationControl({
          showCompass: false
        }), navControlPosition);

        addDownloadButton(map.value, downloadPosition)
        addContactButton(map.value, contactPosition)

        map.value.addControl(new mapboxgl.AttributionControl({
            customAttribution: attributionContent
        }), attributionPosittion);
      } else {
        addLegendButton(map.value, legendPosition)

        // Add the custom navigation control buttons
        addStatePickerButton(map.value, navControlPosition)
        addConusButton(map.value, navControlPosition)

        // Add mapbox navigation control buttons
        map.value.addControl(new mapboxgl.NavigationControl({
          showCompass: false
        }), navControlPosition);

        map.value.addControl(new mapboxgl.AttributionControl({
            customAttribution: attributionContent
        }), attributionPosittion);      
        addContactButton(map.value, contactPosition)  
        addDownloadButton(map.value, downloadPosition)
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
      const lowZoomThreshold = screenCategory.value == 'desktop' ? 5 : 4;
      const highZoomThreshold = screenCategory.value == 'desktop' ? 10 : 9;
      const lowZoomPointSize = screenCategory.value == 'desktop' ? 3 : 3;
      const lowZoomHighlightSize = 4.5;
      const lowZoomSelectedSize = 6.5;
      const highZoomPointSize = screenCategory.value == 'desktop' ? 7 : 8;
      const highZoomHighlightSize = 8;
      const highZoomSelectedSize = screenCategory.value == 'desktop' ? 10 : 11;
      const symbolSizeFactor = 70;

      // Draw point data for NA points
      map.value.addLayer({
        id: pointLayerID,
        type: 'circle',
        source: pointSourceName,
        minzoom: minZoom,
        layout: {
          'circle-sort-key': [
            "*", 
            -1, 
            ["get", pointFeatureValueField]
          ]
        },
        paint: {
          'circle-radius': [
            "interpolate",
            ["linear"],
            ["zoom"],
            // zoom is lowZoomThreshold (or less) -> circle radius will be lowZoomPointSize
            // unless selected or highlighted
            lowZoomThreshold, 
            [
              'case',
              ['boolean', ['feature-state', 'selected'], false],
              // if map feature is selected
              lowZoomSelectedSize,
              ['boolean', ['feature-state', 'highlight'], false],
              // if map feature is highlighted
              lowZoomHighlightSize,
              // if map feature is not selected and not highlighted
              lowZoomPointSize
            ],
            // zoom is highZoomThreshold (or greater) -> circle radius will be highZoomPointSize
            // unless selected or highlighted
            highZoomThreshold,
            [
              'case',
              ['boolean', ['feature-state', 'selected'], false],
              // if map feature is selected
              highZoomSelectedSize,
              ['boolean', ['feature-state', 'highlight'], false],
              // if map feature is highlighted
              highZoomHighlightSize,
              // if map feature is not selected and not highlighted
              highZoomPointSize
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
            defaultStrokeHex,
            ['boolean', ['feature-state', 'highlight'], false],
            // if map feature is highlighted
            defaultStrokeHex,
            // if map feature is not selected and not highlighted
            [
              'step',
              ['get', pointFeatureValueField],
              // predicted percentile is < 5 -> first color
              pointDataBin[0].stroke,
              pointDataBreaks[0],
              // predicted percentile is >=5 and <10 -> second color
              pointDataBin[1].stroke,
              pointDataBreaks[1],
              // predicted percentile is >=10 and <20 -> third color
              pointDataBin[2].stroke,
              pointDataBreaks[2],
              // predicted percentile is >=20 -> fourth color
              pointDataBin[3].stroke,
              pointDataBreaks[3],
              // predicted percentile is >=999 (NA)
              noDataBin.stroke
            ]
          ],
        }
      });

      // Add "x" symbol over sites w/ NA values (observed data only)
			map.value.loadImage(
        getImageURL("x_icon.png"),
        (error, image) => {
          if (error) throw error;
          map.value.addImage('x_icon', image);
          
          // Add the layers after the image has loaded
          map.value.addLayer({
            id: naLayerID, 
            type: 'symbol', 
            filter: ['==', pointFeatureValueField, 999],
            source: pointSourceName, 
            layout: { 
              'icon-image': 'x_icon', 
              'icon-size': [
                "interpolate",
                ["linear"],
                ["zoom"],
                // zoom is lowZoomThreshold (or less) -> scaled to point size at low zoom
                lowZoomThreshold, 
                lowZoomPointSize/symbolSizeFactor,
                // zoom is highZoomThreshold (or greater) -> scaled to point size at high zoom
                highZoomThreshold,
                highZoomPointSize/symbolSizeFactor
              ],
              'icon-allow-overlap': true
            }
          });
        }
      );
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

          // add popup on mobile
          if (screenCategory.value != 'desktop') {
            const coordinates = feature.geometry.coordinates.slice();

            mobilePopup = new mapboxgl.Popup();
            addPopup(mobilePopup, feature.properties[pointFeatureIdField], coordinates)
          }
          
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
          // on mobile, hide site summary view
          fullSummaryShownOnMobile.value = false;

          if (pointSelectedFeature.value) {
            map.value.setFeatureState(pointSelectedFeature.value, { selected: false });
            pointSelectedFeature.value = null;

            // update global ref
            selectedSite.value = null;
          }
        }
      });

      // On desktop, add hover pop-up functionality for all sites
      // And also highlight feature on hover
      if (screenCategory.value == 'desktop') {
        const desktopPopup = new mapboxgl.Popup({
          closeButton: false,
          closeOnClick: false
        });
        map.value.addInteraction('mouseenter', {
          type: 'mouseenter',
          target: { layerId: pointLayerID },
          handler: ({ feature }) => {
            map.value.setFeatureState(feature, { highlight: true });
            map.value.getCanvas().style.cursor = 'pointer';

            // Copy the coordinates from the POI underneath the cursor
            const coordinates = feature.geometry.coordinates.slice();

            // Populate the popup and set its coordinates based on the feature found.
            addPopup(desktopPopup, feature.properties[pointFeatureIdField], coordinates)
          }
        });

        // Moving the mouse away from a feature will remove the highlight and popup
        map.value.addInteraction('mouseleave', {
          type: 'mouseleave',
          target: { layerId: pointLayerID },
          handler: ({ feature }) => {
            map.value.setFeatureState(feature, { highlight: false });
            map.value.getCanvas().style.cursor = '';
            desktopPopup.remove();
            return false;
          }
        });
      } else {
        
      }
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

    function addPopup(popup, currentSite, currentSiteCoordinates) {
      const newDiv = document.createElement('div');
      newDiv.id = "site-popup"
      newDiv.innerHTML = buildPopupContent(currentSite);
      popup.setLngLat(currentSiteCoordinates).setDOMContent(newDiv).addTo(map.value);
    }

    function buildPopupContent(currentSite) {
      hoveredSite.value = currentSite;

      const datePreface = globalDataStore.dataType == 'Observed' ? 'as of' : 'on';
      let siteStatusStatement;
      switch(true) {
        case globalDataStore.hoveredSiteStatus == "none":
          siteStatusStatement = `${globalDataStore.statusPreface} <span class="slight-emph">not</span> ${globalDataStore.statusPhrase} streamflow drought on ${globalDataStore.selectedDateFormatted}`;
          break;
        case globalDataStore.hoveredSiteStatus == "NA":
          siteStatusStatement = `<span>No streamflow data available for ${globalDataStore.selectedDateFormatted}</span>`;
          break;
        default:
          siteStatusStatement = `${globalDataStore.statusPreface} ${globalDataStore.statusPhrase} <span  class="highlight slight-emph ${globalDataStore.hoveredSiteStatus}">${globalDataStore.hoveredSiteStatus}</span> streamflow drought ${datePreface} ${globalDataStore.selectedDateFormatted}`;
      }
      return `<div class='gage-info'><p>Gage <span class='slight-emph'>${hoveredSite.value}</span></p><p class='station-name'>${globalDataStore.hoveredSiteInfo.station_nm}</p></div><p>${siteStatusStatement}</p>`
    }

    function updateMobilePopup(currentSite) {
      const newDiv = document.createElement('div');
      newDiv.id = "site-popup"
      newDiv.innerHTML = buildPopupContent(currentSite);
      mobilePopup.setDOMContent(newDiv);
    }

</script>

<style scoped>
  #map-container {
    position: relative;
  }
  #interactive-map-container {
    display: flex;
    height: calc(100vh - 23.4px - 71px - 40px - 72px - 0rem); /* page height - USWDS banner (23.4) - USGS header (71)- Experimental banner (40 on desktop, 58 mobile)- prefooter code links (32) - USGS footer (72) - container margin (top + bottom) */
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
<style>
  #site-popup p {
    font-family: var(--default-font);
    padding: 0;
    color: var(--color-text);
    font-size: 1.6rem;
  }
  #site-popup .gage-info {
    margin-bottom: 10px;
  }
  #site-popup .station-name {
    color: var(--grey_7_1);
    font-size: 1.2rem;
    line-height: 1.1;
    padding-top: 0.1rem;
  }
  .mapboxgl-ctrl-group button:focus-visible {
    box-shadow: none;
    box-shadow: 0 0 1px 2px rgb(0, 0, 0, 0.85) !important;
  }
  .mapboxgl-ctrl-attrib button:focus-visible {
    box-shadow: none;
    box-shadow: 0 0 1px 2px rgb(0, 0, 0, 0.85) !important;
  }
</style>