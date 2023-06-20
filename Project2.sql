/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [PortfolioProject].[dbo].[NashvilleHousing]


Select * 
from dbo.NashvilleHousing

--Converting the saledate column into standard date
SELECT CONVERT(VARCHAR(10), SaleDate, 120) AS NewSaleDate
FROM dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
ADD NewSaleDate DATE;

Update dbo.NashvilleHousing
SET NewSaleDate = CONVERT(VARCHAR(10), SaleDate, 120);

--------------------------------------------------------------------------------------------------------------------------------------------
--Property address
select *
from dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

-- there are null values in th property address. Having examined the dataset, it was observed that all parcels with same ParcelID are going to the same property address. Now, we have to autoPopulate the "null values" in the Property address coulm

UPDATE dbo.NashvilleHousing
SET PropertyAddress = (
  SELECT MAX(t2.PropertyAddress)
  FROM dbo.NashvilleHousing t2
  WHERE t2.ParcelID = dbo.NashvilleHousing.ParcelID
    AND t2.PropertyAddress IS NOT NULL
)
WHERE PropertyAddress IS NULL;

-- OR
--UPDATE dbo.NashvilleHousing
--SET PropertyAddress = (
--  SELECT t2.PropertyAddress
--  FROM dbo.NashvilleHousing
--  WHERE t2.ParcelID = dbo.NashvilleHousing.ParcelID
--    AND t2.PropertyAddress IS NOT NULL
--  LIMIT 1
--)
--WHERE PropertyAddress IS NULL;

---- lets confirm this worked (There are no more Null Values in the PropertyAddress column if you run this code below)
--select [UniqueID ], ParcelID, PropertyAddress
--from dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

---------------------------------------------------------------------------------------------------------------
--Splitting the address into street and city

Select 
    PARSENAME(replace(PropertyAddress, ',', '.'), 2),
    PARSENAME(replace(PropertyAddress, ',', '.'), 1)
from
    dbo.NashvilleHousing;

Alter table dbo.NashvilleHousing
Add StreetAddress Nvarchar (255);

Update dbo.NashvilleHousing
Set StreetAddress = PARSENAME(replace(PropertyAddress, ',', '.'), 2)


Alter table dbo.NashvilleHousing
Add CityAddress Nvarchar (255);

Update dbo.NashvilleHousing
Set CityAddress = PARSENAME(replace(PropertyAddress, ',', '.'), 1)


Select *
from dbo.NashvilleHousing

--ALTER TABLE dbo.NashvilleHousing
--DROP COLUMN Street;

-- Moving on to the Owners address
SELECT
    PARSENAME(replace(OwnerAddress, ',', '.'), 3) AS OwnerStreet,
    PARSENAME(replace(OwnerAddress, ',', '.'), 2) AS OwnerCity,
    PARSENAME(replace(OwnerAddress, ',', '.'), 1) AS OwnerState
FROM dbo.NashvilleHousing;

Alter table dbo.NashvilleHousing
Add OwnerStreet Nvarchar (255);

Update dbo.NashvilleHousing
Set OwnerStreet = PARSENAME(replace(OwnerAddress, ',', '.'), 3)

Alter table dbo.NashvilleHousing
Add OwnerCity Nvarchar (255);

Update dbo.NashvilleHousing
Set OwnerCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2)

Alter table dbo.NashvilleHousing
Add OwnerState Nvarchar (255);

Update dbo.NashvilleHousing
Set OwnerState = PARSENAME(replace(OwnerAddress, ',', '.'), 1)


select *
from dbo.NashvilleHousing

-- I want to replace the name of my columns for the splitted property address

EXEC sp_rename 'dbo.NashvilleHousing.StreetADdress', 'PropStreetAddress', 'COLUMN';
EXEC sp_rename 'dbo.NashvilleHousing.CityADdress', 'PropCityAddress', 'COLUMN';


------------------------------------------------------------------------------------
-- There are  irregularities in the Sales 
select distinct(SoldAsVacant)
from dbo.NashvilleHousing

select distinct(SoldAsVacant), count(SoldAsVacant) as countofSold
from dbo.NashvilleHousing
group by SoldAsVacant
Order by 2

Select SoldAsVacant,
 case
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end
from dbo.NashvilleHousing

Update dbo.NashvilleHousing
Set SoldAsVacant = case
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end


----------------------------------------------------------
-- Remove Duplicates
WITH RowNUMcte AS (
    SELECT *,
        ROW_NUMBER() OVER (
		PARTITION BY ParcelID, 
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY UniqueID) AS row_num
    FROM dbo.NashvilleHousing
)
--Select *
--from RowNUMcte
--where row_num > 1
--order by ParcelID
DELETE FROM RowNUMcte WHERE row_num > 1;


---finally, I want to drop unused tables
alter table dbo.NashvilleHousing
Drop Column SaleDate, PropertyAddress, TaxDistrict, OwnerAddress





