/*

Cleaning data in SQL queries

*/

SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing



-- Standardize date format

SELECT saledate, CONVERT(date,SaleDate)
FROM PortfolioProject..NashvilleHousing;


UPDATE NashvilleHousing
SET SaleDate = CONVERT(date,SaleDate);


ALTER TABLE NashvilleHousing
ADD SalesDateConverted Date;


UPDATE NashvilleHousing
SET SalesDateConverted = CONVERT(date,SaleDate);


SELECT salesdateconverted
FROM NashvilleHousing





-- Populate Property Address Data

SELECT *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]






-- Breaking out address to individual columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);


UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1),
	PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


SELECT *
FROM PortfolioProject..NashvilleHousing



SELECT 
PARSENAME(REPLACE(owneraddress,',','.'),3),
PARSENAME(REPLACE(owneraddress,',','.'),2),
PARSENAME(REPLACE(owneraddress,',','.'),1)
FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255),
	OwnerSplitCity NVARCHAR(255),
	OwnerSplitState NVARCHAR(255)
	


UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(owneraddress,',','.'),3),
	OwnerSplitCity = PARSENAME(REPLACE(owneraddress,',','.'),2),
	OwnerSplitState = PARSENAME(REPLACE(owneraddress,',','.'),1)


SELECT *
FROM PortfolioProject..NashvilleHousing






-- Change Y and N to Yes and No in 'SoldAsVacant' column


SELECT DISTINCT Soldasvacant, COUNT(soldasvacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY soldasvacant
ORDER BY 2


SELECT soldasvacant,
CASE WHEN soldasvacant = 'Y' THEN 'Yes'
	WHEN soldasvacant = 'N' THEN 'No'
	ELSE soldasvacant
	END
FROM PortfolioProject..NashvilleHousing


UPDATE NashvilleHousing
SET soldasvacant = CASE WHEN soldasvacant = 'Y' THEN 'Yes'
	WHEN soldasvacant = 'N' THEN 'No'
	ELSE soldasvacant
	END








-- Remove Duplicates

WITH rownumcte AS(
SELECT *, 
	ROW_NUMBER() OVER(PARTITION BY parcelid, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS row_num
FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)
DELETE 
FROM rownumcte
WHERE row_num>1
--ORDER BY PropertyAddress


SELECT * 
FROM PortfolioProject..NashvilleHousing








-- Delete unused column

SELECT * 
FROM PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

