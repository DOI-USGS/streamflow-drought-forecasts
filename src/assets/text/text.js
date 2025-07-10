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
            {
                heading: "What are the limitations of this tool?",
                content: [
                    {
                        type: "text",
                        content: "The limitations of this tool are..."
                    }
                ],
                activeOnLoad: false
            },
        ]
    },
    graph: {
        title: "How do I read this graph?",
        intro: "This graph shows recent streamflow conditions and forecasts of streamflow drought for a selected site. It shows the following information: the issue date, recent streamflow, drought categories and associated historical drought thresholds, streamflow drought forecasts, the uncertainty of those forecasts, and summary information about observed and forecast droughts. The x-axis is a date axis. The y-axis is in units of cubic feet per second (cfs), which is a common unit for reporting streamflow.",
        heading1: "Issue date",
        paragraph1: "The graph is split vertically by a dotted line indicating the issue date — the date the forecasts were made.",
        heading2: "Recent streamflow",
        paragraph2: "To the left of the issue date line, the previous 90 days of observed streamflow are shown as a black line. These data are included to help you understand streamflow conditions leading up to the forecast period.",
        heading3: "Drought categories and historical drought thresholds",
        paragraph3a: "Behind the streamflow line are three shaded bands that indicate the levels of streamflow associated with three categories of streamflow drought:<span><ul><li><span class='highlight moderate slight-emph'>Moderate drought</span></li><li><span class='highlight severe slight-emph'>Severe drought</span></li><li><span class='highlight extreme slight-emph'>Extreme drought</span></li></ul></span>",
        paragraph3b: "Each of these three categories is defined by a specific threshold value. The drought thresholds vary by day of year and are based on 40 years of historical records for each site.",
        paragraph3c: "For each site, the moderate drought threshold for each day of the year is the 20<sup>th</sup> percentile streamflow for that day of year. That 20<sup>th</sup> percentile streamflow is calculated from the historical record. It is the streamflow level that streamflow (at that site on that day of year) drops below in only 20% of recorded years. In other words, on that day of year, streamflow at the site is less than that threshold value 20% of the time. When streamflow drops below the 20<sup>th</sup> percentile threshold value, the site enters a <span class='highlight moderate slight-emph'>moderate drought</span>.",
        paragraph3d: "The severe drought threshold for each site on each day of the year is the 10<sup>th</sup> percentile streamflow for that day of year. Based on the historical record, streamflow (at that site on that day of year) drops below that threshold in only 10% of recorded years. When streamflow drops below the 10<sup>th</sup> percentile threshold value, the site enters a <span class='highlight severe slight-emph'>severe drought</span>.",
        paragraph3e: "The extreme drought threshold for each site on each day of the year is the 5<sup>th</sup> percentile streamflow for that day of year. Based on the historical record, streamflow (at that site on that day of year) drops below that threshold in only 5% of recorded years. When streamflow drops below the 5<sup>th</sup> percentile threshold value, the site enters an <span class='highlight extreme slight-emph'>extreme drought</span>.",
        heading4: "Streamflow drought forecasts",
        paragraph4: "To the left of the issue date line is the forecast period. Forecasts of streamflow drought are shown weekly for 1 through 13 weeks from the issue date. For each forecast date, the median prediction is shown as a circle. The color of the circle indicates if drought is predicted or not, and, if yes, what category of streamflow drought is predicted, <span class='highlight moderate slight-emph'>moderate</span>, <span class='highlight severe slight-emph'>severe</span>, or <span class='highlight extreme slight-emph'>extreme</span>.",
        heading5: "Uncertainty of streamflow drought forecasts",
        paragraph5: "The uncertainty associated with each weekly forecast is depicted by a rectangular box behind the median prediction circles. The height of this box represents the 90% prediction interval. This interval represents the range of streamflow that the model predicted, excluding the 10% least likely scenarios. When the range of values includes streamflow predictions that are below the moderate drought threshold, the rectangle ‘dips’ into the shaded bands for the drought categories, showing what categories of drought are included in the prediction interval.",
        heading6: "Summary of observed and forecast droughts",
        paragraph6: "Beneath the main part of the graph is a visual summary of observed and forecast droughts for the selected site. Observed droughts are shown as horizontal bands. The color of the band indicates the category of the drought. Forecast droughts are shown as circles. The color of the circle indicates if the median prediction is for drought or not, and, if yes, what category of streamflow drought is predicted."
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
            promptTrue: "Site has non-perennial flow",
            promptFalse: "Site has perennial flow"
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