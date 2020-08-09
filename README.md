# FlatlandView
Desktop version of Flatland

To help resolve issues in the mobile version of Flatland, I wrote a desktop version using the mobile version as a template, but mostly from scratch given the subtle differences between mobile and desktop in SceneKit and other SDKs.

The desktop version has taken on a life of its own and is now more complex and functional than the mobile version, which I haven't touched for a while. 

## Purpose

Flatland's original purpose was to show night and day on a flat map of the Earth. To more more efficient use of mobile devices, I used a polar-projected equirectangula map for the 2D mode.
Later, I added a 3D mode which the user can see day and night as he spins the globe.

## Features

* 2D: 
  * Show a 2D polar-projected equirectangular map (either north-centered or south-centered) with day and night plotted on top of it.
  * Show cities from a set of pre-loaded cities.
  * Show locations the user specifies.
  * Show earthquakes according to a user-defined earthquake filter.
  
* 3D:
  * Show equirectangular maps (of various types) projected onto a 3D sphere.
  * The sphere is oriented according to the season such that the proper parts of the Earth are illuminated by the sun. (The dark side is illuminated by a moon light.)
  * Show cities from a set of pre-loaded cities.
  * Show locations the user specifies.
  * Show regions the user specifies.
  * Show earthquakes according to a user-defined earthquake filter.
  
* Asynchronous:
  * Earthquakes are retrieved from the USGS once a minute and are grouped by location (to prevent data overload). Additionally, the user may specify a set of filters to determine which earthquakes are displayed.
  * Certain map types download the most recent satellite data available from NASA (where "most recent" means within the last 36 hours to avoid areas of no coverage).
    * Satellite images are downloaded tile-by-tile and reassembled in Flatland into a equirectangular map that is projected onto the 3D sphere.
    * Most satellites have gaps in coverages over the course of a day - these gaps will appear as diagonal, black regions.
    * Usually, the north polar area is black in winter, and the south polar area is black in winter.
