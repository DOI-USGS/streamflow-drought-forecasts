<template>
  <section id="extent-summary-wrapper">
    <div id="summary-header-container" />
    <div id="extent-summary-container">
      <div class="extent-scroll-watcher" />
      <div
        v-if="showGaged"
        id="gaged-extent-summary-container"
      >
        <div
          id="gaged-intro-wrapper"
          class="extent-summary-intro-container-wrapper"
        >
          <div
            id="gaged-intro"
            class="extent-summary-intro-container"
          >
            <FaqButton
              class="intro-faq-button"
              data-open-modal
              aria-controls="faq-dialog"
            />
            <div class="intro-text-container">
              <p>
                <span
                  v-if="globalDataStore.sitesDrought"
                  class="slight-emph"
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
                of
                <span class="slight-emph">
                  {{ nSites }}
                </span>
                gages<span
                  v-if="
                    dataType == 'Current' &&
                      (globalDataStore.sitesNA?.length > 0 ||
                        globalDataStore.highlyRegulatedSitesNA?.length > 0)
                  "
                >
                  with data</span><span
                  v-if="
                    !globalDataStore.includeHighlyRegulated &&
                      globalDataStore.highlyRegulatedSiteList?.length > 0
                  "
                >*</span>
                in
                <span
                  v-if="globalDataStore.selectedExtent"
                  class="slight-emph"
                >
                  {{ globalDataStore.selectedExtent }}
                </span>
                <span v-else>
                  <span class="tooltip-group">
                    <span class="tooltip-span">
                      {{ globalDataStore.defaultExtent }}
                      <span
                        id="conus-tooltip"
                        class="tooltiptext"
                      >
                        The conterminous United States, or the lower 48 states.
                      </span>
                    </span>
                  </span>
                </span>
                are
              </p>
              <p>
                <span
                  v-if="dataType == 'Current'"
                  class="slight-emph"
                >observed</span>
                <span
                  v-else
                  class="slight-emph"
                >forecast</span>
                to be in streamflow drought, with
              </p>
            </div>
          </div>
        </div>
        <div class="category-summary-container">
          <div class="category-text-container">
            <span class="category-percent">
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
            </span>
            <span class="category-label">
              <span class="highlight moderate slight-emph">moderate</span>,
            </span>
          </div>
          <div class="category-text-container">
            <span class="category-percent">
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
            </span>
            <span class="category-label">
              <span class="highlight severe slight-emph">severe</span>, and
            </span>
          </div>
          <div class="category-text-container">
            <span class="category-percent">
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
            </span>
            <span class="category-label">
              <span class="highlight extreme slight-emph">extreme</span>
              streamflow drought
            </span>
          </div>
        </div>
        <div
          v-if="
            !globalDataStore.includeHighlyRegulated &&
              globalDataStore.highlyRegulatedSiteList?.length > 0
          "
          class="regulated-note-container"
          :class="{ spaced: showGaged && showUngaged }"
        >
          <span class="regulated-text">
            * Excluding
            {{
              globalDataStore.highlyRegulatedSiteList?.length -
                globalDataStore.highlyRegulatedSitesNA?.length
            }}
            highly regulated gages<span
              v-if="
                dataType == 'Current' &&
                  (globalDataStore.sitesNA?.length > 0 ||
                    globalDataStore.highlyRegulatedSitesNA?.length > 0)
              "
            >
              with data</span>
          </span>
        </div>
      </div>
      <div
        v-if="showGaged && showUngaged"
        id="spacer"
      />
      <div
        v-if="showUngaged"
        id="ungaged-extent-summary-container"
      >
        <div
          id="ungaged-intro-wrapper"
          class="extent-summary-intro-container-wrapper"
        >
          <div
            id="ungaged-intro"
            class="extent-summary-intro-container"
          >
            <FaqButton
              v-if="!showGaged"
              class="intro-faq-button"
              data-open-modal
              aria-controls="faq-dialog"
            />
            <div class="intro-text-container">
              <p>
                <span class="slight-emph">
                  {{ roundPercent(globalDataStore.ungagedPerAreaDrought) }}%</span>
                of the watershed area<span
                  v-if="
                    !globalDataStore.includeHighlyRegulated &&
                      globalDataStore.highlyRegulatedSiteList?.length > 0
                  "
                >*</span>
                of
                <span
                  v-if="globalDataStore.selectedExtent"
                  class="slight-emph"
                >
                  {{ globalDataStore.selectedExtent }}
                </span>
                <span v-else>
                  <span class="tooltip-group">
                    <span class="tooltip-span">
                      {{ globalDataStore.defaultExtent }}
                      <span
                        id="ungaged-conus-tooltip"
                        class="tooltiptext"
                      >
                        The conterminous United States, or the lower 48 states.
                      </span>
                    </span>
                  </span>
                </span>
                is
              </p>
              <p>
                <span
                  v-if="dataType == 'Current'"
                  class="tooltip-group"
                >
                  <span
                    id="estimated-tooltip-span"
                    class="tooltip-span"
                  >
                    <span>estimated</span>
                    <span
                      id="estimated-tooltip"
                      class="tooltiptext"
                    >Current conditions at unmonitored locations are based on spatial
                      extrapolation from nearby gages.
                    </span>
                  </span>
                </span>
                <span
                  v-else
                  class="slight-emph"
                >forecast</span>
                to be in streamflow drought, with
              </p>
            </div>
          </div>
        </div>
        <div class="category-summary-container">
          <div class="category-text-container">
            <span class="category-percent">
              <span :class="globalDataStore.ungagedPerAreaModerate > 0 ? 'slight-emph' : ''">{{ roundPercent(globalDataStore.ungagedPerAreaModerate) }}%</span>
              in
            </span>
            <span class="category-label"><span class="highlight moderate slight-emph">moderate</span>,
            </span>
          </div>
          <div class="category-text-container">
            <span class="category-percent">
              <span :class="globalDataStore.ungagedPerAreaSevere > 0 ? 'slight-emph' : ''">{{ roundPercent(globalDataStore.ungagedPerAreaSevere) }}%</span>
              in
            </span>
            <span class="category-label"><span class="highlight severe slight-emph">severe</span>, and
            </span>
          </div>
          <div class="category-text-container">
            <span class="category-percent">
              <span :class="globalDataStore.ungagedPerAreaExtreme > 0 ? 'slight-emph' : ''">{{ roundPercent(globalDataStore.ungagedPerAreaExtreme) }}%</span>
              in
            </span>
            <span class="category-label">
              <span class="highlight extreme slight-emph">extreme</span> streamflow drought
            </span>
          </div>
        </div>
        <div
          v-if="
            !globalDataStore.includeHighlyRegulated &&
              globalDataStore.highlyRegulatedSiteList?.length > 0
          "
          class="regulated-note-container"
          :class="{ spaced: showGaged && showUngaged }"
        >
          <span class="regulated-text">
            * Excluding highly regulated watersheds that make up
            {{ globalDataStore.ungagedPercentArea.perHighlyReg }}% of the watershed area
          </span>
        </div>
      </div>
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
const { dataType } = storeToRefs(globalDataStore)
const { showGaged } = storeToRefs(globalDataStore)
const { showUngaged } = storeToRefs(globalDataStore)
const nSites = computed(() => {
  if (dataType.value == 'Current' && globalDataStore.sitesNA?.length > 0) {
    return (globalDataStore.siteList?.length - globalDataStore.sitesNA?.length).toLocaleString(
      'en-US'
    )
  } else {
    return globalDataStore.siteList?.length.toLocaleString('en-US')
  }
})
const ungagedSummaryPreface = computed(() => {
  return globalDataStore.dataType == 'Forecast' ? 'to be ' : 'is '
})

onMounted(() => {
  // re-position tooltips that go off screen
  if (showGaged.value) {
    globalDataStore.positionTooltips('gaged-intro')
  }
  if (showUngaged.value) {
    globalDataStore.positionTooltips('ungaged-intro')
  }
})

onMounted(async () => {
  const header = document.querySelector('#summary-header-container')
  const scrollWatcher = document.querySelector('.extent-scroll-watcher')

  const observer = new IntersectionObserver(([entry]) => {
    if (!entry.isIntersecting) {
      header.classList.add('stuck')
    } else {
      header.classList.remove('stuck')
    }
  })

  observer.observe(scrollWatcher)
})

watch(dataType, (newValue) => {
  if (newValue == 'Current') {
    if (showUngaged.value) {
      handleTooltips('ungaged-intro')
    }
    if (showGaged.value && !globalDataStore.selectedExtent) {
      handleTooltips('gaged-intro')
    }
  }
})

watch(showGaged, (newValue) => {
  if (newValue == true) {
    handleTooltips('gaged-intro')
  }
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
  return nCategory > 0 ? `${percentCategoryRounded}%` : '0%'
}

function roundPercent(percent) {
  if (percent < 99 && percent >= 1) {
    return Math.round(percent)
  } else {
    return Math.round(percent * 10) / 10
  }
}
</script>

<style scoped lang="scss">
#extent-summary-wrapper {
  display: flex;
  flex-direction: column;
  max-height: 100%;
  width: 100%;
  overflow-x: visible;
}
#summary-header-container {
  height: 15px;
}
#summary-header-container.stuck {
  box-shadow: 0px 5px 4px -4px rgba(0, 0, 0, 0.2); /* Shadow when stuck */
}
#extent-summary-container {
  height: 100%;
  @media only screen and (min-width: 641px) {
    overflow-y: auto;
    scrollbar-width: thin;
    scrollbar-color: var(--grey_3_1) var(--near-white);
    padding-right: 5px; /* add a little padding for cases when scroll needed */
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
#spacer {
  height: 2rem;
  @media only screen and (min-width: 641px) {
    height: 1.5rem;
  }
}
#gaged-intro-wrapper p {
  padding: 0;
}
#ungaged-intro-wrapper p {
  padding: 0;
}
.extent-summary-intro-container {
  display: flex;
  justify-content: space-between;
  align-items: start;
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
.category-summary-container {
  padding-left: 0.75rem;
  @media only screen and (min-width: 641px) {
    padding-left: 1rem;
  }
}
.category-text-container {
  font-weight: 300;
  padding: 0 0 1rem 0;
  display: flex;
  flex-direction: row;
  gap: 0.4rem;
  @media only screen and (min-width: 641px) {
    gap: 0.4rem;
  }
}
.category-percent {
  width: 6rem;
  text-align: end;
  @media only screen and (min-width: 641px) {
    width: 7.5rem;
  }
}
#estimated-tooltip {
  width: 300px;
}
.regulated-note-container {
  display: flex;
  align-items: center;
  width: 100%;
  margin: 0;
  padding: 0;
  line-height: 1.2;
  overflow: hidden;

  padding-top: 0.5rem;
  padding-bottom: 0.75rem;
}

.regulated-note-container.spaced {
  padding-bottom: 1rem;
}
.regulated-text {
  font-weight: 300;
  font-style: italic;
  font-size: 1.6rem;
  display: inline-block;
  vertical-align: bottom;
}
</style>
