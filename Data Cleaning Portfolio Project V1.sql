

/*

Cleaning Data in SQL Queries

*/

SELECT *
From PortfolioProject.dbo.nashville_housing

---------------------------------------------------------------------------------------------------------
-- Standardize Date Format

SELECT SaleDate, CONVERT(date, SaleDate)
From PortfolioProject.dbo.nashville_housing

Alter Table PortfolioProject.dbo.nashville_housing
Alter Column SaleDate date

-- If it doesn't Update properly

---------------------------------------------------------------------------------------------------------
-- Populate Property Address data

SELECT *
From PortfolioProject.dbo.nashville_housing
--Where PropertyAddress is NULL
Order By ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.nashville_housing a
JOIN PortfolioProject.dbo.nashville_housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.nashville_housing a
JOIN PortfolioProject.dbo.nashville_housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

---------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
From PortfolioProject.dbo.nashville_housing
--Where PropertyAddress is NULL
--Order By ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
From PortfolioProject.dbo.nashville_housing

Alter Table PortfolioProject.dbo.nashville_housing
Add PropertySplitAddress Nvarchar(255);
Update PortfolioProject.dbo.nashville_housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table PortfolioProject.dbo.nashville_housing
Add PropertySplitCity Nvarchar(255);
Update PortfolioProject.dbo.nashville_housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
From PortfolioProject.dbo.nashville_housing

-- Trying in a different way with "Parsename" function

SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject.dbo.nashville_housing

Alter Table PortfolioProject.dbo.nashville_housing
Add OwnerSplitAddress Nvarchar(255);
Update PortfolioProject.dbo.nashville_housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Alter Table PortfolioProject.dbo.nashville_housing
Add OwnerSplitCity Nvarchar(255);
Update PortfolioProject.dbo.nashville_housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter Table PortfolioProject.dbo.nashville_housing
Add OwnerSplitState Nvarchar(255);
Update PortfolioProject.dbo.nashville_housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
From PortfolioProject.dbo.nashville_housing

---------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject.dbo.nashville_housing
Group By SoldAsVacant
Order By 2

SELECT SoldAsVacant,
	CASE When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
	END
From PortfolioProject.dbo.nashville_housing

Update PortfolioProject.dbo.nashville_housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
						When SoldAsVacant = 'N' Then 'No'
						Else SoldAsVacant
					END

---------------------------------------------------------------------------------------------------------
-- Remove Duplicates

WITH RowNumCTE As
(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) as RowNum
From PortfolioProject.dbo.nashville_housing
--Order By ParcelID
)
Select *
From RowNumCTE
Where RowNum > 1
Order By PropertyAddress

SELECT *
From PortfolioProject.dbo.nashville_housing

---------------------------------------------------------------------------------------------------------
-- Delete Unused Columns

SELECT *
From PortfolioProject.dbo.nashville_housing

ALTER TABLE PortfolioProject.dbo.nashville_housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
-- Importing Data using OPENROWSET and BULK INSERT	

-- More advanced and looks cooler, but have to configure server appropriately to do correctly
-- Wanted to provide this in case you wanted to try it

--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO