final int[] COLS = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17};

public class Query
{
    public int textBoxHeight = 40;
    public int textBoxWidth = 500;
    public float boxXPos;
    public float boxYPos;
    private Table data;
    private String userQuery = "";
    private boolean isKeyDepressed = false;
    //Checks whether a String occurs within a specified Array
    private Dropdown queryDD;
    
    Query(Table data)
    {
        this.data = data;
        _initDropdowns();
    }
    
    private void _initDropdowns()
    {
        String[] queryLabels  = new String[COLS.length];
        int[]    queryIndices = new int[COLS.length];
        
        for (int i = 0; i < COLS.length; i++)
        {
            if(i<11)
            {
                queryIndices[i] = CATEGORICAL_COLS[i];
            }
            queryLabels[i]  = data.getString(0, COLS[i]);
        }

        queryDD = new Dropdown(20, 50, 210, queryLabels, queryIndices, GRAPH_FONT);

    }
    
    public boolean exists(String searchTerm, String[] data)
    {
        boolean isValuePresent = false;
        for(int index = 0; index < data.length; index++)
        {
            if(searchTerm.equals(data[index]))
            {
                isValuePresent = true;
            }
        }
        return isValuePresent;
    }

    // Checks whether a String occurs within a specified ArrayList
    public boolean exists(String searchTerm, ArrayList<String> data)
    {
        String[] dataArray = data.toArray(new String[data.size()]);
        return exists(searchTerm, dataArray);
    }

    // Takes in user input from he keyboard and returns it as a string
    private String getUserQueryString()
    {
        fill(0);
        if(keyPressed == true)
        {
            if(!isKeyDepressed)
            {
                if(key == '\b' && userQuery.length() != 0)
                {
                    userQuery = userQuery.substring(0, userQuery.length()-1);
                }
                if((key >= 'A' && key <= 'z') || key == ' ' || key == '/' || key == ',' || key == ':' || (key >= '0' && key <= '9'))
                {
                    userQuery += key;
                }
                isKeyDepressed = true;
            }
        }
        else
        {
            isKeyDepressed = false;
        }
        
        return userQuery;
    }

        public void printQueryBox(float xPos, float yPos, Dropdown dropDown)
    {
        textFont(loadFont(Visuals.QUERY_SEARCH_FONT));
        String searchbyString = "Search through: ";
        float widgetWidth = textBoxWidth+60+dropDown.ddW+textWidth(searchbyString);
        boxXPos=xPos-((widgetWidth)/2);
        boxYPos = yPos;
        dropDown.setPosition(boxXPos+textBoxWidth+textWidth(searchbyString)+20,yPos);

        fill(#D8D8D8);
        rect(boxXPos-20, yPos-20, widgetWidth, textBoxHeight+80, 10);
        stroke(0);
        fill(#a5a5a5a5);
        rect(boxXPos, yPos, textBoxWidth, textBoxHeight, 10);
        fill(0);
        text("Search for: " + userQuery, boxXPos+20, yPos+28);
        text(searchbyString, boxXPos+20+textBoxWidth, yPos+28);
        rect(boxXPos+20+textWidth("Search for: "+ userQuery), yPos+8, 1,23);
    }

      public int getSelectedColumn() {
        return queryDD.getSelectedIndex();
    }
}
