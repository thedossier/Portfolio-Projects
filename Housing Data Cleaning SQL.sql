SELECT Sale_Date_Converted
FROM Nashville_Housing_Data..Nashville_Housing

--Standardizing Date Formats

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM Nashville_Housing_Data..Nashville_Housing

UPDATE Nashville_Housing
SET SaleDate = CONVERT(Date, SaleDate)

--Adding a column for conversion, update alone didn't update [Success]
ALTER TABLE Nashville_Housing
ADD Sale_Date_Converted Date;

UPDATE Nashville_Housing
SET Sale_Date_Converted = CONVERT(Date, SaleDate)


--Populating Property Address Data
SELECT *
FROM Nashville_Housing_Data..Nashville_Housing
WHERE PropertyAddress IS NULL

SELECT *
FROM Nashville_Housing_Data..Nashville_Housing
ORDER BY ParcelID
/*ParcelID could be used to populate NULL ProperyAddress s 
if at least 1 ParcelID has the address using a SELF JOIN*/

SELECT Parcel.ParcelID, Parcel.PropertyAddress, PopulateNULL.ParcelID, PopulateNULL.PropertyAddress 
FROM Nashville_Housing_Data..Nashville_Housing Parcel
JOIN Nashville_Housing_Data..Nashville_Housing PopulateNULL
	ON Parcel.ParcelID = PopulateNULL.ParcelID  --If these are the same
	AND Parcel.[UniqueID ] <> PopulateNULL.[UniqueID ] -- But have a different ID
WHERE Parcel.PropertyAddress IS NULL

SELECT Parcel.ParcelID, Parcel.PropertyAddress, PopulateNULL.ParcelID, PopulateNULL.PropertyAddress, ISNULL(Parcel.PropertyAddress,PopulateNULL.PropertyAddress)
FROM Nashville_Housing_Data..Nashville_Housing Parcel
JOIN Nashville_Housing_Data..Nashville_Housing PopulateNULL
	ON Parcel.ParcelID = PopulateNULL.ParcelID  
	AND Parcel.[UniqueID ] <> PopulateNULL.[UniqueID ] 
WHERE Parcel.PropertyAddress IS NULL

 -- Updating the table with NULL property addresses 
UPDATE Parcel
SET PropertyAddress = ISNULL(Parcel.PropertyAddress,PopulateNULL.PropertyAddress)
FROM Nashville_Housing_Data..Nashville_Housing Parcel
JOIN Nashville_Housing_Data..Nashville_Housing PopulateNULL
	ON Parcel.ParcelID = PopulateNULL.ParcelID  
	AND Parcel.[UniqueID ] <> PopulateNULL.[UniqueID ] 
WHERE Parcel.PropertyAddress IS NULL


/* Breaking out PropertyAddress into Individual Columns (Address, City) */

SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM Nashville_Housing_Data..Nashville_Housing

ALTER TABLE Nashville_Housing
ADD Property_Split_Address NVARCHAR(255);

UPDATE Nashville_Housing
SET Property_Split_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE Nashville_Housing
ADD Property_Split_City NVARCHAR(255);

UPDATE Nashville_Housing
SET Property_Split_City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

/* Breaking out OwnerAddress into Individual Columns (Address, City, State) */

SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as Owner_Split_Address,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as Owner_Split_City,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as Owner_Split_State
FROM Nashville_Housing_Data..Nashville_Housing

-- Adding Owner Split Address
ALTER TABLE Nashville_Housing
ADD Owner_Split_Address NVARCHAR(255);

UPDATE Nashville_Housing
SET Owner_Split_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

-- Adding Owner Split City
ALTER TABLE Nashville_Housing
ADD Owner_Split_City NVARCHAR(255);

UPDATE Nashville_Housing
SET Owner_Split_City = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

-- Adding Owner Split State
ALTER TABLE Nashville_Housing
ADD Owner_Split_State NVARCHAR(255);

UPDATE Nashville_Housing
SET Owner_Split_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


/* Changing 'Y' , 'N' to 'Yes' and 'No' in "SoldAsVacant" field */

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Nashville_Housing_Data..Nashville_Housing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant, 
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM Nashville_Housing_Data..Nashville_Housing


UPDATE Nashville_Housing
SET SoldAsVacant = 	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

/* Remove Duplicates */

WITH Row_Num_CTE AS (
SELECT *, 
	ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY
						UniqueID
						) row_num
FROM Nashville_Housing_Data..Nashville_Housing
--ORDER BY ParcelID
)
DELETE
FROM Row_Num_CTE


/* Delete Unused Columns*/
SELECT *
FROM Nashville_Housing_Data..Nashville_Housing

ALTER TABLE Nashville_Housing_Data..Nashville_Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress






