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
<img width="1920" height="1140" alt="image" src="https://github.com/user-attachments/assets/8971b4fa-b300-4265-8ebf-a32114893a4d" />
<img width="1920" height="1140" alt="image" src="https://github.com/user-attachments/assets/655b42a7-131e-44cc-b445-b834c6140a20" />
<img width="1920" height="1140" alt="image" src="https://github.com/user-attachments/assets/c4ae5668-97fa-41f0-8a4a-5dcd1a5922ff" />
<img width="1920" height="1140" alt="image" src="https://github.com/user-attachments/assets/7e78b28e-7545-4f6b-bd61-2ab3c0690a22" />

#
# Features
1. Overview Screen
   - Data Visualization: Displays flight data through three main chart types: Pie Charts, Bar Charts, and Line Charts.
   - Interactive Analysis: Users can change the data categories being viewed using integrated dropdown menus for categorical and numerical values.
   - Flight Data Table: A paginated view of flight records allowing for quick browsing of the dataset.
2. Query Mode
   - Search Functionality: Allows users to filter the flight database based on specific criteria using a search bar.
   - Status Filtering: Includes checkboxes to filter flights specifically by "Cancelled" or "Diverted" status.
3. Map View
   - Flight Arcs: Visualizes flight paths across the USA using dynamic arcs, color-coded by status: Green (Normal), Red (Cancelled), and Orange (Diverted).
   - Airport Activity: Represents airports with dots that scale in size based on the volume of flight traffic.
   - Temporal Control: Includes a date selection dropdown to view flight patterns for specific days.
4. Passenger Mode
   - Hero Flight Card: Highlights a main flight with high-visibility details.
   - Live Schedule: A "glassmorphism" styled list displaying upcoming flights and their statuses.
   - Telemetry HUD: Displays flight-related technical data like altitude and speed in a modern dashboard interface.
#

# UI Components
   - The application utilizes a custom-built UI library including:
     - Buttons: Interactive elements with hover effects.
     - Dropdowns: Used for selecting dates and chart categories.
     - Checkboxes: Used for binary filters in the query screen.
     - TableWidget: A complex component for displaying tabular data with pagination.
#

# Installation & Setup
   - Ensure you have the Processing Development Environment installed.
   - Place all .pde files in a folder named AirLine_Dashboard.
   - Ensure the data folder contains the required assets:
     - flights2k.csv: The primary flight dataset.
     - Map.png: The background image for the map screen.
     - Required .vlw font files as defined in the Visuals class (e.g., button and table fonts).
   - Open AirLine_Dashboard.pde and click Run.
#

# Controls
   - Navigation: Use the top navigation bar to switch between Overview, Query, Map, and Passenger Mode.
   - Interactions: Use your mouse to interact with dropdowns, buttons, and checkboxes across all screens.
