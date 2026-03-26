public class Query
{
    private boolean isTextBoxSelected;
    private int textBoxHeight = 40;
    private int textBoxWidth = 500;
    private int textBoxX;
    private int textBoxY;
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
                else if(key >= 'A' && key <= 'z' || key == ' ')
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

    public void printQueryBox()
    {
        stroke(0);
        fill(#a5a5a5a5);
        rect(textBoxX, textBoxY, textBoxWidth, textBoxHeight, 10);
        fill(0);
        text("Query: " + userQuery, textBoxX+20, textBoxY+25);
        print("Query: " + userQuery);
    }


}