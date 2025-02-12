SELECT * 
FROM PortfolioProject..NashvilleHousing

-------------------------------------------------------------------------------------------------------------------

--Dátum szabványosítása

SELECT  SaleDateConverted,
		SaleDate,
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing -- Nem mûködik.
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing -- Másik megoldás.
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate);


-------------------------------------------------------------------------------------------------------------------


--Hiányzó ingatlan címek kitöltése.


SELECT *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID


SELECT	a.ParcelID, 
		a.PropertyAddress, 
		b.ParcelID,
		b.PropertyAddress,
		ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


-------------------------------------------------------------------------------------------------------------------


-- Address felosztása külön oszlopokra (Address, City, State).

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1 , LEN(PropertyAddress)) as Address
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing 
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress =SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) 

ALTER TABLE NashvilleHousing 
ADD PropertySplitCityAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCityAddress = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1 , LEN(PropertyAddress))

SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3 ),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2 ),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1 )
FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing 
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress =PARSENAME(REPLACE(OwnerAddress, ',', '.'),3 )

ALTER TABLE NashvilleHousing 
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2 )

ALTER TABLE NashvilleHousing 
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1 )


-------------------------------------------------------------------------------------------------------------------


-- A Y és a N Yes, és No-ra változtatása a "Sold in Vacant" mezõbe.

SELECT	Distinct(SoldAsVacant),
		Count(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT	SoldAsVacant,
		CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
			 WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM PortfolioProject..NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant =
		CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END


-------------------------------------------------------------------------------------------------------------------


--Duplikációk eltávolítása

WITH RowNumCTE AS(
SELECT  *,
		ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY 
						UniqueID
						) row_num
FROM PortfolioProject..NashvilleHousing
)
SELECT *  -- DELETE statement volt itt, nem írtam neki külön queryt.
FROM RowNumCTE
WHERE row_num >1
ORDER BY PropertyAddress


-------------------------------------------------------------------------------------------------------------------


--Nem használt oszlopok törlése (RAW datából ez nem praktikus).

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress











