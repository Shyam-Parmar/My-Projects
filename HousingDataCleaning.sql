/* 

Cleaning Data in SQL Queries

*/

SELECT * 
FROM HousingProject..NashvilleHousing

-------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDate, CONVERT(DATE, SaleDate)
FROM HousingProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(DATE, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDate2 Date;

UPDATE NashvilleHousing
SET SaleDate2 = CONVERT(DATE, SaleDate)

SELECT SaleDate2
FROM HousingProject..NashvilleHousing


-------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

SELECT * 
FROM HousingProject..NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT *
FROM HousingProject..NashvilleHousing
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM HousingProject..NashvilleHousing a
JOIN HousingProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM HousingProject..NashvilleHousing a
JOIN HousingProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]


-------------------------------------------------------------------------------------------------------------------

-- Breaking Down Address Into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousing

SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) AS Address,
SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM HousingProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

SELECT * 
FROM NashvilleHousing

SELECT OwnerAddress
FROM NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM HousingProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-------------------------------------------------------------------------------------------------------------------


-- Changing Y to Yes and N to No in "Sold as vacant" Field

SELECT DISTINCT(SoldAsVacant), COUNT (SoldAsVacant)
FROM HousingProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM HousingProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						 WHEN SoldAsVacant = 'N' THEN 'No'
						 ELSE SoldAsVacant
						 END

-------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS
(
	SELECT *,
		ROW_NUMBER () 
		OVER( PARTITION BY	ParcelID,
							PropertyAddress,
							SalePrice,
							SaleDate,
							LegalReference
							ORDER BY UniqueID ) row_num
	FROM HousingProject..NashvilleHousing
)
SELECT * 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

WITH RowNumCTE AS
(
	SELECT *,
		ROW_NUMBER () 
		OVER( PARTITION BY	ParcelID,
							PropertyAddress,
							SalePrice,
							SaleDate,
							LegalReference
							ORDER BY UniqueID ) row_num
	FROM HousingProject..NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

-------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE HousingProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

SELECT * 
FROM HousingProject..NashvilleHousing