![GitHub](https://img.shields.io/badge/license-GPL--3.0-blue)

# Location assignment to activities of the synthetic population

## Table of Contents

1.  [Description](#description)
2.  [Data preparation](#1)\-data-preparation)
3.  [Location assignment](2)\-location-assignment)
4.  [Analysis](analysis)
5.  [Contributors](#contributors)
6.  [License](#license)

## Description

This repository contains scripts to assign locations to the activities of a synthetic population. The code is specific for a case-study project on The Hague Zuid West. This project was undertaken at Utrecht University, The Netherlands, during 2022-2023 by Marco Pellegrino and a team of contributors.

Agents in the simulation engage in activities either within the DHZW case study area or outside of it. For activities within the area, specific locations are assigned, while for activities outside the boundary, only postcodes are used to denote the general location.

## 1) Data preparation

Script: [`data_preparation_DHZW`](data_preparation_DHZW.R)  
To assign locations, statistical analysis is conducted based on ODiN trips made by DHZW residents. The postcode PC4 destinations for each residential PC4 in DHZW are analysed, and the proportions of PC4 destinations are calculated for each destination activity. This information helps determine the spatial distribution of activities. See [data](README_data.md) for the used surveys.

## 2) Location assignment

#### Assign home locations

Script: [`assign-home_locations.R`](assign-home_locations.R)

The agent's household location is already determined within the synthetic population. The script adds such spatial information to all home activities.

#### Assign work locations

Script: [`assign-work_locations.R`](assign-work_locations.R)

The first step in the process is to select agents from the synthetic population who have at least one work location. From this group, for each PC4 of DHZW, the residents are identified. These residents are then assigned a PC4 work location based on step 1.

If the assigned work postcode is within DHZW, a work building within the respective PC4 is randomly chosen and assigned to each agent. However, if there are no available work buildings within the retrieved work postcode from the ODiN distribution, the provided tool is scalable and searches in alternative close postcodes within DHZW based on Euclidean distance.

Finally, all work activities of the agents are associated with their assigned work locations. It is assumed that agents go to work at the same location consistently.

#### Assign shopping and sports locations

Script: [`assign-shopping_locations.R`](assign-shopping_locations.R) and [`assign-sport_locations.R`](assign-sport_locations.R)

The procedure for assigning locations for shopping and sports activities follows the same approach as explained for work activities. However, unlike work activities where agents are assumed to go to the same location, agents' shopping and sports activities are not assumed to take place at the same location throughout the week. Hence, the location assignment is done directly for each activity.

#### Assign school locations

Script: [`assign-school_locations.R`](assign-school_locations.R)  
The procedure for assigning school locations follows a similar approach as explained for work activities. Agents are assumed to attend school at the same location.

However, the school buildings for activities within DHZW are assigned based on the agents' age as follows:

*   Daycare, for agents younger than 5 years old (inclusive)
*   Primary school, for agents with age between 6 and 11 (inclusive)
*   High school, for agents with age between 12 and 18 (inclusive)
*   University, for agents older than 19 years old (inclusive)

## Analysis

Scripts in \[`analysis/`\] allow the extrapolation of trips from the located activities for comparison with mobility surveys. The tools permit plotting different distributions for the evaluation of distances and postcodes.

## Contributors

This project was made possible thanks to the hard work and contributions from:

*   Marco Pellegrino (Author)
*   Jan de Mooij
*   Tabea Sonnenschein
*   Mehdi Dastani
*   Dick Ettema
*   Brian Logan
*   Judith A. Verstegen

## License

This repository is licensed under the GNU General Public License v3.0 (GPL-3.0). For more details, see the [LICENSE](LICENSE) file.