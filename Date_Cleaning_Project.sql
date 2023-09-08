-- Data Cleaning in SQL Queries

-- Select all data from the HousingData table
SELECT *
FROM Project.dbo.HousingData

-- Standardize Dates

-- Select SaleDateConverted and convert SaleDate to Date
SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM Project.dbo.HousingData

-- Update SaleDate and add SaleDateConverted column
UPDATE HousingData
SET SaleDate = CONVERT(Date, SaleDate)

-- Add SaleDateConverted column
ALTER TABLE HousingData
ADD SaleDateConverted Date

-- Update SaleDateConverted column with converted SaleDate values
UPDATE HousingData
SET SaleDateConverted = CONVERT(Date, SaleDate)

-- Property Address Date

-- Select rows with NULL PropertyAddress
SELECT PropertyAddress
FROM Project.dbo.HousingData
WHERE PropertyAddress IS NULL

-- Update NULL PropertyAddress with values from matching records
UPDATE t1
SET PropertyAddress = ISNULL(t1.PropertyAddress, t2.PropertyAddress)
FROM Project.dbo.HousingData t1
JOIN Project.dbo.HousingData t2 ON t1.ParcelID = t2.ParcelID AND t1.[UniqueID] <> t2.[UniqueID]
WHERE t1.PropertyAddress IS NULL

-- Breaking Down Address in Details

-- Select PropertyAddress
SELECT PropertyAddress
FROM Project.dbo.HousingData

-- Split PropertyAddress into Address and City
SELECT
  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM Project.dbo.HousingData

-- Add PropertySplitedAddress column and update with Address values
ALTER TABLE HousingData
ADD PropertySplitedAddress NVARCHAR(255)

UPDATE HousingData
SET PropertySplitedAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

-- Add PropertySplittedCity column and update with City values
ALTER TABLE HousingData
ADD PropertySplittedCity NVARCHAR(255)

UPDATE HousingData
SET PropertySplittedCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

-- Select all data from HousingData
SELECT *
FROM Project.dbo.HousingData

-- Splitting Owner Address

-- Select OwnerAddress
SELECT OwnerAddress
FROM Project.dbo.HousingData

-- Split OwnerAddress into Address, City, and State
SELECT
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address,
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City,
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
FROM Project.dbo.HousingData

-- Add OwnerSplitedAddress column and update with Address values
ALTER TABLE HousingData
ADD OwnerSplitedAddress NVARCHAR(255)

UPDATE HousingData
SET OwnerSplitedAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

-- Add OwnerSplittedCity column and update with City values
ALTER TABLE HousingData
ADD OwnerSplittedCity NVARCHAR(255)

UPDATE HousingData
SET OwnerSplittedCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

-- Add OwnerSplitedState column and update with State values
ALTER TABLE HousingData
ADD OwnerSplitedState NVARCHAR(255)

UPDATE HousingData
SET OwnerSplitedState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- Select all data from HousingData
SELECT *
FROM Project.dbo.HousingData

-- Change Y AND N TO YES AND NO in "SOLASVACANT" Column

-- Show distinct SoldAsVacant values and their counts
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Project.dbo.HousingData
GROUP BY SoldAsVacant
ORDER BY 2

-- Update SoldAsVacant values to YES and NO
UPDATE HousingData
SET SoldAsVacant = CASE
  WHEN SoldAsVacant = 'Y' THEN 'YES'
  WHEN SoldAsVacant = 'N' THEN 'NO'
  ELSE SoldAsVacant
END

-- Remove Duplicates

-- Common Table Expression to identify duplicate rows
WITH RowNumCTE AS (
  SELECT *,
    ROW_NUMBER() OVER (
      PARTITION BY ParcelID,
                   PropertyAddress,
                   SalePrice,
                   SaleDate,
                   LegalReference
      ORDER BY UniqueID
    ) row_num
  FROM Project.dbo.HousingData
)
-- Select and delete duplicate rows
SELECT *
FROM RowNumCTE
WHERE row_num > 1

-- Deleting UNUSED COLUMNS

-- Select all data from HousingData
SELECT *
FROM Project.dbo.HousingData

-- Remove TaxDistrict, PropertyAddress, and OwnerAddress columns
ALTER TABLE Project.dbo.HousingData
DROP COLUMN TaxDistrict, PropertyAddress, OwnerAddress
