#Connecting Python to MySQL Database

import pandas as pd
from sqlalchemy import create_engine

conn_string = "mysql+mysqlconnector://root:yourpassword@localhost:3306/paintings"
            #mysql+<drivername>://<username>:<password>@<server>:<port>/dbname
db = create_engine(conn_string)
conn = db.connect()

#Load CSV files (we will looping through all the files. alterantive option is that we can write the same piece of code n times for n files in the dataset)

files = ['artist','canvas_size','image_link','museum','museum_hours','product_size','subject','work']
for file in files:
    df = pd.read_csv(f"C:/Users/SHREE/Desktop/Portfolio Projects/SQL Projects or Case Studies/Project 1/Datasets/{file}.csv")
    #Convert the Pandas DataFrame to a Format for MySQL Table Insertion
    df.to_sql(file,con = conn, if_exists = 'replace', index=False)
