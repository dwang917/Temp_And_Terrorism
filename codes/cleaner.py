import pandas as pd  
import numpy as np  
import os, sys  

def main():  
    path_in_terror  = os.path.join(sys.path[0], "globalterrorismdb.csv")  
    path_out_terror = os.path.join(sys.path[0], "global_terrorism_cleaned.csv") 

    path_in_temps  = os.path.join(sys.path[0], "GlobalLandTemperaturesByCountry.csv")  
    path_out_temps = os.path.join(sys.path[0], "global_temps_cleaned.csv")  

    '''
        Global Terrorism Database 
    '''
    data = pd.read_csv(path_in_terror, low_memory=False)  
    df = pd.DataFrame(data, columns=['iyear', 'imonth', 'iday', 'country_txt', 'success', 'suicide', 'nkill', 'property', 'ransom'])  

    #fix dates  
    invalidDays = df[df['iday'] == 0].index  
    df.drop(invalidDays, inplace=True)  
    invalidMonths = df[df['iday'] == 0].index  
    df.drop(invalidMonths, inplace=True)  

    df['iday'] = df['iday'].apply(lambda x: '{0:0>2}'.format(x))  
    df['imonth'] = df['imonth'].apply(lambda x: '{0:0>2}'.format(x))  
    dates = df['iyear'].astype(str) + '-' + (df['imonth']).astype(str)  + '-' + (df['iday']).astype(str)  
    df.insert(0, 'date', dates)  
    df = df.drop(['iyear', 'imonth', 'iday'], axis=1)  

    df['nkill'] = df['nkill'].astype("Int64")  
    df['ransom'] = df['ransom'].astype("Int64")  

    df.loc[df['property'] <= 0, 'property'] = np.NaN
    df.loc[df['ransom'] <= 0, 'ransom'] = np.NaN 
    df.loc[df['nkill'] <= 0, 'nkill'] = np.NaN 

    df.dropna() #remove rows with invalid values

    df.to_csv(path_out_terror, index = False, header=True)  # save file
    print("saved cleaned terrorism data")
    
    '''
        Global Land Temperatures Dataset
    '''
    data = pd.read_csv(path_in_temps, low_memory=False)  
    df = pd.DataFrame(data, columns=['dt', 'AverageTemperature', 'Country'])  

    df.to_csv(path_out_temps, index = False, header=True)  # save file
    print("saved cleaned temperature data")  
    print("done")


if __name__ == "__main__":  
    main() 

 