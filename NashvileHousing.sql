select * 
from NashvilleHousing

--standardize date format

select SaleDateConverted ,convert(date,SaleDate)
from NashvilleHousing

update NashvilleHousing
set SaleDate = convert(date,SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = CONVERT(date,SaleDate)

--populate property address data

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID 
	and  a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is not null

update a
set PropertyAddress =  ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID 
	and  a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

-- Breaking out address into individual columns

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from NashvilleHousing

Alter Table NashvilleHousing
Add PropSplitAddress nvarchar(255);

Alter Table NashvilleHousing
Add PropSplitCity nvarchar(255);

Update NashvilleHousing
set PropSplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

Update NashvilleHousing
Set PropSplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));

select
PARSENAME(REPLACE(OwnerAddress,',','.') ,3)
,PARSENAME(REPLACE(OwnerAddress,',','.') ,2)
,PARSENAME(REPLACE(OwnerAddress,',','.') ,1)
from NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.') ,3);

Update NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.') ,2);

Update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.') ,1);

Update NashvilleHousing
set OwnerName = 'Michael B. Jordan'
where [UniqueID ] = '29467'

-- Change Y and N to Yes and No in SoldAsVacant Column

select SoldAsVacant,
case 
	when SoldAsVacant = 'Y' Then  'Yes'
	when SoldAsVacant = 'N' Then 'No'
	else SoldAsVacant
	End
from NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = case 
	when SoldAsVacant = 'Y' Then  'Yes'
	when SoldAsVacant = 'N' Then 'No'
	else SoldAsVacant
	End;

select distinct SoldAsVacant, count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
Order by 2

--Remove Duplicate Values

With Row_NumCTE
as (
select * ,
	ROW_NUMBER() Over (
	Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	order by UniqueID
	) row_num			
from NashvilleHousing
--order by ParcelID
)
--to Check for duplicate rows
/*select * 
from Row_NumCTE
where row_num >1
order by PropertyAddress
*/
--to delete duplicate rows
delete 
from Row_NumCTE
where row_num >1

--Delete Unused Column

Select * from NashvilleHousing

Alter Table NashvilleHousing
drop column OwnerAddress

