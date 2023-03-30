/*
Cleaning Data in SQL Queries
*/

SELECT * FROM PortfolioProject.dbo.NashvileHouseData

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Standardize Date Format

SELECT SaleDateConverted,CONVERT(DATE,SaleDate) 
From PortfolioProject.dbo.NashvileHouseData


UPDATE NashvileHouseData 
SET SaleDate = CONVERT(DATE,SaleDate)

ALTER TABLE NashvileHouseData
ADD SaleDateConverted Date;

UPDATE NashvileHouseData 
SET SaleDateConverted = CONVERT(DATE,SaleDate)

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Populate Property Address Data

SELECT *
From PortfolioProject.dbo.NashvileHouseData
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvileHouseData a
JOIN PortfolioProject.dbo.NashvileHouseData b
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvileHouseData a
JOIN PortfolioProject.dbo.NashvileHouseData b
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is null


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Breaking out Address into individual columns (Address,city,state)

SELECT PropertyAddress
FROM PortfolioProject.DBO.NashvileHouseData

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1,LEN(PropertyAddress))
FROM PortfolioProject.DBO.NashvileHouseData


ALTER TABLE NashvileHouseData
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvileHouseData 
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvileHouseData
ADD PropertySplitCity nvarchar(255);

UPDATE NashvileHouseData 
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1,LEN(PropertyAddress))

SELECT * 
FROM PortfolioProject.DBO.NashvileHouseData


SELECT OwnerAddress
FROM PortfolioProject.DBO.NashvileHouseData


SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1) 
FROM PortfolioProject.DBO.NashvileHouseData


ALTER TABLE NashvileHouseData
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvileHouseData 
SET  OwnerSplitAddress= PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvileHouseData
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvileHouseData 
SET  OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvileHouseData
ADD OwnerSPlitState nvarchar(255);

UPDATE NashvileHouseData 
SET OwnerSPlitState =PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT * 
FROM PortfolioProject.DBO.NashvileHouseData

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------


--Change Y and N to Yes and No in "Solid as Vacant" field

SELECT DISTINCT(SoldAsVacant),count(SoldAsVacant)
FROM PortfolioProject.DBO.NashvileHouseData
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldASVacant = 'Y' THEN 'Yes'
	 WHEN SoldASVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject.DBO.NashvileHouseData

UPDATE NashvileHouseData
SET SoldAsVacant=CASE WHEN SoldASVacant = 'Y' THEN 'Yes'
	 WHEN SoldASVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


SELECT DISTINCT(SoldAsVacant),count(SoldAsVacant)
FROM PortfolioProject.DBO.NashvileHouseData
GROUP BY SoldAsVacant
ORDER BY 2


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	Partition by ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
	ORDER BY 
	UniqueID) row_num
FROM PortfolioProject.DBO.NashvileHouseData
--ORDER BY ParcelID
)
SELECT *
 FROM RowNumCTE
WHERE row_num>1


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--DELETE unused Columns

SELECT *
FROM PortfolioProject.DBO.NashvileHouseData

ALTER TABLE PortfolioProject.DBO.NashvileHouseData
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE PortfolioProject.DBO.NashvileHouseData
DROP COLUMN SaleDate
