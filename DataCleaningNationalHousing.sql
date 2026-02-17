SELECT *
FROM [Portfolio Project - Nashville Housing Data]..[Nashville Housing]

--Standardize the Date Format
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM [Portfolio Project - Nashville Housing Data]..[Nashville Housing]

UPDATE [Nashville Housing]
SET SaleDate = CONVERT(Date, SaleDate)
--SQL isn't converting the date type via Update

ALTER TABLE [Nashville Housing]
ADD Salesdateconverted Date;

UPDATE [Nashville Housing]
SET Salesdateconverted = CONVERT(Date, SaleDate)

SELECT SalesDateConverted
FROM [Portfolio Project - Nashville Housing Data]..[Nashville Housing]
------------------------------------------------------------------------
--Populate the Property Address Data
--Ensure all possible NULL address' have an address, using the ParcelIDs
SELECT *
FROM [Portfolio Project - Nashville Housing Data]..[Nashville Housing]
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Portfolio Project - Nashville Housing Data]..[Nashville Housing] a
JOIN [Portfolio Project - Nashville Housing Data]..[Nashville Housing] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Portfolio Project - Nashville Housing Data]..[Nashville Housing] a
JOIN [Portfolio Project - Nashville Housing Data]..[Nashville Housing] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


SELECT PropertyAddress
FROM [Portfolio Project - Nashville Housing Data]..[Nashville Housing]
WHERE PropertyAddress IS NULL

------------------------------------------------------------------------
--Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
FROM [Portfolio Project - Nashville Housing Data]..[Nashville Housing]

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(', ', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(', ', PropertyAddress)+1, LEN(PropertyAddress)) as City

FROM [Portfolio Project - Nashville Housing Data]..[Nashville Housing]

ALTER TABLE [Nashville Housing]
ADD PropertySplitAddress NVARCHAR(255)

UPDATE [Nashville Housing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(', ', PropertyAddress)-1)

ALTER TABLE [Nashville Housing]
ADD PropertySplitCity NVARCHAR(255)

UPDATE [Nashville Housing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(', ', PropertyAddress)+1, LEN(PropertyAddress))

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM [Portfolio Project - Nashville Housing Data]..[Nashville Housing]


ALTER TABLE [Nashville Housing]
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE [Nashville Housing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE [Nashville Housing]
ADD OwnerSplitCity NVARCHAR(255)

UPDATE [Nashville Housing]
SET OwnerSplitCity  = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE [Nashville Housing]
ADD OwnerSplitState NVARCHAR(255)

UPDATE [Nashville Housing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

------------------------------------------------------------------------
--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Portfolio Project - Nashville Housing Data]..[Nashville Housing]
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y'THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM [Portfolio Project - Nashville Housing Data]..[Nashville Housing]


UPDATE [Nashville Housing]
SET SoldAsVacant = CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END;

------------------------------------------------------------------------
--Removing Duplicates
WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 Saledate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM [Portfolio Project - Nashville Housing Data]..[Nashville Housing]
)

DELETE
--SELECT *
FROM RowNumCTE
WHERE row_num > 1

------------------------------------------------------------------------
--Deleting Unused Columns
SELECT *
FROM [Portfolio Project - Nashville Housing Data]..[Nashville Housing]

ALTER TABLE [Portfolio Project - Nashville Housing Data]..[Nashville Housing]
DROP COLUMN OwnerAddress,TaxDistrict, PropertyAddress, SaleDate