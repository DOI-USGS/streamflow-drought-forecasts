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
    datasets: [],
    lineDataTypes: ["streamflow"],
    pointDataTypes: ["forecasts"],
    areaDataTypes: ["thresholds", "overlays_lower", "overlays_upper"],
    rectDataTypes: ["uncertainty"]
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
        // console.log(`Getting all stored data for ${siteId}`)
        return state.datasets.filter((dataset) => {
          return (
            dataset.siteId === siteId 
          );
        });
      };
    },
    getFilteredDataset: (state)=> {
      return (siteId, dataType, filterField, filterValue) => {
        const dataset = state.getDataset(siteId, dataType)
        const filteredDataset = {}
        filteredDataset.datasetID = siteId + dataType,
        filteredDataset.siteId = siteId,
        filteredDataset.dataType = dataType,
        filteredDataset.values = dataset.values.filter((value) => {
          return (
            value[filterField] === filterValue
          )
        })
        return(filteredDataset)
      }
    },
    /*
     * Returns a function which takes a siteId and dataType and returns an array representing the
     * minimum and maximum result values. The returned value will be null if no observations.
     * @returns {Function} - The function takes a string representing the siteId and dataType and
     * returns a two element Array of Number or null.
     */
    getDatasetResultDomain: (state) => {
      return (siteId, dataType, resultField = "result") => {
        const results = state
          .getDataset(siteId, dataType)
          ?.values?.map((value) => value[resultField])
          .filter((result) => !isNaN(result));
        if (results && results.length) {
          return [Math.min(...results), Math.max(...results)];
        } else {
          return null;
        }
      };
    },
    getDrawingSegments: (state) => {
      return ( { siteId, dataType, values = [], resultFields = { result: "result"}, groupIdentifier = undefined }) => {
        const getNewSegment = function (id) {
          return {
            id: id,
            points: [],
          };
        };

        // if no dataset passed in, retrieve based on siteId and dataType
        if (!values.length) {
          values = state.getDataset(siteId, dataType).values
        }
        
        if (!values.length) {
          return [];
        }

        let segments = [];

        if (state.lineDataTypes.includes(dataType) | state.pointDataTypes.includes(dataType)) {
          let newSegment = getNewSegment(dataType);

          if (state.lineDataTypes.includes(dataType)) {       
            // testing with single value (to draw point)
            // newSegment.points.push({
            //     id: value.dt,
            //     dateTime:  new Date(values[0].dt),
            //     value: values[0].result,
            //   });

            values.forEach((value) => {
              if (!isNaN(value[resultFields.result])) {
                newSegment.points.push({
                  id: siteId,
                  dateTime:  new Date(value.dt),
                  value: value[resultFields.result],
                });
              }
            });        
          } else if (state.pointDataTypes.includes(dataType)) {
            values.forEach((value) => {
              if (!isNaN(value[resultFields.result])) {
                newSegment.points.push({
                  id: `${siteId}-${value.dt}`,
                  dateTime:  new Date(value.dt),
                  value: value[resultFields.result],
                  class: value[resultFields.class]
                });
              }
            });        
          }
          if (newSegment.points.length > 0) {
            segments.push(newSegment);
          } else {
            console.log(`All ${resultFields.result} values for ${dataType} for ${siteId} are NaN`)
          }
        } else if (state.areaDataTypes.includes(dataType)) {
          
          if (groupIdentifier) {
            const areaGroups = [...new Set(values.map(value => value[groupIdentifier]))];
            
            areaGroups.forEach((areaGroup) => {
              let newSegment = getNewSegment(areaGroup);
              const groupValues = values.filter(value => value[groupIdentifier] == areaGroup)
              groupValues.forEach((value) => {
                if (!isNaN(value[resultFields.result_max])) {
                  newSegment.points.push({
                    id: siteId,
                    dateTime:  new Date(value.dt),
                    value_min: value[resultFields.result_min],
                    value_max: value[resultFields.result_max]
                  });
                }
              });
              segments.push(newSegment);
            })
          } else {
            let newSegment = getNewSegment(dataType);
            values.forEach((value) => {
              if (!isNaN(value[resultFields.result_max])) {
                newSegment.points.push({
                  id: siteId,
                  dateTime:  new Date(value.dt),
                  value_min: value[resultFields.result_min],
                  value_max: value[resultFields.result_max]
                });
              }
            });  
            segments.push(newSegment);
          }

        } else if (state.rectDataTypes.includes(dataType)) {
          let newSegment = getNewSegment(dataType);
            values.forEach((value) => {
              if (!isNaN(value[resultFields.result_max])) {
                newSegment.points.push({
                  id: `${siteId}-${value.dt}`,
                  dateTime:  new Date(value.dt),
                  value_min: value[resultFields.result_min],
                  value_max: value[resultFields.result_max]
                });
              }
            });  
            segments.push(newSegment);
        }
        console.log(dataType)
        console.log(segments)
        return segments;
      };
    },
  },
  actions: {
    /*
     *
     */
    async fetchAndAddDatasets(siteId, dataType, dataNumericFields) {
        // console.log(`Fetching ${dataType} data for ${siteId}`)
        const response = await d3.csv(`${import.meta.env.VITE_APP_S3_PROD_URL}${import.meta.env.VITE_APP_TITLE}/${dataType}/${siteId}.csv`, d => {
          if (dataNumericFields) {
            dataNumericFields.forEach(numericField => {
              d[numericField] = +d[numericField]
            });
          }
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