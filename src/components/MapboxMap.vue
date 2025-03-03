<template>
  <div
    ref="mapContainer"
    class="map-container"
  />
</template>

<script setup>
    import { onMounted, ref } from 'vue';
    import mapboxgl from "mapbox-gl";
    mapboxgl.accessToken = import.meta.env.VITE_APP_MAPBOX_TOKEN;;
    
    // Global variables
    const mapContainer = ref(null);
    const publicPath = import.meta.env.BASE_URL;
    const colors = ["#7E1717", "#F24C3D", "#E3B418", "#9DB9F1"]

    onMounted(async () => {
        const map = new mapboxgl.Map({
            container: mapContainer.value, // container ID
            style: 'mapbox://styles/hcorson-dosch/cm7jkdo7g003201s5hepq8ulm', // style URL
            center: [-98.5, 40], // starting position [lng, lat]
            zoom: 4, // starting zoom
            maxZoom: 16,
            minZoom: 3
        });

        map.addControl(new mapboxgl.NavigationControl());

        map.on('load', () => {
            map.addSource('gages', {
                type: 'geojson',
                // Use a URL for the value for the `data` property.
                data: publicPath + 'CONUS_data.geojson'
            });

            map.addLayer({
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
    });

    function buildMap() {
        
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