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
        new mapboxgl.Map({
            container: mapContainer.value, // container ID
            style: 'mapbox://styles/hcorson-dosch/cm7jkdo7g003201s5hepq8ulm', // style URL
            center: [-74.5, 40], // starting position [lng, lat]
            zoom: 9, // starting zoom
        });
    });

</script>

<style>
    .map-container {
        display: flex;
        height: 100vh;
        padding: 0;
        flex: 1;
    }
</style>