# Change Log
All notable changes to this project will be documented in this file.
 
The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [1.2.0] - 2026-03-04

### Changed
- Updated data prep pipeline to pull in and process LSTM <50 forecasts in place of LSTM <30 forecasts
- Updated FAQs to reflect switch to LSTM <50 model
- Dropped 'early release' language from title dialog, page banner, and metadata

### Fixed
- Catch when streamflow data pull results include >1 distinct value per site per day 

## [1.1.0] - 2026-01-27

### Changed

- Update name of application to "River DroughtCast — Streamflow drought status and forecasts"

## [1.0.0] - 2025-12-10
 
### Added

- Initial early public release of the Streamflow drought assessment and forecasting tool
