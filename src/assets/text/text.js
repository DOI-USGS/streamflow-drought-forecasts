export default {
    pageTitle: "Streamflow drought forecasts",
    faqs: {
        title: 'FAQs',
        accordionData: [
            {
                heading: "How does streamflow drought differ from meteorological drought?",
                content: [
                    {
                        type: "text",
                        content: "Meteorological drought ..., while streamflow drought ..."
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "What’s the difference between streamflow drought and low streamflow?",
                content: [
                    {
                        type: "text",
                        content: "It’s important to note the difference between ‘low streamflow’ and ‘streamflow drought.’ Low flows occur seasonally in many streams and are in line with typical conditions. In contrast, streamflow drought results when flows are unusually low compared to typical conditions."
                    },
                    {
                        type: "quote",
                        content: '"While droughts may include periods of low flows, a recurring seasonal low flow event is not necessarily a drought."—<a href="https://library.wmo.int/idurl/4/32176" target="_blank">WMO, 2008</a>'
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "How do these categories relate to the U.S. Drought Monitor categories?",
                content: [
                    {
                        type: "text",
                        content: "The low levels of streamflow that indicate streamflow drought are classified using <a href='https://droughtmonitor.unl.edu/About/AbouttheData/DroughtClassification.aspx' target='_blank'>U.S. Drought Monitor categories</a>. These categories bin low streamflow percentiles into specific drought categories that describe the intensity of the drought. For this project, we have specifically trained the model to forecast the following three categories of streamflow drought:<span><ul><li>Moderate drought (< 20<sup>th</sup> percentile)</li><li>Severe drought (< 10<sup>th</sup> percentile)</li><li>Extreme drought (< 5<sup>th</sup> percentile)</li></ul></span>"
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "How is streamflow drought modeled?",
                content: [
                    {
                        type: "text",
                        content: "To forecast streamflow drought at USGS stream gages across the contiguous United States (CONUS), the USGS has built a machine learning model that predicts streamflow percentiles. Learn more on the <a href='https://water.usgs.gov/vizlab/modeling-drought/' target='_blank'>Modeling streamflow drought</a> website."
                    }
                ],
                activeOnLoad: false
            },
        ]
    },
    graph: {
        title: "How do I read this graph?",
        text: "This timeseries plot..."
    },
    icons: {
        regulated: {
            title: "Highly-managed flow regime",
            text: "Streamflow at this site is highly regulated, due to storage of streamflow in upstream reservoirs.",
            promptTrue: "Site is highly-regulated",
            promptFalse: "Site is not highly-regulated"
        },
        intermittent: {
            title: "Zero-flow site",
            text: "This site experiences non-perennial flow.",
            promptTrue: "Site is has non-perennial flow",
            promptFalse: "Site is has perennial flow"
        },
        snow: {
            title: "Snow-dominated system",
            text: "Precipitation within this site's watershed is snow-dominated.",
            promptTrue: "Site is snow-dominated",
            promptFalse: "Site is not snow-dominated"
        },
        ice: {
            title: "Ice-impacted site",
            text: "At this site, flow is sometimes estimated because of ice conditions.",
            promptTrue: "Site experiences ice conditions",
            promptFalse: "Site does not experience ice conditions"
        }
    }
}