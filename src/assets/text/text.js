export default {
    siteInfo: {
        title: "<span class='major-emph'>Streamflow drought</span><br> assessment and forecasting tool",
        about1: "Streamflow drought occurs when streamflow drops to unusually low levels, leaving less water available for ecological, home, farm, business, and energy needs.",
        about2: "This <span class='major-emph'>experimental</span> tool delivers current streamflow drought conditions and weekly forecasts of streamflow drought at select streamgages with long-term, complete records across the lower 48 states (the conterminous U.S., or CONUS).",
    },
    faqs: {
        title: 'FAQs',
        accordionData: [
            {
                heading: "How do I use this tool?",
                content: [
                    {
                        type: "text",
                        content: "On page load, the map displays current conditions at more than 3000 gages sites across the continental United States (CONUS). Each site is shown as a circle, and the color of the circle indicates if streamflow drought is observed or not, and, if yes, what category of streamflow drought is observed — moderate, severe, or extreme."
                    },
                    {
                        type: "text",
                        content: "To view forecast conditions, select a future date in the upper left panel. When forecast conditions are shown, the color of the circle indicates if drought is predicted or not, and, if yes, what category of streamflow drought is predicted — moderate, severe, or extreme."
                    },
                    {
                        type: "text",
                        content: "By default, a summary of drought conditions for all of CONUS is shown in the upper left panel, indicating what percentage of gages are experiencing each of three categories of streamflow drought. To view a summary for an individual state, use the state picker button in the lower right (above the zoom controls) to select a state to view. The map will zoom to that state, show only gages located in that state, and provide a summary of drought conditions for gages in that state."
                    },
                    {
                        type: "text",
                        content: "To view antecedent, current, and forecast conditions at an individual site, click on the circle for the site. This will populate the left panel with a summary for the selected site."
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "What is streamflow drought?",
                content: [
                    {
                        type: "text",
                        content: "Streamflow drought occurs when streamflow at a particular location drops to levels that are unusually low for the time of year. These ‘unusually low’ streamflow levels are identified based on the historical record for each site, as described in the <a href='https://water.usgs.gov/vizlab/what-is-drought/' target='_blank'>What is Streamflow Drought?</a> website."
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "Why forecast streamflow drought?",
                content: [
                    {
                        type: "text",
                        content: "Streamflow drought has widespread and recurring impacts on industrial water supply, municipal water supply, hydropower, thermoelectric power, river navigation, irrigation, water quality, and aquatic organisms. Streamflow drought forecasts help decision makers anticipate periods of limited water availability so they can develop plans for ensuring the safety and health of their communities."
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "How does streamflow drought differ from meteorological drought?",
                content: [
                    {
                        type: "text",
                        content: "Meteorological drought occurs when an area experiences a prolonged period of significantly less precipitation than normal, while streamflow drought occurs when streamflow is unusually low for the time of year."
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "What’s the difference between streamflow drought and low streamflow?",
                content: [
                    {
                        type: "text",
                        content: "It’s important to note the difference between ‘low streamflow’ and ‘streamflow drought.’ Low flows occur seasonally in many streams and are considered normal conditions. In contrast, streamflow drought results when flows are unusually low for a given time of year compared to normal conditions."
                    },
                    {
                        type: "quote",
                        content: '"While droughts may include periods of low flows, a recurring seasonal low flow event is not necessarily a drought."—<a href="https://library.wmo.int/idurl/4/32176" target="_blank">WMO, 2008</a>'
                    },
                    {
                        type: "text",
                        content: "Low flow is often a regular, seasonal phenomenon (like a dry season) and a normal component of a river's flow regime. A streamflow drought is an abnormal, extended period of significantly reduced streamflow."
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "How do these streamflow drought categories relate to the U.S. Drought Monitor categories?",
                content: [
                    {
                        type: "text",
                        content: "The low levels of streamflow that indicate streamflow drought are classified using <a href='https://droughtmonitor.unl.edu/About/AbouttheData/DroughtClassification.aspx' target='_blank'>U.S. Drought Monitor categories</a>. These categories bin low streamflow percentiles into specific streamflow drought categories that describe the intensity of the streamflow drought. For this project, we have specifically trained the model to forecast the following three categories of streamflow drought:<span><ul><li>Moderate streamflow drought (< 20<sup>th</sup> percentile)</li><li>Severe streamflow drought (< 10<sup>th</sup> percentile)</li><li>Extreme streamflow drought (< 5<sup>th</sup> percentile)</li></ul></span>"
                    },
                    {
                        type: "text",
                        content: "The U.S. Drought Monitor additionally provides a category of drought below the 2<sup>nd</sup> percentile, termed exceptional drought. For the data-driven models used to generate our streamflow drought forecasts, the sample of droughts below the 2<sup>nd</sup> percentile was too small to generate accurate models, so the lowest percentile-based category that we include on this tool is extreme drought."
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "How were these sites selected?",
                content: [
                    {
                        type: "text",
                        content: "We chose U.S. Geological Survey streamgages that met two simple criteria:<span><ul><li>Each gage had to record streamflow data for at least 95% of the days in every year</li><li>Each gage needed to have full data for at least 8 out of 10 years in each decade between 1981 and 2020 (like the years 2000–2009 or 2010–2019)</li></ul></span>"
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "How is streamflow drought forecast?",
                content: [
                    {
                        type: "text",
                        content: "To forecast streamflow drought at USGS stream gages across the contiguous United States (CONUS), the USGS has built a machine learning model that predicts streamflow percentiles using watershed characteristics, recent precipitation and streamflow conditions, and upcoming weather forecasts. Learn more on the <a href='https://water.usgs.gov/vizlab/modeling-drought/' target='_blank'>Modeling streamflow drought</a> website."
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "How well does the model forecast streamflow drought?",
                content: [
                    {
                        type: "text",
                        content: "Model performance is generally lower for extreme streamflow droughts and higher for moderate streamflow droughts. Model performance also tends to decline with increasing forecast lead time. Overall, these models predict the occurrence and duration of streamflow drought well for 1-4 weeks in advance, though forecasts still contain useful information for longer lead times. For more information, please see the <a href='https://water.usgs.gov/vizlab/modeling-drought/' target='_blank'>Modeling streamflow drought</a> website and the technical documentation of modeling methods and evaluation."
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "How reliable are the long-term forecasts?",
                content: [
                    {
                        type: "text",
                        content: "The maximum forecast horizon for this model is 13 weeks in the future. Weather forecasts are very limited for this timeframe, making streamflow drought predictions highly uncertain. Nonetheless, these predictions provide more insight into future conditions than simply referencing median conditions from prior years. Please see a detailed evaluation of the performance of our model’s ability to forecast streamflow drought occurrence as well as drought onset and termination at the link below:  LINK TBD"
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "Are there special considerations when interpreting forecasts at particular types of sites?",
                content: [
                    {
                        type: "text",
                        content: "We highlight four categories of sites where we suggest interpreting forecasts with nuance: non-perennial, highly regulated, snow-dominated, and ice-impacted. In the individual site summary views, icons beneath the USGS gage id indicate whether the site has perennial or non-perennial flow, and whether or not the site is highly regulated, snow-dominated, or ice-impacted. Icons are greyed out when they do not apply."
                    },
                    {
                        type: "text",
                        content: "For sites with non-perennial streamflow, streamflow drought may occur due to longer stretches without streamflow rather than abnormally low streamflow. While we use a method that considers whether a continuous stretch without streamflow is longer than normal, familiarity with the general patterns of streamflow at these sites may be useful for interpreting these streamflow drought forecasts."
                    },
                    {
                        type: "text",
                        content: "For highly regulated sites below dams, below normal streamflow percentiles may be reflective of streamflow drought in systems with over-year storage in irrigation and water supply reservoirs. However, reservoirs are often managed in coordination, and looking at other data sources and multiple sites in a region will provide more information. The way that we define streamflow drought in areas with a high degree of flow regulation is dependent on historical patterns in water storage and release for the period 1981-2020. We assume reservoirs operate similarly to how they did during the 1981-2020 observed record."
                    },
                    {
                        type: "text",
                        content: "For snow-dominated sites and other sites with strong streamflow seasonality, changes in the timing of snowmelt or seasonal input may display as streamflow drought even if the amount of snowmelt is similar."
                    },
                    {
                        type: "text",
                        content: "Finally, for ice-impacted sites, streamflow may be impacted by the presence of ice during cold times of the year. Frozen streams may appear to be abnormally low though even when the site is not in streamflow drought."
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "Why are forecasts graphed in units of streamflow (cfs) instead of percentiles?",
                content: [
                    {
                        type: "text",
                        content: "In each individual site summary view, the timeseries graph displays streamflow drought forecasts in units of streamflow – cubic feet per second (cfs). While the predictions generated by the machine learning model are in units of percentiles, we chose to display the forecast in units of cfs for ease of comparison to recent observed conditions, and for consistency with monitoring data reporting. For each forecast date at each site, the percentile predictions were interpolated to cfs using the 1980-2020 record of streamflow and streamflow percentiles on the corresponding Julian day."
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "What are the limitations of this tool?",
                content: [
                    {
                        type: "text",
                        content: "The models currently deployed operationally have limited accuracy in predicting streamflow drought occurrence or streamflow drought onset/termination more than 4 weeks into the future, so we suggest focusing interpretation on forecasts for 1-4 weeks. Limited data on subsurface storage, flow modifications including reservoir releases, diversions and withdrawals, and difficulties in capturing sub-seasonal transitions between streamflow drought and flood conditions underscore the need for continued model improvement."
                    },
                    {
                        type: "text",
                        content: "A known issue with the current modeling approach is that model predictions tend towards drought being less likely for longer lead times, underrepresenting the prevalence of drought more than 4 weeks in advance."
                    }
                ],
                activeOnLoad: false
            },
        ]
    },
    graph: {
        title: "How do I read this graph?",
        intro: "This graph shows recent streamflow conditions and forecasts of streamflow drought for a selected site. It shows the following information: the issue date, recent streamflow, streamflow drought categories and associated historicalstreamflow drought thresholds, streamflow drought forecasts, the uncertainty of those forecasts, and summary information about observed and forecast streamflow droughts. The x-axis is a date axis. The y-axis is in units of cubic feet per second (cfs), which is a common unit for reporting streamflow.",
        heading1: "Issue date",
        paragraph1: "The graph is split vertically by a dotted line indicating the issue date — the date the forecasts were made.",
        heading2: "Recent streamflow",
        paragraph2: "To the left of the issue date line, the previous 90 days of observed streamflow are shown as a black line. These data are included to help you understand streamflow conditions leading up to the forecast period.",
        heading3: "Drought categories and historical streamflow drought thresholds",
        paragraph3a: "Behind the streamflow line are three shaded bands that indicate the levels of streamflow associated with three categories of streamflow drought:<span><ul><li><span class='highlight moderate slight-emph'>Moderate</span> streamflow drought</li><li><span class='highlight severe slight-emph'>Severe</span> streamflow drought</li><li><span class='highlight extreme slight-emph'>Extreme</span> streamflow drought</li></ul></span>",
        paragraph3b: "Each of these three categories is defined by a specific threshold value. The streamflow drought thresholds vary by day of year and are based on 40 years of historical records for each site.",
        paragraph3c: "For each site, the moderate streamflow drought threshold for each day of the year is the 20<sup>th</sup> percentile streamflow for that day of year. That 20<sup>th</sup> percentile streamflow is calculated from the historical record. It is the streamflow level that streamflow (at that site on that day of year) drops below in only 20% of recorded years. In other words, on that day of year, streamflow at the site is less than that threshold value 20% of the time. When streamflow drops below the 20<sup>th</sup> percentile threshold value, the site enters a <span class='highlight moderate slight-emph'>moderate</span> streamflow drought.",
        paragraph3d: "The severe streamflow drought threshold for each site on each day of the year is the 10<sup>th</sup> percentile streamflow for that day of year. Based on the historical record, streamflow (at that site on that day of year) drops below that threshold in only 10% of recorded years. When streamflow drops below the 10<sup>th</sup> percentile threshold value, the site enters a <span class='highlight severe slight-emph'>severe</span> streamflow drought.",
        paragraph3e: "The extreme streamflow drought threshold for each site on each day of the year is the 5<sup>th</sup> percentile streamflow for that day of year. Based on the historical record, streamflow (at that site on that day of year) drops below that threshold in only 5% of recorded years. When streamflow drops below the 5<sup>th</sup> percentile threshold value, the site enters an <span class='highlight extreme slight-emph'>extreme</span> streamflow drought.",
        paragraph3f: "On the graph, the shaded band for each streamflow drought category is partially transparent except for where it intersects the rectangular box showing the prediction interval for each forecast date.",
        paragraph3g: "To learn more about streamflow drought thresholds and streamflow percentiles, visit the <a href='https://water.usgs.gov/vizlab/modeling-drought/' target='_blank'>Modeling streamflow drought</a> website.",
        heading4: "Streamflow drought forecasts",
        paragraph4: "To the right of the issue date line is the forecast period. Forecasts of streamflow drought are shown weekly for 1 through 13 weeks from the issue date. To learn more about how the forecasts are generated, visit the <a href='https://water.usgs.gov/vizlab/modeling-drought/' target='_blank'>Modeling streamflow drought</a> website. On the graph, the median prediction for each forecasts date is shown as a circle. The color of the circle indicates if streamflow drought is predicted or not, and, if yes, what category of streamflow drought is predicted, <span class='highlight moderate slight-emph'>moderate</span>, <span class='highlight severe slight-emph'>severe</span>, or <span class='highlight extreme slight-emph'>extreme</span>. The circle for the currently selected date has a thick black border.",
        heading5: "Uncertainty of streamflow drought forecasts",
        paragraph5: "The uncertainty associated with each weekly forecast is depicted by a rectangular box behind the median prediction circles. The height of this box represents the 90% prediction interval. This interval represents the range of streamflow that the model predicted, excluding the 10% most extreme scenarios. To learn more about the uncertainty of the forecasts, visit the <a href='https://water.usgs.gov/vizlab/modeling-drought/' target='_blank'>Modeling streamflow drought</a> website. On the graph, when the range of values includes streamflow predictions that are below the moderate streamflow drought threshold, the rectangle ‘dips’ into the shaded bands for the streamflow drought categories, showing what categories of streamflow drought are included in the prediction interval.",
        heading6: "Summary of observed and forecast streamflow droughts",
        paragraph6: "Beneath the main part of the graph is a visual summary of observed and forecast streamflow droughts for the selected site. Observed streamflow droughts are shown as horizontal bands. The color of the band indicates the category of the streamflow drought. Forecast streamflow droughts are shown as circles. The color of the circle indicates if the median prediction is for streamflow drought or not, and, if yes, what category of streamflow drought is predicted."
    },
    icons: {
        normal: {
            title: "Perennial site",
            paragraph1: "This site experiences perennial streamflow, meaning that it flows continuously throughout the year.",
            promptTrue: "Site has perennial streamflow"
        },
        intermittent: {
            title: "Non-perennial site",
            paragraph1: "This site experiences non-perennial streamflow, meaning that it dries up for part of the year.",
            paragraph2: "For sites with non-perennial streamflow, streamflow drought may occur due to longer stretches without streamflow rather than abnormally low streamflow. While we use a method that considers whether a continuous stretch without streamflow is longer than normal, familiarity with the general patterns of streamflow at these sites may be useful for interpreting these streamflow drought forecasts.",
            promptTrue: "Site has non-perennial streamflow"
        },
        regulated: {
            title: "Highly regulated site",
            paragraph1: "Streamflow at this site is highly regulated, due to storage of streamflow in upstream reservoirs.",
            paragraph2: "For highly regulated sites below dams, below normal streamflow percentiles may be reflective of streamflow drought in systems with over-year storage in irrigation and water supply reservoirs. However, reservoirs are often managed in coordination, and looking at other data sources and multiple sites in a region will provide more information. The way that we define streamflow drought in areas with a high degree of flow regulation is dependent on historical patterns in water storage and release for the period 1981-2020. We assume reservoirs operate similarly to how they did during the 1981-2020 observed record.",
            promptTrue: "Site is highly regulated",
            promptFalse: "Site is not highly regulated"
        },
        snow: {
            title: "Snow-dominated site",
            paragraph1: "This hydrology of this site is considered to be snow-dominated because within the site's contributing drainage area, the peak snow water equivalent is at least 25% of the annual precipitation total. Snow water equivalent is a measure of the liquid water contained in snowpack.",
            paragraph2: "For snow-dominated sites and other sites with strong streamflow seasonality, changes in the timing of snowmelt or seasonal input may display as streamflow drought even if the amount of snowmelt is similar.",
            promptTrue: "Site is snow-dominated",
            promptFalse: "Site is not snow-dominated"
        },
        ice: {
            title: "Ice-impacted site",
            paragraph1: "At this site, streamflow is sometimes estimated because ice is present.",
            paragraph2: "For ice-impacted sites, streamflow may be impacted by the presence of ice during cold times of the year. Frozen streams may appear to be abnormally low even when the site is not in streamflow drought.",
            promptTrue: "Site is impacted by ice",
            promptFalse: "Site is not impacted by ice"
        }
    }
}