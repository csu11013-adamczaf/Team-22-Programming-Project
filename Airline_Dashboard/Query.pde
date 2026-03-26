public class Query
{
    public int textBoxHeight = 40;
    public int textBoxWidth = 500;
    private String userQuery = "";
    private boolean isKeyDepressed= false;
    //Checks whether a String occurs within a specified Array
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
        textFont(loadFont(Visuals.QUERY_SEARCH_FONT));
        if(keyPressed == true)
        {
            if(!isKeyDepressed)
            {
                if(key == '\b' && userQuery.length() != 0)
                {
                    userQuery = userQuery.substring(0, userQuery.length()-1);
                }
                else if((key >= 'A' && key <= 'z') || key == ' ' || key == '/' || key == ',' || key == ':' || (key >= '0' && key <= '9'))
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
        float boxXPos=xPos-((textBoxWidth+dropDown.ddW)/2);
        
        dropDown.setPosition(boxXPos+textBoxWidth+10,yPos);

        stroke(0);
        fill(#a5a5a5a5);
        rect(boxXPos, yPos, textBoxWidth, textBoxHeight, 10);
        fill(0);
        text("Query: " + userQuery, boxXPos+20, yPos+25);
    }


}