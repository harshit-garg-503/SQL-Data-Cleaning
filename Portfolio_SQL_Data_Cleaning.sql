-- 1. The Data:

SELECT * FROM property_data
ORDER BY ParcelID;

-- 2. Standardize Date Format:

ALTER TABLE property_data ADD SaleDateConverted DATE;

UPDATE property_data
SET SaleDateConverted = STR_TO_DATE(SaleDate, '%M %e, %Y');

-- 3.1 Are there any duplicates in the data? Print their #Occurences of the duplicates if any:

WITH temp_data AS(
SELECT ParcelID, COUNT(*) AS '#Occurences' FROM property_data
GROUP BY ParcelID
HAVING COUNT(*)>1
ORDER BY ParcelID)

SELECT * FROM property_data 
WHERE ParcelID IN (SELECT ParcelID FROM temp_data)
;
-- 3.2 Reason For duplicated values: These properties had been sold more than once since these entries have different sale date.


-- 4. Extract Address, City from PropertyAddress 

ALTER TABLE property_data 
ADD Address VARCHAR(255), 
ADD City VARCHAR(255);

UPDATE property_data 
SET Address= SUBSTRING_INDEX(PropertyAddress,',',1),  City= SUBSTRING_INDEX(PropertyAddress,',', -1);

-- 5. Extract Owner's City, State and Address:

ALTER TABLE property_data
ADD OwnerCity VARCHAR(255),
ADD OwnerAddressExtracted VARCHAR(255),
ADD OwnerState VARCHAR(255);

UPDATE property_data
SET OwnerCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1),
OwnerAddressExtracted = SUBSTRING_INDEX(OwnerAddress, ',', 1),
OwnerState= SUBSTRING_INDEX(OwnerAddress, ',', -1);

-- 6. There is some incosistency in SoldAsVacantColumn, Resolve it:

SELECT DISTINCT(SoldAsVacant) FROM property_data;

UPDATE property_data
SET SoldAsVacant= (
CASE WHEN SoldAsVacant= "Y" THEN "Yes"
	 WHEN SoldAsVacant= "N" THEN "No"
ELSE SoldAsVacant
END 
);

-- 7. Rows which contain missing values:

SELECT * FROM property_data
WHERE OwnerName = "";

-- 8. Drop unwanted columns:

ALTER TABLE property_data
DROP  OwnerAddress, DROP PropertyAddress, DROP SaleDate, DROP TaxDistrict;

SELECT * FROM property_data







