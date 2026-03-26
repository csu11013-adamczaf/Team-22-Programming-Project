public class Query
{
    private boolean isTextBoxSelected;
    private int textBoxHeight;
    private int textBoxWidth;
    private int textBoxX;
    private int tetBoxY;
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

    private String getUserQueryString()
    {
        fill(0);
        textFont(loadFont(Visuals.QUERY_SEARCH_FONT));
        text("Query: " + userQuery, 500, 500);
        if(keyPressed == true)
        {
            if(!isKeyDepressed)
            {
                if(key == '\n')
                {
                    userQuery = "";
                }
                else if(key == '\b')
                {

                }
                else
                {
                    isKeyDepressed = true;
                    userQuery += key;
                }
            }
        }
        else
        {
            isKeyDepressed = false;
        }
        return userQuery;
    }

    public void isTextBoxSelected()
    {

    }

    void mousePressed()
    {
        
    }

}