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

    onMounted(async () => {
        const map = new mapboxgl.Map({
            container: mapContainer.value, // container ID
            style: 'mapbox://styles/hcorson-dosch/cm7jkdo7g003201s5hepq8ulm', // style URL
            center: [-98.5, 40], // starting position [lng, lat]
            zoom: 4, // starting zoom
        });

        map.addControl(new mapboxgl.NavigationControl());

        map.on('load', () => {
            map.addSource('gages', {
                type: 'geojson',
                // Use a URL for the value for the `data` property.
                data: publicPath + 'CONUS_gages.geojson'
            });

            map.addLayer({
                'id': 'gages-layer',
                'type': 'circle',
                'source': 'gages',
                'paint': {
                    'circle-radius': 4,
                    'circle-stroke-width': 2,
                    'circle-color': 'red',
                    'circle-stroke-color': 'white'
                }
            });
        });
    });

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