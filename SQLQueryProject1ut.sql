
 -- Addresses table
 -- Adress - full adress 
 -- CN - customer number
 -- Contract - contract number
 -- Total_area total area per contract in sq. m.
 -- Region - region name
 -- Town - town name
 
 -- Types_Colors table
 -- Contract - contract number
 -- Contract_date - date of contract signing
 -- Total_area - the total area per contract in sq. m.
 -- Total_area_grass, area_grass20, area_grass40, area_grass60 - the total area of synthetic grass of each type per contract in sq. m.
 -- rubber10, rubber12, rubber15, rubber20, rubber25, rubber30, rubber40, rubber55 - the total area of rubber coating of each type per contract in sq. m.
 -- spray8+2, spray10+2, spray10+3 - the total area of a spray coat of each type per contract in sq. m.
 -- rubber_black, rubber_terracota, rubber_green, rubber_blue, rubber_gray, rubber_orange, rubber_yellow - the total area of rubber coating of each color per contract in sq. m.
 -- rubber_tile - the total area of rubber tile coating per contract in sq. m.
 -- roll_coating - the total area of roll_coating per contract in sq. m.
 -- EPDM10+5, EPDM15+5, EPDM20+5, EPDM25+5, EPDM30+10, EPDM40+5, EPDM40+10 - the total area of EPDM coating of each type per contract in sq. m.
 -- EPDM_green, EPDM_terracota, EPDM_redй, EPDM_yellow, EPDM_blue, EPDM_white, EPDM_orange, EPDM_grey, EPDM_beige, EPDM_lightblue - the total area of EPDM coating of each color per contract in sq. m.
 
 
 
 
 -- Total contracts, coating total area per region
Create view Contracts_by_region as
select TOP 10 Region, count(Contract) AS contracts, SUM (Total_area) AS sum_area, ROUND(AVG (Total_area),0) AS avg_area
from PortfolioProject1..Addresses
where Region is not NULL
group by Region
order by sum_area DESC

-- Total contracts, coating total area per town
Create view Towns as
select TOP 10 Town, count(Contract) AS Contract, SUM (Total_area) AS Total_area, ROUND(AVG (Total_area),0) AS Avarege_area
from PortfolioProject1..Addresses
where Town is not NULL
group by Town
order by Contract DESC

-- How many distinct regions and towns where the company works
Create view Regions_Towns as
select  count(distinct Region) as Region, count(distinct Town) as Town
from PortfolioProject1..Addresses
where Town is not NULL
and Region is not NULL


-- Total area by flooring type
Create table pvt
(Год Year nvarchar(255),
Трава total_grass_area numeric,
БРП total_rubber_area numeric,
Напыление total_spray_area numeric,
ЭПДМ total_EPDM_area numeric,
Рулонное total_roll_coating numeric)

Insert into pvt
select DATEPART(year, [Дата Дог#]) as year,
SUM (Total_area_grass) AS total_grass_area,
SUM (ISNULL(rubber10,0)) + SUM (ISNULL(rubber15,0)) + SUM(ISNULL(rubber20,0)) + SUM(ISNULL(rubber25,0)) + SUM(ISNULL(rubber30,0)) + SUM(ISNULL(rubber40,0)) +
SUM(ISNULL(rubber55,0)) AS total_rubber_area,
SUM(ISNULL(spray8+2,0)) + SUM(ISNULL(spray10+2,0)) + SUM(ISNULL(spray10+3,0)) AS total_spray_area,
SUM(ISNULL(EPDM10+5,0)) + SUM(ISNULL(EPDM15+5,0)) + SUM(ISNULL(EPDM20+5,0)) + SUM(ISNULL(EPDM25+5,0)) + SUM(ISNULL(EPDM30+10,0)) +
SUM(ISNULL(EPDM40+10,0)) + SUM(ISNULL(EPDM40+5,0)) AS total_EPDM_area,
SUM (roll_coating) AS total_roll_coating
from PortfolioProject1..Types_Colors
where Contract_date is not NULL
group by DATEPART(year, Contract_date)
Create view type_area as
SELECT year, type, total_area
FROM   
   (SELECT year, total_grass_area, total_rubber_area, total_spray_area, total_EPDM_area, total_roll_coating 
   FROM pvt) p
UNPIVOT  
	(total_area FOR type IN   
		(total_grass_area, total_rubber_area, total_spray_area, total_EPDM_area, total_roll_coating)  
)AS unpvt;
GO


-- Seamless rubber floors color distribution
select 'Black' AS Color, SUM(rubber_black) AS total_area
from PortfolioProject1..Types_Colors
union 
select 'Terracota' AS Color, SUM(rubber_terracota) AS total_area
from PortfolioProject1..Types_Colors
union 
select 'Green' AS Color, SUM(rubber_green]) AS total_area
from PortfolioProject1..Types_Colors
union 
select 'Blue AS Color, SUM(rubber_blue]) AS total_area
from PortfolioProject1..Types_Colors
union 
select 'Gray' AS Color, SUM(rubber_gray]) AS total_area
from PortfolioProject1..Types_Colors
union 
select 'Orange' AS Color, SUM(rubber_orange]) AS total_area
from PortfolioProject1..Types_Colors
union 
select 'Yellow' AS Color, SUM(rubber_yellow]) AS total_area
from PortfolioProject1..Types_Colors
where Contract_date is not NULL
order by total_area desc


-- EPDM flooring cumulative total 
Create view EPDM_cumulative_total as
select convert(date, Contract_date) as Date,
SUM(EPDM_green) OVER (order by Contract_date) AS Green,
SUM(EPDM_terracota) OVER (order by Contract_date) AS Terracota, 
SUM(EPDM_red) OVER (order by Contract_date) AS Red, 
SUM(EPDM_yellow) OVER (order by Contract_date AS Yellow,
SUM(EPDM_blue) OVER (order by Contract_date) AS Blue,
SUM(EPDM_white) OVER (order by Contract_date) AS White,
SUM(EPDM_orange) OVER (order by Contract_date) AS Orange,
SUM(EPDM_gray) OVER (order by Contract_date) AS Gray,
SUM(EPDM_beige) OVER (order by Contract_date) AS Beige,
SUM(EPDM_lightblue) OVER (order by Contract_date) AS Light_blue
from PortfolioProject1..Types_Colors
where Contract_date is not NULL
group by Contract_date, EPDM_green, EPDM_terracota, EPDM_red, EPDM_yellow, [EPDM_blue, EPDM_white, [EPDM_orange,
[EPDM_gray, EPDM_beige, EPDM_lightblue


-- Main info
select
'Regions' as Name,
count (distinct Region) as Value
from PortfolioProject1..Addresses
union
select
'Towns' as Name,
count (distinct Towns) as Value
from PortfolioProject1..Addresses
union
select
'Tota_area' as Name,
sum (round (Total_are, 0)) as Value
from PortfolioProject1..Types_Colors
union
select 
'rubber colors' as Name,
'7' as Value
from PortfolioProject1..Types_Colors
union
select
'EPDM colors' as Name,
'16' as Value
from PortfolioProject1..Types_Colors
