export default {
    siteInfo: {
        title: "<span class='major-emph'>Streamflow drought</span><br> assessment and forecasting tool",
        about1: "This <span class='major-emph'>experimental</span> tool delivers current <span class='tooltip-group'><span class='tooltip-span'> streamflow drought <span id='streamflow-drought-tooltip' class='tooltiptext'>Streamflow drought occurs when streamflow drops to unusually low levels, leading to inadequate water availability for sector needs (e.g., the agriculture, domestic, industry, ecology, or energy sector)</span></span> </span> conditions and weekly forecasts of streamflow drought at select streamgages with long-term, complete records across the lower 48 states (the conterminous U.S., or CONUS).",
    },
    faqs: {
        title: 'FAQs',
        accordionData: [
            {
                heading: "How do I use this tool?",
                content: [
                    {
                        type: "text",
                        content: "On page load, the map displays current conditions at more than 3,000 streamgage sites across the conterminous United States (CONUS). Each site is shown as a circle, and the color of the circle indicates what category of streamflow drought is observed: <span class='highlight moderate slight-emph'>moderate</span>, <span class='highlight severe slight-emph'>severe</span>, <span class='highlight extreme slight-emph'>extreme</span>, or no streamflow drought."
                    },
                    {
                        type: "text",
                        content: "To view forecast conditions, select a future date in the upper left panel. When forecast conditions are shown, the color of the circle indicates what category of streamflow drought is predicted rather than observed."
                    },
                    {
                        type: "text",
                        content: "By default, a summary of streamflow drought conditions for all of CONUS is shown in the upper left panel, indicating what percentage of gages are experiencing each of three categories of streamflow drought. To view a summary for an individual state, use the state picker button in the lower right (above the zoom controls) to select a state to view. The map will zoom to that state, show only gages located in that state, and provide a summary of streamflow drought conditions for gages in that state."
                    },
                    {
                        type: "text",
                        content: "To view recent, current, and forecast conditions at an individual site, click on the circle for the site. This will populate the left panel with a streamflow drought summary for the selected site over the last 90 days and 13 weeks into the future."
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "What is streamflow drought?",
                content: [
                    {
                        type: "text",
                        content: "Streamflow drought occurs when streamflow at a particular location drops to levels that are unusually low for the time of year. These ‘unusually low’ streamflow levels are identified on the basis of the historical record for each site, as described in the <a href='https://water.usgs.gov/vizlab/what-is-drought/' target='_blank'>What is Streamflow Drought?</a> website."
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
                heading: "How does streamflow drought differ from meteorological and hydrological drought?",
                content: [
                    {
                        type: "text",
                        content: "Meteorological drought occurs when an area experiences a prolonged period of substantially less precipitation than normal, while streamflow drought occurs when streamflow is unusually low for the time of year."
                    },
                    {
                        type: "text",
                        content: "Hydrological drought is a lack of water in the hydrological system, displaying as abnormally low flow in rivers and streams, and as abnormally low levels in lakes, reservoirs, and groundwater. By focusing on streamflow drought specifically, we concentrate on identifying periods of abnormally low flows in streams and rivers and forecasting whether these conditions may occur for future weeks."
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "What’s the difference between streamflow drought and low streamflow?",
                content: [
                    {
                        type: "text",
                        content: "Low flows occur seasonally in many streams and are considered normal conditions. In contrast, streamflow drought results when flows are unusually low for a given time of year compared to normal conditions."
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
                heading: "How are these streamflow drought categories defined, and do they align with U.S. Drought Monitor categories?",
                content: [
                    {
                        type: "text",
                        content: "In other tools, like the <a href='https://dashboard.waterdata.usgs.gov/app/nwd/en/' target='_blank'>National Water Dashboard</a> and <a href='https://waterdata.usgs.gov/' target='_blank'>Water Data for the Nation</a>, the USGS typically uses 7 categories to classify streamflow levels at USGS streamgages. Low levels of streamflow are categorized as ‘below normal’ (10<sup>th</sup> – 24<sup>th</sup> percentile), ‘much below normal’ (5<sup>th</sup> – 10<sup>th</sup> percentile), ‘extremely below normal’ (<5<sup>th</sup> percentile), or as an all-time low for a given day (0<sup>th</sup> percentile)."
                    },
                    {
                        type: "text",
                        content: "This tool uses a different classification method for low levels of streamflow that aligns with the following <a href='https://droughtmonitor.unl.edu/About/AbouttheData/DroughtClassification.aspx' target='_blank'>U.S. Drought Monitor (USDM) categories</a>:<span><ul><li><span class='highlight moderate slight-emph'>Moderate</span> streamflow drought (10<sup>th</sup> – 20<sup>th</sup> percentile, USDM D1 drought)</li><li><span class='highlight severe slight-emph'>Severe</span> streamflow drought (5<sup>th</sup> – 10<sup>th</sup> percentile, USDM D2 drought)</li><li><span class='highlight extreme slight-emph'>Extreme</span> streamflow drought (< 5<sup>th</sup> percentile, USDM D3 drought)</li></ul></span>"
                    },
                    {
                        type: "text",
                        content: "The U.S. Drought Monitor provides an additional category of drought below the 2<sup>nd</sup> percentile, termed exceptional drought (D4). For the data-driven models used to generate our streamflow drought forecasts, the sample of streamflow droughts below the 2<sup>nd</sup> percentile was too small to generate accurate models, so the lowest percentile-based category that we include on this tool is extreme streamflow drought."
                    },
                    {
                        type: "text",
                        content: "Another key difference between this tool and the <a href='https://dashboard.waterdata.usgs.gov/app/nwd/en/' target='_blank'>National Water Dashboard</a> and <a href='https://waterdata.usgs.gov/' target='_blank'>Water Data for the Nation</a> is that all sites included in this tool were required to have long-term complete streamflow records for 40 years (see “How were these sites selected?”, below), which allows for a more robust identification of drought periods than is possible with shorter records."
                    },
                    {
                        type: "text",
                        content: "To learn more about streamflow drought thresholds and streamflow percentiles, visit the <a href='https://water.usgs.gov/vizlab/modeling-drought/' target='_blank'>Modeling streamflow drought</a> website."
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "How were these sites selected?",
                content: [
                    {
                        type: "text",
                        content: "We chose U.S. Geological Survey streamgages that met the criteria below:<span><ul><li>Only gages with nearly complete records for the 40-year period 1981–2020 were included in this tool.</li><li>Specifically, each gage needed to have complete daily data for at least 8 out of 10 years in each decade between 1981 and 2020 (like the years 2000–2009 or 2010–2019).</li><li>A year was considered to have complete daily data if it had recorded data on at least 95% of the days.</li></ul></span>"
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "How is streamflow drought forecast?",
                content: [
                    {
                        type: "text",
                        content: "To forecast streamflow drought at USGS streamgages across the conterminous United States (CONUS), the USGS has built a machine learning model that predicts streamflow percentiles using watershed characteristics, recent precipitation and streamflow conditions, and upcoming weather forecasts. Learn more on the <a href='https://water.usgs.gov/vizlab/modeling-drought/' target='_blank'>Modeling streamflow drought</a> website."
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "How well does the model forecast streamflow drought?",
                content: [
                    {
                        type: "text",
                        content: "The model’s predictions are most accurate 1–4 weeks in the future. Model performance tends to decline with increasing forecast time, but these long-range forecasts still contain useful information for decision makers (see “How reliable are the long-term forecasts?, below). Model performance is also generally better for moderate streamflow droughts than for extreme streamflow droughts. For more information, please see the <a href='https://water.usgs.gov/vizlab/modeling-drought/' target='_blank'>Modeling streamflow drought</a> website and the <a href='' target='_blank'>technical documentation of modeling methods and model evaluation.</a>"
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "How reliable are the long-term forecasts?",
                content: [
                    {
                        type: "text",
                        content: "The maximum forecast horizon for this model is 13 weeks in the future. Weather forecasts are very limited for this timeframe, making streamflow drought predictions highly uncertain. Nonetheless, these predictions provide more insight into future conditions than simply referencing median conditions from prior years. Please see a detailed evaluation of our model’s ability to forecast streamflow drought occurrence as well as streamflow drought onset and termination at the link below: LINK TBD"
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
                        content: "A known issue with the current modeling approach is that model predictions tend towards streamflow drought being less likely for longer lead times, underrepresenting the prevalence of streamflow drought more than 4 weeks in advance."
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "Are there special considerations when interpreting forecasts at particular types of sites?",
                content: [
                    {
                        type: "text",
                        content: "We highlight four categories of sites where we suggest interpreting forecasts with nuance: non-perennial, highly regulated, snow-dominated, and ice-impacted. In the individual site summary views, icons beneath the USGS gage ID indicate whether the site has perennial or non-perennial flow, and whether or not the site is highly regulated, snow-dominated, or ice-impacted. Icons are greyed out when they do not apply."
                    },
                    {
                        type: "text",
                        content: "For sites with non-perennial streamflow where it is typical for the stream to dry at certain times of year, streamflow drought may occur due to abnormally long stretches without streamflow rather than due to abnormally low streamflow. While we use a method that considers whether a continuous stretch without streamflow is longer than normal, familiarity with the general patterns of streamflow at these sites may be useful for interpreting these streamflow drought forecasts."
                    },
                    {
                        type: "text",
                        content: "For highly regulated sites below dams, below normal streamflow percentiles may reflect streamflow drought in systems with over-year storage in irrigation and water supply reservoirs. However, reservoirs are often managed in coordination (for example releases from one reservoir may be stored in another), so looking at the total reservoir storage in a watershed or basin provides more information to models. The way that we define streamflow drought in areas with a high degree of flow regulation is dependent on historical patterns in water storage and release for the period 1981–2020. We assume reservoirs operate similarly to how they did during the 1981–2020 observed record."
                    },
                    {
                        type: "text",
                        content: "For snow-dominated sites and other sites with strong streamflow seasonality, changes in the timing of snowmelt or seasonal input may display as streamflow drought even if the amount of snowmelt is similar."
                    },
                    {
                        type: "text",
                        content: "Finally, for ice-impacted sites, streamflow may be impacted by the presence of ice during cold times of the year. Frozen streams may appear to be abnormally low even when the site is not in streamflow drought."
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "Why are forecasts graphed in units of streamflow (cfs) instead of percentiles?",
                content: [
                    {
                        type: "text",
                        content: "In each individual site summary view, the timeseries graph displays streamflow drought forecasts in units of streamflow – cubic feet per second (cfs). While the predictions generated by the machine learning model are in units of percentiles, we chose to display the forecast in units of cfs for ease of comparison to recent observed conditions and for consistency with monitoring data reporting. For each forecast date at each site, the percentile predictions were interpolated to cfs using the 1981–2020 record of streamflow and streamflow percentiles on the corresponding Julian day."
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "Why is the line showing observed streamflow incomplete for some sites?",
                content: [
                    {
                        type: "text",
                        content: "In the individual site summary view, the line for observed streamflow on the timeseries graph may be incomplete or discontinuous. This indicates that streamflow data are not currently available for the full 90-day period leading up to the issue date (the date the forecasts were made)."
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "How are forecasts generated for sites with recently missing or incomplete data?",
                content: [
                    {
                        type: "text",
                        content: "No forecasts will be provided if streamflow data are missing for all of the prior 30 days. If incomplete data are available for this period, a prediction will be made but may be less accurate."
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "Why do observed streamflow and historical streamflow drought thresholds drop to zero at some sites?",
                content: [
                    {
                        type: "text",
                        content: "At non-perennial sites, it is typical for the stream to dry at certain times of year, meaning that it is normal for streamflow to be zero cubic feet per second (cfs). Under these conditions, a lack of streamflow does not necessarily indicate that a site is in streamflow drought. As a result, the historical drought thresholds drop to zero cfs, disappearing from view on the timeseries graphs. During these periods, the occurrence of streamflow drought is determined based on the length of time a site is continuously without streamflow. If zero streamflow conditions persist for longer than normal (e.g., lasting 30 continuous days rather than only 10 continuous days), the site is considered to be in streamflow drought. The three categories of streamflow drought (moderate, severe, and extreme) are associated with progressively longer extensions of zero streamflow conditions."
                    }
                ],
                activeOnLoad: false
            }
        ]
    },
    graph: {
        title: "How do I read this graph?",
        intro: "This graph shows recent streamflow conditions and forecasts of streamflow drought for a selected site. It shows the following information: the issue date, recent streamflow, streamflow drought categories and associated historical streamflow drought thresholds, streamflow drought forecasts, the uncertainty of those forecasts, and summary information about observed and forecast streamflow droughts. The x-axis is a date axis. The y-axis is in units of cubic feet per second (cfs), which is a common unit for reporting streamflow.",
        heading1: "Issue date",
        paragraph1: "The graph is split vertically by a dotted line indicating the issue date — the date the forecasts were made.",
        heading2: "Recent streamflow",
        paragraph2: "To the left of the issue date line, the previous 90 days of observed streamflow are shown as a black line. These data are included to help you understand streamflow conditions leading up to the forecast period. For some sites, streamflow data may not currently be available for all 90 days, in which case the line for observed streamflow may be incomplete or discontinuous.",
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
            paragraph1: "This site experiences non-perennial streamflow, meaning that it dries at certain times of year.",
            paragraph2: "For sites with non-perennial streamflow, streamflow drought may occur due to longer stretches without streamflow rather than abnormally low streamflow. While we use a method that considers whether a continuous stretch without streamflow is longer than normal, familiarity with the general patterns of streamflow at these sites may be useful for interpreting these streamflow drought forecasts.",
            promptTrue: "Site has non-perennial streamflow"
        },
        regulated: {
            title: "Highly regulated site",
            paragraph1: "Streamflow at this site is highly regulated, due to storage of streamflow in upstream reservoirs.",
            paragraph2: "For highly regulated sites below dams, below normal streamflow percentiles may reflect streamflow drought in systems with over-year storage in irrigation and water supply reservoirs. However, reservoirs are often managed in coordination (for example releases from one reservoir may be stored in another), so looking at the total reservoir storage in a watershed or basin provides more information to models. The way that we define streamflow drought in areas with a high degree of flow regulation is dependent on historical patterns in water storage and release for the period 1981–2020. We assume reservoirs operate similarly to how they did during the 1981–2020 observed record.",
            promptTrue: "Site is highly regulated",
            promptFalse: "Site is not highly regulated"
        },
        snow: {
            title: "Snow-dominated site",
            paragraph1: "The hydrology of this site is considered to be snow-dominated because within the site's contributing drainage area, the peak snow water equivalent is at least 25% of the annual precipitation total. Snow water equivalent is a measure of the liquid water contained in snowpack.",
            paragraph2: "For snow-dominated sites and other sites with strong streamflow seasonality, changes in the timing of snowmelt or seasonal input may display as streamflow drought even if the amount of snowmelt is similar.",
            promptTrue: "Site is snow-dominated",
            promptFalse: "Site is not snow-dominated"
        },
        ice: {
            title: "Ice-impacted site",
            paragraph1: "At this site, streamflow is sometimes estimated because ice is present.",
            paragraph2: "For ice-impacted sites, streamflow may be impacted by the presence of ice during cold times of the year. Frozen streams may appear to be abnormally low even when the site is not in streamflow drought.",
            promptTrue: "Site may be impacted by ice",
            promptFalse: "Site is not impacted by ice"
        }
    }
}