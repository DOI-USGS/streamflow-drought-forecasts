<template>
  <section>
    <div id="dropdown-wrapper">
      <select
        v-model="selectedOption"
        @change="$emit('update:modelValue', selectedOption)"
      >
        <option
          v-for="option, index in options"
          :key="index"
          :value="option[valueField]"
        >
          {{ option[labelField] }}
        </option>
      </select>
    </div>
  </section>
</template>

<script setup>
  import { ref } from 'vue';

  const props = defineProps({
    modelValue: {
        type: [String, Number],
        required: true,
        default: null
    }, // v-model binding for selected value

    // array of dropdown options
    options: {
        type: Array,
        required: true
    },

    // fields to use for labels and values
    labelField: {
        type: String,
        default: 'label'
    },
    valueField: {
        type: String,
        default: 'value'
    }
  });

  defineEmits(['update:modelValue']);

  const selectedOption = ref(props.modelValue)

</script>

<style scoped>
</style>