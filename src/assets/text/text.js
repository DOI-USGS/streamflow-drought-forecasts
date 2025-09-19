export default {
    siteInfo: {
        title: "<span class='major-emph'>Streamflow drought</span><br aria-hidden=true> assessment and forecasting tool",
        about1: "This <span class='major-emph'>experimental</span> tool delivers current streamflow drought conditions and weekly forecasts of streamflow drought at select streamgages with long-term, complete records across the lower 48 states (the conterminous U.S., or CONUS).",
    },
    faqs: {
        title: 'FAQs',
        accordionData: [
            {
                heading: "How do I use this tool?",
                content: [
                    {
                        type: "text",
                        content: "<span class='moderate-emph'>On page load, the map displays current conditions</span> at more than 3,000 USGS <a href='https://labs.waterdata.usgs.gov/visualizations/gages-through-the-ages/' target='_blank'>streamgage</a> sites across the conterminous United States (CONUS). Each site is shown as a circle, and the color of the circle indicates what category of streamflow drought is observed: <span class='highlight moderate slight-emph'>moderate</span>, <span class='highlight severe slight-emph'>severe</span>, <span class='highlight extreme slight-emph'>extreme</span>, or no streamflow drought."
                    },
                    {
                        type: "text",
                        content: "<span class='moderate-emph'>To view forecast conditions, select a future date using the date slider</span>. When forecast conditions are shown, the color of the circle indicates what category of streamflow drought is predicted rather than observed."
                    },
                    {
                        type: "text",
                        content: "<span class='moderate-emph'>By default, a summary of streamflow drought conditions for all of CONUS is shown in the main panel</span>, indicating what percentage of gages is/is forecast to be in streamflow drought and what percentage is/is forecast to be in each of three categories of streamflow drought. The reported percentages for each category are categorical, not cumulative. <span class='moderate-emph'>To view a summary for an individual state, use the state picker button in the upper right</span> (above the zoom controls) to select a state to view. The map will zoom to that state, show only gages located in that state, and provide a summary of streamflow drought conditions for gages in that state."
                    },
                    {
                        type: "text",
                        content: "<span class='moderate-emph'>To view recent, current, and forecast conditions at an individual site, click on the circle for the site</span>. This will populate the main panel with a streamflow drought summary for the selected site over the last 90 days and 13 weeks into the future."
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "What is streamflow drought?",
                content: [
                    {
                        type: "text",
                        content: "Streamflow drought occurs when streamflow at a particular location drops to levels that are <span class='moderate-emph'>unusually low for the time of year</span>. These ‘unusually low’ streamflow levels are identified on the basis of the historical record for each site, as described in the <a href='https://water.usgs.gov/vizlab/what-is-drought/' target='_blank'>What is Streamflow Drought?</a> website."
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "Why forecast streamflow drought?",
                content: [
                    {
                        type: "text",
                        content: "Streamflow drought has widespread and recurring impacts on industrial water supply, municipal water supply, hydropower, thermoelectric power, river navigation, irrigation, water quality, and aquatic organisms. <span class='moderate-emph'>Streamflow drought forecasts help decision makers anticipate periods of limited water availability</span> so they can develop plans for ensuring the safety and health of their communities."
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "How does streamflow drought differ from meteorological and hydrological drought?",
                content: [
                    {
                        type: "text",
                        content: "<span class='moderate-emph'>Meteorological drought</span> occurs when an area experiences a prolonged period of substantially less precipitation than normal, while streamflow drought occurs when streamflow is unusually low for the time of year."
                    },
                    {
                        type: "text",
                        content: "<span class='moderate-emph'>Hydrological drought</span> is a lack of water in the hydrological system, displaying as abnormally low streamflow in rivers and streams, and as abnormally low levels in lakes, reservoirs, and groundwater. By focusing on <span class='moderate-emph'>streamflow drought</span> specifically, we concentrate on identifying periods of abnormally low streamflow in streams and rivers and forecasting whether these conditions may occur for future weeks."
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "What’s the difference between streamflow drought and low streamflow?",
                content: [
                    {
                        type: "text",
                        content: "<span class='moderate-emph'>Low flows</span> occur seasonally in many streams and are considered normal conditions. In contrast, <span class='moderate-emph'>streamflow drought</span> results when flows are unusually low for a given time of year compared to normal conditions."
                    },
                    {
                        type: "quote",
                        content: '"While droughts may include periods of low flows, a recurring seasonal low flow event is not necessarily a drought."—<a href="https://library.wmo.int/idurl/4/32176" target="_blank">WMO, 2008</a>'
                    },
                    {
                        type: "text",
                        content: "<span class='moderate-emph'>Low flow</span> is often a <span class='moderate-emph'>regular, seasonal phenomenon</span> (like a dry season) and a normal component of a river's flow regime. A <span class='moderate-emph'>streamflow drought</span> is an <span class='moderate-emph'>abnormal</span>, extended period of significantly reduced streamflow."
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "How are these streamflow drought categories defined, and do they align with U.S. Drought Monitor categories?",
                content: [
                    {
                        type: "text",
                        content: "This tool uses a classification method for low levels of streamflow that aligns with the following <a href='https://droughtmonitor.unl.edu/About/AbouttheData/DroughtClassification.aspx' target='_blank'>U.S. Drought Monitor (USDM) categories</a>:<span><ul><li><span class='highlight moderate slight-emph'>Moderate</span> streamflow drought (10<sup>th</sup> – 20<sup>th</sup> percentile, USDM D1 drought)</li><li><span class='highlight severe slight-emph'>Severe</span> streamflow drought (5<sup>th</sup> – 10<sup>th</sup> percentile, USDM D2 drought)</li><li><span class='highlight extreme slight-emph'>Extreme</span> streamflow drought (< 5<sup>th</sup> percentile, USDM D3 drought)</li></ul></span>"
                    },
                    {
                        type: "text",
                        content: "The U.S. Drought Monitor provides an additional category of drought below the 2<sup>nd</sup> percentile, termed exceptional drought (D4). For the data-driven models used to generate our streamflow drought forecasts, the sample of streamflow droughts below the 2<sup>nd</sup> percentile was too small to generate accurate models, so the lowest percentile-based category that we include on this tool is extreme streamflow drought."
                    },
                    {
                        type: "text",
                        content: "When the map view includes a summary of streamflow drought conditions for CONUS or for an individual state, the reported percentages for each streamflow drought category are categorical, not cumulative."
                    },
                    {
                        type: "text",
                        content: "This classification approach differs from that used by other USGS tools like the <a href='https://dashboard.waterdata.usgs.gov/app/nwd/en/' target='_blank'>National Water Dashboard</a> and <a href='https://waterdata.usgs.gov/' target='_blank'>Water Data for the Nation</a>. These tools use 7 categories to classify streamflow levels at USGS <a href='https://labs.waterdata.usgs.gov/visualizations/gages-through-the-ages/' target='_blank'>streamgages</a>. Low levels of streamflow are categorized as ‘below normal’ (10<sup>th</sup> – 24<sup>th</sup> percentile), ‘much below normal’ (5<sup>th</sup> – 10<sup>th</sup> percentile), ‘extremely below normal’ (<5<sup>th</sup> percentile), or as an all-time low for a given day (0<sup>th</sup> percentile)."
                    },
                    {
                        type: "text",
                        content: "Another key difference between this tool and the <a href='https://dashboard.waterdata.usgs.gov/app/nwd/en/' target='_blank'>National Water Dashboard</a> and <a href='https://waterdata.usgs.gov/' target='_blank'>Water Data for the Nation</a> is that all sites included in this tool were required to have long-term complete streamflow records for 40 years (refer to “How were these sites selected?”, below), which allows for a more robust identification of drought periods than is possible with shorter records."
                    },
                    {
                        type: "text",
                        content: "<a href='https://water.usgs.gov/vizlab/modeling-drought/' target='_blank'>Learn more about streamflow drought thresholds and streamflow percentiles</a>."
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "How were these sites selected?",
                content: [
                    {
                        type: "text",
                        content: "We chose U.S. Geological Survey <a href='https://labs.waterdata.usgs.gov/visualizations/gages-through-the-ages/' target='_blank'>streamgages</a> that met the criteria below:<span><ul><li>Only gages with <span class='moderate-emph'>nearly complete records for the 40-year period 1981–2020</span> were included in this tool.</li><li>Specifically, each gage needed to have <span class='moderate-emph'>complete daily data for at least 8 out of 10 years</span> in each decade between 1981 and 2020 (like the years 2000–2009 or 2010–2019).</li><li>A year was considered to have complete daily data if it had recorded data on at least <span class='moderate-emph'>95% of the days</span>.</li></ul></span>"
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "How is streamflow drought forecast?",
                content: [
                    {
                        type: "text",
                        content: "To forecast streamflow drought at USGS <a href='https://labs.waterdata.usgs.gov/visualizations/gages-through-the-ages/' target='_blank'>streamgages</a> across the conterminous United States (CONUS), the USGS has built a <span class='moderate-emph'>machine learning model</span> that predicts streamflow percentiles. The model is trained to learn the relationship between input and output data for thousands of watersheds across the country. <span><ul><li><span class='moderate-emph'>Input data</span>: <span class='tooltip-group'><span class='tooltip-span'> Watershed characteristics<span id='characteristics-tooltip' class='tooltiptext'>Some watershed characteristics that the model finds useful are average annual precipitation summaries, watershed elevation, and flowline slope. Many other characteristics are also provided, including land cover types, soil types, irrigation density (ditches, withdrawals, tile drainage), and transportation density (trails, roads, highways).</span></span></span>, recent precipitation and streamflow conditions, and upcoming weather forecasts</li><li><span class='moderate-emph'>Output data</span>: Streamflow percentiles at USGS streamgages. Because streamflow droughts occur when streamflow is unusually low, USGS scientists trained the model to accurately predict <i>low </i>streamflow percentiles by restricting the training dataset to observed streamflow values below the 30<sup>th</sup> percentile.</li></ul></span>"
                    },
                    {
                        type: "text",
                        content: "To learn more, visit the <a href='https://water.usgs.gov/vizlab/modeling-drought/' target='_blank'>Modeling streamflow drought</a> website or refer to the <a href='https://doi.org/10.31223/X56X77' target='_blank'>technical documentation of modeling methods and model evaluation</a>."
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "How well does the model forecast streamflow drought?",
                content: [
                    {
                        type: "text",
                        content: "The model’s predictions are <span class='moderate-emph'>most accurate 1–4 weeks in the future</span>. Model performance tends to decline with increasing forecast time, but these long-range forecasts still contain streamflow information for decision makers (refer to “How reliable are the long-term forecasts?, below). Model performance is also generally <span class='moderate-emph'>more accurate for moderate streamflow droughts than for extreme streamflow droughts</span>. For more information, please refer to the <a href='https://water.usgs.gov/vizlab/modeling-drought/' target='_blank'>Modeling streamflow drought</a> website and the <a href='https://doi.org/10.31223/X56X77' target='_blank'>technical documentation of modeling methods and model evaluation</a>."
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "Why do model predictions rarely exceed 30<sup>th</sup> percentile streamflow?",
                content: [
                    {
                        type: "text",
                        content: "As noted in “How is streamflow drought forecast?”, above, <span class='moderate-emph'>the dataset used to train the model is restricted to observed streamflow values below the 30<sup>th</sup> percentile</span> (when streamflow is below normal conditions). This produces a trained model that accurately predicts the occurrence and severity of streamflow drought. But when the model predicts that streamflow drought will <i>not</i> occur, the streamflow percentile predicted by the model may be lower than what will actually be observed. In addition, the model will not be able to accurately capture the uncertainty above the 30<sup>th</sup> percentile. This reduced accuracy at percentiles above the 30<sup>th</sup> percentile is a worthwhile tradeoff for improved accuracy at low streamflow percentiles, since this tool was developed to forecast streamflow drought."
                    },
                    {
                        type: "text",
                        content: "For more information, please refer to the <a href='https://water.usgs.gov/vizlab/modeling-drought/' target='_blank'>Modeling streamflow drought</a> website and the <a href='https://doi.org/10.31223/X56X77' target='_blank'>technical documentation of modeling methods and model evaluation</a>."
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "How reliable are the long-term forecasts?",
                content: [
                    {
                        type: "text",
                        content: "The maximum forecast horizon for this model is 13 weeks in the future. Weather forecasts are very limited for this timeframe, making streamflow drought predictions highly uncertain. Nonetheless, these predictions provide more insight into future conditions than simply referencing median conditions from prior years. Please refer to the <a href='https://doi.org/10.31223/X56X77' target='_blank'>technical documentation</a> for a detailed evaluation of our model’s ability to forecast streamflow drought occurrence as well as streamflow drought onset and termination and visit the <a href='https://water.usgs.gov/vizlab/modeling-drought/' target='_blank'>Modeling streamflow drought</a> website for an overview of the modeling approach."
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "What are the limitations of this tool?",
                content: [
                    {
                        type: "text",
                        content: "The models currently deployed operationally have limited accuracy in predicting streamflow drought occurrence or streamflow drought onset/termination more than 4 weeks into the future, and <span class='moderate-emph'>interpreting forecasts for 1-4 weeks may be most useful</span>. Continued model development can benefit from additional inputs, as this model incorporates limited data on subsurface storage and flow modifications, including reservoir releases, diversions, and withdrawals. In addition, there are difficulties in capturing sub-seasonal transitions between streamflow drought and flood conditions."
                    },
                    {
                        type: "text",
                        content: "A known issue with the current modeling approach is that <span class='moderate-emph'>model predictions tend towards streamflow drought being more likely for longer lead times</span>, which may overrepresent the prevalence of streamflow drought more than 4 weeks in advance."
                    },
                    {
                        type: "text",
                        content: "For more information, please refer to the <a href='https://water.usgs.gov/vizlab/modeling-drought/' target='_blank'>Modeling streamflow drought</a> website and the <a href='https://doi.org/10.31223/X56X77' target='_blank'>technical documentation of modeling methods and model evaluation</a>."
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "Are there special considerations when interpreting forecasts at particular types of sites?",
                content: [
                    {
                        type: "text",
                        content: "We highlight four categories of sites where there may be additional considerations for interpreting streamflow drought forecasts with nuance: <span class='moderate-emph'>non-perennial</span>, <span class='moderate-emph'>highly regulated</span>, <span class='moderate-emph'>snow-dominated</span>, and <span class='moderate-emph'>ice-impacted</span>."
                    },
                    {
                        type: "text",
                        content: "In the individual site summary views, <span class='moderate-emph'>icons beneath the USGS gage ID</span> indicate whether the site has perennial or non-perennial flow, and whether or not the site is highly regulated, snow-dominated, or ice-impacted. Icons are greyed out when they do not apply. "
                    },
                    {
                        type: "flex",
                        flex_dir: "row",
                        flex_align: "center",
                        flex_justify: "left",
                        flex_gap: "5px",
                        flex_line_height: "30px",
                        flex_margin: "1.5rem 0 0.5rem 0",
                        content: [
                            {
                                type: "svg",
                                content: "normal",
                                width: "30px",
                                height: "30px",
                                class: "hydro-icon"
                            },
                            {
                                type: "text",
                                content: "Perennial streamflow"
                            }
                        ]
                    },
                    {
                        type: "text",
                        content: "For <span class='moderate-emph'>perennial</span> sites with continuous streamflow throughout the year, no special considerations are needed for interpreting streamflow drought forecasts."
                    },
                    {
                        type: "flex",
                        flex_dir: "row",
                        flex_align: "center",
                        flex_justify: "left",
                        flex_gap: "5px",
                        flex_line_height: "30px",
                        flex_margin: "1.5rem 0 0.5rem 0",
                        content: [
                            {
                                type: "svg",
                                content: "intermittent",
                                width: "30px",
                                height: "30px",
                                class: "hydro-icon"
                            },
                            {
                                type: "text",
                                content: "Non-perennial streamflow"
                            }
                        ]
                    },
                    {
                        type: "text",
                        content: "At sites with <span class='moderate-emph'>non-perennial</span> streamflow where it is typical for the stream to dry at certain times of year, streamflow drought may occur due to abnormally long stretches without streamflow rather than due to abnormally low streamflow. While the model uses a method that considers whether a continuous stretch without streamflow is longer than normal, familiarity with the general patterns of streamflow at these sites may be useful for interpreting these streamflow drought forecasts."
                    },
                    {
                        type: "flex",
                        flex_dir: "row",
                        flex_align: "center",
                        flex_justify: "left",
                        flex_gap: "5px",
                        flex_line_height: "30px",
                        flex_margin: "1.5rem 0 0.5rem 0",
                        content: [
                            {
                                type: "svg",
                                content: "dam",
                                width: "30px",
                                height: "30px",
                                class: "hydro-icon"
                            },
                            {
                                type: "text",
                                content: "Highly regulated site"
                            }
                        ]
                    },
                    {
                        type: "text",
                        content: "At <span class='moderate-emph'>highly regulated</span> sites below dams, below normal streamflow percentiles may reflect streamflow drought in systems with over-year storage in irrigation and water supply reservoirs. However, reservoirs are often managed in coordination (for example releases from one reservoir may be stored in another), and evaluating the total reservoir storage in a watershed or basin can provide more information to models. Streamflow drought in areas with a high degree of flow regulation is dependent on historical patterns in water storage and release for the period 1981–2020. We assume reservoirs operate similarly to how they did during the 1981–2020 observed record."
                    },
                    {
                        type: "flex",
                        flex_dir: "row",
                        flex_align: "center",
                        flex_justify: "left",
                        flex_gap: "5px",
                        flex_line_height: "30px",
                        flex_margin: "1.5rem 0 0.5rem 0",
                        content: [
                            {
                                type: "svg",
                                content: "snow",
                                width: "30px",
                                height: "30px",
                                class: "hydro-icon"
                            },
                            {
                                type: "text",
                                content: "Snow-dominated site"
                            }
                        ]
                    },
                    {
                        type: "text",
                        content: "At <span class='moderate-emph'>snow-dominated</span> sites and other sites with strong streamflow seasonality, changes in the timing of snowmelt or seasonal input may display as streamflow drought even if the amount of snowmelt is similar."
                    },
                    {
                        type: "flex",
                        flex_dir: "row",
                        flex_align: "center",
                        flex_justify: "left",
                        flex_gap: "5px",
                        flex_line_height: "30px",
                        flex_margin: "1.5rem 0 0.5rem 0",
                        content: [
                            {
                                type: "svg",
                                content: "frozen",
                                width: "30px",
                                height: "30px",
                                class: "hydro-icon"
                            },
                            {
                                type: "text",
                                content: "Ice-impacted site"
                            }
                        ]
                    },
                    {
                        type: "text",
                        content: "At <span class='moderate-emph'>ice-impacted</span> sites, streamflow may be impacted by the presence of ice during cold times of the year. Frozen streams may appear to be abnormally low even when the site is not in streamflow drought."
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "What period of record is used for computing percentiles in order to classify streamflow levels?",
                content: [
                    {
                        type: "text",
                        content: "All sites included in this tool have nearly complete records for the 40-year period 1981–2020 (refer to “How were these sites selected?”, above)."
                    },
                    {
                        type: "text",
                        content: "For each site, this <span class='moderate-emph'>1981–2020 period is used as the period of record</span> when computing percentiles for recent observed streamflow and when forecasting streamflow percentiles. The percentile values determine the streamflow drought category of each observation/prediction (refer to “How are these streamflow drought categories defined, and do they align with U.S. Drought Monitor categories?”, above)."
                    },
                    {
                        type: "text",
                        content: "The 1981–2020 period of record is also used to convert forecast percentiles to units of streamflow – cubic feet per second (cfs) – when plotting the forecasts (refer to “Why are forecasts plotted in units of streamflow (cfs) instead of percentiles?”, below)."
                    },
                    {
                        type: "text",
                        content: "To learn more, visit the <a href='https://water.usgs.gov/vizlab/modeling-drought/' target='_blank'>Modeling streamflow drought</a> website or refer to the <a href='https://doi.org/10.31223/X56X77' target='_blank'>technical documentation of modeling methods and model evaluation</a>."
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "What does it mean if the observed condition for a site is ‘current streamflow unavailable’?",
                content: [
                    {
                        type: "text",
                        content: "The observed condition for a site is ‘current streamflow unavailable’ when <span class='moderate-emph'>streamflow data are not yet available for yesterday’s date</span> – the date before the forecasts were made. These data may be missing because the <a href='https://labs.waterdata.usgs.gov/visualizations/gages-through-the-ages/' target='_blank'>streamgage</a> is out of commission, there is an issue receiving data from the streamgage, or the release of the data has been delayed to perform additional quality assurance/quality control checks."
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "Why is the line showing observed streamflow incomplete for some sites?",
                content: [
                    {
                        type: "text",
                        content: "In the individual site summary view, the line for observed streamflow on the timeseries chart may be incomplete or have gaps. This indicates that <span class='moderate-emph'>streamflow data are not currently available for the full 90–day period leading up to the issue date</span> (the date the forecasts were made). So long as there are streamflow data in the last 30 days, the model will make a prediction using other input data (refer to “How are forecasts generated for sites with recently missing streamflow data?”, below)."
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "How are forecasts generated for sites with recently missing streamflow data?",
                content: [
                    {
                        type: "text",
                        content: "No forecasts are provided if streamflow data are missing for all of the last 30 days. If streamflow data are available for part of this period, a <span class='moderate-emph'>prediction will be made using other input data</span> (refer to “How is streamflow drought forecast?”, above), but may be less accurate."
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "Why are forecasts plotted in units of streamflow (cfs) instead of percentiles?",
                content: [
                    {
                        type: "text",
                        content: "In each individual site summary view, the timeseries chart displays streamflow drought forecasts in units of streamflow – cubic feet per second (cfs). While the predictions generated by the machine learning model are in units of percentiles, we chose to display the forecast in units of cfs <span class='moderate-emph'>for ease of comparison to recent observed conditions and for consistency with monitoring data reporting</span>. For each forecast date at each site, the percentile predictions were interpolated to cfs using the 1981–2020 record of streamflow and streamflow percentiles on the corresponding Julian day (refer to “What period of record is used for computing percentiles in order to classify streamflow levels?”, above)."
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "Why do observed streamflow and historical streamflow drought thresholds drop to zero at some sites?",
                content: [
                    {
                        type: "text",
                        content: "At <span class='moderate-emph'>non-perennial</span> sites, it is typical for the stream to dry at certain times of year, meaning that it is <span class='moderate-emph'>normal for streamflow to be zero cubic feet per second</span> (cfs). Under these conditions, a lack of streamflow does not necessarily indicate that a site is in streamflow drought. As a result, the historical drought thresholds drop to zero cfs, disappearing from view on the timeseries charts. During these periods, <span class='moderate-emph'>the occurrence of streamflow drought is determined based on the length of time a site is continuously without streamflow</span>. If zero streamflow conditions persist for longer than normal (e.g., lasting 30 continuous days rather than only 10 continuous days), the site is considered to be in streamflow drought. The three categories of streamflow drought (moderate, severe, and extreme) are associated with progressively longer extensions of zero streamflow conditions."
                    }
                ],
                activeOnLoad: false
            },
            {
                heading: "How do I read the timeseries charts?",
                content: [
                    {
                        type: "svg",
                        content: "timeseries_legend_v3",
                        width: "320px"
                    },
                    {
                        type: "text",
                        content: "Each timeseries chart shows recent streamflow conditions and forecasts of streamflow drought for a selected site. <span class='moderate-emph'>Date is on the x-axis</span>. The <span class='moderate-emph'>y-axis is streamflow</span> in units of cubic feet per second (cfs)."
                    },
                    {
                        type: "text",
                        content: "<h3>Issue date</h3>The chart is split vertically by a dotted line indicating the issue date — <span class='moderate-emph'>the date the forecasts were made</span>."
                    },
                    {
                        type: "text",
                        content: "<h3>Observed streamflow</h3>To the left of the issue date line, the <span class='moderate-emph'>previous 90 days of observed streamflow</span> are shown as a black line. The line represents the 7-day rolling average of mean daily streamflow. Using a smoother rolling average is common practice for low flow and drought analysis, as it makes streamflow drought calculations more robust to minor day–to–day variations in streamflow. The observed streamflow data are included to illustrate streamflow conditions leading up to the forecast period. For some sites, streamflow data may not currently be available for all 90 days, in which case the line for observed streamflow may be incomplete or have gaps."
                    },
                    {
                        type: "text",
                        content: "<h3>Drought categories and historical streamflow drought thresholds</h3>Behind the streamflow line are three shaded bands that indicate the levels of streamflow associated with three categories of streamflow drought:<span><ul><li><span class='highlight moderate slight-emph'>Moderate</span> streamflow drought</li><li><span class='highlight severe slight-emph'>Severe</span> streamflow drought</li><li><span class='highlight extreme slight-emph'>Extreme</span> streamflow drought</li></ul></span>"
                    },
                    {
                        type: "text",
                        content: "Each of these three categories is defined by a specific threshold value. The streamflow drought thresholds vary by day of year and are based on 40 years of historical records for each site."
                    },
                    {
                        type: "text",
                        content: "The <span class='highlight moderate slight-emph'>moderate</span> streamflow drought threshold for each site is the <span class='moderate-emph'>20<sup>th</sup> percentile streamflow</span> for each day of the year. That 20<sup>th</sup> percentile streamflow is calculated as the level that streamflow drops below in only 20% of recorded years (at that site on that day of year). This means that, on that day of year, streamflow at the site is less than that threshold value 20% of the time. When streamflow drops below the 20<sup>th</sup> percentile threshold value, the site enters a <span class='highlight moderate slight-emph'>moderate</span> streamflow drought."
                    },
                    {
                        type: "text",
                        content: "The <span class='highlight severe slight-emph'>severe</span> streamflow drought threshold for each site is the <span class='moderate-emph'>10<sup>th</sup> percentile streamflow</span> for each day of the year. When streamflow drops below this threshold value, the site enters a <span class='highlight severe slight-emph'>severe</span> streamflow drought."
                    },
                    {
                        type: "text",
                        content: "The <span class='highlight extreme slight-emph'>extreme</span> streamflow drought threshold for each site is the <span class='moderate-emph'>5<sup>th</sup> percentile streamflow</span> for each day of the year. When streamflow drops below this threshold value, the site enters an <span class='highlight extreme slight-emph'>extreme</span> streamflow drought."
                    },
                    {
                        type: "text",
                        content: "On the chart, the shaded band for each streamflow drought category is partially transparent except for where it intersects the rectangular box showing the prediction interval for each forecast date."
                    },
                    {
                        type: "text",
                        content: "<a href='https://water.usgs.gov/vizlab/modeling-drought/' target='_blank'>Learn more about streamflow drought thresholds and streamflow percentiles</a>."
                    },
                    {
                        type: "text",
                        content: "<h3>Streamflow drought forecasts</h3>To the right of the issue date line is the forecast period. <span class='moderate-emph'>Forecasts of streamflow drought are shown weekly for 1 through 13 weeks from the issue date</span>. The median prediction for each forecasts date is shown as a circle. The color of the circle indicates what category of streamflow drought is predicted: <span class='highlight moderate slight-emph'>moderate</span>, <span class='highlight severe slight-emph'>severe</span>, <span class='highlight extreme slight-emph'>extreme</span>, or no streamflow drought. The circle for the currently selected date has a thick black border. To learn more about how the forecasts are generated, visit the <a href='https://water.usgs.gov/vizlab/modeling-drought/' target='_blank'>Modeling streamflow drought</a> website."
                    },
                    {
                        type: "text",
                        content: "<h3>Uncertainty of streamflow drought forecasts</h3>The uncertainty associated with each weekly forecast is depicted by a rectangular box behind the median prediction circles. The height of this box represents the <span class='moderate-emph'>90% prediction interval</span>. This interval represents the range of streamflow that the model predicted, excluding the 10% least likely scenarios. When the range of values includes streamflow predictions that are below the moderate streamflow drought threshold, the rectangle ‘dips’ into the shaded bands for the streamflow drought categories, showing what categories of streamflow drought are included in the prediction interval. To learn more about the uncertainty of the forecasts, visit the <a href='https://water.usgs.gov/vizlab/modeling-drought/' target='_blank'>Modeling streamflow drought</a> website."
                    },
                    {
                        type: "text",
                        content: "<h3>Summary of observed and forecast streamflow droughts</h3>Beneath the main part of the chart is a visual summary of observed and forecast streamflow droughts for the selected site. <span class='moderate-emph'>Observed streamflow droughts</span> are shown as <span class='moderate-emph'>horizontal bands</span>. The color of the band indicates the category of the streamflow drought. <span class='moderate-emph'>Forecast streamflow droughts</span> are shown as <span class='moderate-emph'>circles</span>. The color of the circle indicates what category of streamflow drought is predicted: <span class='highlight moderate slight-emph'>moderate</span>, <span class='highlight severe slight-emph'>severe</span>, <span class='highlight extreme slight-emph'>extreme</span>, or no streamflow drought."
                    }
                ]
            }
        ]
    },
    graph: {
        title: "How do I read this chart?",
        intro: "This chart shows recent streamflow conditions and forecasts of streamflow drought for a selected site. <span class='moderate-emph'>Date is on the x-axis</span>. The <span class='moderate-emph'>y-axis is streamflow</span> in units of cubic feet per second (cfs).",
        heading1: "Issue date",
        paragraph1: "The chart is split vertically by a dotted line indicating the issue date — <span class='moderate-emph'>the date the forecasts were made</span>.",
        heading2: "Observed streamflow",
        paragraph2: "To the left of the issue date line, the <span class='moderate-emph'>previous 90 days of observed streamflow</span> are shown as a black line. The line represents the 7-day rolling average of mean daily streamflow. Using a smoother rolling average is common practice for low flow and drought analysis, as it makes streamflow drought calculations more robust to minor day–to–day variations in streamflow. The observed streamflow data are included to illustrate streamflow conditions leading up to the forecast period. For some sites, streamflow data may not currently be available for all 90 days, in which case the line for observed streamflow may be incomplete or have gaps.",
        heading3: "Drought categories and historical streamflow drought thresholds",
        paragraph3a: "Behind the streamflow line are three shaded bands that indicate the levels of streamflow associated with three categories of streamflow drought:<span><ul><li><span class='highlight moderate slight-emph'>Moderate</span> streamflow drought</li><li><span class='highlight severe slight-emph'>Severe</span> streamflow drought</li><li><span class='highlight extreme slight-emph'>Extreme</span> streamflow drought</li></ul></span>",
        paragraph3b: "Each of these three categories is defined by a specific threshold value. The streamflow drought thresholds vary by day of year and are based on 40 years of historical records for each site.",
        paragraph3c: "The <span class='highlight moderate slight-emph'>moderate</span> streamflow drought threshold for each site is the <span class='moderate-emph'>20<sup>th</sup> percentile streamflow</span> for each day of the year. That 20<sup>th</sup> percentile streamflow is calculated as the level that streamflow drops below in only 20% of recorded years (at that site on that day of year). This means that, on that day of year, streamflow at the site is less than that threshold value 20% of the time. When streamflow drops below the 20<sup>th</sup> percentile threshold value, the site enters a <span class='highlight moderate slight-emph'>moderate</span> streamflow drought.",
        paragraph3d: "The <span class='highlight severe slight-emph'>severe</span> streamflow drought threshold for each site is the <span class='moderate-emph'>10<sup>th</sup> percentile streamflow</span> for each day of the year. When streamflow drops below this threshold value, the site enters a <span class='highlight severe slight-emph'>severe</span> streamflow drought.",
        paragraph3e: "The <span class='highlight extreme slight-emph'>extreme</span> streamflow drought threshold for each site is the <span class='moderate-emph'>5<sup>th</sup> percentile streamflow</span> for each day of the year. When streamflow drops below this threshold value, the site enters an <span class='highlight extreme slight-emph'>extreme</span> streamflow drought.",
        paragraph3f: "On the chart, the shaded band for each streamflow drought category is partially transparent except for where it intersects the rectangular box showing the prediction interval for each forecast date.",
        paragraph3g: "<a href='https://water.usgs.gov/vizlab/modeling-drought/' target='_blank'>Learn more about streamflow drought thresholds and streamflow percentiles</a>.",
        heading4: "Streamflow drought forecasts",
        paragraph4: "To the right of the issue date line is the forecast period. <span class='moderate-emph'>Forecasts of streamflow drought are shown weekly for 1 through 13 weeks from the issue date</span>. The median prediction for each forecasts date is shown as a circle. The color of the circle indicates what category of streamflow drought is predicted: <span class='highlight moderate slight-emph'>moderate</span>, <span class='highlight severe slight-emph'>severe</span>, <span class='highlight extreme slight-emph'>extreme</span>, or no streamflow drought. The circle for the currently selected date has a thick black border. To learn more about how the forecasts are generated, visit the <a href='https://water.usgs.gov/vizlab/modeling-drought/' target='_blank'>Modeling streamflow drought</a> website.",
        heading5: "Uncertainty of streamflow drought forecasts",
        paragraph5: "The uncertainty associated with each weekly forecast is depicted by a rectangular box behind the median prediction circles. The height of this box represents the <span class='moderate-emph'>90% prediction interval</span>. This interval represents the range of streamflow that the model predicted, excluding the 10% least likely scenarios. When the range of values includes streamflow predictions that are below the moderate streamflow drought threshold, the rectangle ‘dips’ into the shaded bands for the streamflow drought categories, showing what categories of streamflow drought are included in the prediction interval. To learn more about the uncertainty of the forecasts, visit the <a href='https://water.usgs.gov/vizlab/modeling-drought/' target='_blank'>Modeling streamflow drought</a> website.",
        heading6: "Summary of observed and forecast streamflow droughts",
        paragraph6: "Beneath the main part of the chart is a visual summary of observed and forecast streamflow droughts for the selected site. <span class='moderate-emph'>Observed streamflow droughts</span> are shown as <span class='moderate-emph'>horizontal bands</span>. The color of the band indicates the category of the streamflow drought. <span class='moderate-emph'>Forecast streamflow droughts</span> are shown as <span class='moderate-emph'>circles</span>. The color of the circle indicates what category of streamflow drought is predicted: <span class='highlight moderate slight-emph'>moderate</span>, <span class='highlight severe slight-emph'>severe</span>, <span class='highlight extreme slight-emph'>extreme</span>, or no streamflow drought."
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
            paragraph2: "At sites with non-perennial streamflow, streamflow drought may occur due to longer stretches without streamflow rather than abnormally low streamflow. While the model uses a method that considers whether a continuous stretch without streamflow is longer than normal, familiarity with the general patterns of streamflow at these sites may be useful for interpreting these streamflow drought forecasts.",
            promptTrue: "Site has non-perennial streamflow"
        },
        regulated: {
            title: "Highly regulated site",
            paragraph1: "Streamflow at this site is highly regulated, due to storage of streamflow in upstream reservoirs.",
            paragraph2: "At highly regulated sites below dams, below normal streamflow percentiles may reflect streamflow drought in systems with over-year storage in irrigation and water supply reservoirs. However, reservoirs are often managed in coordination (for example releases from one reservoir may be stored in another), and evaluating the total reservoir storage in a watershed or basin can provide more information to models. Streamflow drought in areas with a high degree of flow regulation is dependent on historical patterns in water storage and release for the period 1981–2020. We assume reservoirs operate similarly to how they did during the 1981–2020 observed record.",
            promptTrue: "Site is highly regulated",
            promptFalse: "Site is not highly regulated"
        },
        snow: {
            title: "Snow-dominated site",
            paragraph1: "The hydrology of this site is considered to be snow-dominated because within the site's contributing drainage area, the peak snow water equivalent is at least 25% of the annual precipitation total. Snow water equivalent is a measure of the liquid water contained in snowpack.",
            paragraph2: "At snow-dominated sites and other sites with strong streamflow seasonality, changes in the timing of snowmelt or seasonal input may display as streamflow drought even if the amount of snowmelt is similar.",
            promptTrue: "Site is snow-dominated",
            promptFalse: "Site is not snow-dominated"
        },
        ice: {
            title: "Ice-impacted site",
            paragraph1: "At this site, streamflow is sometimes estimated because ice is present.",
            paragraph2: "At ice-impacted sites, streamflow may be impacted by the presence of ice during cold times of the year. Frozen streams may appear to be abnormally low even when the site is not in streamflow drought.",
            promptTrue: "Site may be impacted by ice",
            promptFalse: "Site is not likely to be impacted by ice"
        }
    }
}