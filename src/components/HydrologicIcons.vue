<template>
  <section
    id="icon-container"
  >
    <button
      class="icon-button"
      :disabled="!siteRegulated"
      @click="showDialog('Highly regulated')"
    >
      <DamIcon
        class="hydrology-icon"
      />
    </button>
    <button
      class="icon-button"
      :disabled="!siteIntermittent"
      @click="showDialog('Intermittent')"
    >
      <IntermittentIcon
        class="hydrology-icon"
      />
    </button>
    <button
      class="icon-button"
      :disabled="!siteSnowDominated"
      @click="showDialog('Snow dominated')"
    >
      <SnowIcon
        class="hydrology-icon"
      />
    </button>
    <button
      class="icon-button"
      :disabled="!siteIceImpacted"
      @click="showDialog('Ice impacted')"
    >
      <FrozenIcon
        class="hydrology-icon"
      />
    </button>
  </section>
</template>

<script setup>
  import DamIcon from "@/assets/svgs/dam.svg";
  import IntermittentIcon from "@/assets/svgs/intermittent.svg";
  import SnowIcon from "@/assets/svgs/snow.svg";
  import FrozenIcon  from "@/assets/svgs/frozen.svg";

  const props = defineProps({
    siteRegulated: {
        type: Boolean,
        required: true,
        default: false
    },
    siteIntermittent: {
        type: Boolean,
        required: true,
        default: false
    },
    siteSnowDominated: {
        type: Boolean,
        required: true,
        default: false
    },
    siteIceImpacted: {
        type: Boolean,
        required: true,
        default: false
    },
  })

  function showDialog(type) {
    console.log(type)
  }
</script>

<style>
#icon-container {
  display: flex;
  flex-direction: row;
  gap: 3px;
}
.icon-button {
  cursor: pointer;
  display: flex;
  align-items: center;
  background-color: transparent;
  border: none;
  width: 30px;
  height: 30px;
  padding: 0;
}
.icon-button:disabled {
  opacity: 0.25;
  cursor: not-allowed;
}
.hydrology-icon {
  width: 30px;
  height: 30px;
}
</style>