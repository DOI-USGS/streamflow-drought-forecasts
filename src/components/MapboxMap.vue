<template>
    <div ref="mapContainer" class="map-container">
    </div>
</template>

<script setup>
    import { onMounted, ref } from 'vue';
    import mapboxgl from "mapbox-gl";
    mapboxgl.accessToken = 'pk.eyJ1IjoiaGNvcnNvbi1kb3NjaCIsImEiOiJjbTY5dDdjNzYwMXA2MnNwdWI5eDhkbHhrIn0.XZwtzARti22ehtFUVNwRug';
    
    // Global variables
    const mapContainer = ref(null);

    onMounted(async () => {
        new mapboxgl.Map({
            container: mapContainer.value, // container ID
            style: 'mapbox://styles/mapbox/light-v11', // style URL
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