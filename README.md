# BirdNET Acoustic Monitoring — Permaisuri Lake Garden (Test Run)

## ⚠️ Test Run — Not a Formal Survey
This dataset comes from a **single ~90-minute test recording**, made to build and validate a
BirdNET-based acoustic monitoring workflow — it is **not** a rigorous or representative bird
survey of Permaisuri Lake Garden. A public event was taking place nearby for part of the
recording, and the resulting crowd noise (children shouting, people talking) caused BirdNET to
generate high-confidence false-positive detections for the two most frequent "species" in the
raw output (see **Data Quality** below). Treat the results here as a demonstration of the
pipeline, not as an accurate species inventory of the site.

## Project Overview
An end-to-end passive acoustic monitoring workflow: audio recording → BirdNET-Analyzer species
detection → data cleaning and quality control in R → species richness, relative abundance, and
activity-over-time analysis.

## Data Source
- **Location:** Permaisuri Lake Garden, Kuala Lumpur, Malaysia
- **Date:** 15 August 2026
- **Time:** 09:50–11:22 (approx. 1h 32m)
- **Method:** Single continuous recording, one location, recorded on a mobile phone (converted
  from mp3 to wav for processing)
- **Note:** the original audio file is not included in this repository (file size). The raw,
  unfiltered BirdNET detection output is provided instead, in `data/15 Aug 2026.BirdNET.results.csv`.

## Workflow
1. Audio recorded on-site with a phone
2. Species detection via [BirdNET-Analyzer](https://github.com/birdnet-team/BirdNET-Analyzer)
   (GUI, batch mode), exported as CSV → `data/15 Aug 2026.BirdNET.results.csv`
3. Data cleaning and analysis in R (`dplyr`, `ggplot2`, `lubridate`):
   - Species richness and relative abundance
   - Detection activity over the course of the recording (5-minute bins)
   - Species-by-time activity heatmap

## Data Quality / False-Positive Check
Two species dominated the raw automated output (>65% of all detections combined) but were not
observed in the field. Manual review of the highest-confidence detections against the original
audio confirmed both were misidentifications, not real bird calls:

| Species (raw output) | Raw detections | Manually verified as |
|---|---|---|
| Black-headed Ibis | 146 (33.1%) | Children shouting / people talking |
| Cattle Egret | 145 (32.9%) | Background noise |

Both were excluded, along with other low-confidence (< 0.5) single detections, before the final
analysis. This process is documented step by step in `analysis_permaisuri.R` (steps 8–11).
**Note:** the raw CSV included in `data/` has not had these removed — opening it directly will
show all 25 species / 441 raw detections, including the two false positives above. The cleaning
happens when you run `analysis_permaisuri.R` on it.

## Results (after cleaning)
- **Species richness:** 12 species (down from 25 in the raw, unfiltered output)
- **Total valid detections:** 37
- **Most frequent species:** Purple Heron (13 detections, 35.1%), followed by Black-crowned
  Night-Heron and Stork-billed Kingfisher (5 each, 13.5%)
- See `figures/` for the detection-activity and species-activity plots

## Limitations
- Single ~90-minute session, one location, one day — not repeated or randomized sampling, so
  results should not be read as a species inventory of the park
- Nearby event noise likely affected detectability of quieter or more distant species during
  parts of the recording, beyond just the two false positives listed above
- Cattle Egret's exclusion is based on manually checking its five highest-confidence detections,
  not every single one — a reasonable simplification for this test run, not a certainty
- Built as a workflow/portfolio demonstration, not a scientific monitoring output

## How to Reproduce
1. The raw BirdNET output is already included: `data/15 Aug 2026.BirdNET.results.csv`
   (re-running BirdNET-Analyzer yourself on the original audio is optional, not required)
2. Open `analysis_permaisuri.R` in RStudio, select all (Ctrl+A), and run (Ctrl+Enter / Source) —
   when prompted by `file.choose()`, select the CSV above
3. R packages required: `dplyr`, `ggplot2`, `lubridate`

## License
Code released under the MIT License.
