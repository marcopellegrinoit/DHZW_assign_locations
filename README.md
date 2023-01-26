
# Location assignment to activities of the synthetic population

#### _Author: Marco Pellegrino, Utrecht University_

#### _April 2022 - July 2023_

## Description

This repository contains scripts to assign locations to the activities of a synthetic population. The code is specific for a case-study project on The Hague Zuid West.

## **Generate PC4 statistics about where activities take place in ODiN in DHZW**
Firstly, reformat ODiN to take into account only the destination information. It is not relevant to clean missing data about attributes not used for this scope (e.g. demographic information).
[ODiN-data_preparation.R](https://github.com/mr-marco/DHZW_assign_locations/blob/main/ODiN-data_preparation.R)

Secondly, starting from ODiN trips of DHZW inhabitants, statistics about the PC4 destinations are computed ([ODiN-activity_destination_PC4.R](https://github.com/mr-marco/DHZW_assign_locations/blob/main/ODiN-activity_destination_PC4.R)).
In particular, for each residential PC4 in DHZW, a probability distribution of destination PC4 is calculated. The destination PC4 are all the PC4 codes in DHZW, plus "outside DHZW" that represents all the trips arriving outside the case-study area.
Probability distributions are divided by trip reason: work, shopping and sport.

## **Assign locations to the activities based on the previously computed ODiN statistics**
	
### Assign home locations ([assign-home_locations.R](https://github.com/mr-marco/DHZW_assign_locations/blob/main/assign-home_locations.R))
Input:
 - Synthetic activities;
 - Synthetic households;
 - BAG building addresses dataset.

Procedure:

 -Consider  only the residential BAG buildings in DHZW;
 - From the BAG dataset we know the amount of real addresses per PC6. Each neighbourhood is partitioned in PC6 areas, hence for each PC6 the percentage (proportion) of real addresses over its neighbourhood is computed. With these proportions, synthetic households are assigned to PC6 areas, returning a finer geolocation level than neighbourhoods;
 - For each synthetic household, the centroid of its PC6 is used as coordinates;
 - in the synthetic activities, the location of activities of type "home" is assigned to the home of the corresponding synthetic agent.

### Assign work locations ([assign-work_locations.R](https://github.com/mr-marco/DHZW_assign_locations/blob/main/assign-work_locations.R "assign-work_locations.R"))
Input:
 - Synthetic activities;
 - Synthetic agents;
 - BAG building addresses dataset.

Procedure:

 - Consider only the office and retail BAG buildings in DHZW;
 - For each residential PC4 of the synthetic agents, compute a probability distribution of PC4 where inhabitants go to work in DHZW, plus an external "outside DHZW" area ([ODiN-activity_destination_PC4.R](https://github.com/mr-marco/DHZW_assign_locations/blob/main/ODiN-activity_destination_PC4.R));
 - Distribute PC4 work areas over synthetic agents that have at least a "work" activity, based on the previous distribution. PC4 work areas are fixed per agents, so that if the agent goes to work more than once in the simulation, the location remains fixed.
 - For each agent, select a random work location existing in the previously generated PC4 work area. Each BAG location already contains precise coordinates.
 
 ### Assign shopping and sport locations ([assign-shopping_locations.R](https://github.com/mr-marco/DHZW-assign_locations/blob/main/assign-shopping_locations.R "assign-shopping_locations.R"), [assign-sport_locations.R](https://github.com/mr-marco/DHZW_assign_locations/blob/main/assign-sport_locations.R "assign-sport_locations.R"))
 Input:
 - Synthetic activities;
 - Synthetic agents;
 - BAG building addresses dataset.

Procedure:

 - Consider only the sport and shopping BAG buildings in DHZW;
 - For each residential PC4 of the synthetic agents, compute a probability distribution of PC4 where inhabitants go for shopping and sport in DHZW, plus an external "outside DHZW" area ([ODiN-activity_destination_PC4.R](https://github.com/mr-marco/DHZW_assign_locations/blob/main/ODiN-activity_destination_PC4.R));
 - Distribute PC4 work areas over the synthetic activities based on the previous distribution. PC4 shopping and sport areas are not fixed per agents, so the location can change within activities of the same agent;
 - For each agent, select a random shoppinf and sport location existing in the previously generated PC4 areas. Each BAG location already contains precise coordinates.

 ### Assign school locations ([assign-school_locations.R](https://github.com/mr-marco/DHZW_assign_locations/blob/main/assign-school_locations.R "assign-school_locations.R"))
 Input:
 - Synthetic activities;
 - Synthetic agents;
 - [Municipality dataset](https://denhaag.dataplatform.nl/#/data/cc1362f7-d847-4141-9361-d106b3f497ec) about school buildings.

Procedure:
- Consider only the schools in DHZW;
- For each activity of type "school", assign the closest school to the home coordinates of the synthetic agent. Schools can be of type: daycare, primary and high school. Synthetic agents to an appropriate type of school based on their age.