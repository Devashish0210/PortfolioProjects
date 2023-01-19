--Standardize Date Format

Select SaleDateConverted
from NashvilleHousing..Sheet1$

Alter Table Sheet1$
Add SaleDateConverted date;

update Sheet1$
SET SaleDate = CONVERT(Date, SaleDate)

Update Sheet1$
set SaleDateConverted = CONVERT(Date,SaleDate)


--Populating Property Address Column

SELECT PropertyAddress
FROM NashvilleHousing..Sheet1$
WHERE PropertyAddress is null

SELECT s1.ParcelID, s1.PropertyAddress, s2.ParcelID, s2.PropertyAddress, ISNULL(s1.PropertyAddress,s2.PropertyAddress)
FROM NashvilleHousing..Sheet1$ s1
JOIN NashvilleHousing..Sheet1$ s2
ON s1.ParcelID = s2.ParcelID
AND s1.[UniqueID ] <> s2.[UniqueID ]
WHERE s1.PropertyAddress is null

UPDATE s1
SET propertyAddress = ISNULL(s1.PropertyAddress,s2.PropertyAddress)
FROM NashvilleHousing..Sheet1$ s1
JOIN NashvilleHousing..Sheet1$ s2
ON s1.ParcelID = s2.ParcelID
AND s1.[UniqueID ] <> s2.[UniqueID ]


--Splitting the Property Address into Address and City


--Using Substring
SELECT 
SUBSTRING(propertyAddress, 1, CHARINDEX(',',propertyAddress)-1) as Address
, SUBSTRING(propertyAddress, CHARINDEX(',',propertyAddress)+1, LEN(propertyAddress)) as Address
FROM NashvilleHousing..Sheet1$

ALTER TABLE Sheet1$
ADD PropertySplitAdress nvarchar(255);

UPDATE Sheet1$
SET PropertySplitAdress = SUBSTRING(propertyAddress, 1, CHARINDEX(',',propertyAddress)-1)

ALTER TABLE Sheet1$
ADD PropertySplitCity nvarchar(255);

UPDATE Sheet1$
SET PropertySplitCity = SUBSTRING(propertyAddress, CHARINDEX(',',propertyAddress)+1, LEN(propertyAddress))

SELECT *
FROM NashvilleHousing..Sheet1$


--Using PARSENAME
SELECT 
PARSENAME(REPLACE(propertyAddress,',','.'),2) as PropertySplitAddress1,
PARSENAME(REPLACE(propertyAddress,',','.'),1) as PropertySplitCity1
FROM NashvilleHousing..Sheet1$

ALTER TABLE Sheet1$
ADD PropertySplitCity1 nvarchar(255);

UPDATE Sheet1$
SET PropertySplitCity1 = PARSENAME(REPLACE(propertyAddress,',','.'),1)

ALTER TABLE Sheet1$
ADD PropertySplitAddress1 nvarchar(255);

UPDATE Sheet1$
SET PropertySplitAddress1 = PARSENAME(REPLACE(propertyAddress,',','.'),2)

SELECT *
FROM NashvilleHousing..Sheet1$


-- Splitting the owner address into address, city and state

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3) as OwnerSplitAddress1,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) as OwnerSplitCity1,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) as PropertySplitState1
FROM NashvilleHousing..Sheet1$

ALTER TABLE Sheet1$
ADD OwnerSplitAddress1 nvarchar(255);

UPDATE Sheet1$
SET OwnerSplitAddress1 = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE Sheet1$
ADD OwnerSplitCity1 nvarchar(255);

UPDATE Sheet1$
SET OwnerSplitCity1 = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE Sheet1$
ADD OwnerSplitState1 nvarchar(255);

UPDATE Sheet1$
SET OwnerSplitState1 = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM NashvilleHousing..Sheet1$


--Change Y and N to Yes and No in SoldAsVacant

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing..Sheet1$
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
      WHEN SoldAsVacant = 'N' THEN 'NO'
	  ELSE SoldAsVacant
	  END
FROM NashvilleHousing..Sheet1$

UPDATE Sheet1$
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
      WHEN SoldAsVacant = 'N' THEN 'NO'
	  ELSE SoldAsVacant
	  END


	  --Removing Duplicates

	  WITH RowNumCTE AS (
	  SELECT *,
	  ROW_NUMBER() OVER(
	  PARTITION BY ParcelID,
	               PropertyAddress,
				   SalePrice,
				   SaleDate,
				   LegalReference
				   ORDER BY
				   UniqueID
	  )row_num
	  FROM NashvilleHousing..Sheet1$
	  --ORDER BY ParcelID
	  )

	  --SELECT *
	  --FROM RowNumCTE
	  --WHERE row_num > 1
	  --ORDER BY PropertyAddress

	  DELETE
	  FROM RowNumCTE
	  WHERE row_num > 1


	  --Deleting Columns

	  SELECT *
	  FROM NashvilleHousing..Sheet1$

	  ALTER TABLE NashvilleHousing..Sheet1$
	  DROP COLUMN PropertySplitAddress1, PropertySplitCity1, OwnerAddress, TaxDistrict, PropertyAddress

	  ALTER TABLE NashvilleHousing..Sheet1$
	  DROP COLUMN SaleDate