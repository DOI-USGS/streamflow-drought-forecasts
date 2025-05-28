import { defineStore } from "pinia";
import * as d3 from 'd3-fetch'; // import smaller set of modules

// const STREAMFLOW_VALUE_COLUMN = "Flow_7d"

const extractDatasetProperties = function (dataset, location, dataType) {
    return {
        datasetId: location + dataType
    };
};

export const useTimeseriesDataStore = defineStore("timeseriesDataStore", {
  state: () => ({
    datasets: []
  }),
  getters: {
    /*
     * Returns a function which takes a datasetId and returns the dataset stored or undefined if not in store
     * @returns {Function} - which takes a string representing the datasetId.
     */
    getDataset: (state) => {
        return (siteId, dataType) => {
          return state.datasets.find((dataset) => {
              return(
                dataset.siteId === siteId &&
                dataset.dataType === dataType
              )
          }) || {};
        };
    },
    getDatasets: (state) => {
      return (siteId) => {
        console.log(`Getting all data for ${siteId}`)
        return state.datasets.filter((dataset) => {
          return (
            dataset.siteId === siteId 
          );
        });
      };
    },
    /*
     * Returns a function which takes a siteId and dataType and returns an array representing the
     * minimum and maximum result values. The returned value will be null if no observations.
     * @returns {Function} - The function takes a string representing the siteId and dataType and
     * returns a two element Array of Number or null.
     */
    getDatasetResultDomain: (state) => {
      return (siteId, dataType) => {
        const results = state
          .getDataset(siteId, dataType)
          ?.values?.map((value) => value.result)
          .filter((result) => !isNaN(result));
        if (results && results.length) {
          return [Math.min(...results), Math.max(...results)];
        } else {
          return null;
        }
      };
    },
  },
  actions: {
    /*
     *
     */
    async fetchAndAddDatasets(siteId, dataType) {
        console.log(`fetching ${dataType} data for ${siteId}`)
        const response = await d3.csv(`${import.meta.env.VITE_APP_S3_PROD_URL}${import.meta.env.VITE_APP_TITLE}/${dataType}/${siteId}.csv`, d => {
          d.result = + d.result;
          return d;
        })
        const dataset = [{
            datasetID: siteId + dataType,
            siteId: siteId,
            dataType: dataType,
            values: response
        }]
        this.datasets = this.datasets.concat(dataset);
    }
  }
})