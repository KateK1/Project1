
 -- Adresses
 -- Adress - Adress - full adress 
 -- ИНН - CN - customer number
 -- Договор - Contract - contract number
 -- Общ S м2 - Total_area total area per contract in sq. m.
 -- Субъект - Region - region name
 -- Населенный пункт - Town - town name
 
 -- Types_Colors
 -- Договор - Contract - contract number
 -- Дата Дог Contract_date - date of contract signing
 -- Общ S м2 Total_area total area per contract in sq. m.
 -- Total_area_grass, area_grass20, area_grass40, area_grass60 - 
 -- rubber10, rubber12, rubber15, rubber20, rubber25, rubber30, rubber40, rubber55
 -- spray8+2, spray10+2, spray10+3
 -- rubber_black, rubber_терракот, rubber_green, rubber_blue, rubber_gray, rubber_orange, rubber_yellow
 -- Плитка
 -- Рулонное
 -- EPDM10+5, EPDM15+5, EPDM20+5, EPDM25+5, EPDM30+10, EPDM40+5, EPDM40+10
 -- EPDM_зеленый, EPDM_терракот, EPDM_Красный, EPDM_Желтый, EPDM_синий, EPDM_белый, EPDM_оранжевый, EPDM_фиолетовый, EPDM_розовый, EPDM_серый, EPDM_коричневый, EPDM_бежевый, EPDM_голубой, EPDM_бирюзовый, EPDM_изумруд, EPDM_Лосось
 -- Основание
 
 
 
 
 --Total contracts, square by regions
Create view Contracts_by_region as
select TOP 10 Region, count(Contract) AS contracts, SUM (Total_area) AS sum_area, ROUND(AVG (Total_area),0) AS avg_area
from PortfolioProject1..Adresses
where Region is not NULL
group by Region
order by sum_area DESC

-- Total contracts, square by cities
Create view Towns as
select TOP 10 Town, count(Contract) AS Contract, SUM (Total_area) AS Total_area, ROUND(AVG (Total_area),0) AS Avarege_area
from PortfolioProject1..Adresses
where Town is not NULL
group by Town
order by Contract DESC

--Distinct regions and cities
Create view Regions_Towns as
select  count(distinct Region) as Region, count(distinct Town) as Town
from PortfolioProject1..Adresses
where Town is not NULL
and Region is not NULL


--Total square by flooring type
Create table pvt
(Год Year nvarchar(255),
Трава Grass numeric,
БРП Rubber numeric,
Напыление Spray_coating numeric,
ЭПДМ EPDM numeric,
Рулонное Roll_coating numeric)

Insert into pvt
select DATEPART(year, [Дата Дог#]) as Year,
SUM (Total_area_grass) AS Трава,
SUM (ISNULL(БРП10,0)) + SUM (ISNULL(БРП15,0))+ SUM(ISNULL(БРП20,0))+ SUM(ISNULL(БРП25,0))+SUM(ISNULL(БРП30,0))+SUM(ISNULL(БРП40,0))+ SUM(ISNULL([БРП 55],0)) AS аБРП,
SUM(ISNULL([БРП напыл 8+2],0)) + SUM(ISNULL([БРП напыл 10+2],0)) + SUM(ISNULL([БРП напыл 10+3],0)) AS СуммаНапыление,
SUM(ISNULL([ЭПДМ10+5],0)) + SUM(ISNULL([ЭПДМ 15+5],0)) + SUM(ISNULL([ЭПДМ 20+5],0)) + SUM(ISNULL([ЭПДМ 25+5],0)) + SUM(ISNULL([ЭПДМ 30+10],0)) + SUM(ISNULL([ЭПДМ 40+10],0)) + SUM(ISNULL([ЭПДМ 40+5],0)) AS ЭПДМ,
SUM (Рулонное) AS Рулонное
from PortfolioProject1..Types_Colors
where [Дата Дог#] is not NULL
group by DATEPART(year, [Дата Дог#])
Create view ПлощадиПоВидам as
SELECT Год, Категория, Количество
FROM   
   (SELECT Год, Трава, БРП, Напыление, ЭПДМ, Рулонное  
   FROM pvt) p
UNPIVOT  
	(Количество FOR Категория IN   
		(Трава, БРП, Напыление, ЭПДМ, Рулонное)  
)AS unpvt;
GO


--Seamless rubber floors color distribution
select'Черный' AS Цвет, SUM([БРП черный]) AS Площадь
from PortfolioProject1..Types_Colors
union 
select 'Терракот' AS Цвет, SUM([БРП терракот]) AS Площадь
from PortfolioProject1..Types_Colors
union 
select 'Зеленый' AS Цвет, SUM([БРП зеленый]) AS Площадь
from PortfolioProject1..Types_Colors
union 
select 'Синий' AS Цвет, SUM([БРП синий]) AS Площадь
from PortfolioProject1..Types_Colors
union 
select 'Серый' AS Цвет, SUM([БРП серый]) AS Площадь
from PortfolioProject1..Types_Colors
union 
select 'Оранжевый' AS Цвет, SUM([БРП оранжевый]) AS Площадь
from PortfolioProject1..Types_Colors
union 
select 'Желтый' AS Цвет, SUM([БРП желтый]) AS Площадь
from PortfolioProject1..Types_Colors
where [Дата Дог#] is not NULL
order by Площадь desc


--EPDM flooring cumulative total 
Create view ЭПДМ_НаростающийИтог as
select convert(date,[Дата Дог#]) as Дата,
SUM([ЭПДМ зеленый]) OVER (order by [Дата Дог#]) AS Зеленый,
SUM([ЭПДМ терракот]) OVER (order by [Дата Дог#]) AS Терракот, 
SUM([ЭПДМ красный]) OVER (order by [Дата Дог#]) AS Красный, 
SUM([ЭПДМ желтый]) OVER (order by [Дата Дог#]) AS Желтый,
SUM([ЭПДМ синий]) OVER (order by [Дата Дог#]) AS Синий,
SUM([ЭПДМ белый]) OVER (order by [Дата Дог#]) AS Белый,
SUM([ЭПДМ оранжевый]) OVER (order by [Дата Дог#]) AS Оранжевый,
SUM([ЭПДМ серый]) OVER (order by [Дата Дог#]) AS Серый,
SUM([ЭПДМ бежевый]) OVER (order by [Дата Дог#]) AS Бежевый,
SUM([ЭПДМ голубой]) OVER (order by [Дата Дог#]) AS Голубой
from PortfolioProject1..Types_Colors
where [Дата Дог#] is not NULL
group by [Дата Дог#], [ЭПДМ зеленый], [ЭПДМ терракот], [ЭПДМ красный], [ЭПДМ желтый], [ЭПДМ синий], [ЭПДМ белый], [ЭПДМ оранжевый], [ЭПДМ серый], [ЭПДМ бежевый], [ЭПДМ голубой]


--Main info
select
'Субъектов' as Название,
count (distinct Субъект) as Знач
from PortfolioProject1..Adresses
union
select
'Населеных пунктов' as Название,
count (distinct [Населенный пункт]) as Знач
from PortfolioProject1..Adresses
union
select
'Общая площадь' as Название,
sum (round ([Общ S м2],0)) as Знач
from PortfolioProject1..Types_Colors
union
select 
'ЦветаБРП' as Название,
'7' as Знач
from PortfolioProject1..Types_Colors
union
select
'Цвета ЭПДМ' as Название,
'16' as Знач
from PortfolioProject1..Types_Colors

