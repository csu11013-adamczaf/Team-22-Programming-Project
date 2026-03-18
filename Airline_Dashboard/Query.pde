public class Query
{
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
}