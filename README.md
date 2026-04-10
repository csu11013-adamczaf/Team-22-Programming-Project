# Team-22-Programming-Project: Airline Dashboard

Team Members:
  - Filip Adamczak (Leader)
  - Irene Bijoy
  - Pariddhi Jus Roy
  - Vhidula Abirami Prakash
  - Karthikeyan Vinodkumar
#

# Description
A comprehensive data visualization and management tool built with Processing for analyzing and exploring airline flight data.
This application provides multiple perspectives on flight information through interactive charts, a live map, and detailed query tools.

Comprehensive documentation on classes/functions can be found under the 'wiki' tab of this repository or click [here](https://github.com/csu11013-adamczaf/Team-22-Programming-Project/wiki/)
#

# Screens
<img width="1920" height="1140" alt="image" src="images/Passenger Screen.png" />
<img width="1920" height="1140" alt="image" src="images/Query Screen.png" />
<img width="1920" height="1140" alt="image" src="images/Map Screen.png" />

#
# Features
1. Passenger Mode
   - Schedule: A "glassmorphism" styled list displaying upcoming flights & departures and their statuses.
   - Cancelled & Delayed Flights: Two tables that show flights that have been cancelled or delayed. Flight data has been reduced so passengers only
     get the information that they need
2. Search Screen
   - Data Visualization: Displays flight data through three main chart types: Pie Charts, Bar Charts, and Line Charts.
   - Interactive Analysis: Users can change the data categories being viewed using integrated dropdown menus for categorical and numerical values.
   - Flight Data Table: A paginated view of flight records allowing for quick browsing of the dataset.
   - Search Functionality: Allows users to filter the flight database based on specific criteria using a search bar.
   - Status Filtering: Includes checkboxes to filter flights specifically by "Cancelled" or "Diverted" status.
3. Map View
   - Flight Arcs: Visualizes flight paths across the USA using dynamic arcs, color-coded by status: Green (Normal), Red (Cancelled), and Orange (Diverted).
   - Airport Activity: Represents airports with dots that scale in size based on the volume of flight traffic.
   - Temporal Control: Includes a date selection dropdown to view flight patterns for specific days.
#

# UI Components
   - The application utilizes a custom-built UI library including:
     - Buttons: Interactive elements with hover effects.
     - Search Bars: Used to take in user keyboard input for searching.
     - Dropdowns: Used for selecting dates and chart categories.
     - Checkboxes: Used for binary filters in the query screen.
     - TableWidget: A complex component for displaying tabular data with pagination.
     - Graphs: A class that contains 3 types of graphs that work on passed-in Table data.
#

# Installation & Setup
   - Ensure you have the Processing Development Environment installed.
   - Place all .pde files in a folder named AirLine_Dashboard.
   - Ensure the data folder contains the required assets:
     - flights2k.csv: The primary flight dataset.
     - Map.png: The background image for the map screen.
     - Required .vlw font files as defined in the Visuals class (e.g., button and table fonts).
   - Open AirLine_Dashboard.pde and click Run.

_**It is best practice to ensure that everything that is mentioned in VisualsClass.pde is present in the data folder. The Visuals class is the central file for storing references to external files. All files that Visuals uses must be present for the program to function.**_
#

# Controls
   - Navigation: Use the top navigation bar to switch between Overview, Query, Map, and Passenger Mode.
   - Interactions: Use your mouse to interact with dropdowns, buttons, and checkboxes across all screens.
