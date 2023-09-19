/*

Cleaning Data in SQL Queries

*/


Select *
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing

--If the column does not update 

Alter table NashvilleHousing 
add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)
 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

----In some places we have property Address as Null so we have to populate it
----It is observed that Parcel Id in some cases are same  but unique id are different so we can populate it using same address as parcel id 
-----Lets self join table  first

Select a.ParcelID , a.PropertyAddress, b.ParcelID, b.PropertyAddress
From PortfolioProject.dbo.NashvilleHousing a 
JOIN NashvilleHousing b 
ON a. ParcelID = b. ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

----Incase of null values ISNULL(a.PropertyAddress, b.PropertyAddress)


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

----CharIndex is used to find specific characters

----We want to remove comma from behind -1 and if remove comma before than +1

Select
Substring (PropertyAddress, 1, CHARINDEX (',',PropertyAddress) -1) as Address
,Substring (PropertyAddress, CHARINDEX (',',PropertyAddress) +1,LEN(PropertyAddress)) as Addrress
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = Substring (PropertyAddress, 1, CHARINDEX (',',PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = Substring (PropertyAddress, CHARINDEX (',',PropertyAddress) +1,LEN(PropertyAddress))

----Checking the final result 

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

--For Owner Address

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

----We can do it with substring but it gets complicated so we can also do PARSENAME
----ownerAddress contains , to remove we have to replace with .

SELECT
PARSENAME(REPLACE (OwnerAddress, ',','.'),3)
,PARSENAME(REPLACE (OwnerAddress, ',','.'),2)
,PARSENAME(REPLACE (OwnerAddress, ',','.'),1)
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE (OwnerAddress, ',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar (255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE (OwnerAddress, ',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE (OwnerAddress, ',','.'),1)

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------


-- --Change Y and N to Yes and No in "Sold as Vacant" field


SELECT SoldASVacant ,COUNT (SoldAsVacant)
FROM  PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsvAcant 

SELECT SoldAsVacant ,
CASE 
WHEN SoldAsVacant = 'Y' THEN 'Yes '
WHEN SoldAsVacant = 'N' THEN 'No '
ELSE SoldAsVacant 
END 
From PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
WHEN SoldAsVacant = 'Y' THEN 'Yes '
WHEN SoldAsVacant = 'N' THEN 'No '
ELSE SoldAsVacant 
END 


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH CTE_RowNum as
(
SELECT *,
ROW_Number() OVER(PARTITION BY ParcelID, 
                               PropertyAddress,
							   SalePrice,
							   SaleDate,
							   LegalReference
							   ORDER BY 
							   UniqueID
							   )row_num
From PortfolioProject.dbo.NashvilleHousing
)
SELECT *
FROM CTE_RowNum
WHERE row_num > 1
Order by PropertyAddress
                  		

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT*
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
DROP Column OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP Column SaleDate



