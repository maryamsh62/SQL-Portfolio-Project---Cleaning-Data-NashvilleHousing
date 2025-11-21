# Data Cleaning for Nashville Housing Dataset


This project cleans and standardizes the Nashville Housing real estate transactions dataset using SQL (T-SQL). It applies production-style data wrangling: enforcing correct data types, populating reliable fields, normalizing categorical values, splitting compound addresses into atomic columns, and safely removing duplicates. 

During analysis, we observed null values in the output, although the cause is unclear. Certain fields, especially PropertyAddress, should be stable (OwnerAddress may change, but PropertyAddress is ~99.9% static). Records sharing the same ParcelID consistently share the same PropertyAddress, so missing addresses can be populated from another record with the same ParcelID.
For duplicates, we avoid deleting source data. When de-duplication is necessary (e.g., for full-table queries), we write the results to a temporary, de-duplicated table, preserving the original records and maintaining data integrity.


It demonstrates my ability to:
- Work with real-world datasets
- Perform data cleaning and transformation
- Use complex SQL queries for insights

  
## Project Files


- `Cleaning Data NashvilleHousing Portfolio Project.sql`  
  Contains all SQL queries used to explore and clean the NashvilleHousing datasets.


## Tools Used

- **SQL Server Management Studio (SSMS)**
- **Microsoft SQL Server**
