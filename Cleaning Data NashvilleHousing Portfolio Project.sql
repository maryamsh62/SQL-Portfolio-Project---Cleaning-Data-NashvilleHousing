/*
Cleaning Data In SQL Queries
*/

SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing

--------------------
-- Change Date Format for SaleDate field
--SELECT SaleDate 
--FROM PortfolioProject.dbo.NashvilleHousing

SELECT SaleDate, CONVERT(date,SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDate = CONVERT(date,SaleDate) -- This is may work or may not, try it out on your system 

SELECT SaleDate 
FROM PortfolioProject.dbo.NashvilleHousing

--Alternative Way
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD SaleDateConverted date;

SELECT SaleDateConverted 
FROM PortfolioProject.dbo.NashvilleHousing

--------------------
--Populate PropertyAddress Field
SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress is null

/*
When we run this, we notice that there are null values in the output. It's unclear why these nulls are occurring.
While the dataset contains a lot of information, certain fields, like the property address, are expected to remain
constant. The owner's address may change over time, but the property address itself is typically static 99.9% of the
time. Therefore, we believe the property address could be populated if we had a reliable reference to use as a lookup or base.
*/

-- let's look at every thing order by ParcelID
SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing
ORDER BY ParcelID

/* Upon review, we observed that entries with the same ParcelID consistently share the same PropertyAddress.
Based on this pattern, we can infer that if multiple records have the same ParcelID but some are missing the
PropertyAddress, we can confidently populate the missing values using the address from the corresponding ParcelID where it is present.
*/

-- Let's do self join
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing AS a
JOIN PortfolioProject.dbo.NashvilleHousing AS b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL

-- Populate a.PropertyAddress with b.PropertyAddress where a.ParcelID = b.ParcelID and a.PropertyAddress is null
UPDATE a
SET a.PropertyAddress = b.PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing AS a
JOIN PortfolioProject.dbo.NashvilleHousing AS b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL

--------------------
--Breaking out address into individual columns (address, city, state)
SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)- 1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS City
FROM PortfolioProject.dbo.NashvilleHousing

--Create new columns and add these values
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(225);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)- 1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(225);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing

--Use an alternative method to split the OwnerAddress field into separate columns for street address, city, and state
SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject.dbo.NashvilleHousing

--Create new columns and add these values
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(225);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar(225);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar(225);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing

--------------------
-- Change Y and N to Yes and No in "SoldAsVacant" field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) 
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
                        WHEN SoldAsVacant = 'N' THEN 'No'
                        ELSE SoldAsVacant
                        END

--------------------
--Remove Duplicates
/* 
We don’t frequently remove duplicates in SQL, but we have done it on occasion, typically when querying full tables.
In such cases, we usually create a temporary table where we store the de-duplicated results, rather than modifying
the original data. It's important to note that it's generally not standard practice to delete data directly from the
database. Maintaining data integrity and preserving raw records is usually preferred.
*/

WITH RowNumCTE AS
(SELECT *,
ROW_NUMBER() OVER( PARTITION BY ParcelID,
                                PropertyAddress,
                                SaleDate,
                                SalePrice,
                                LegalReference
                   ORDER BY UniqueID) AS row_num
FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1


--------------------
--Delete Unused Columns
SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict
