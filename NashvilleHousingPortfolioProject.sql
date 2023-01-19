--Cleaning Data using SQL queries


Select *
From PortfolioProject..NashvilleHousing

--Standardize Date Format using Convert()

Select SaleDateConverted, Convert(Date,SaleDate)
From PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
Set SaleDate = Convert(Date,SaleDate)

	--Other option to standardize date format
	Alter Table PortfolioProject..NashvilleHousing
	Add SaleDateConverted Date;
	
	Update PortfolioProject..NashvilleHousing
Set SaleDateConverted = Convert(Date,SaleDate)


--Populate Property Address Data to help replace null values

Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

--We can use ParcelID to populate null PropertyAddress by joining the data on itself.
-- and a.[UniqueID] <> b.[UniqueID] makes it so the properties do not repeat 
--ISNULL lets you check what is null and if it is, what do we want to populate.
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

--Updated table

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null



-- Seperating out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

--We can see that the PropertyAddress only has one comma

Select
SUBSTRING(PropertyAddress, 1, Charindex(',', PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing

--We can change quiery to take out comma

Select
SUBSTRING(PropertyAddress, 1, Charindex(',', PropertyAddress) -1) as Address
from PortfolioProject..NashvilleHousing


Select
SUBSTRING(PropertyAddress, 1, Charindex(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, Charindex(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
from PortfolioProject..NashvilleHousing

--Add Columns for Split Address and City

Alter Table PortfolioProject..NashvilleHousing
	Add PropertySplitAddress NVARCHAR(255);
	
	Update PortfolioProject..NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, Charindex(',', PropertyAddress) -1)


Alter Table PortfolioProject..NashvilleHousing
	Add PropertySplitCity NVARCHAR(255);
	
	Update PortfolioProject..NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, Charindex(',', PropertyAddress) +1, LEN(PropertyAddress))




--Seperating out OwnerAddress by (Address, City, State) using Parsename(). PARSENAME looks for periods so we need to specify what we are looking for by changing the commas to periods REPLACE()
Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject..NashvilleHousing

--Now add columns and values for Split OwnerAddress
Alter Table PortfolioProject..NashvilleHousing
	Add OwnerSplitAddress NVARCHAR(255);
	
Update PortfolioProject..NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Alter Table PortfolioProject..NashvilleHousing
	Add OwnerSplitCity NVARCHAR(255);
	
Update PortfolioProject..NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter Table PortfolioProject..NashvilleHousing
	Add OwnerSplitState NVARCHAR(255);
	
Update PortfolioProject..NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
From PortfolioProject..NashvilleHousing


--Change Y and N to Yes and No in "Sold as Vacant Field using CASE()

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant, 
CASE When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	END
From PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	END

--Removing duplicates

--finding duplicate values


With RowNumCTE As(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					Order By
					UniqueID
					) row_num

From PortfolioProject..NashvilleHousing
--Order by ParcelID
)
Select*
from RowNumCTE
Where row_num > 1
Order by PropertyAddress



--Delete unused columns (usually done when making views, do not delete actual data)

Select *
From PortfolioProject..NashvilleHousing

Alter table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter table PortfolioProject..NashvilleHousing
Drop Column SaleDate