<template>
  <section
    id="icon-container"
  >
    <button
      class="icon-button"
      :disabled="!siteRegulated"
      :title="siteRegulated ? text.regulated.promptTrue : text.regulated.promptFalse"
      @click="showRegulatedDialog"
    >
      <DamIcon
        class="hydrology-icon"
        aria-hidden="true"
      />
    </button>
    <button
      class="icon-button"
      :disabled="!siteIntermittent"
      :title="siteIntermittent ? text.intermittent.promptTrue : text.intermittent.promptFalse"
      @click="showIntermittentDialog"
    >
      <IntermittentIcon
        class="hydrology-icon"
        aria-hidden="true"
      />
    </button>
    <button
      class="icon-button"
      :disabled="!siteSnowDominated"
      :title="siteSnowDominated ? text.snow.promptTrue : text.snow.promptFalse"
      @click="showSnowDialog"
    >
      <SnowIcon
        class="hydrology-icon"
        aria-hidden="true"
      />
    </button>
    <button
      class="icon-button"
      :disabled="!siteIceImpacted"
      :title="siteIceImpacted ? text.ice.promptTrue : text.ice.promptFalse"
      @click="showIceDialog"
    >
      <FrozenIcon
        class="hydrology-icon"
        aria-hidden="true"
      />
    </button>
    <DialogBox
      v-model="regulatedDialogShown"
    >
      <template #dialogTitle>
        <div
          class="title-container"
        >
          <DamIcon
            class="hydrology-icon"
            aria-hidden="true"
          />
          <p v-html="text.regulated.title" />
        </div>
      </template>
      <template #dialogContent>
        <p v-html="text.regulated.text" />
      </template>
    </DialogBox>
    <DialogBox
      v-model="intermittentDialogShown"
    >
      <template #dialogTitle>
        <div
          class="title-container"
        >
          <IntermittentIcon
            class="hydrology-icon"
            aria-hidden="true"
          />
          <p v-html="text.intermittent.title" />
        </div>
      </template>
      <template #dialogContent>
        <p v-html="text.intermittent.text" />
      </template>
    </DialogBox>
    <DialogBox
      v-model="snowDialogShown"
    >
      <template #dialogTitle>
        <div
          class="title-container"
        >
          <SnowIcon
            class="hydrology-icon"
            aria-hidden="true"
          />
          <p v-html="text.snow.title" />
        </div>
      </template>
      <template #dialogContent>
        <p v-html="text.snow.text" />
      </template>
    </DialogBox>
    <DialogBox
      v-model="iceDialogShown"
    >
      <template #dialogTitle>
        <div
          class="title-container"
        >
          <FrozenIcon
            class="hydrology-icon"
            aria-hidden="true"
          />
          <p v-html="text.ice.title" />
        </div>
      </template>
      <template #dialogContent>
        <p v-html="text.ice.text" />
      </template>
    </DialogBox>
  </section>
</template>

<script setup>
  import { ref } from 'vue';
  import DialogBox from "./DialogBox.vue";
  import DamIcon from "@/assets/svgs/dam.svg";
  import IntermittentIcon from "@/assets/svgs/intermittent.svg";
  import SnowIcon from "@/assets/svgs/snow.svg";
  import FrozenIcon  from "@/assets/svgs/frozen.svg";

  const props = defineProps({
    text: {
      type: Object,
      default: () => ({}),
      required: true,
    },
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
  

  // global variables
  const regulatedDialogShown = ref(false);
  const intermittentDialogShown = ref(false);
  const snowDialogShown = ref(false);
  const iceDialogShown = ref(false);

  function showRegulatedDialog() {
    regulatedDialogShown.value = true;
  }
  function showIntermittentDialog() {
    intermittentDialogShown.value = true;
  }
  function showSnowDialog() {
    snowDialogShown.value = true;
  }
  function showIceDialog() {
    iceDialogShown.value = true;
  }
</script>

<style scoped lang="scss">
#icon-container {
  display: flex;
  flex-direction: row;
  gap: 6px;
  margin: 6px 0 3px 3px;
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
  // padding: 0 3px 0 3px;
  border-radius: 4px;
  // box-shadow: 0 0 3px 2px rgba(161, 178, 196, 0.15);
}
.icon-button:hover {
  box-shadow: 0 0 3px 2px rgba(161, 178, 196, 0.3);
}
.icon-button:disabled {
  opacity: 0.25;
  cursor: not-allowed;
}
.icon-button:disabled:hover {
  box-shadow: none;
  // box-shadow: 0 0 3px 2px rgba(161, 178, 196, 0.15);
}
.hydrology-icon {
  width: 30px;
  height: 30px;
}
.title-container {
  display: flex;
  gap: 1rem;
  align-content: center;
}
.title-container p {
  padding: 0;
  line-height: 30px;
}
</style>