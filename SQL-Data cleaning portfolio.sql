--Data Cleaning with SQL queries

SELECT *
FROM [Porfolio Project].dbo.Nashvillehousing

--Standardize Date Forat

SELECT SaleDateConvert
FROM [Porfolio Project].dbo.Nashvillehousing

UPDATE Nashvillehousing
SET SaleDate = CONVERT(DATE, SaleDate)

ALTER TABLE Nashvillehousing
Add SaleDateConvert Date;

UPDATE Nashvillehousing
SET SaleDateConvert =CONVERT(DATE, SaleDate)

--Populate Property Address

SELECT* 
FROM [Porfolio Project].dbo.Nashvillehousing

--WHERE PropertyAddress IS NULL

ORDER BY ParcelID

SELECT A.ParcelID,A.PropertyAddress,B.ParcelID,B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM Nashvillehousing A
JOIN Nashvillehousing B
	ON A.ParcelID=B.ParcelID
	AND A.[UniqueID ]<>B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress= ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM Nashvillehousing A
JOIN Nashvillehousing B
	ON A.ParcelID=B.ParcelID
	AND A.[UniqueID ]<>B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

--Breaking out Address into Individual Columns (Address, City, State)
SELECT Property_city
FROM [Porfolio Project].dbo.Nashvillehousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM [Porfolio Project].dbo.Nashvillehousing

ALTER TABLE Nashvillehousing
Add Property_Address Nvarchar(255);

UPDATE Nashvillehousing
SET Property_Address =SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE Nashvillehousing
Add Property_city Nvarchar(255);

UPDATE Nashvillehousing
SET Property_City =SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--method 2

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS Owner_address,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS OwnerCity,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS OwnerState
FROM Nashvillehousing

ALTER TABLE Nashvillehousing
Add Owner_Address Nvarchar(255);

UPDATE Nashvillehousing
SET Owner_Address =PARSENAME(REPLACE(OwnerAddress,',','.'),3) 

ALTER TABLE Nashvillehousing
Add OwnerCity Nvarchar(255);

UPDATE Nashvillehousing
SET OwnerCity =PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE Nashvillehousing
Add OwnerState Nvarchar(255);

UPDATE Nashvillehousing
SET OwnerState =PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--Change Y and N to YES an NO

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)  
FROM Nashvillehousing
GROUP BY SoldAsVacant

Select SoldAsVacant,
	CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
		 WHEN SoldAsVacant ='N' THEN 'No'
		 Else SoldAsVacant
		 End
FROM Nashvillehousing

UPDATE Nashvillehousing
SET SoldAsVacant=CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
	 WHEN SoldAsVacant ='N' THEN 'No'
	 Else SoldAsVacant
	 End

--Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num
FROM Nashvillehousing
--ORDER BY ParcelID
)

SELECT *
FROM RowNumCTE
WHERE row_num >1
ORDER BY PropertyAddress

DELETE
From RowNumCTE
WHERE row_num >1

--Delete Unused Columns

ALTER TABLE Nashvillehousing
DROP COLUMN Owneraddress, TaxDistrict, PropertyAddress,SaleDate

SELECT *
FROM Nashvillehousing
order by ParcelID