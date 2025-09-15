/**
 * Export runtime configuration settings stored in the global CONFIG variable.
 */
export default {
  ...(window.CONFIG || {}),

  // These are the screen size breakpoints in the USWDS style sheet
  USWDS_SMALL_SCREEN: 481,
  USWDS_MEDIUM_SCREEN: 641,
  USWDS_LARGE_SCREEN: 1025,
  USWDS_SITE_MAX_WIDTH: 1024,

  DATA_STATUS_BAR_HEIGHT: {
    desktop: 23,
    tablet: 23,
    phone: 19,
  },
  DATA_STATUS_BAR_INDICATOR_OFFSET: {
    desktop: 14,
    tablet: 14,
    phone: 11.5,
  },
};
