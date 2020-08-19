using ODBC
using DataFrames

# list installed ODBC drivers
@show ODBC.drivers()
# list pre-defined ODBC DSNs
@show ODBC.dsns()

# connect to a DSN using a pre-defined DSN or custom connection string
conn = ODBC.Connection("Ocean.FDB")

df = DBInterface.execute(conn, "SELECT * FROM STATION WHERE ID>1 and ID<5")  |> DataFrame

@show df

"""
# Basic a basic query that returns results at a Data.Table by default
datatable = ODBC.query(dsn, "show databases")

# convert result to a DataFrame for additional data manipulation functionality
df = DataFrame(datatable)
# ... additional data processing ...

# Execute a query without returning results
ODBC.execute!(dsn, "use mydb")

# return query results as a CSV file
csv = CSV.Sink("mydb_tables.csv")
data = ODBC.query(dsn, "select table_name from information_schema.tables", csv);

# return query results in an SQLite table
db = SQLite.DB()
source = ODBC.Source(dsn, "select table_name from information_schema.tables")
sqlite = SQLite.Sink(source, db)
Data.stream!(source, sqlite)
"""