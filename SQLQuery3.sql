/*
cleaning data in SQL
*/


select *
from PortfolioProject.dbo.[Nashville Housing Data]


--standardised Date format
 
select SaleDate
from PortfolioProject.dbo.[Nashville Housing Data]

/*
Convert SaleDate to the right format of standardize format
*/

select SaleDateconverted, CONVERT(date,saledate)
from PortfolioProject.dbo.[Nashville Housing Data]


alter table [Nashville Housing Data]
add saledateconverted date;

update [Nashville Housing Data]
set saledateconverted = CONVERT(date,saledate)


select *
from [Nashville Housing Data]


-- populate the property address data

-- shows only the property address from the table
select PropertyAddress
from PortfolioProject.dbo.[Nashville Housing Data]
--where PropertyAddress is null


--shows the places the property address is null
select PropertyAddress
from PortfolioProject.dbo.[Nashville Housing Data]
where PropertyAddress is null


-- here, we are trying to find out dupliciated parcelID from the same address
select *
from PortfolioProject.dbo.[Nashville Housing Data]
--where PropertyAddress is null
order by ParcelID

select *
from PortfolioProject.dbo.[Nashville Housing Data] a
join PortfolioProject.dbo.[Nashville Housing Data] b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress,b.PropertyAddress)
from PortfolioProject.dbo.[Nashville Housing Data] a
join PortfolioProject.dbo.[Nashville Housing Data] b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is null

-- now updating the table to reflect the null property address

update a
set PropertyAddress = ISNULL(a.propertyaddress,b.PropertyAddress)
from PortfolioProject.dbo.[Nashville Housing Data] a
join PortfolioProject.dbo.[Nashville Housing Data] b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is null


--checking the new table
select *
from [Nashville Housing Data]



-- breaking out addresss into Individual colums like (address, City, state)
select PropertyAddress
from PortfolioProject.dbo.[Nashville Housing Data]
--where PropertyAddress is null


select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress))  as Address

from PortfolioProject.dbo.[Nashville Housing Data]


alter table [Nashville Housing Data]
add PropertySplitAddress Nvarchar(255);

update [Nashville Housing Data]
set PropertySplitAddress =SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

alter table [Nashville Housing Data]
add PropertySplitCity Nvarchar(255);

update [Nashville Housing Data]
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress))


select *
from PortfolioProject.dbo.[Nashville Housing Data]


select OwnerAddress
from PortfolioProject.dbo.[Nashville Housing Data]



select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 2)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
from PortfolioProject.dbo.[Nashville Housing Data]


alter table [Nashville Housing Data]
add OwnerSplitAddress Nvarchar(255);

update [Nashville Housing Data]
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

alter table [Nashville Housing Data]
add OwnerSplitCity Nvarchar(255);

update [Nashville Housing Data]
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

alter table [Nashville Housing Data]
add OwnerSplitState Nvarchar(255);

update [Nashville Housing Data]
set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)


select * 
from PortfolioProject.dbo.[Nashville Housing Data]



--a little work on the soldasVacant column


select distinct(SoldAsVacant)
from PortfolioProject.dbo.[Nashville Housing Data]

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject.dbo.[Nashville Housing Data]
group by SoldAsVacant
order by 2



select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
 		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
from PortfolioProject.dbo.[Nashville Housing Data]


update PortfolioProject.dbo.[Nashville Housing Data]
set SoldAsVacant =  case when SoldAsVacant = 'Y' then 'Yes'
 		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end



--Remove duplicate
With RowNumCTE AS(
select *,
	ROW_NUMBER() Over (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) row_num

from PortfolioProject.dbo.[Nashville Housing Data]
)
select *
from RowNumCTE
where row_num > 1
--order by PropertyAddress



select * 
from PortfolioProject.dbo.[Nashville Housing Data]

-- Delete unused columns

alter table PortfolioProject.dbo.[Nashville Housing Data]
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

alter table PortfolioProject.dbo.[Nashville Housing Data]
drop column SaleDate

