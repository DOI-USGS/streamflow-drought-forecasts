<template>
  <section id="extent-summary-container">
    <div id="gaged-extent-summary-container">
      <div id="gaged-intro-wrapper" class="extent-summary-intro-container-wrapper">
        <div id="gaged-intro" class="extent-summary-intro-container">
          <FaqButton class="intro-faq-button" data-open-modal aria-controls="faq-dialog" />
          <div class="intro-text-container">
            <p>
              <span>
                Of
                <span class="slight-emph">{{
                  globalDataStore.siteList?.length.toLocaleString('en-US')
                }}</span>
              </span>
              gaged sites in
              <span v-if="globalDataStore.selectedExtent" class="slight-emph">
                {{ globalDataStore.selectedExtent }}
              </span>
              <span v-else>
                <span class="tooltip-group">
                  <span class="tooltip-span">
                    {{ globalDataStore.defaultExtent }}
                    <span id="conus-tooltip" class="tooltiptext">
                      The conterminous United States, or the lower 48 states.
                    </span>
                  </span>
                </span>
              </span>
              <span>,</span>
              <span v-if="globalDataStore.dataType == 'Forecast'"> the forecast is for</span>
            </p>
          </div>
        </div>
        <div
          v-if="globalDataStore.dataType == 'Observed' && globalDataStore.sitesNA?.length > 0"
          id="gaged-current-data-statement-container"
        >
          <p>
            <span class="slight-emph">
              {{
                (globalDataStore.siteList?.length - globalDataStore.sitesNA?.length).toLocaleString(
                  'en-US'
                )
              }}
            </span>
            <span v-if="globalDataStore.siteList?.length - globalDataStore.sitesNA?.length == 1">
              has</span
            >
            <span v-else> have</span>
            current streamflow data. Of these,
          </p>
        </div>
      </div>
      <p>
        <span
          v-if="globalDataStore.sitesDrought"
          :class="globalDataStore.sitesDrought?.length > 0 ? 'slight-emph' : ''"
        >
          {{
            buildSummary(
              globalDataStore.sitesDrought?.length,
              globalDataStore.siteList?.length,
              false,
              globalDataStore.sitesNA?.length
            )
          }}
        </span>
        {{ mainSummaryPreface }}in streamflow drought, with
      </p>
      <p>
        <span
          v-if="globalDataStore.sitesModerate"
          :class="globalDataStore.sitesModerate?.length > 0 ? 'slight-emph' : ''"
        >
          {{
            buildSummary(
              globalDataStore.sitesModerate?.length,
              globalDataStore.siteList?.length,
              false,
              globalDataStore.sitesNA?.length
            )
          }}
        </span>
        in
        <span class="highlight moderate slight-emph">moderate</span>
        streamflow drought
      </p>
      <p>
        <span
          v-if="globalDataStore.sitesSevere"
          :class="globalDataStore.sitesSevere?.length > 0 ? 'slight-emph' : ''"
        >
          {{
            buildSummary(
              globalDataStore.sitesSevere?.length,
              globalDataStore.siteList?.length,
              false,
              globalDataStore.sitesNA?.length
            )
          }}
        </span>
        in
        <span class="highlight severe slight-emph">severe</span>
        streamflow drought
      </p>
      <p>
        <span
          v-if="globalDataStore.sitesExtreme"
          :class="globalDataStore.sitesExtreme?.length > 0 ? 'slight-emph' : ''"
        >
          {{
            buildSummary(
              globalDataStore.sitesExtreme?.length,
              globalDataStore.siteList?.length,
              false,
              globalDataStore.sitesNA?.length
            )
          }}
        </span>
        in
        <span class="highlight extreme slight-emph">extreme</span>
        streamflow drought
      </p>
    </div>
    <div v-if="showUngaged" id="ungaged-extent-summary-container">
      <div id="ungaged-intro-wrapper" class="extent-summary-intro-container-wrapper">
        <div id="ungaged-intro" class="extent-summary-intro-container">
          <div class="intro-text-container">
            <p>
              <span>
                Of
                <span class="slight-emph">{{
                  globalDataStore.ungagedList?.length.toLocaleString('en-US')
                }}</span>
              </span>
              watersheds in
              <span v-if="globalDataStore.selectedExtent" class="slight-emph">
                {{ globalDataStore.selectedExtent }}
              </span>
              <span v-else>
                <span class="tooltip-group">
                  <span class="tooltip-span">
                    {{ globalDataStore.defaultExtent }}
                    <span id="ungaged-conus-tooltip" class="tooltiptext">
                      The conterminous United States, or the lower 48 states.
                    </span>
                  </span>
                </span>
              </span>
              <span>,</span>
              <span v-if="globalDataStore.dataType == 'Observed'">
                we <span class="slight-emph">estimate</span> that</span
              >
              <span v-else> the forecast is for</span>
            </p>
          </div>
        </div>
      </div>
      <p>
        <span
          v-if="globalDataStore.ungagedDrought"
          :class="globalDataStore.ungagedDrought?.length > 0 ? 'slight-emph' : ''"
        >
          {{
            buildSummary(
              globalDataStore.ungagedDrought?.length,
              globalDataStore.ungagedList?.length
            )
          }}
        </span>
        {{ mainSummaryPreface }}in streamflow drought, with
      </p>
      <p>
        <span
          v-if="globalDataStore.ungagedModerate"
          :class="globalDataStore.ungagedModerate?.length > 0 ? 'slight-emph' : ''"
        >
          {{
            buildSummary(
              globalDataStore.ungagedModerate?.length,
              globalDataStore.ungagedList?.length
            )
          }}
        </span>
        in
        <span class="highlight moderate slight-emph">moderate</span>
        streamflow drought
      </p>
      <p>
        <span
          v-if="globalDataStore.ungagedSevere"
          :class="globalDataStore.ungagedSevere?.length > 0 ? 'slight-emph' : ''"
        >
          {{
            buildSummary(globalDataStore.ungagedSevere?.length, globalDataStore.ungagedList?.length)
          }}
        </span>
        in
        <span class="highlight severe slight-emph">severe</span>
        streamflow drought
      </p>
      <p>
        <span
          v-if="globalDataStore.ungagedExtreme"
          :class="globalDataStore.ungagedExtreme?.length > 0 ? 'slight-emph' : ''"
        >
          {{
            buildSummary(
              globalDataStore.ungagedExtreme?.length,
              globalDataStore.ungagedList?.length
            )
          }}
        </span>
        in
        <span class="highlight extreme slight-emph">extreme</span>
        streamflow drought
      </p>
    </div>
  </section>
</template>

<script setup>
import { computed, nextTick, onMounted, watch } from 'vue'
import { useGlobalDataStore } from '@/stores/global-data-store'
import { storeToRefs } from 'pinia'
import FaqButton from './FaqButton.vue'

// Global variables
const globalDataStore = useGlobalDataStore()
const { showUngaged } = storeToRefs(globalDataStore)
const mainSummaryPreface = computed(() => {
  return globalDataStore.dataType == 'Forecast' ? 'to be ' : 'are '
})

onMounted(() => {
  // re-position tooltips that go off screen
  globalDataStore.positionTooltips('gaged-intro')
})

watch(showUngaged, (newValue) => {
  if (newValue == true) {
    handleTooltips('ungaged-intro')
  }
})

async function handleTooltips(containerId) {
  await nextTick()
  globalDataStore.positionTooltips(containerId)
}

// Build summary values
function buildSummary(nCategory, nSites, includeAllSites = true, nNaSites = 0) {
  let percentCategory
  if (includeAllSites) {
    percentCategory = (nCategory / nSites) * 100
  } else {
    // exclude sites where drought status is NA
    percentCategory = (nCategory / (nSites - nNaSites)) * 100
  }
  let percentCategoryRounded
  switch (true) {
    case percentCategory < 0.05:
      percentCategoryRounded = Math.round(percentCategory * 100) / 100
      break
    case percentCategory < 1:
      percentCategoryRounded = Math.round(percentCategory * 10) / 10
      break
    default:
      percentCategoryRounded = Math.round(percentCategory)
  }
  return nCategory > 0 ? `${percentCategoryRounded}%` : 'None'
}
</script>

<style scoped lang="scss">
#extent-summary-container {
  margin-top: 1.5rem;
  @media only screen and (min-width: 641px) {
    margin-top: 1rem;
  }
}
.extent-summary-intro-container-wrapper {
  display: flex;
  flex-direction: column;
  margin-bottom: 0.5rem;
  @media only screen and (min-width: 641px) {
    margin-bottom: 1rem;
  }
}
#gaged-intro-wrapper p {
  padding: 0;
}
#ungaged-intro-wrapper {
  margin-top: 2rem;
  @media only screen and (min-width: 641px) {
    margin-top: 1.5rem;
  }
}
#ungaged-intro-wrapper p {
  padding: 0;
}
.extent-summary-intro-container {
  display: flex;
  justify-content: space-between;
  align-items: end;
}
#gaged-intro p {
  line-height: 2.4rem;
  @media only screen and (min-width: 641px) {
    line-height: auto;
  }
}
#ungaged-intro p {
  line-height: 2.4rem;
  @media only screen and (min-width: 641px) {
    line-height: auto;
  }
}
#gaged-current-data-statement-container {
  margin-bottom: 0.4rem;
  @media only screen and (min-width: 641px) {
    margin-bottom: 0.25rem;
  }
}
.intro-text-container {
  order: 1;
}
.intro-faq-button {
  order: 2;
}
</style>
