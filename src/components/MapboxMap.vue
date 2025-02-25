<template>
    <div ref="mapContainer" class="map-container">
    </div>
</template>

<script setup>
    import { onMounted, ref } from 'vue';
    import mapboxgl from "mapbox-gl";
    mapboxgl.accessToken = import.meta.env.VITE_APP_MAPBOX_TOKEN;;
    
    // Global variables
    const mapContainer = ref(null);

    onMounted(async () => {
        const map = new mapboxgl.Map({
            container: mapContainer.value, // container ID
            style: 'mapbox://styles/hcorson-dosch/cm7jkdo7g003201s5hepq8ulm', // style URL
            center: [-98.5, 40], // starting position [lng, lat]
            zoom: 4, // starting zoom
        });

        map.addControl(new mapboxgl.NavigationControl());
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