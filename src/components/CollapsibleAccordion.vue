<template>
  <div 
    :id="accordionId"
    class="accordion-container"
    :style="{'border-left-color': leftBorderColor }"
  > 
    <h2>
      <button
        :id="`${accordionId}-button`" 
        class="accordion" 
        type="button"
        :class="{ active: active }"
        :aria-expanded="active ? true : false"
        :aria-controls="`${accordionId}-panel`"
        :style="{'background-color': active ? buttonActiveBackgroundColor : buttonInactiveBackgroundColor, 'font-weight': buttonFontWeight, color: buttonFontColor}"
        @click="accordionClick"
      >
        <p 
          class="accordion-button-text" 
          v-html="heading" 
        />
        <span 
          class="accordion-button-text symbol"
          :class="{ active: active }"
        >
          <svg 
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 20 20"
          >
            <line 
              class="symbol-line"
              x1="10"
              y1="1"
              x2="10"
              y2="19"
              :stroke="buttonFontColor"
            />
            <line
              class="symbol-line"
              x1="19"
              y1="10"
              x2="1"
              y2="10"
              :stroke="buttonFontColor"
            />
          </svg>  
        </span>
      </button>
    </h2>
    <div
      :id="`${accordionId}-panel`"
      role="region"
      class="panel"
      :aria-labelledby="`${accordionId}-button`"
      :class="[{ 'active': active }]"
    >
      <div
        v-for="item, index in content"
        :key="index"
      >
        <div
          v-if="item.type=='text'"
          class="accordion-text-container"
        >
          <p
            v-html="item.content"
          />
        </div>
        <div
          v-if="item.type=='quote'"
          class="accordion-text-container"
        >
          <p
            class="quote"
            v-html="item.content"
          />
        </div>
        <div
          v-if="item.type=='image'"
          class="accordion-image-container"
        >
          <img
            :src="getImageURL(item.content)"
            class="accordion-image"
            :class="{ mobile: mobileView}"
          >
        </div>
        <div
          v-if="item.type=='svg'"
          class="accordion-svg-container"
          :style="{ width: item.width }"
          :class="item.class"
        > 
          <component 
            :is="getSVG(item.content)" 
            class="accordion-svg"
          />
        </div>
        <div
          v-if="item.type=='flex'"
          class="accordion-flex-container"
          :style="{ 'flex-direction': item.flex_dir, 'align-items': item.flex_align, 'justify-content': item.flex_justify, 'gap': item.flex_gap, 'line-height': item.flex_line_height, 'margin': item.flex_margin}"
        >
          <div
            v-for="flex_item, flex_index in item.content"
            :key="flex_index"
          >
            <p
              v-if="flex_item.type=='text'"
              v-html="flex_item.content"
            />
            <p
              v-if="flex_item.type=='quote'"
              class="quote"
              v-html="flex_item.content"
            />
            <div
              v-if="flex_item.type=='image'"
              class="accordion-image-container"
            >
              <img
                :src="getImageURL(flex_item.content)"
                class="accordion-image"
                :class="{ mobile: mobileView}"
              >
            </div>
            <div
              v-if="flex_item.type=='svg'"
              :style="{ width: flex_item.width, height: flex_item.height }"
              :class="flex_item.class"
            > 
              <component 
                :is="getSVG(flex_item.content)" 
                class="accordion-svg"
                aria-hidden="true"
              />
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
  import { defineAsyncComponent, nextTick, ref, watch } from "vue";
  import { isMobile } from 'mobile-device-detect';

  const props = defineProps({
    activeOnLoad: Boolean, // should accordion be open on load
    accordionId: {
      type: String,
      required: true,
      default: ""
    }, // id of acordion, for selection
    heading: {
      type: String,
      required: true,
      default: 'Accordion heading'
    },
    content: {
      type: Array,
      required: true,
      default: () => ([
        {
          type: 'text',
          content: 'Accordion content'
        }
      ]),
    },
    leftBorderColor: {
      type: String,
      required: true,
      default: '#000000'
    },
    buttonActiveBackgroundColor: {
      type: String,
      required: true,
      default: '#F2F2F2'
    },
    buttonInactiveBackgroundColor: {
      type: String,
      required: true,
      default: '#ffffff'
    },
    buttonFontWeight: {
      type: String,
      required: true,
      default: '800'
    },
    buttonFontColor: {
      type: String,
      required: true,
      default: '#000000'
    },
    tooltipFunction: {
      type: Function,
      required: false,
      default: () => {
        console.log('Default function');
      }
    }
  })

  // global variables
  const mobileView = isMobile;
  const active = ref(props.activeOnLoad);

  watch(active, () => {
    if (active.value == true) {
      if (props.tooltipFunction) {
        handleTooltips()
      }
    }
  });

  async function handleTooltips() {
    await nextTick();
    props.tooltipFunction(props.accordionId)
  }

  function accordionClick() {
    active.value = !active.value;
  }

  function getImageURL(file) {
    return new URL(`../assets/images/${file}`, import.meta.url).href
  }

  function getSVG(file) {
    return defineAsyncComponent(() => import(`../../src/assets/svgs/${file}.svg`));
  }
</script>

<style scoped lang="scss">
$margin: 10px;
$text-margin-phone: 0.75rem;
$text-margin: 1rem;
$padding: 10px;
$text-padding: 0.5rem;
$left-border-width: 5px;
.accordion-container {
  border-left: $left-border-width solid;  
  border-right: 1px solid #dee2e6;
  border-top: 1px solid #dee2e6;
  border-bottom: 1px solid #dee2e6;
  border-radius: .25rem;
  overflow-wrap: break-word;
  margin: $margin calc(($margin + $left-border-width/2)*-1) $margin calc(($margin + $left-border-width/2)*-1);
  overflow: hidden;
}
.accordion-container h2 {
  font-size: 1.6rem;
  @media only screen and (min-width: 641px) {
    font-size: 2rem;
  }
}
.accordion {
  cursor: pointer;
  padding: calc($padding / 2);
  padding-left: $padding;
  width: 100%;
  border: none;
  text-align: left;
  outline: none;
  display: flex;
  justify-content: space-between;
  gap: 5px;
  align-items: center;
  position: relative;
  border-radius: 0 .25rem .25rem 0;
}
.accordion:focus-visible {
  border: 2px solid;
  border-radius: 0 .25rem .25rem 0;
}
.accordion:hover {
  background-color: var(--medium-light-grey) !important;
}
.accordion-button-text {
  padding: 0;
}
.symbol {
  height: 35px;
  display: flex;
  align-items: center;
  padding-right: calc($padding / 2);
}
.symbol svg {
  width: 25px;
  height: 25px;
}
.symbol.active svg {
  transform: rotate(45deg);
}
.symbol-line {
  stroke-width: 0.8px;
}
.panel {
  display: none; 
  margin: 2rem 0 2rem 0;
}
.panel.active {
  display: block; 
}
.accordion-text-container {
  padding: 0 $padding 0 0;
  margin: calc($text-margin-phone / 2) 0 $text-margin-phone $margin;
  @media only screen and (min-width: 641px) {
    margin: calc($text-margin / 2) 0 $text-margin $margin;
  }
}
.panel p {
  padding: 0 0 $text-padding 0;
  font-weight: 400 !important;  
}
.accordion-image-container {
  text-align: center;
}
.accordion-image {
  padding: 10px;
  max-width: 95%;
}
.accordion-image.mobile {
  padding: 10px;
  max-width: 100%;
}
.accordion-svg-container {
  padding: 10px;
  max-width: 95%;
  margin: auto;
}
.accordion-svg {
  width: 100%;
  height: 100%;
}
.accordion-flex-container {
  display: flex;
  padding: 0 0 0 10px;
}
.accordion-flex-container p {
  padding: 0;
}
.quote {
  font-style: italic;
  padding-left: calc($padding * 2) !important;
  opacity: 0.7;
}
ul {
  display: list-item;
  padding-bottom: 1rem;
  padding-left: 0.25rem;
  margin-left: 40px;
}
ul:first-child {
  padding-top: 1rem;
}
ul:last-child {
  padding-bottom: 1rem;
}
</style>