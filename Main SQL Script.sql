--  This project aims to clean the 'Nashville Housing dataset' for data analysis.

select *
from [ Nashville Housing Data for Data Cleaning]

----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Standardize date formate.

ALTER TABLE  [ Nashville Housing Data for Data Cleaning]
Alter column SaleDate Date;

/* alternative method

select saledate,convert(date,saledate)
from [ Nashville Housing Data for Data Cleaning]

update [ Nashville Housing Data for Data Cleaning]
set saledate=convert(date,saledate)

*/

----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Populate property address.

/*
select propertyAddress,[UniqueID ]
from [ Nashville Housing Data for Data Cleaning]
where PropertyAddress is null
*/

-- after carrfully looking into the propertyadress column,we found that there are 29 rows in which adress in null.

/*
select parcelid,propertyAddress 
from [ Nashville Housing Data for Data Cleaning]
order by ParcelID
*/

-- records having same parcelid have same propertyadress.

select a.[UniqueID ],a.PropertyAddress,b.[UniqueID ],b.PropertyAddress,ISNULL(a.propertyAddress,b.PropertyAddress)
from [ Nashville Housing Data for Data Cleaning] a
join [ Nashville Housing Data for Data Cleaning] b
on a.ParcelID=b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set propertyaddress = ISNULL(a.propertyAddress,b.PropertyAddress)
from [ Nashville Housing Data for Data Cleaning] a
join [ Nashville Housing Data for Data Cleaning] b
on a.ParcelID=b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

---------------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out owneraddress into individual columns (Address,city,state)
-- propertyaddress is same as owneraddress and owneraddress contains null values(30462).
 
-- spliting propertyaddress

select propertyaddress,SUBSTRING(propertyaddress,1,CHARINDEX(',',propertyaddress)-1) as prop_address,
SUBSTRING(propertyaddress, CHARINDEX(',',PropertyAddress)+1,len(propertyaddress)) as prop_city
from [ Nashville Housing Data for Data Cleaning]
 
-- Now add created split columns into main table.

 alter table [ Nashville Housing Data for Data Cleaning]
 add propaddress nvarchar(255);

 update [ Nashville Housing Data for Data Cleaning]
 set propaddress = SUBSTRING(propertyaddress,1,CHARINDEX(',',propertyaddress)-1)

 alter table [ Nashville Housing Data for Data Cleaning]
 add propcity nvarchar(255);

 update [ Nashville Housing Data for Data Cleaning]
 set propcity = SUBSTRING(propertyaddress, CHARINDEX(',',PropertyAddress)+1,len(propertyaddress))

-- splitting owneraddress by parsename()

 select   
 parsename(replace(owneraddress,',','.'),3) as owner_address,
 parsename(replace(owneraddress,',','.'),2) as owner_city,
 parsename(replace(owneraddress,',','.'),1) as owner_state
 from [ Nashville Housing Data for Data Cleaning]

-- Now add splited columns to original table.

 alter table [ Nashville Housing Data for Data Cleaning]
 add owner_address nvarchar(255)

 update [ Nashville Housing Data for Data Cleaning]
 set owner_address = parsename(replace(owneraddress,',','.'),3)

 alter table [ Nashville Housing Data for Data Cleaning]
 add owner_city nvarchar(255)

 update [ Nashville Housing Data for Data Cleaning]
 set owner_city = parsename(replace(owneraddress,',','.'),2)

 alter table [ Nashville Housing Data for Data Cleaning]
 add owner_state nvarchar(255)

 update [ Nashville Housing Data for Data Cleaning]
 set owner_state = parsename(replace(owneraddress,',','.'),1)

 --------------------------------------------------------------------------------------------------------------------------------------------------------

 -- Change Y,N to Yes and No in soldasvacant column.

 select  distinct(SoldAsVacant)
 from [ Nashville Housing Data for Data Cleaning]
 
 select soldasvacant,
 case
	when soldasvacant='N' then 'No' 
	when soldasvacant='Y' then 'Yes'
	when soldasvacant='No' then 'No' 
	when soldasvacant='Yes' then 'Yes'
end as updatedsoldasvacant
from [ Nashville Housing Data for Data Cleaning];

-- now update in original table.

update [ Nashville Housing Data for Data Cleaning]
set SoldAsVacant =
 case
	when soldasvacant='N' then 'No' 
	when soldasvacant='Y' then 'Yes'
	when soldasvacant='No' then 'No' 
	when soldasvacant='Yes' then 'Yes'
end 
from [ Nashville Housing Data for Data Cleaning];

-------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates.

--First we need to identify the duplicates.

WITH ROWNUMCTE AS(
SELECT *,
	ROW_NUMBER() over (
	partition by parcelid,
	propertyaddress,
	saleprice,
	saledate,
	legalreference
	order by  uniqueid) row_num
 from [ Nashville Housing Data for Data Cleaning])

 -- FOR DELETING THE DUPLICATED ROWS

/* DELETE
 FROM ROWNUMCTE
 WHERE row_num >1 */
 
-- IT IS JUST TO VERIFY WHETHER ALL DUPLICATE ROWS ARE DELETED OR NOT.

 SELECT *
 FROM ROWNUMCTE
 WHERE row_num >1 
 ORDER BY PropertyAddress

 --------------------------------------------------------------------------------------------------------------------------------------------------------

-- Get rid off unused cloumns (owneraddress,taxdistrict)

ALTER TABLE [ Nashville Housing Data for Data Cleaning]
DROP COLUMN owneraddress,taxdistrict

/* In my main script file I have dropped the 'propertyaddress' column while performing 'Get rid off unused columns' task because I had already formated this column
correctly in above steps but realised that deleting it is not a good option because it will create an error when I will run this script in future due to unavailability
of 'propertyaddress' column.Hence I am editing last task here so that other people don't have a problem of re-runability. */
 
